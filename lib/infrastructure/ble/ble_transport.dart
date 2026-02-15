import 'dart:async';
import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';

import '../../core/domain/entities/trainer_device.dart';
import 'ble_connection.dart';
import 'ble_constants.dart';
import 'ble_permission_handler.dart';

final _log = Logger('BleTransport');

/// High-level state of the BLE transport layer.
enum BleTransportState { idle, scanning, connecting, connected, reconnecting }

/// Scanned device result.
class BleScannedDevice {
  const BleScannedDevice({
    required this.device,
    required this.rssi,
    required this.serviceUuids,
  });

  final TrainerDevice device;
  final int rssi;
  final List<Guid> serviceUuids;
}

/// BLE transport layer — scanning, connection management, and auto-reconnect
/// with exponential backoff.
///
/// Manages the lifecycle of a single active connection at a time.
class BleTransport {
  BleTransport({
    BlePermissionHandler? permissionHandler,
  }) : _permissionHandler = permissionHandler ?? BlePermissionHandler();

  final BlePermissionHandler _permissionHandler;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  BleTransportState _state = BleTransportState.idle;
  final _stateController = StreamController<BleTransportState>.broadcast();

  /// Stream of transport state changes.
  Stream<BleTransportState> get stateStream => _stateController.stream;

  /// Current transport state.
  BleTransportState get state => _state;

  void _setState(BleTransportState newState) {
    _state = newState;
    _stateController.add(newState);
    _log.fine('State → $newState');
  }

  // ---------------------------------------------------------------------------
  // Scanning
  // ---------------------------------------------------------------------------

  final _scanResultsController =
      StreamController<List<BleScannedDevice>>.broadcast();
  StreamSubscription? _scanSubscription;

  /// Stream of scan results, updated as devices are discovered.
  Stream<List<BleScannedDevice>> get scanResults =>
      _scanResultsController.stream;

