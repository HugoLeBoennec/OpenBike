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
/// Holds **concurrent connections** keyed by device id, so a trainer, an HR
/// strap, and a power meter can all be connected at once, each with its own
/// independent auto-reconnect lifecycle. [connectToDevice] /
/// [activeConnection] / [disconnectDevice] remain as a single-connection
/// convenience API for callers (like [FtmsDevicePlugin]) that only manage
/// one device at a time — they operate on the most-recently-connected device
/// without disturbing other concurrent connections.
class BleTransport {
  BleTransport({
    BlePermissionHandler? permissionHandler,
    BleConnection Function(String deviceId)? connectionFactory,
    Duration Function(int attempt)? backoffCalculator,
  })  : _permissionHandler = permissionHandler ?? BlePermissionHandler(),
        _connectionFactory = connectionFactory ??
            ((deviceId) => BleConnection(BluetoothDevice.fromId(deviceId))),
        _backoffCalculator = backoffCalculator ?? _defaultBackoff;

  final BlePermissionHandler _permissionHandler;
  final BleConnection Function(String deviceId) _connectionFactory;
  final Duration Function(int attempt) _backoffCalculator;

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

  /// Bumped by every [startScan] so a scan that finishes after a newer one
  /// has started doesn't tear down the newer one's subscription.
  int _scanGeneration = 0;

  /// Stream of scan results, updated as devices are discovered.
  Stream<List<BleScannedDevice>> get scanResults =>
      _scanResultsController.stream;

  /// Whether Bluetooth is available on this device.
  ///
  /// Returns `false` if the adapter is unsupported, off, or permissions
  /// were denied. Callers can check this before calling [startScan].
  Future<bool> get isAvailable async {
    try {
      final availability = await _permissionHandler.requestAccess();
      return availability == BleAvailability.ready;
    } catch (e) {
      _log.warning('BLE availability check failed: $e');
      return false;
    }
  }

  /// Why the last [startScan] couldn't run, or `null` if it could. Lets the
  /// UI offer the right fix — e.g. an "Open Settings" action when access
  /// was denied.
  BleAvailability? lastScanProblem;

  /// User-facing message for the last failed scan attempt, or `null`.
  String? lastScanError;

  /// Opens this app's page in the system Settings, where a denied
  /// Bluetooth permission can be granted.
  Future<bool> openPermissionSettings() => _permissionHandler.openSettings();

  /// User-facing explanation of why BLE can't be used.
  static String describeProblem(BleAvailability availability) {
    switch (availability) {
      case BleAvailability.permissionDenied:
        return 'OpenBike isn\'t allowed to use Bluetooth. '
            'Allow it in Settings, then scan again.';
      case BleAvailability.bluetoothOff:
        return 'Bluetooth is turned off. Turn it on, then scan again.';
      case BleAvailability.unsupported:
        return 'This device doesn\'t support Bluetooth LE.';
      case BleAvailability.ready:
        return '';
    }
  }

