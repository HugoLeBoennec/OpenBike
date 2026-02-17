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

  testWidgets('simulator converges to workout step targets', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    // Get container to interact with providers directly.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );

    // Connect the simulator.
    final plugin = container.read(simulatorPluginProvider)!;
    final devices = await plugin.scan(const Duration(seconds: 1));
    final trainer = await plugin.connect(devices.first);

    // Load a simple 2-step workout: 50% FTP for 10s, 100% FTP for 10s.
    final workout = Workout(
      id: 'test-workout-1',
      name: 'Test Workout',
      steps: const [
        WorkoutStep(
          type: StepType.steadyState,
          durationSeconds: 10,
          powerTargetPercent: 0.50,
        ),
        WorkoutStep(
          type: StepType.steadyState,
          durationSeconds: 10,
          powerTargetPercent: 1.00,
        ),
      ],
    );

    container.read(currentWorkoutProvider.notifier).state = workout;

    // Set the first target (100W = 50% of default 200W FTP).
    await trainer.setTargetPower(const Watts(100));

    // Wait for convergence.
    final readings1 = <SensorReading>[];
    final sub1 = trainer.dataStream.listen(readings1.add);
    await tester.pump(const Duration(seconds: 8));
    await Future<void>.delayed(const Duration(seconds: 8));
    await sub1.cancel();

    // Power should be near 100W.
    if (readings1.isNotEmpty) {
      final lastPower = readings1.last.power!.value;
      expect(lastPower, closeTo(100, 50),
          reason: 'Power should converge toward 100W');
    }

    // Set the second target (200W = 100% FTP).
    await trainer.setTargetPower(const Watts(200));

    final readings2 = <SensorReading>[];
    final sub2 = trainer.dataStream.listen(readings2.add);
    await tester.pump(const Duration(seconds: 8));
    await Future<void>.delayed(const Duration(seconds: 8));
    await sub2.cancel();

    // Power should be near 200W.
    if (readings2.isNotEmpty) {
      final lastPower = readings2.last.power!.value;
      expect(lastPower, closeTo(200, 50),
          reason: 'Power should converge toward 200W');
    }

    await trainer.disconnect();
  });
}
