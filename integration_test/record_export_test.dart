import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/presentation/state/providers.dart';

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('connect simulator → record → stop → ride saved in storage',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );

    // Connect the simulator.
    final plugin = container.read(simulatorPluginProvider)!;
    final devices = await plugin.scan(const Duration(seconds: 1));
    final trainer = await plugin.connect(devices.first);

    // Wire data to live providers (like DevToolsScreen does).
    trainer.dataStream.listen((reading) {
      container.read(livePowerProvider.notifier).state =
          reading.power ?? const Watts(0);
      container.read(liveCadenceProvider.notifier).state =
          reading.cadence ?? const Cadence(0);
      container.read(liveHeartRateProvider.notifier).state =
          reading.heartRate ?? const HeartRate(0);
    });

    // Start recording.
    final engine = container.read(recordingEngineProvider);
    engine.start();

    // Wait for some data to accumulate.
    await tester.pump(const Duration(seconds: 5));
    await Future<void>.delayed(const Duration(seconds: 5));

    // Stop recording.
    await engine.stop();

    // Verify ride is saved in storage.
    final storage = container.read(storageProvider);
    final rides = await storage.getRides();
    expect(rides, isNotEmpty, reason: 'At least one ride should be stored');

    final ride = rides.last;
    expect(ride.status, RideStatus.finished);

    // Verify sensor readings were stored.
    final readings = await storage.getSensorReadings(ride.id);
    expect(readings, isNotEmpty,
        reason: 'Sensor readings should be stored for the ride');

    await trainer.disconnect();
  });
}
