import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/device_pairing_service.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/ble/sensors/sensor_fusion.dart';
import 'package:open_bike/plugins/plugin_interfaces.dart';
import 'package:open_bike/plugins/plugin_manifest.dart';
import 'package:open_bike/plugins/plugin_registry.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeTrainerPort implements TrainerPort {
  FakeTrainerPort();

  final _controller = StreamController<SensorReading>.broadcast();
  int disconnectCalls = 0;

  @override
  Stream<SensorReading> get dataStream => _controller.stream;

  void emit(SensorReading reading) => _controller.add(reading);

  @override
  Future<void> setTargetPower(Watts watts) async {}

  @override
  Future<void> setSimulationParams(
      double windSpeed, Grade grade, double crr, double cda) async {}

  @override
  Future<void> setResistance(double percent) async {}

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    await _controller.close();
  }
}

/// A [DevicePlugin] fake that hands out a fresh [FakeTrainerPort] per
/// [connect] call and matches devices by [protocol].
class FakeDevicePlugin implements DevicePlugin {
  FakeDevicePlugin(this.protocol);

  final DeviceProtocol protocol;
  final List<FakeTrainerPort> connectedPorts = [];

  @override
  PluginManifest get manifest => PluginManifest(
        id: 'fake.$protocol',
        name: 'Fake $protocol',
        version: '0.0.1',
        type: PluginType.device,
      );

  @override
  bool canHandle(TrainerDevice device) => device.protocol == protocol;

  @override
  Future<List<TrainerDevice>> scan(Duration timeout) async => [];

  @override
  Future<TrainerPort> connect(TrainerDevice device) async {
    final port = FakeTrainerPort();
    connectedPorts.add(port);
    return port;
  }
}

