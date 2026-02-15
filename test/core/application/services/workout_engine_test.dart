import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_bike/core/application/services/workout_engine.dart';
import 'package:open_bike/core/domain/entities/workout.dart';
import 'package:open_bike/core/domain/entities/workout_step.dart';
import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/app_event.dart';
import 'package:open_bike/core/events/event_bus.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockTrainerPort extends Mock implements TrainerPort {}

class FakeWatts extends Fake implements Watts {}

void main() {
  late EventBus eventBus;
  late MockTrainerPort trainer;
  late WorkoutEngine engine;

  // Simple 3-step workout: 2s warmup → 3s steady → 2s cooldown.
  late Workout simpleWorkout;

  // Interval workout: 2×(2s on + 1s off).
  late Workout intervalWorkout;

  // Ramp workout: 3s ramp from 50% to 100%.
  late Workout rampWorkout;

  setUpAll(() {
    registerFallbackValue(const Watts(0));
  });

  setUp(() {
    eventBus = EventBus();
    trainer = MockTrainerPort();
    engine = WorkoutEngine(trainerPort: trainer, eventBus: eventBus);

    when(() => trainer.setTargetPower(any())).thenAnswer((_) async {});

    simpleWorkout = const Workout(
      id: 'simple',
      name: 'Simple',
      steps: [
        WorkoutStep(
          type: StepType.warmup,
          durationSeconds: 2,
          powerTargetPercent: 0,
          powerLowPercent: 50,
          powerHighPercent: 75,
        ),
        WorkoutStep(
          type: StepType.steadyState,
          durationSeconds: 3,
          powerTargetPercent: 100,
        ),
        WorkoutStep(
          type: StepType.cooldown,
          durationSeconds: 2,
          powerTargetPercent: 0,
          powerLowPercent: 75,
          powerHighPercent: 50,
        ),
      ],
    );

    intervalWorkout = const Workout(
      id: 'interval',
      name: 'Intervals',
      steps: [
        WorkoutStep(
          type: StepType.interval,
          durationSeconds: 2,
          offDurationSeconds: 1,
          powerTargetPercent: 120,
          powerLowPercent: 55,
          repeat: 2,
        ),
      ],
    );

    rampWorkout = const Workout(
      id: 'ramp',
      name: 'Ramp',
      steps: [
        WorkoutStep(
          type: StepType.ramp,
          durationSeconds: 3,
          powerTargetPercent: 0,
          powerLowPercent: 50,
          powerHighPercent: 100,
        ),
      ],
    );
  });

  tearDown(() {
    engine.dispose();
    eventBus.dispose();
  });

  // =========================================================================
  // State transitions
  // =========================================================================

  group('WorkoutEngine — state transitions', () {
    test('initial state is idle', () {
      expect(engine.state, WorkoutEngineState.idle);
      expect(engine.currentWorkout, isNull);
    });

    test('start transitions to running', () {
      engine.start(simpleWorkout, const Watts(250));

      expect(engine.state, WorkoutEngineState.running);
      expect(engine.currentWorkout, isNotNull);
    });

    test('start fires WorkoutStarted event', () async {
      final events = <WorkoutEvent>[];
      eventBus.on<WorkoutEvent>().listen(events.add);

      engine.start(simpleWorkout, const Watts(250));

      await Future<void>.delayed(Duration.zero);
      expect(events, hasLength(greaterThanOrEqualTo(1)));
      expect(events.first, isA<WorkoutStarted>());
    });

    test('start fires WorkoutStepChanged for step 0', () async {
      final events = <WorkoutEvent>[];
      eventBus.on<WorkoutEvent>().listen(events.add);

      engine.start(simpleWorkout, const Watts(250));

      await Future<void>.delayed(Duration.zero);
      expect(events.whereType<WorkoutStepChanged>(), isNotEmpty);
    });

    test('pause transitions to paused', () {
      engine.start(simpleWorkout, const Watts(250));
      engine.pause();

      expect(engine.state, WorkoutEngineState.paused);
    });

    test('resume transitions back to running', () {
      engine.start(simpleWorkout, const Watts(250));
      engine.pause();
      engine.resume();

      expect(engine.state, WorkoutEngineState.running);
    });

    test('stop transitions to idle', () {
      engine.start(simpleWorkout, const Watts(250));
      engine.stop();

      expect(engine.state, WorkoutEngineState.idle);
      expect(engine.currentWorkout, isNull);
    });

    test('stateStream emits transitions', () async {
      final states = <WorkoutEngineState>[];
      engine.stateStream.listen(states.add);

      engine.start(simpleWorkout, const Watts(250));
      engine.pause();
      engine.resume();
      engine.stop();

      await Future<void>.delayed(Duration.zero);
      expect(states, [
        WorkoutEngineState.running,
        WorkoutEngineState.paused,
        WorkoutEngineState.running,
        WorkoutEngineState.idle,
      ]);
    });
  });

  // =========================================================================
  // Guard clauses
  // =========================================================================

  group('WorkoutEngine — invalid transitions', () {
    test('start when running throws', () {
      engine.start(simpleWorkout, const Watts(250));
      expect(() => engine.start(simpleWorkout, const Watts(250)),
          throwsStateError);
    });

    test('pause when idle throws', () {
      expect(() => engine.pause(), throwsStateError);
    });

    test('resume when idle throws', () {
      expect(() => engine.resume(), throwsStateError);
    });

    test('resume when running throws', () {
      engine.start(simpleWorkout, const Watts(250));
      expect(() => engine.resume(), throwsStateError);
    });

    test('stop when idle throws', () {
      expect(() => engine.stop(), throwsStateError);
    });

    test('skip when idle throws', () {
      expect(() => engine.skip(), throwsStateError);
    });
  });

  // =========================================================================
  // Power computation — steady state
  // =========================================================================

  group('WorkoutEngine — steady state power', () {
    test('sends correct power for steady state step', () {
      engine.start(simpleWorkout, const Watts(250));

      // Skip warmup to reach steady state (step 1: 100% of 250W).
      engine.skip();

      // Verify setTargetPower was called with 250W (100% of 250).
      final captured = verify(() => trainer.setTargetPower(captureAny()))
          .captured;
      // The last call should be for the steady state step.
      final lastCall = captured.last as Watts;
      expect(lastCall.value, closeTo(250, 1));
    });
  });

  // =========================================================================
  // Power computation — ramp interpolation
  // =========================================================================

  group('WorkoutEngine — ramp interpolation', () {
    test('ramp starts at low power', () {
      engine.start(rampWorkout, const Watts(200));

      // At t=0, should be at powerLow = 50% of 200 = 100W.
      expect(engine.targetPower.value, closeTo(100, 1));
    });

    test('warmup ramp starts at low power', () {
      engine.start(simpleWorkout, const Watts(200));

      // Warmup: 50% → 75% of 200W. At t=0, should be at 100W.
      expect(engine.targetPower.value, closeTo(100, 1));
    });
  });

  // =========================================================================
  // Interval phases
  // =========================================================================

  group('WorkoutEngine — intervals', () {
    test('starts in on-phase with on-power', () {
      engine.start(intervalWorkout, const Watts(200));

      // 120% of 200W = 240W for on-phase.
      expect(engine.targetPower.value, closeTo(240, 1));
    });

    test('interval total duration = 2 × (2 + 1) = 6s', () {
      final step = intervalWorkout.steps.first;
      expect(step.totalDurationSeconds, 6);
      expect(intervalWorkout.totalDuration, const Duration(seconds: 6));
    });

    test('completes after all repeats', () async {
      final states = <WorkoutEngineState>[];
      engine.stateStream.listen(states.add);

      engine.start(intervalWorkout, const Watts(200));

      // Total: 2 repeats × (2s on + 1s off) = 6 seconds.
      await Future<void>.delayed(const Duration(milliseconds: 7500));

      expect(states.last, WorkoutEngineState.completed);
    });
  });

  // =========================================================================
  // Skip
  // =========================================================================

  group('WorkoutEngine — skip', () {
    test('skip advances to next step', () async {
      final events = <WorkoutEvent>[];
      eventBus.on<WorkoutEvent>().listen(events.add);

      engine.start(simpleWorkout, const Watts(250));
      engine.skip(); // skip warmup → steady state

      await Future<void>.delayed(Duration.zero);
      final stepChanges = events.whereType<WorkoutStepChanged>().toList();
      expect(stepChanges.length, greaterThanOrEqualTo(2));
      expect(stepChanges.last.index, 1); // steady state index
    });

    test('skip on last step completes workout', () async {
      engine.start(simpleWorkout, const Watts(250));
      engine.skip(); // → steady
      engine.skip(); // → cooldown
      engine.skip(); // → completed

      await Future<void>.delayed(Duration.zero);
      expect(engine.state, WorkoutEngineState.completed);
    });

    test('skip while paused works', () {
      engine.start(simpleWorkout, const Watts(250));
      engine.pause();
      engine.skip(); // should not throw

      expect(engine.currentStepIndex, 1);
    });
  });

  // =========================================================================
  // Workout completion
  // =========================================================================

  group('WorkoutEngine — completion', () {
    test('completes after all steps finish', () async {
      // Simple workout: 2 + 3 + 2 = 7 seconds total.
      engine.start(simpleWorkout, const Watts(250));

      await Future<void>.delayed(const Duration(milliseconds: 8500));

      expect(engine.state, WorkoutEngineState.completed);
    });

    test('fires WorkoutCompleted event', () async {
      final events = <WorkoutEvent>[];
      eventBus.on<WorkoutEvent>().listen(events.add);

      engine.start(simpleWorkout, const Watts(250));

      await Future<void>.delayed(const Duration(milliseconds: 8500));

      expect(events.whereType<WorkoutCompleted>(), isNotEmpty);
    });
  });

  // =========================================================================
  // Progress stream
  // =========================================================================

  group('WorkoutEngine — progress', () {
    test('emits progress at 1 Hz', () async {
      final progresses = <WorkoutProgress>[];
      engine.progressStream.listen(progresses.add);

      engine.start(simpleWorkout, const Watts(250));

      await Future<void>.delayed(const Duration(milliseconds: 3500));
      engine.stop();

      // Should have ~3 progress ticks.
      expect(progresses.length, greaterThanOrEqualTo(2));
    });

    test('progress contains step info', () async {
      final progresses = <WorkoutProgress>[];
      engine.progressStream.listen(progresses.add);

      engine.start(simpleWorkout, const Watts(250));

      await Future<void>.delayed(const Duration(milliseconds: 1500));
      engine.stop();

      if (progresses.isNotEmpty) {
        final p = progresses.first;
        expect(p.currentStepIndex, 0);
        expect(p.currentStep.type, StepType.warmup);
        expect(p.totalSteps, 3);
        expect(p.targetPower.value, greaterThan(0));
        expect(p.totalDuration, simpleWorkout.totalDuration);
      }
    });

    test('does not emit during pause', () async {
      final progresses = <WorkoutProgress>[];
      engine.progressStream.listen(progresses.add);

      engine.start(simpleWorkout, const Watts(250));
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      final countBeforePause = progresses.length;

      engine.pause();
      await Future<void>.delayed(const Duration(milliseconds: 2200));
      final countDuringPause = progresses.length;

      expect(countDuringPause, countBeforePause);
    });
  });

  // =========================================================================
  // FreeRide
  // =========================================================================

  group('WorkoutEngine — free ride', () {
    test('free ride sets zero target power', () {
      const freeWorkout = Workout(
        id: 'free',
        name: 'Free',
        steps: [
          WorkoutStep(
            type: StepType.freeRide,
            durationSeconds: 5,
            powerTargetPercent: 0,
          ),
        ],
      );

      engine.start(freeWorkout, const Watts(250));

      expect(engine.targetPower, Watts.zero);
      // Should NOT call setTargetPower for free ride.
      verifyNever(() => trainer.setTargetPower(any()));
    });
  });

  // =========================================================================
  // Trainer interaction
  // =========================================================================

  group('WorkoutEngine — trainer integration', () {
    test('setTargetPower called on start', () {
      engine.start(simpleWorkout, const Watts(250));

      verify(() => trainer.setTargetPower(any())).called(greaterThanOrEqualTo(1));
    });

    test('setTargetPower called on each tick', () async {
      engine.start(simpleWorkout, const Watts(250));

      await Future<void>.delayed(const Duration(milliseconds: 3500));
      engine.stop();

      // At least initial call + 3 tick calls.
      verify(() => trainer.setTargetPower(any()))
          .called(greaterThanOrEqualTo(3));
    });
  });
}
