import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/physics_engine.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/simulator/simulator.dart';
import 'package:open_bike/plugins/plugin_manifest.dart';

void main() {
  late EventBus eventBus;
  late CyclingPhysicsEngine physics;
  late SimulatorDevicePlugin plugin;

  setUp(() {
    eventBus = EventBus();
    physics = CyclingPhysicsEngine();
    plugin = SimulatorDevicePlugin(
      eventBus: eventBus,
      physics: physics,
    );
  });

  tearDown(() {
    eventBus.dispose();
  });

  // =========================================================================
  // Scanning
  // =========================================================================

  group('SimulatorDevicePlugin — scan', () {
    test('scan() returns one simulator device', () async {
      final devices = await plugin.scan(const Duration(seconds: 1));

      expect(devices, hasLength(1));
      expect(devices.first.id, 'simulator-0');
      expect(devices.first.name, 'OpenBike Virtual Trainer');
      expect(devices.first.protocol, DeviceProtocol.simulator);
      expect(devices.first.isControllable, isTrue);
      expect(devices.first.supportedModes, contains(ControlMode.erg));
      expect(devices.first.supportedModes, contains(ControlMode.simulation));
      expect(devices.first.supportedModes, contains(ControlMode.resistance));
    });
  });

  // =========================================================================
  // canHandle
  // =========================================================================

  group('SimulatorDevicePlugin — canHandle', () {
    test('returns true for simulator protocol', () {
      const device = TrainerDevice(
        id: 'sim-1',
        name: 'Test Sim',
        protocol: DeviceProtocol.simulator,
      );
      expect(plugin.canHandle(device), isTrue);
    });

    test('returns false for BLE FTMS protocol', () {
      const device = TrainerDevice(
        id: 'ble-1',
        name: 'BLE Trainer',
        protocol: DeviceProtocol.bleFtms,
      );
      expect(plugin.canHandle(device), isFalse);
    });

    test('returns false for ANT+ protocol', () {
      const device = TrainerDevice(
        id: 'ant-1',
        name: 'ANT+ Trainer',
        protocol: DeviceProtocol.antFec,
      );
      expect(plugin.canHandle(device), isFalse);
    });
  });

  // =========================================================================
  // Connection
  // =========================================================================

  group('SimulatorDevicePlugin — connect', () {
    test('connect() returns a working TrainerPort with live data', () async {
      final devices = await plugin.scan(const Duration(seconds: 1));
      final trainerPort = await plugin.connect(devices.first);

      expect(trainerPort, isNotNull);

      final readings = await trainerPort.dataStream.take(2).toList();
      expect(readings, hasLength(2));
      expect(readings.first.power, isNotNull);
      expect(readings.first.cadence, isNotNull);
      expect(readings.first.heartRate, isNotNull);

      await trainerPort.disconnect();
    });

    test('activeTrainer is set after connect', () async {
      expect(plugin.activeTrainer, isNull);

      final devices = await plugin.scan(const Duration(seconds: 1));
      await plugin.connect(devices.first);

      expect(plugin.activeTrainer, isNotNull);

      await plugin.activeTrainer!.disconnect();
    });
  });

  // =========================================================================
  // Manifest
  // =========================================================================

  group('SimulatorDevicePlugin — manifest', () {
    test('has correct metadata', () {
      expect(plugin.manifest.id, 'openbike.simulator');
      expect(plugin.manifest.name, 'Virtual Trainer');
      expect(plugin.manifest.type, PluginType.device);
    });
  });
}
