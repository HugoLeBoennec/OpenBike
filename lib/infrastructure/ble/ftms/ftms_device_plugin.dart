import 'dart:async';

import 'package:logging/logging.dart';

import '../../../core/domain/entities/entities.dart';
import '../../../core/domain/ports/trainer_port.dart';
import '../../../core/domain/value_objects/value_objects.dart';
import '../../../core/events/app_event.dart';
import '../../../core/events/event_bus.dart';
import '../../../plugins/plugin_interfaces.dart';
import '../../../plugins/plugin_manifest.dart';
import '../ble_connection.dart';
import '../ble_constants.dart';
import '../ble_transport.dart';
import 'ftms_control_client.dart';
import 'ftms_data_parser.dart';

final _log = Logger('FtmsDevicePlugin');

// ---------------------------------------------------------------------------
// FtmsDevicePlugin — implements DevicePlugin
// ---------------------------------------------------------------------------

/// Plugin that drives FTMS (Fitness Machine Service) trainers over BLE.
class FtmsDevicePlugin implements DevicePlugin {
  FtmsDevicePlugin({
    required BleTransport transport,
    required EventBus eventBus,
  })  : _transport = transport,
        _eventBus = eventBus;

  final BleTransport _transport;
  final EventBus _eventBus;

  @override
  PluginManifest get manifest => const PluginManifest(
        id: 'openbike.ftms',
        name: 'FTMS Trainer',
        version: '0.1.0',
        type: PluginType.device,
        author: 'OpenBike',
        description: 'Bluetooth FTMS indoor bike trainer support.',
        capabilities: ['erg', 'simulation', 'resistance'],
      );

  @override
  bool canHandle(TrainerDevice device) =>
      device.protocol == DeviceProtocol.bleFtms;

