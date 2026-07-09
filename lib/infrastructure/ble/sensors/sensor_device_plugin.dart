import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';

import '../../../core/domain/entities/entities.dart';
import '../../../core/domain/ports/sensor_port.dart';
import '../../../core/domain/ports/trainer_port.dart';
import '../../../core/domain/value_objects/value_objects.dart';
import '../../../core/events/app_event.dart';
import '../../../core/events/event_bus.dart';
import '../../../plugins/plugin_interfaces.dart';
import '../../../plugins/plugin_manifest.dart';
import '../ble_connection.dart';
import '../ble_constants.dart';
import '../ble_transport.dart';
import 'csc_reader.dart';
import 'cycling_power_reader.dart';
import 'heart_rate_reader.dart';

final _log = Logger('SensorDevicePlugin');

// ---------------------------------------------------------------------------
// SensorDevicePlugin — DevicePlugin for simple BLE sensors
// ---------------------------------------------------------------------------

/// Plugin that handles BLE sensor devices (HR, power meter, speed/cadence).
///
/// Unlike FTMS trainers, these devices are read-only — they don't support
/// control commands.
class SensorDevicePlugin implements DevicePlugin {
  SensorDevicePlugin({
    required BleTransport transport,
    required EventBus eventBus,
  })  : _transport = transport,
        _eventBus = eventBus;

  final BleTransport _transport;
  final EventBus _eventBus;

  @override
  PluginManifest get manifest => const PluginManifest(
        id: 'openbike.sensors',
        name: 'BLE Sensors',
        version: '0.1.0',
        type: PluginType.device,
        author: 'OpenBike',
        description: 'Heart rate, power meter, and speed/cadence sensors.',
        capabilities: ['hr', 'power', 'cadence', 'speed'],
      );

  @override
  bool canHandle(TrainerDevice device) {
    return device.protocol == DeviceProtocol.blePower ||
        device.protocol == DeviceProtocol.bleCsc ||
        device.protocol == DeviceProtocol.bleHr;
  }

  @override
  Future<List<TrainerDevice>> scan(Duration timeout) async {
    final devices = <TrainerDevice>[];

    final sub = _transport.scanResults.listen((results) {
      devices.clear();
      for (final r in results) {
        final uuids = r.serviceUuids;
        // Exclude FTMS — those are handled by FtmsDevicePlugin.
        if (uuids.contains(BleConstants.ftmsService)) continue;

        final hasSensorService = uuids.contains(BleConstants.hrsService) ||
            uuids.contains(BleConstants.cpsService) ||
            uuids.contains(BleConstants.cscService);
        if (hasSensorService) {
          devices.add(r.device);
        }
      }
    });

    try {
      await _transport.startScan(timeout: timeout);
    } catch (e) {
      _log.warning('Scan failed: $e');
    }

    await sub.cancel();
    _log.info('Scan found ${devices.length} sensor device(s)');
    return devices;
  }

  @override
  Future<TrainerPort> connect(TrainerDevice device) async {
    _log.info('Connecting to sensor ${device.name} (${device.id})');

    final connection = await _transport.connectToDevice(device.id);

    final adapter = SensorAdapter(
      connection: connection,
      device: device,
      eventBus: _eventBus,
    );

    await adapter.initialize();
    return adapter;
  }
}

// ---------------------------------------------------------------------------
// SensorAdapter — implements SensorPort (and TrainerPort for compatibility)
// ---------------------------------------------------------------------------

/// Adapts a BLE sensor connection into [SensorPort].
///
/// Also implements [TrainerPort] so it can be returned from [DevicePlugin.connect],
/// but control methods are no-ops since sensors are read-only.
///
/// Automatically subscribes to whichever characteristics the device exposes:
/// - HR Measurement (0x2A37)
/// - CPS Measurement (0x2A63)
/// - CSC Measurement (0x2A5B)
class SensorAdapter implements TrainerPort, SensorPort {
  SensorAdapter({
    required BleConnection connection,
    required TrainerDevice device,
    required EventBus eventBus,
  })  : _connection = connection,
        _device = device,
        _eventBus = eventBus;

  final BleConnection _connection;
  final TrainerDevice _device;
  final EventBus _eventBus;

  final _hrReader = const HeartRateReader();
  final _cpsReader = CyclingPowerReader();
  final _cscReader = CscReader();

  final _dataController = StreamController<SensorReading>.broadcast();
  final List<StreamSubscription> _subscriptions = [];

  @override
  Stream<SensorReading> get dataStream => _dataController.stream;

  /// Discovers and subscribes to all available sensor characteristics.
  Future<void> initialize() async {
    _log.info('Initializing sensor adapter for ${_device.name}');

    await _trySubscribe(
      BleConstants.hrsService,
      BleConstants.hrsMeasurement,
      _onHrData,
    );
    await _trySubscribe(
      BleConstants.cpsService,
      BleConstants.cpsMeasurement,
      _onCpsData,
    );
    await _trySubscribe(
      BleConstants.cscService,
      BleConstants.cscMeasurement,
      _onCscData,
    );

    _eventBus.fire(TrainerEvent.connected(_device));
    _log.info('Sensor adapter initialized');
  }

  Future<void> _trySubscribe(
    Guid serviceUuid,
    Guid charUuid,
    void Function(List<int>) handler,
  ) async {
    final char = _connection.findCharacteristic(serviceUuid, charUuid);
    if (char == null) {
      _log.fine('Characteristic $charUuid not available');
      return;
    }

    try {
      final stream = await _connection.subscribe(serviceUuid, charUuid);
      _subscriptions.add(stream.listen(handler));
      _log.info('Subscribed to $charUuid');
    } catch (e) {
      _log.warning('Failed to subscribe to $charUuid: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Notification handlers
  // ---------------------------------------------------------------------------

  void _onHrData(List<int> raw) {
    final parsed = _hrReader.parse(raw);
    if (parsed == null) return;
    _dataController.add(_hrReader.toSensorReading(parsed));
  }

  void _onCpsData(List<int> raw) {
    final parsed = _cpsReader.parse(raw);
    if (parsed == null) return;
    final cadence = _cpsReader.computeCadence(parsed);
    _dataController.add(_cpsReader.toSensorReading(parsed, cadence: cadence));
  }

  void _onCscData(List<int> raw) {
    final parsed = _cscReader.parse(raw);
    if (parsed == null) return;
    final speed = _cscReader.computeSpeed(parsed);
    final cadence = _cscReader.computeCadence(parsed);
    _dataController.add(_cscReader.toSensorReading(
      speedKmh: speed,
      cadence: cadence,
    ));
  }

  // ---------------------------------------------------------------------------
  // TrainerPort — control methods (no-ops for sensors)
  // ---------------------------------------------------------------------------

  @override
  Future<void> setTargetPower(Watts watts) async {}

  @override
  Future<void> setSimulationParams(
    double windSpeed,
    Grade grade,
    double crr,
    double cda,
  ) async {}

  @override
  Future<void> setResistance(double percent) async {}

  // ---------------------------------------------------------------------------
  // Disconnect
  // ---------------------------------------------------------------------------

  @override
  Future<void> disconnect() async {
    _log.info('Disconnecting sensor adapter');

    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();

    _cpsReader.reset();
    _cscReader.reset();

    await _dataController.close();
    _eventBus.fire(TrainerEvent.disconnected(_device.id));
  }
}