TrainerDevice _device(String id, DeviceProtocol protocol) => TrainerDevice(
      id: id,
      name: 'Device $id',
      protocol: protocol,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late EventBus eventBus;
  late SensorFusion fusion;
  late PluginRegistry registry;
  late FakeDevicePlugin trainerPlugin;
  late FakeDevicePlugin hrPlugin;
  late FakeDevicePlugin powerPlugin;
  late DevicePairingService service;

  setUp(() {
    eventBus = EventBus();
    fusion = SensorFusion(eventBus: eventBus);
    registry = PluginRegistry();
    trainerPlugin = FakeDevicePlugin(DeviceProtocol.bleFtms);
    hrPlugin = FakeDevicePlugin(DeviceProtocol.bleHr);
    powerPlugin = FakeDevicePlugin(DeviceProtocol.blePower);
    registry.registerDevice(trainerPlugin);
    registry.registerDevice(hrPlugin);
    registry.registerDevice(powerPlugin);
    service = DevicePairingService(registry: registry, sensorFusion: fusion);
  });

  tearDown(() async {
    await service.dispose();
    await fusion.dispose();
    eventBus.dispose();
  });

  group('DevicePairingService — priority rules', () {
    test('trainer role gets normal priority', () {
      expect(DevicePairingService.priorityFor(SensorRole.trainer),
          SensorPriority.normal);
    });

    test('every other role gets high priority', () {
      expect(DevicePairingService.priorityFor(SensorRole.heartRate),
          SensorPriority.high);
      expect(DevicePairingService.priorityFor(SensorRole.power),
          SensorPriority.high);
      expect(DevicePairingService.priorityFor(SensorRole.cadenceSpeed),
          SensorPriority.high);
    });
  });

  group('DevicePairingService — assign', () {
    test('connects via the matching plugin and tracks the port', () async {
      final device = _device('trainer-1', DeviceProtocol.bleFtms);
      final port = await service.assign(SensorRole.trainer, device);

      expect(trainerPlugin.connectedPorts, hasLength(1));
      expect(service.portForRole(SensorRole.trainer), port);
      expect(service.activeRoles, contains(SensorRole.trainer));
    });

    test('throws when no plugin can handle the device protocol', () async {
      final device = _device('ant-1', DeviceProtocol.antFec);
      expect(
        () => service.assign(SensorRole.trainer, device),
        throwsStateError,
      );
    });

    test('a dedicated HR strap wins fusion over the trainer\'s embedded HR',
        () async {
      final trainerPort = await service.assign(
        SensorRole.trainer,
        _device('trainer-1', DeviceProtocol.bleFtms),
      ) as FakeTrainerPort;
      final hrPort = await service.assign(
        SensorRole.heartRate,
        _device('hrm-1', DeviceProtocol.bleHr),
      ) as FakeTrainerPort;

      final futureReading = fusion.stream.first;

      // Trainer reports its own (lower-quality) embedded HR alongside power.
      trainerPort.emit(SensorReading(
        timestamp: DateTime.now(),
        power: const Watts(200),
        heartRate: const HeartRate(130),
      ));
      // Dedicated HR strap reports the "real" HR.
      hrPort.emit(SensorReading(
        timestamp: DateTime.now(),
        heartRate: const HeartRate(148),
      ));

      await Future<void>.delayed(Duration.zero);
      final fused = await futureReading.timeout(const Duration(seconds: 3));

      expect(fused.power?.value, 200); // trainer is the only power source
      expect(fused.heartRate?.bpm, 148); // dedicated HR strap wins
    });

    test(
        'assigning a power meter to the power role wins over the '
        'trainer\'s own power for that field', () async {
      final trainerPort = await service.assign(
        SensorRole.trainer,
        _device('trainer-1', DeviceProtocol.bleFtms),
      ) as FakeTrainerPort;
      final powerMeterPort = await service.assign(
        SensorRole.power,
        _device('pm-1', DeviceProtocol.blePower),
      ) as FakeTrainerPort;

      final futureReading = fusion.stream.first;

      trainerPort.emit(SensorReading(
        timestamp: DateTime.now(),
        power: const Watts(180),
        cadence: const Cadence(85),
      ));
      powerMeterPort.emit(SensorReading(
        timestamp: DateTime.now(),
        power: const Watts(203),
      ));

      await Future<void>.delayed(Duration.zero);
      final fused = await futureReading.timeout(const Duration(seconds: 3));

      expect(fused.power?.value, 203); // assigned power meter wins
      expect(fused.cadence?.rpm, 85); // trainer still supplies cadence
    });

    test('re-assigning the same role disconnects the previous device',
        () async {
      final first = await service.assign(
        SensorRole.heartRate,
        _device('hrm-1', DeviceProtocol.bleHr),
      ) as FakeTrainerPort;

      final second = await service.assign(
        SensorRole.heartRate,
        _device('hrm-2', DeviceProtocol.bleHr),
      ) as FakeTrainerPort;

      expect(first.disconnectCalls, 1);
      expect(second.disconnectCalls, 0);
      expect(service.portForRole(SensorRole.heartRate), second);
    });
  });

  group('DevicePairingService — release', () {
    test('disconnects the port and removes it from active roles', () async {
      final port = await service.assign(
        SensorRole.power,
        _device('pm-1', DeviceProtocol.blePower),
      ) as FakeTrainerPort;

      await service.release(SensorRole.power);

      expect(port.disconnectCalls, 1);
      expect(service.portForRole(SensorRole.power), isNull);
      expect(service.activeRoles, isNot(contains(SensorRole.power)));
    });

    test('is a no-op when nothing is assigned to the role', () async {
      await service.release(SensorRole.cadenceSpeed); // should not throw
      expect(service.portForRole(SensorRole.cadenceSpeed), isNull);
    });

    test('frees the role\'s fusion source id (no leaked subscription)',
        () async {
      final firstPort = await service.assign(
        SensorRole.heartRate,
        _device('hrm-1', DeviceProtocol.bleHr),
      ) as FakeTrainerPort;

      await service.release(SensorRole.heartRate);

      final secondPort = await service.assign(
        SensorRole.heartRate,
        _device('hrm-2', DeviceProtocol.bleHr),
      ) as FakeTrainerPort;

      final futureReading = fusion.stream.first;
      secondPort.emit(SensorReading(
        timestamp: DateTime.now(),
        heartRate: const HeartRate(160),
      ));

      await Future<void>.delayed(Duration.zero);
      final fused = await futureReading.timeout(const Duration(seconds: 3));

      expect(fused.heartRate?.bpm, 160);
      expect(firstPort.disconnectCalls, 1);
    });
  });

  group('DevicePairingService — dispose', () {
    test('releases every connected role', () async {
      final trainerPort = await service.assign(
        SensorRole.trainer,
        _device('trainer-1', DeviceProtocol.bleFtms),
      ) as FakeTrainerPort;
      final hrPort = await service.assign(
        SensorRole.heartRate,
        _device('hrm-1', DeviceProtocol.bleHr),
      ) as FakeTrainerPort;

      await service.dispose();

      expect(trainerPort.disconnectCalls, 1);
      expect(hrPort.disconnectCalls, 1);
      expect(service.activeRoles, isEmpty);
    });
  });
}