  @override
  Future<List<TrainerDevice>> scan(Duration timeout) async {
    final devices = <TrainerDevice>[];
    final completer = Completer<List<TrainerDevice>>();

    final sub = _transport.scanResults.listen((results) {
      devices.clear();
      for (final r in results) {
        if (r.serviceUuids.contains(BleConstants.ftmsService)) {
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

    if (!completer.isCompleted) {
      _log.info('Scan found ${devices.length} FTMS device(s)');
    }

    return devices;
  }

  @override
  Future<TrainerPort> connect(TrainerDevice device) async {
    _log.info('Connecting to FTMS device ${device.name} (${device.id})');

    final connection = await _transport.connectToDevice(device.id);

    final adapter = FtmsTrainerAdapter(
      connection: connection,
      device: device,
      eventBus: _eventBus,
    );

    await adapter.initialize();
    return adapter;
  }
}

// ---------------------------------------------------------------------------
// FtmsTrainerAdapter — implements TrainerPort
// ---------------------------------------------------------------------------

/// Adapts an FTMS BLE connection into the domain [TrainerPort] interface.
///
/// - Subscribes to Indoor Bike Data → parses with [FtmsDataParser] → emits
///   on [dataStream]
/// - Delegates control commands to [FtmsControlClient]
/// - Fires [TrainerEvent]s on the [EventBus]
class FtmsTrainerAdapter implements TrainerPort {
  FtmsTrainerAdapter({
    required BleConnection connection,
    required TrainerDevice device,
    required EventBus eventBus,
  })  : _connection = connection,
        _device = device,
        _eventBus = eventBus;

  final BleConnection _connection;
  final TrainerDevice _device;
  final EventBus _eventBus;

  final _dataParser = const FtmsDataParser();
  late final FtmsControlClient _controlClient;

  final _dataController = StreamController<SensorReading>.broadcast();
  StreamSubscription? _dataSub;
  StreamSubscription? _connectionStateSub;
  StreamSubscription? _statusSub;

  /// Grade difficulty scalar (0.0–1.0). Applied to every [setSimulationParams]
  /// call before forwarding to the FTMS control client. Default 0.5 (Zwift
  /// style: half the real gradient).
  double _difficulty = 0.5;

  /// Update the gradient difficulty at runtime (e.g. from a ride-screen slider).
  // ignore: avoid_setters_without_getters
  set difficulty(double value) => _difficulty = value.clamp(0.0, 1.0);

  @override
  Stream<SensorReading> get dataStream => _dataController.stream;

  /// The underlying control client, exposed for advanced usage.
  FtmsControlClient get controlClient => _controlClient;

  /// The FTMS features read during initialization.
  FtmsFeatures? get features => _controlClient.features;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Sets up data subscriptions and runs the FTMS control handshake.
  Future<void> initialize() async {
    _log.info('[BLE-DEBUG] Initializing FTMS adapter for ${_device.name} '
        '(${_device.id})');

    // Monitor BLE connection state.
    _connectionStateSub = _connection.stateStream.listen((state) {
      _log.info('[BLE-DEBUG] BLE connection state → $state');
      if (state == BleConnectionState.disconnected) {
        _eventBus.fire(TrainerEvent.disconnected(_device.id));
      }
    });

    // Subscribe to Indoor Bike Data (0x2AD2).
    _log.info('[BLE-DEBUG] Subscribing to Indoor Bike Data '
        '(${BleConstants.ftmsIndoorBikeData})');
    final bikeDataStream = await _connection.subscribe(
      BleConstants.ftmsService,
      BleConstants.ftmsIndoorBikeData,
    );
    _log.info('[BLE-DEBUG] Indoor Bike Data subscription active — '
        'waiting for notifications');
    _dataSub = bikeDataStream.listen(_onIndoorBikeData);

    // Initialize the control client (full FTMS handshake).
    _log.info('[BLE-DEBUG] Starting FTMS control handshake');
    _controlClient = FtmsControlClient(_connection);
    await _controlClient.initialize();
    _log.info('[BLE-DEBUG] FTMS control handshake complete — '
        'features: ${_controlClient.features}');

    // Subscribe to Fitness Machine Status notifications (0x2ADA).
    _statusSub = _controlClient.statusChanges.listen(_onMachineStatusChange);

    // Fire events.
    _eventBus.fire(TrainerEvent.connected(_device));
    _eventBus.fire(TrainerEvent.controlAcquired(_device.id));

    _log.info('[BLE-DEBUG] FTMS adapter fully initialized');
  }

  // ---------------------------------------------------------------------------
  // Fitness Machine Status handler (0x2ADA)
  // ---------------------------------------------------------------------------

  void _onMachineStatusChange(FtmsMachineStatus status) {
    _log.info('Machine status: $status');
    switch (status) {
      case FtmsMachineStatus.stoppedOrPausedByUser:
        _log.info('Physical stop button pressed on ${_device.name}');
        _eventBus.fire(TrainerEvent.physicalStop(_device.id));
      case FtmsMachineStatus.stoppedBySafetyKey:
        _log.warning('Safety key / limit triggered on ${_device.name}');
        _eventBus.fire(TrainerEvent.safetyStop(_device.id));
      case FtmsMachineStatus.targetPowerChanged:
        _log.info('Target power changed externally on ${_device.name}');
      case FtmsMachineStatus.controlPermissionLost:
        _log.warning('Control permission lost on ${_device.name}');
      default:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Data parsing
  // ---------------------------------------------------------------------------

  void _onIndoorBikeData(List<int> raw) {
    _log.fine('[BLE-DEBUG] Raw Indoor Bike Data (${raw.length} bytes): $raw');

    final parsed = _dataParser.parseIndoorBikeData(raw);
    if (parsed == null) {
      _log.warning('[BLE-DEBUG] Failed to parse Indoor Bike Data');
      return;
    }

    final reading = _dataParser.toSensorReading(parsed);
    _log.fine('[BLE-DEBUG] Parsed → power=${reading.power}, '
        'cadence=${reading.cadence}, speed=${reading.speed}, '
        'hr=${reading.heartRate}');

    _dataController.add(reading);
    _eventBus.fire(SensorEvent(reading: reading, deviceId: _device.id));
  }

  // ---------------------------------------------------------------------------
  // TrainerPort — control commands
  // ---------------------------------------------------------------------------

  @override
  Future<void> setTargetPower(Watts watts) async {
    final response =
        await _controlClient.setTargetPower(watts.value.round());
    if (!response.isSuccess) {
      _log.warning('setTargetPower failed: ${response.resultCode}');
    }
    _eventBus.fire(TrainerEvent.modeChanged(_device.id, ControlMode.erg));
  }

  @override
  Future<void> setSimulationParams(
    double windSpeed,
    Grade grade,
    double crr,
    double cda,
  ) async {
    // Scale grade by difficulty (Zwift-style: half-difficulty on downhills).
    var scaledGrade = grade.percent * _difficulty;
    if (scaledGrade < 0) scaledGrade *= 0.5;

    final response = await _controlClient.setSimulationParameters(
      windSpeed: windSpeed,
      grade: scaledGrade,
      crr: crr,
      cda: cda,
    );
    if (!response.isSuccess) {
      _log.warning('setSimulationParams failed: ${response.resultCode}');
    }
    _eventBus
        .fire(TrainerEvent.modeChanged(_device.id, ControlMode.simulation));
  }

  @override
  Future<void> setResistance(double percent) async {
    final response = await _controlClient.setTargetResistance(percent);
    if (!response.isSuccess) {
      _log.warning('setResistance failed: ${response.resultCode}');
    }
    _eventBus
        .fire(TrainerEvent.modeChanged(_device.id, ControlMode.resistance));
  }

  @override
  Future<void> disconnect() async {
    _log.info('Disconnecting FTMS adapter');

    await _dataSub?.cancel();
    _dataSub = null;
    await _connectionStateSub?.cancel();
    _connectionStateSub = null;
    await _statusSub?.cancel();
    _statusSub = null;

    // Stop the trainer before disconnecting.
    if (_controlClient.hasControl) {
      try {
        await _controlClient.stopOrPause();
      } catch (e) {
        _log.warning('Failed to stop trainer on disconnect: $e');
      }
    }

    await _controlClient.dispose();
    await _dataController.close();

    _eventBus.fire(TrainerEvent.disconnected(_device.id));
  }
}
