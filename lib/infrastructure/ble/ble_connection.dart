import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';

final _log = Logger('BleConnection');

/// Connection state exposed by [BleConnection].
enum BleConnectionState { disconnected, connecting, connected, disconnecting }

/// Wraps a single BLE peripheral connection with service discovery,
/// characteristic subscribe / write / read, and MTU negotiation.
class BleConnection {
  BleConnection(this._device);

  final BluetoothDevice _device;

  List<BluetoothService> _services = [];
  final List<StreamSubscription> _subscriptions = [];

  int _negotiatedMtu = 23;

  final _stateController =
      StreamController<BleConnectionState>.broadcast();

  /// Stream of connection-state changes.
  Stream<BleConnectionState> get stateStream => _stateController.stream;

  /// The current negotiated MTU (defaults to 23 before negotiation).
  int get mtu => _negotiatedMtu;

  /// The underlying device id.
  String get deviceId => _device.remoteId.str;

  // ---------------------------------------------------------------------------
  // Connect
  // ---------------------------------------------------------------------------

  /// Opens the GATT connection, negotiates MTU and discovers services.
  Future<void> connect({Duration timeout = const Duration(seconds: 15)}) async {
    _log.info('[BLE-DEBUG] GATT connecting to ${_device.remoteId}…');
    _stateController.add(BleConnectionState.connecting);

    try {
      await _device.connect(timeout: timeout, autoConnect: false);
      _log.info('[BLE-DEBUG] GATT connected to ${_device.remoteId}');

      // Listen for platform-level disconnection.
      _subscriptions.add(
        _device.connectionState.listen((state) {
          if (state == BluetoothConnectionState.disconnected) {
            _log.info('[BLE-DEBUG] Device ${_device.remoteId} disconnected (platform)');
            _stateController.add(BleConnectionState.disconnected);
          }
        }),
      );

      await _negotiateMtu();
      await _discoverServices();

      _stateController.add(BleConnectionState.connected);
      _log.info('[BLE-DEBUG] Connected to ${_device.remoteId} '
          '(MTU=$_negotiatedMtu, ${_services.length} services)');
    } catch (e) {
      _log.severe('[BLE-DEBUG] Connection to ${_device.remoteId} failed: $e');
      _stateController.add(BleConnectionState.disconnected);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Disconnect
  // ---------------------------------------------------------------------------

  Future<void> disconnect() async {
    _log.info('Disconnecting from ${_device.remoteId}…');
    _stateController.add(BleConnectionState.disconnecting);

    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _services = [];

    try {
      await _device.disconnect();
    } catch (e) {
      _log.warning('Error during disconnect: $e');
    }

    _stateController.add(BleConnectionState.disconnected);
    _log.info('Disconnected from ${_device.remoteId}');
  }

  // ---------------------------------------------------------------------------
  // MTU negotiation
  // ---------------------------------------------------------------------------

  Future<void> _negotiateMtu() async {
    try {
      _negotiatedMtu = await _device.requestMtu(512);
      if (_negotiatedMtu < 23) _negotiatedMtu = 23;
      _log.fine('MTU negotiated: $_negotiatedMtu');
    } catch (e) {
      _negotiatedMtu = 23;
      _log.warning('MTU negotiation failed, using default (23): $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Service discovery
  // ---------------------------------------------------------------------------

  Future<void> _discoverServices() async {
    _services = await _device.discoverServices();
    _log.info('[BLE-DEBUG] Discovered ${_services.length} services');
    for (final s in _services) {
      _log.info('[BLE-DEBUG]   Service ${s.serviceUuid} '
          '(${s.characteristics.length} chars)');
      for (final c in s.characteristics) {
        _log.fine('[BLE-DEBUG]     Char ${c.characteristicUuid} '
            'props: notify=${c.properties.notify}, '
            'indicate=${c.properties.indicate}, '
            'read=${c.properties.read}, '
            'write=${c.properties.write}');
      }
    }
  }

  /// Returns all discovered services.
  List<BluetoothService> get services => List.unmodifiable(_services);

  /// Finds a characteristic by [serviceUuid] and [charUuid].
  /// Returns `null` if not found.
  BluetoothCharacteristic? findCharacteristic(Guid serviceUuid, Guid charUuid) {
    for (final service in _services) {
      if (service.serviceUuid == serviceUuid) {
        for (final c in service.characteristics) {
          if (c.characteristicUuid == charUuid) return c;
        }
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Subscribe (notifications / indications)
  // ---------------------------------------------------------------------------

  /// Subscribes to notifications on the given characteristic and returns
  /// a broadcast stream of raw byte lists.
  ///
  /// Throws if the characteristic does not support notify or indicate.
  Future<Stream<List<int>>> subscribe(
    Guid serviceUuid,
    Guid charUuid,
  ) async {
    final char = findCharacteristic(serviceUuid, charUuid);
    if (char == null) {
      throw StateError(
        'Characteristic $charUuid not found on service $serviceUuid',
      );
    }

    _log.info('[BLE-DEBUG] Subscribing to $charUuid on service $serviceUuid');
    await char.setNotifyValue(true);
    _log.info('[BLE-DEBUG] Notifications enabled for $charUuid');

    return char.onValueReceived;
  }

  /// Unsubscribes from notifications on the given characteristic.
  Future<void> unsubscribe(Guid serviceUuid, Guid charUuid) async {
    final char = findCharacteristic(serviceUuid, charUuid);
    if (char == null) return;
    _log.fine('Unsubscribing from $charUuid');
    await char.setNotifyValue(false);
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  /// Writes [data] to a characteristic.
  ///
  /// Set [withResponse] to `false` for write-without-response (command).
  Future<void> write(
    Guid serviceUuid,
    Guid charUuid,
    List<int> data, {
    bool withResponse = true,
  }) async {
    final char = findCharacteristic(serviceUuid, charUuid);
    if (char == null) {
      throw StateError(
        'Characteristic $charUuid not found on service $serviceUuid',
      );
    }

    _log.fine('Writing ${data.length} bytes to $charUuid '
        '(response=$withResponse)');
    await char.write(data, withoutResponse: !withResponse);
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Reads the current value of a characteristic.
  Future<List<int>> read(Guid serviceUuid, Guid charUuid) async {
    final char = findCharacteristic(serviceUuid, charUuid);
    if (char == null) {
      throw StateError(
        'Characteristic $charUuid not found on service $serviceUuid',
      );
    }

    _log.fine('Reading from $charUuid');
    return char.read();
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  /// Releases resources. Call [disconnect] first if still connected.
  void dispose() {
    _stateController.close();
  }
}
