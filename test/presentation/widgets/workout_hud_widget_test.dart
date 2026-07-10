import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_bike/core/application/services/workout_engine.dart';
import 'package:open_bike/core/domain/entities/workout.dart';
import 'package:open_bike/core/domain/entities/workout_step.dart';
import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/workout_hud_widget.dart';

class MockTrainerPort extends Mock implements TrainerPort {}

final _workout = Workout(
  id: 'w1',
  name: 'Test Workout',
  steps: const [
    WorkoutStep(
      type: StepType.steadyState,
      durationSeconds: 60,
      powerTargetPercent: 100,
    ),
    WorkoutStep(
      type: StepType.steadyState,
      durationSeconds: 30,
      powerTargetPercent: 150,
    ),
  ],
);

WorkoutProgress _progress({
  int stepIndex = 0,
  Duration elapsedInStep = const Duration(seconds: 15),
  Watts targetPower = const Watts(200),
}) {
  return WorkoutProgress(
    currentStepIndex: stepIndex,
    currentStep: _workout.steps[stepIndex],
    elapsedInStep: elapsedInStep,
    stepDuration: Duration(seconds: _workout.steps[stepIndex].durationSeconds),
    totalSteps: _workout.steps.length,
    targetPower: targetPower,
    totalElapsed: elapsedInStep,
    totalDuration: _workout.totalDuration,
  );
}

Widget _wrap(Widget child, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const Watts(0));
  });

  testWidgets('shows nothing when there is no current workout', (tester) async {
    await tester.pumpWidget(_wrap(const WorkoutHudWidget(), [
      currentWorkoutProvider.overrideWith((ref) => null),
    ]));
    await tester.pump();

    expect(find.byType(WorkoutHudWidget), findsOneWidget);
    expect(find.text('STEADY STATE'), findsNothing);
  });

  testWidgets('shows target power and step info from a fake WorkoutProgress',
      (tester) async {
    final progress = _progress(targetPower: const Watts(200));

    await tester.pumpWidget(_wrap(const WorkoutHudWidget(), [
      currentWorkoutProvider.overrideWith((ref) => _workout),
      workoutProgressProvider.overrideWith((ref) => Stream.value(progress)),
      ftpProvider.overrideWithValue(const Watts(200)),
    ]));
    await tester.pump();

    expect(find.text('STEADY STATE'), findsOneWidget);
    expect(find.textContaining('200 W'), findsOneWidget);
    expect(find.textContaining('100% FTP'), findsOneWidget);
    expect(find.textContaining('Next:'), findsOneWidget);
  });

  testWidgets('skip button advances the workout to the next step',
      (tester) async {
    final eventBus = EventBus();
    addTearDown(eventBus.dispose);
    final trainer = MockTrainerPort();
    when(() => trainer.setTargetPower(any())).thenAnswer((_) async {});

    final engine = WorkoutEngine(trainerPort: trainer, eventBus: eventBus);
    engine.start(_workout, const Watts(200));

    await tester.pumpWidget(_wrap(const WorkoutHudWidget(), [
      currentWorkoutProvider.overrideWith((ref) => _workout),
      workoutEngineProvider.overrideWithValue(engine),
      workoutProgressProvider.overrideWith((ref) => engine.progressStream),
      ftpProvider.overrideWithValue(const Watts(200)),
    ]));
    // The engine only emits its first WorkoutProgress on the 1 Hz tick, so
    // the HUD stays in its loading (empty) state until then.
    await tester.pump(const Duration(seconds: 1));

    expect(engine.currentStepIndex, 0);

    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pump();

    expect(engine.currentStepIndex, 1);

    // Cancel the engine's periodic timer before the test ends — flutter_test
    // fails the test if a Timer is still pending when it completes, and
    // addTearDown callbacks run after that check.
    engine.dispose();
  });

  testWidgets('ERG compliance badge color changes with live power',
      (tester) async {
    final progress = _progress(targetPower: const Watts(200));

    final container = ProviderContainer(overrides: [
      currentWorkoutProvider.overrideWith((ref) => _workout),
      workoutProgressProvider.overrideWith((ref) => Stream.value(progress)),
      ftpProvider.overrideWithValue(const Watts(200)),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: WorkoutHudWidget())),
      ),
    );
    await tester.pump();

    // Setting state directly bypasses the ring buffer's ~1 Hz add()
    // throttle, so each assertion below reflects its own value.

    // On target (200 W avg vs 200 W target) → "ON".
    container.read(powerHistoryProvider.notifier).state = [200, 200, 200];
    await tester.pump();
    expect(find.text('ON'), findsOneWidget);

    // Well under target → "UNDER".
    container.read(powerHistoryProvider.notifier).state = [100, 100, 100];
    await tester.pump();
    expect(find.text('UNDER'), findsOneWidget);

    // Well over target → "OVER".
    container.read(powerHistoryProvider.notifier).state = [300, 300, 300];
    await tester.pump();
    expect(find.text('OVER'), findsOneWidget);
  });
}
