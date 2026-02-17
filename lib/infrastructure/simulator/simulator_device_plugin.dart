import 'dart:async';

import 'package:logging/logging.dart';

import '../../core/application/services/physics_engine.dart';
import '../../core/domain/entities/entities.dart';
import '../../core/domain/ports/trainer_port.dart';
import '../../core/events/event_bus.dart';
import '../../plugins/plugin_interfaces.dart';
import '../../plugins/plugin_manifest.dart';
import 'fake_trainer.dart';

final _log = Logger('SimulatorDevicePlugin');

/// Plugin that provides a simulated trainer for development and testing.
///
/// Mirrors [FtmsDevicePlugin] pattern but returns a [FakeTrainer] instead
/// of a real BLE-connected adapter.
class SimulatorDevicePlugin implements DevicePlugin {
  SimulatorDevicePlugin({
    required EventBus eventBus,
    required CyclingPhysicsEngine physics,
  })  : _eventBus = eventBus,
        _physics = physics;

  final EventBus _eventBus;
  final CyclingPhysicsEngine _physics;
  FakeTrainer? _activeTrainer;

  @override
  PluginManifest get manifest => const PluginManifest(
        id: 'openbike.simulator',
        name: 'Virtual Trainer',
        version: '0.1.0',
        type: PluginType.device,
        author: 'OpenBike',
        description: 'Simulated indoor trainer for development and testing.',
        capabilities: ['erg', 'simulation', 'resistance'],
      );

  @override
  bool canHandle(TrainerDevice device) =>
      device.protocol == DeviceProtocol.simulator;

  @override
  Future<List<TrainerDevice>> scan(Duration timeout) async {
    _log.info('Scanning for virtual trainers…');
    // Simulate a short scan delay to feel realistic.
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return const [
      TrainerDevice(
        id: 'simulator-0',
        name: 'OpenBike Virtual Trainer',
        manufacturer: 'OpenBike',
        protocol: DeviceProtocol.simulator,
        isControllable: true,
        supportedModes: [
          ControlMode.erg,
          ControlMode.simulation,
          ControlMode.resistance,
        ],
      ),
    ];
  }

  @override
  Future<TrainerPort> connect(TrainerDevice device) async {
    _log.info('Connecting to virtual trainer ${device.id}');

    final trainer = FakeTrainer(
      eventBus: _eventBus,
      physics: _physics,
      deviceId: device.id,
    );

    await trainer.initialize();
    _activeTrainer = trainer;
    return trainer;
  }

  /// Returns the active [FakeTrainer], if connected. Used by dev tools
  /// to access manual override controls.
  FakeTrainer? get activeTrainer => _activeTrainer;
}
