import 'dart:async';

import 'package:logging/logging.dart';

import '../../events/app_event.dart';
import '../../events/event_bus.dart';
import '../../../infrastructure/ble/ble_transport.dart';

final _log = Logger('ConnectionMonitor');

/// Monitors trainer connectivity and attempts auto-reconnect when the
/// connection drops during an active recording.
///
/// Relies on the existing exponential-backoff reconnect logic in
/// [BleTransport]. This service adds the coordination layer: listening for
/// disconnect events, checking whether a recording is active, and triggering
/// the reconnect.
class ConnectionMonitor {
  ConnectionMonitor({
    required EventBus eventBus,
    required BleTransport bleTransport,
    required List<String> Function() getSavedDeviceIds,
    required bool Function() isRecording,
  })  : _eventBus = eventBus,
        _bleTransport = bleTransport,
        _getSavedDeviceIds = getSavedDeviceIds,
        _isRecording = isRecording;

  final EventBus _eventBus;
  final BleTransport _bleTransport;
  final List<String> Function() _getSavedDeviceIds;
  final bool Function() _isRecording;

  StreamSubscription<TrainerEvent>? _sub;
  bool _reconnecting = false;

  /// Start listening for disconnect events.
  void start() {
    _sub = _eventBus.on<TrainerEvent>().listen(_onTrainerEvent);
    _log.info('ConnectionMonitor started');
  }

  void _onTrainerEvent(TrainerEvent event) {
    event.map(
      connected: (_) {
        _reconnecting = false;
        _log.info('Trainer connected — reconnect flag cleared');
      },
      disconnected: (e) => _handleDisconnect(e.deviceId),
      controlAcquired: (_) {},
      modeChanged: (_) {},
    );
  }

  Future<void> _handleDisconnect(String deviceId) async {
    if (!_isRecording()) {
      _log.fine('Disconnected but not recording — skipping reconnect');
      return;
    }

    if (_reconnecting) {
      _log.fine('Already attempting reconnect');
      return;
    }

    _reconnecting = true;
    _log.warning('Trainer $deviceId disconnected during recording — '
        'attempting reconnect');

    final savedIds = _getSavedDeviceIds();
    final targetId = savedIds.contains(deviceId) ? deviceId : null;
    if (targetId == null) {
      _log.warning('Device $deviceId not in saved list — cannot reconnect');
      _reconnecting = false;
      return;
    }

    try {
      await _bleTransport.connectToDevice(targetId);
      _log.info('Reconnected to $targetId');
    } catch (e) {
      _log.severe('Reconnect failed: $e');
      _reconnecting = false;
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