  /// Scans for BLE cycling devices and completes when the scan ends — after
  /// [timeout], or earlier if [stopScan] is called.
  ///
  /// Checks permissions first (on first use this is what shows the OS
  /// Bluetooth prompt). Emits discovered devices on [scanResults] while the
  /// scan runs.
  ///
  /// If Bluetooth is unavailable or the scan fails, sets [lastScanError]
  /// (and [lastScanProblem] when the cause is known) and returns without
  /// throwing — the UI can display a user-friendly message.
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_state == BleTransportState.scanning) {
      _log.warning('Already scanning — ignoring startScan()');
      return;
    }

    // Report "scanning" while the permission check runs too: on first use
    // it waits on the OS prompt, and the Scan button has to stay disabled
    // meanwhile or a second tap starts a second scan.
    _setState(BleTransportState.scanning);
    final generation = ++_scanGeneration;

    final availability = await _permissionHandler.requestAccess();
    if (availability != BleAvailability.ready) {
      _log.severe('BLE unavailable ($availability) — cannot scan');
      lastScanProblem = availability;
      lastScanError = describeProblem(availability);
      _scanResultsController.add([]);
      if (_state == BleTransportState.scanning) {
        _setState(BleTransportState.idle);
      }
      return;
    }
    lastScanProblem = null;
    lastScanError = null;

    _log.info('Starting BLE scan (timeout=${timeout.inSeconds}s)…');

    final discovered = <String, BleScannedDevice>{};

    // onScanResults, not scanResults: the latter replays the previous
    // scan's list to every new listener, which would show devices that may
    // no longer be around.
    _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
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
    }, onError: (Object e) {
      _log.severe('BLE scan failed mid-scan: $e');
      lastScanError = 'Scan failed: $e';
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: timeout,
        withServices: BleConstants.knownServiceUuids,
      );
      // startScan returns as soon as the scan is *running*; results keep
      // arriving until the timeout fires or stopScan() is called. Tearing
      // the subscription down here instead (as this used to) dropped every
      // result — the first scan always came back empty.
      await FlutterBluePlus.isScanning.where((scanning) => !scanning).first;
    } catch (e) {
      _log.severe('BLE scan failed to start: $e');
      lastScanError = 'Scan failed: $e';
    } finally {
      if (generation == _scanGeneration) {
        await _scanSubscription?.cancel();
        _scanSubscription = null;
        if (_state == BleTransportState.scanning) {
          _setState(BleTransportState.idle);
        }
      }
    }
    _log.info('Scan complete — ${discovered.length} device(s) found');
  }

  /// Stops an in-progress scan.
  Future<void> stopScan() async {
    if (_scanSubscription == null) return;
    _log.info('Stopping BLE scan');
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    if (_state == BleTransportState.scanning) {
      _setState(BleTransportState.idle);
    }
  }

  // ---------------------------------------------------------------------------
  // Connection management — concurrent, keyed by device id
  // ---------------------------------------------------------------------------

  final Map<String, BleConnection> _connections = {};
  final Map<String, StreamSubscription> _connectionStateSubs = {};
  final Map<String, int> _reconnectAttempts = {};

  /// The device id of the most-recently connected device, for the
  /// single-connection convenience API ([activeConnection]/[disconnectDevice]).
  String? _lastConnectedDeviceId;

  /// All currently-tracked connections, keyed by device id. A connection
  /// remains in this map while a reconnect attempt is in progress.
  Map<String, BleConnection> get connections => Map.unmodifiable(_connections);

  /// The most-recently connected device's connection, or `null`.
  ///
  /// Convenience accessor for single-device callers — does not reflect
  /// other concurrently-connected devices; use [connections] or
  /// [connectionFor] for that.
  BleConnection? get activeConnection =>
      _lastConnectedDeviceId != null
          ? _connections[_lastConnectedDeviceId]
          : null;

  /// Returns the connection for [deviceId], or `null` if not connected.
  BleConnection? connectionFor(String deviceId) => _connections[deviceId];

  /// Whether [deviceId] is currently tracked as connected (or reconnecting).
  bool isConnected(String deviceId) => _connections.containsKey(deviceId);

  /// Whether to auto-reconnect on connection loss.
  bool autoReconnect = true;

  /// Connects to the device with [deviceId] and returns a [BleConnection].
  ///
  /// Does **not** disconnect other concurrently-connected devices — multiple
  /// roles (trainer, HR strap, power meter) can be connected simultaneously.
  /// Reconnecting to a device id that is already connected replaces that
  /// single connection.
  Future<BleConnection> connectToDevice(String deviceId) async {
    // Same gate [startScan] uses. Without it a connect issued before the
    // radio has powered up — notably the auto-reconnect that fires on the
    // first frame after launch — fails against a Bluetooth stack that
    // simply wasn't ready yet.
    final availability = await _permissionHandler.requestAccess();
    if (availability != BleAvailability.ready) {
      throw StateError(describeProblem(availability));
    }

    if (_connections.containsKey(deviceId)) {
      await disconnectDeviceId(deviceId);
    }

    _setState(BleTransportState.connecting);
    _lastConnectedDeviceId = deviceId;
    _reconnectAttempts[deviceId] = 0;

    final connection = await _openConnection(deviceId);
    _connections[deviceId] = connection;

    _setState(BleTransportState.connected);
    return connection;
  }

  Future<BleConnection> _openConnection(String deviceId) async {
    final connection = _connectionFactory(deviceId);

    _connectionStateSubs[deviceId]?.cancel();
    _connectionStateSubs[deviceId] = connection.stateStream.listen((connState) {
      if (connState == BleConnectionState.disconnected &&
          _connections.containsKey(deviceId) &&
          autoReconnect) {
        _log.info('Connection to $deviceId lost — starting auto-reconnect');
        _attemptReconnect(deviceId);
      }
    });

    await connection.connect();
    return connection;
  }

  /// Disconnects a single device by id, leaving other connections untouched.
  Future<void> disconnectDeviceId(String deviceId) async {
    await _connectionStateSubs.remove(deviceId)?.cancel();

    final connection = _connections.remove(deviceId);
    if (connection != null) {
      await connection.disconnect();
      connection.dispose();
    }
    _reconnectAttempts.remove(deviceId);

    if (_lastConnectedDeviceId == deviceId) {
      _lastConnectedDeviceId =
          _connections.keys.isNotEmpty ? _connections.keys.last : null;
    }

    if (_connections.isEmpty) {
      _setState(BleTransportState.idle);
    }
  }

  /// Disconnects the most-recently connected device (single-connection
  /// convenience API). Other concurrent connections are left untouched.
  Future<void> disconnectDevice() async {
    final deviceId = _lastConnectedDeviceId;
    if (deviceId == null) {
      _setState(BleTransportState.idle);
      return;
    }
    await disconnectDeviceId(deviceId);
  }

  /// Disconnects every currently-tracked connection.
  Future<void> disconnectAll() async {
    for (final id in _connections.keys.toList()) {
      await disconnectDeviceId(id);
    }
  }

  // ---------------------------------------------------------------------------
  // Auto-reconnect with exponential backoff (independent per device)
  // ---------------------------------------------------------------------------

  /// Maximum number of reconnection attempts before giving up.
  static const int maxReconnectAttempts = 5;

  Future<void> _attemptReconnect(String deviceId) async {
    if (!autoReconnect) return;
    final attempt = (_reconnectAttempts[deviceId] ?? 0) + 1;

    if (attempt > maxReconnectAttempts) {
      _log.warning('Max reconnect attempts ($maxReconnectAttempts) reached '
          'for $deviceId — giving up');
      await _connectionStateSubs.remove(deviceId)?.cancel();
      _connections.remove(deviceId);
      _reconnectAttempts.remove(deviceId);
      if (_lastConnectedDeviceId == deviceId) {
        _lastConnectedDeviceId =
            _connections.keys.isNotEmpty ? _connections.keys.last : null;
      }
      if (_connections.isEmpty) _setState(BleTransportState.idle);
      return;
    }

    _reconnectAttempts[deviceId] = attempt;
    _setState(BleTransportState.reconnecting);

    final backoff = _backoffCalculator(attempt);
    _log.info('Reconnect attempt $attempt/$maxReconnectAttempts for '
        '$deviceId — waiting ${backoff.inMilliseconds}ms');

    await Future<void>.delayed(backoff);

    if (!autoReconnect || !_connections.containsKey(deviceId)) return;

    try {
      final connection = await _openConnection(deviceId);
      _connections[deviceId] = connection;
      _reconnectAttempts[deviceId] = 0;
      _setState(BleTransportState.connected);
      _log.info('Reconnected to $deviceId');
    } catch (e) {
      _log.warning('Reconnect attempt $attempt for $deviceId failed: $e');
      unawaited(_attemptReconnect(deviceId));
    }
  }

  static Duration _defaultBackoff(int attempt) {
    // Exponential backoff: 1s, 2s, 4s, 8s, 16s — capped at 30s.
    const initial = Duration(seconds: 1);
    const max = Duration(seconds: 30);
    final ms = initial.inMilliseconds * pow(2, attempt - 1);
    final capped = min(ms.toInt(), max.inMilliseconds);
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
    if (serviceUuids.contains(BleConstants.hrsService)) {
      return DeviceProtocol.bleHr;
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
    await disconnectAll();
    await _stateController.close();
    await _scanResultsController.close();
  }
}
