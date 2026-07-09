import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/ble/ble_transport.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/plugins/plugin_interfaces.dart';
import 'package:open_bike/plugins/plugin_manifest.dart';
import 'package:open_bike/plugins/plugin_registry.dart';
import 'package:open_bike/presentation/screens/device_scan_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';

// ---------------------------------------------------------------------------
// Fakes — a DevicePlugin/TrainerPort double so assignment/fusion can be
// exercised without real BLE hardware.
// ---------------------------------------------------------------------------

class FakeTrainerPort implements TrainerPort {
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

Future<AppPreferences> _fakePrefs() async {
  SharedPreferences.setMockInitialValues({});
  return AppPreferences(await SharedPreferences.getInstance());
}

Widget _wrap({
  required List<Override> overrides,
  required void Function(ProviderContainer) captureContainer,
}) {
  return ProviderScope(
    overrides: overrides,
    child: Builder(builder: (context) {
      captureContainer(ProviderScope.containerOf(context));
      return const MaterialApp(home: DeviceScanScreen());
    }),
  );
}

void main() {
  testWidgets(
      'assigning a dedicated HR strap wins fusion over the trainer\'s '
      'embedded HR', (tester) async {
    final registry = PluginRegistry();
    final trainerPlugin = FakeDevicePlugin(DeviceProtocol.bleFtms);
    final hrPlugin = FakeDevicePlugin(DeviceProtocol.bleHr);
    registry.registerDevice(trainerPlugin);
    registry.registerDevice(hrPlugin);

    const trainerDevice = TrainerDevice(
      id: 'trainer-1',
      name: 'Kickr',
      protocol: DeviceProtocol.bleFtms,
    );
    const hrDevice = TrainerDevice(
      id: 'hrm-1',
      name: 'TICKR',
      protocol: DeviceProtocol.bleHr,
    );
    final scanned = [
      const BleScannedDevice(device: trainerDevice, rssi: -40, serviceUuids: []),
      const BleScannedDevice(device: hrDevice, rssi: -40, serviceUuids: []),
    ];

    late ProviderContainer container;
    await tester.pumpWidget(_wrap(
      overrides: [
        pluginRegistryProvider.overrideWithValue(registry),
        appPreferencesProvider.overrideWithValue(await _fakePrefs()),
        bleScanResultsProvider.overrideWith((ref) => Stream.value(scanned)),
        bleScanStateProvider
            .overrideWith((ref) => Stream.value(BleTransportState.idle)),
      ],
      captureContainer: (c) => container = c,
    ));
    await tester.pumpAndSettle();

    // Tap the trainer's scan tile — no role pre-selected, so it defaults to
    // the trainer role for an FTMS device.
    await tester.tap(find.text('Kickr'));
    await tester.pumpAndSettle();

    // Tap the HR strap's scan tile — defaults to the heartRate role.
    await tester.tap(find.text('TICKR'));
    await tester.pumpAndSettle();

    final pairedDevices = container.read(pairedDevicesProvider);
    expect(pairedDevices.forRole(SensorRole.trainer)?.deviceId, 'trainer-1');
    expect(pairedDevices.forRole(SensorRole.heartRate)?.deviceId, 'hrm-1');

    expect(trainerPlugin.connectedPorts, hasLength(1));
    expect(hrPlugin.connectedPorts, hasLength(1));

    final trainerPort = trainerPlugin.connectedPorts.single;
    final hrPort = hrPlugin.connectedPorts.single;

    final fusion = container.read(sensorFusionProvider);
    final futureReading = fusion.stream.first;

    // Trainer reports its own embedded (lower quality) HR alongside power.
    trainerPort.emit(SensorReading(
      timestamp: DateTime.now(),
      power: const Watts(210),
      heartRate: const HeartRate(120),
    ));
    // Dedicated HR strap reports the real HR.
    hrPort.emit(SensorReading(
      timestamp: DateTime.now(),
      heartRate: const HeartRate(151),
    ));

    // SensorFusion emits on a 1 Hz Timer.periodic — real Future.delayed
    // calls never elapse inside testWidgets, so advance the test's virtual
    // clock with tester.pump() instead to let it fire.
    await tester.pump(const Duration(seconds: 1));
    final fused = await futureReading.timeout(const Duration(seconds: 1));

    expect(fused.power?.value, 210); // only the trainer supplies power
    expect(fused.heartRate?.bpm, 151); // dedicated HR strap wins fusion
  });

  testWidgets('forget clears the role slot, disconnects, and persists',
      (tester) async {
    final registry = PluginRegistry();
    final hrPlugin = FakeDevicePlugin(DeviceProtocol.bleHr);
    registry.registerDevice(hrPlugin);

    const hrDevice = TrainerDevice(
      id: 'hrm-1',
      name: 'TICKR',
      protocol: DeviceProtocol.bleHr,
    );
    final scanned = [
      const BleScannedDevice(device: hrDevice, rssi: -40, serviceUuids: []),
    ];

    final appPrefs = await _fakePrefs();

    late ProviderContainer container;
    await tester.pumpWidget(_wrap(
      overrides: [
        pluginRegistryProvider.overrideWithValue(registry),
        appPreferencesProvider.overrideWithValue(appPrefs),
        bleScanResultsProvider.overrideWith((ref) => Stream.value(scanned)),
        bleScanStateProvider
            .overrideWith((ref) => Stream.value(BleTransportState.idle)),
      ],
      captureContainer: (c) => container = c,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('TICKR'));
    await tester.pumpAndSettle();

    expect(
      container.read(pairedDevicesProvider).forRole(SensorRole.heartRate),
      isNotNull,
    );
    final port = hrPlugin.connectedPorts.single;

    await tester.tap(find.byKey(const ValueKey('forget-heartRate')));
    await tester.pumpAndSettle();

    expect(
      container.read(pairedDevicesProvider).forRole(SensorRole.heartRate),
      isNull,
    );
    expect(port.disconnectCalls, 1);

    // Persisted change survives a fresh AppPreferences read (simulated
    // restart) — the round-trip mechanics themselves are covered in
    // app_preferences_test.dart.
    final reloaded = AppPreferences(await SharedPreferences.getInstance());
    expect(reloaded.pairedDevices.forRole(SensorRole.heartRate), isNull);
  });
}
