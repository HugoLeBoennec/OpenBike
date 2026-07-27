import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/plugins/plugin_interfaces.dart';
import 'package:open_bike/plugins/plugin_manifest.dart';
import 'package:open_bike/plugins/plugin_registry.dart';
import 'package:open_bike/presentation/state/providers.dart';

class _FakePort implements TrainerPort {
  final _controller = StreamController<SensorReading>.broadcast();

  @override
  Stream<SensorReading> get dataStream => _controller.stream;

  @override
  Future<void> setTargetPower(Watts watts) async {}

  @override
  Future<void> setSimulationParams(
      double windSpeed, Grade grade, double crr, double cda) async {}

  @override
  Future<void> setResistance(double percent) async {}

  @override
  Future<void> disconnect() async => _controller.close();
}

/// Connects instantly for every device except [stallingDeviceId], whose
/// connect hangs until [releaseStall] is called — standing in for a device
/// that's powered off and burns the full BLE connect timeout.
class _StallingPlugin implements DevicePlugin {
  _StallingPlugin({required this.stallingDeviceId});

  final String stallingDeviceId;
  final _stall = Completer<TrainerPort>();
  final List<String> connected = [];

  void releaseStall() {
    if (!_stall.isCompleted) _stall.completeError(StateError('timed out'));
  }

  @override
  PluginManifest get manifest => const PluginManifest(
        id: 'fake.stalling',
        name: 'Fake',
        version: '0.0.1',
        type: PluginType.device,
      );

  @override
  bool canHandle(TrainerDevice device) => true;

  @override
  Future<List<TrainerDevice>> scan(Duration timeout) async => [];

  @override
  Future<TrainerPort> connect(TrainerDevice device) async {
    if (device.id == stallingDeviceId) return _stall.future;
    connected.add(device.id);
    return _FakePort();
  }
}

void main() {
  test(
      'a powered-off device does not delay the other roles reconnecting',
      () async {
    final plugin = _StallingPlugin(stallingDeviceId: 'trainer-off');
    final registry = PluginRegistry()..registerDevice(plugin);

    // Trainer is off (its connect hangs); the HR strap is worn and ready.
    final paired = const PairedDevices()
        .withRole(
          SensorRole.trainer,
          const PairedDevice(
            deviceId: 'trainer-off',
            name: 'Kickr',
            protocol: DeviceProtocol.bleFtms,
          ),
        )
        .withRole(
          SensorRole.heartRate,
          const PairedDevice(
            deviceId: 'hrm-1',
            name: 'TICKR',
            protocol: DeviceProtocol.bleHr,
          ),
        );

    final container = ProviderContainer(overrides: [
      pluginRegistryProvider.overrideWithValue(registry),
      pairedDevicesProvider.overrideWith((ref) => paired),
    ]);
    addTearDown(container.dispose);

    container.read(autoReconnectPairedRolesProvider);

    // Let the microtask + the fast connect settle. The trainer is still
    // hanging at this point, so if reconnects ran sequentially the strap
    // would not have been reached yet.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(plugin.connected, ['hrm-1']);
    expect(
      container.read(roleConnectionProvider)[SensorRole.heartRate],
      RoleConnection.connected,
    );

    // The stalled trainer eventually fails, and is reported as such.
    plugin.releaseStall();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(
      container.read(roleConnectionProvider)[SensorRole.trainer],
      RoleConnection.notConnected,
    );
  });
}