  /// Starts scanning for BLE cycling devices.
  ///
  /// Checks permissions first.  Emits discovered devices on [scanResults].
  /// Scanning stops automatically after [timeout] or when [stopScan] is called.
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_state == BleTransportState.scanning) {
      _log.warning('Already scanning — ignoring startScan()');
      return;
    }

    final allowed = await _permissionHandler.requestPermissions();
    if (!allowed) {
      _log.severe('BLE permissions not granted — cannot scan');
      throw StateError('BLE permissions not granted');
    }

    _setState(BleTransportState.scanning);
    _log.info('Starting BLE scan (timeout=${timeout.inSeconds}s)…');

    final discovered = <String, BleScannedDevice>{};

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final serviceUuids = r.advertisementData.serviceUuids;

        // Only include devices advertising a known cycling service.
        final hasKnownService = serviceUuids.any(
          (uuid) => BleConstants.knownServiceUuids.contains(uuid),
        );
        if (!hasKnownService) continue;

        final protocol = _detectProtocol(serviceUuids);
        final isControllable =
            serviceUuids.contains(BleConstants.ftmsService);
        final supportedModes = isControllable
            ? [ControlMode.erg, ControlMode.simulation, ControlMode.resistance]
            : <ControlMode>[];

        final scanned = BleScannedDevice(
          device: TrainerDevice(
            id: r.device.remoteId.str,
            name: r.device.platformName.isNotEmpty
                ? r.device.platformName
                : 'Unknown Device',
            protocol: protocol,
            isControllable: isControllable,
            supportedModes: supportedModes,
          ),
          rssi: r.rssi,
          serviceUuids: serviceUuids,
        );

        discovered[scanned.device.id] = scanned;
        _log.fine('Discovered ${scanned.device.name} '
            '(${scanned.device.id}, RSSI=${scanned.rssi})');
      }

      _scanResultsController.add(discovered.values.toList());
    });

    await FlutterBluePlus.startScan(
      timeout: timeout,
      withServices: BleConstants.knownServiceUuids,
    );

    // Scan finished naturally.
    await _scanSubscription?.cancel();
    _scanSubscription = null;

    if (_state == BleTransportState.scanning) {
      _setState(BleTransportState.idle);
    }
    _log.info('Scan complete — ${discovered.length} device(s) found');
  }

  /// Stops an in-progress scan.
  Future<void> stopScan() async {
    if (_state != BleTransportState.scanning) return;
    _log.info('Stopping BLE scan');
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    _setState(BleTransportState.idle);
  }

  // ---------------------------------------------------------------------------
  // Connection management
  // ---------------------------------------------------------------------------

  BleConnection? _activeConnection;
  String? _activeDeviceId;
  StreamSubscription? _connectionStateSub;

  /// The currently active connection, or `null`.
  BleConnection? get activeConnection => _activeConnection;

  /// Connects to the device with [deviceId] and returns a [BleConnection].
  ///
  /// If already connected to a different device, disconnects first.
  Future<BleConnection> connectToDevice(String deviceId) async {
    if (_activeConnection != null && _activeDeviceId != deviceId) {
      _log.info('Disconnecting from $_activeDeviceId before new connection');
      await disconnectDevice();
    }

    _setState(BleTransportState.connecting);
    _activeDeviceId = deviceId;
    _reconnectAttempt = 0;

    final device = BluetoothDevice.fromId(deviceId);
    final connection = BleConnection(device);

    _connectionStateSub = connection.stateStream.listen((connState) {
      if (connState == BleConnectionState.disconnected &&
          _activeDeviceId == deviceId &&
          autoReconnect) {
        _log.info('Connection lost — starting auto-reconnect');
        _attemptReconnect(deviceId);
      }
    });

    await connection.connect();

    _activeConnection = connection;
    _setState(BleTransportState.connected);
    return connection;
  }

  /// Disconnects the current device.
  Future<void> disconnectDevice() async {
    autoReconnect = false;
    await _connectionStateSub?.cancel();
    _connectionStateSub = null;

    if (_activeConnection != null) {
      await _activeConnection!.disconnect();
      _activeConnection!.dispose();
      _activeConnection = null;
    }

    _activeDeviceId = null;
    _reconnectAttempt = 0;
    _setState(BleTransportState.idle);
  }

  // ---------------------------------------------------------------------------
  // Auto-reconnect with exponential backoff
  // ---------------------------------------------------------------------------

  /// Whether to auto-reconnect on connection loss.
  bool autoReconnect = true;

  /// Maximum number of reconnection attempts before giving up.
  static const int maxReconnectAttempts = 5;

  /// Initial backoff delay.
  static const Duration _initialBackoff = Duration(seconds: 1);

  /// Maximum backoff delay.
  static const Duration _maxBackoff = Duration(seconds: 30);

  int _reconnectAttempt = 0;

  Future<void> _attemptReconnect(String deviceId) async {
    if (!autoReconnect) return;
    if (_reconnectAttempt >= maxReconnectAttempts) {
      _log.warning('Max reconnect attempts ($maxReconnectAttempts) reached '
          '— giving up');
      _setState(BleTransportState.idle);
      _activeDeviceId = null;
      return;
    }

    _setState(BleTransportState.reconnecting);
    _reconnectAttempt++;

    final backoff = _calculateBackoff(_reconnectAttempt);
    _log.info('Reconnect attempt $_reconnectAttempt/$maxReconnectAttempts '
        '— waiting ${backoff.inMilliseconds}ms');

    await Future<void>.delayed(backoff);

    if (!autoReconnect || _activeDeviceId != deviceId) return;

    try {
      final device = BluetoothDevice.fromId(deviceId);
      final connection = BleConnection(device);
      await connection.connect();

      _activeConnection = connection;
      _reconnectAttempt = 0;
      _setState(BleTransportState.connected);
      _log.info('Reconnected to $deviceId');

      // Re-subscribe to connection state for future losses.
      await _connectionStateSub?.cancel();
      _connectionStateSub = connection.stateStream.listen((connState) {
        if (connState == BleConnectionState.disconnected &&
            _activeDeviceId == deviceId &&
            autoReconnect) {
          _attemptReconnect(deviceId);
        }
      });
    } catch (e) {
      _log.warning('Reconnect attempt $_reconnectAttempt failed: $e');
      _attemptReconnect(deviceId);
    }
  }

  Duration _calculateBackoff(int attempt) {
    // Exponential backoff: 1s, 2s, 4s, 8s, 16s — capped at 30s.
    final ms = _initialBackoff.inMilliseconds * pow(2, attempt - 1);
    final capped = min(ms.toInt(), _maxBackoff.inMilliseconds);
    return Duration(milliseconds: capped);
  }

  // ---------------------------------------------------------------------------
  // Protocol detection
  // ---------------------------------------------------------------------------

  static DeviceProtocol _detectProtocol(List<Guid> serviceUuids) {
    if (serviceUuids.contains(BleConstants.ftmsService)) {
      return DeviceProtocol.bleFtms;
    }
    if (serviceUuids.contains(BleConstants.cpsService)) {
      return DeviceProtocol.blePower;
    }
    if (serviceUuids.contains(BleConstants.cscService)) {
      return DeviceProtocol.bleCsc;
    }
    return DeviceProtocol.blePower; // fallback
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Releases all resources.
  Future<void> dispose() async {
    autoReconnect = false;
    await stopScan();
    await disconnectDevice();
    await _stateController.close();
    await _scanResultsController.close();
  }
}
