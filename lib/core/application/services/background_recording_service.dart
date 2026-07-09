import 'dart:async';

import 'package:logging/logging.dart';

import '../../../infrastructure/foreground/foreground_service_controller.dart';
import 'recording_engine.dart';

final _log = Logger('BackgroundRecordingService');

/// Binds a foreground service (Android) to [RecordingEngine]'s lifecycle so
/// recording keeps running with the screen off or the app backgrounded:
/// starts when recording begins, stops when it ends, and keeps the
/// notification's elapsed time + current power current while it runs.
///
/// On platforms where [ForegroundServiceController] is a no-op (iOS, desktop)
/// this class still tracks [isServiceRunning] correctly — it just doesn't
/// do anything platform-visible.
class BackgroundRecordingService {
  BackgroundRecordingService({
    required RecordingEngine recordingEngine,
    required ForegroundServiceController controller,
    Duration notificationUpdateInterval = const Duration(seconds: 5),
  })  : _recordingEngine = recordingEngine,
        _controller = controller,
        _notificationUpdateInterval = notificationUpdateInterval {
    _sub = _recordingEngine.stateStream.listen(_onStateChanged);
  }

  final RecordingEngine _recordingEngine;
  final ForegroundServiceController _controller;
  final Duration _notificationUpdateInterval;

  StreamSubscription<RecordingState>? _sub;
  Timer? _notificationTimer;
  bool _serviceRunning = false;

  /// Whether the foreground service is currently started.
  bool get isServiceRunning => _serviceRunning;

  Future<void> _onStateChanged(RecordingState state) async {
    if (state == RecordingState.recording && !_serviceRunning) {
      await _start();
    } else if (state == RecordingState.idle && _serviceRunning) {
      await _stop();
    }
  }

  Future<void> _start() async {
    _serviceRunning = true;
    try {
      await _controller.start(
        title: 'OpenBike — recording',
        text: _notificationText(),
      );
    } catch (e) {
      _log.warning('Failed to start foreground service: $e');
    }
    _notificationTimer = Timer.periodic(
      _notificationUpdateInterval,
      (_) => _controller.update(text: _notificationText()),
    );
  }

  Future<void> _stop() async {
    _serviceRunning = false;
    _notificationTimer?.cancel();
    _notificationTimer = null;
    try {
      await _controller.stop();
    } catch (e) {
      _log.warning('Failed to stop foreground service: $e');
    }
  }

  String _notificationText() {
    final elapsed = _recordingEngine.currentRide?.activeDuration ?? Duration.zero;
    final power = _recordingEngine.latestReading?.power;
    final powerText = power != null ? '${power.value.round()} W' : '-- W';
    return '${_formatDuration(elapsed)} • $powerText';
  }

  static String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _notificationTimer?.cancel();
    if (_serviceRunning) {
      await _stop();
    }
  }
}
