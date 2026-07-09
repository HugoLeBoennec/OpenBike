import 'dart:async';

import 'package:logging/logging.dart';

import '../../domain/entities/entities.dart';
import '../../domain/ports/trainer_port.dart';
import '../../../infrastructure/ble/sensors/sensor_fusion.dart';
import '../../../plugins/plugin_interfaces.dart';
import '../../../plugins/plugin_registry.dart';

final _log = Logger('DevicePairingService');

/// Connects a device to a [SensorRole] and wires its readings into
/// [SensorFusion] with the role-appropriate priority.
///
/// This is the seam that turns "assign this HR strap to the heart-rate
/// slot" into fused sensor data winning over the trainer's own embedded
/// heart-rate/power readings:
///
/// - The `trainer` role is fed in at [SensorPriority.normal] — it's the
///   baseline reading.
/// - Every other role (heartRate/power/cadenceSpeed) is fed in at
///   [SensorPriority.high] — a device the user explicitly assigns to a
///   dedicated role always wins fusion for that field over the trainer's
///   embedded sensor, per [SensorFusion]'s `>=` priority comparison.
class DevicePairingService {
  DevicePairingService({
    required PluginRegistry registry,
    required SensorFusion sensorFusion,
  })  : _registry = registry,
        _sensorFusion = sensorFusion;

  final PluginRegistry _registry;
  final SensorFusion _sensorFusion;

  final Map<SensorRole, TrainerPort> _activePorts = {};

  /// The currently-connected port for [role], or `null`.
  TrainerPort? portForRole(SensorRole role) => _activePorts[role];

  /// All currently-connected roles.
  Iterable<SensorRole> get activeRoles => _activePorts.keys;

  /// Connects [device] and assigns it to [role].
  ///
  /// Replaces whatever was previously connected for that role. Throws a
  /// [StateError] if no registered [DevicePlugin] can handle [device].
  Future<TrainerPort> assign(SensorRole role, TrainerDevice device) async {
    final plugin = _registry.getPluginForDevice(device);
    if (plugin == null) {
      throw StateError(
        'No plugin available to handle ${device.protocol} device '
        '"${device.name}"',
      );
    }

    await release(role);

    final port = await plugin.connect(device);
    _activePorts[role] = port;
    _sensorFusion.addSource(SensorSource(
      id: role.name,
      stream: port.dataStream,
      priority: priorityFor(role),
    ));

    _log.info('Assigned "${device.name}" to role $role '
        '(priority=${priorityFor(role)})');
    return port;
  }

  /// Disconnects and un-wires whatever is currently assigned to [role].
  /// No-op if [role] has nothing connected.
  Future<void> release(SensorRole role) async {
    _sensorFusion.removeSource(role.name);
    final port = _activePorts.remove(role);
    if (port == null) return;

    try {
      await port.disconnect();
    } catch (e) {
      _log.warning('Error disconnecting role $role: $e');
    }
  }

  /// The [SensorPriority] a role's fused source should use.
  static SensorPriority priorityFor(SensorRole role) =>
      role == SensorRole.trainer ? SensorPriority.normal : SensorPriority.high;

  /// Releases every connected role.
  Future<void> dispose() async {
    for (final role in _activePorts.keys.toList()) {
      await release(role);
    }
  }
}
