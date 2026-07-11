import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_bike/core/application/services/trainer_mode_controller.dart';
import 'package:open_bike/core/application/services/workout_engine.dart';
import 'package:open_bike/core/domain/entities/route.dart' as domain;
import 'package:open_bike/core/domain/entities/trainer_device.dart';
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

class FakeGrade extends Fake implements Grade {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

WorkoutStep _step(StepType type, {double powerPct = 100}) => WorkoutStep(
      type: type,
      durationSeconds: 60,
      powerTargetPercent: powerPct,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late EventBus eventBus;
  late MockTrainerPort trainerPort;
  late TrainerModeController controller;

  setUpAll(() {
    registerFallbackValue(FakeWatts());
    registerFallbackValue(FakeGrade());
  });

  setUp(() {
    eventBus = EventBus();
    trainerPort = MockTrainerPort();

    when(() => trainerPort.setTargetPower(any())).thenAnswer((_) async {});
    when(() => trainerPort.setResistance(any())).thenAnswer((_) async {});
    when(() => trainerPort.setSimulationParams(any(), any(), any(), any()))
        .thenAnswer((_) async {});

    controller = TrainerModeController(
      eventBus: eventBus,
      getDefaultResistance: () => 3.0,
    );
    controller.setTrainerPort(trainerPort);
  });

  tearDown(() {
    controller.dispose();
    eventBus.dispose();
  });

  // -------------------------------------------------------------------------
  // Initial state
  // -------------------------------------------------------------------------

  test('initial mode is resistance', () {
    expect(controller.state.mode, ControlMode.resistance);
  });

  // -------------------------------------------------------------------------
  // Workout step events → mode selection
  // -------------------------------------------------------------------------

  group('WorkoutEvent.stepChanged', () {
    Future<void> fireStep(WorkoutStep step) async {
      eventBus.fire(WorkoutEvent.stepChanged(step, 0));
      // Allow microtask queue to process the stream listener.
      await Future<void>.delayed(Duration.zero);
    }

    test('steadyState step → ERG mode', () async {
      await fireStep(_step(StepType.steadyState));
      expect(controller.state.mode, ControlMode.erg);
    });

    test('interval step → ERG mode', () async {
      await fireStep(_step(StepType.interval));
      expect(controller.state.mode, ControlMode.erg);
    });

    test('warmup step → ERG mode', () async {
      await fireStep(_step(StepType.warmup));
      expect(controller.state.mode, ControlMode.erg);
    });

    test('cooldown step → ERG mode', () async {
      await fireStep(_step(StepType.cooldown));
      expect(controller.state.mode, ControlMode.erg);
    });

    test('ramp step → ERG mode', () async {
      await fireStep(_step(StepType.ramp));
      expect(controller.state.mode, ControlMode.erg);
    });

    test('freeRide step → resistance mode (level 3)', () async {
      await fireStep(_step(StepType.freeRide, powerPct: 0));

      expect(controller.state.mode, ControlMode.resistance);
      expect(controller.state.resistanceLevel, 3.0);
      verify(() => trainerPort.setResistance(3.0)).called(1);
    });

    test('freeRide step → no ERG command sent', () async {
      await fireStep(_step(StepType.freeRide, powerPct: 0));
      verifyNever(() => trainerPort.setTargetPower(any()));
    });

    test('ERG step change sends no direct setTargetPower from the controller',
        () async {
      // The controller only calls setTargetPower when an explicit `power` is
      // passed to switchMode (manual UI override) — step-driven ERG mode
      // switches never pass one, since WorkoutEngine owns per-tick power
      // writes. This is what prevents duplicate control writes when a
      // workout is running.
      await fireStep(_step(StepType.steadyState));
      await fireStep(_step(StepType.ramp));
      await fireStep(_step(StepType.interval));
      verifyNever(() => trainerPort.setTargetPower(any()));
    });
  });

  // -------------------------------------------------------------------------
  // Simulation events → SIM mode
  // -------------------------------------------------------------------------

  group('SimulationEvent', () {
    test('SimulationEvent.started (no active workout) → SIM mode', () async {
      eventBus.fire(SimulationEvent.started(
        domain.Route(id: 'r1', name: 'Test', points: []),
      ));
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.mode, ControlMode.simulation);
    });

    test('SimulationEvent.started during active workout → mode unchanged',
        () async {
      // Start a workout first so _hasActiveWorkout = true.
      eventBus.fire(WorkoutEvent.started(
        Workout(id: 'w1', name: 'W', steps: []),
      ));
      await Future<void>.delayed(Duration.zero);

      // Then fire simulation started.
      eventBus.fire(SimulationEvent.started(
        domain.Route(id: 'r1', name: 'Test', points: []),
      ));
      await Future<void>.delayed(Duration.zero);

      // Mode should stay as whatever the workout set it to (resistance by
      // default before any stepChanged), NOT switch to simulation.
      expect(controller.state.mode, isNot(ControlMode.simulation));
    });

    test('SimulationEvent.completed → returns to resistance mode', () async {
      eventBus.fire(SimulationEvent.started(
        domain.Route(id: 'r1', name: 'Test', points: []),
      ));
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.mode, ControlMode.simulation);

      eventBus.fire(const SimulationEvent.completed());
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.mode, ControlMode.resistance);
    });
  });

  // -------------------------------------------------------------------------
  // Workout lifecycle
  // -------------------------------------------------------------------------

  group('WorkoutEvent lifecycle', () {
    test('workout completed → returns to resistance mode', () async {
      eventBus.fire(WorkoutEvent.started(
        Workout(id: 'w1', name: 'W', steps: []),
      ));
      eventBus.fire(WorkoutEvent.stepChanged(_step(StepType.steadyState), 0));
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.mode, ControlMode.erg);

      eventBus.fire(const WorkoutEvent.completed());
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.mode, ControlMode.resistance);
    });

    test('workout completed with active route → switches to SIM mode',
        () async {
      // Start both a workout and a simulation.
      eventBus.fire(SimulationEvent.started(
        domain.Route(id: 'r1', name: 'Test', points: []),
      ));
      eventBus.fire(WorkoutEvent.started(
        Workout(id: 'w1', name: 'W', steps: []),
      ));
      eventBus.fire(WorkoutEvent.stepChanged(_step(StepType.steadyState), 0));
      await Future<void>.delayed(Duration.zero);

      // Workout completes — route still active, so mode should become SIM.
      eventBus.fire(const WorkoutEvent.completed());
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.mode, ControlMode.simulation);
    });
  });

  // -------------------------------------------------------------------------
  // switchMode — manual calls
  // -------------------------------------------------------------------------

  group('switchMode', () {
    test('switchMode(resistance, resistance: 5) → sends level 5 to port',
        () async {
      await controller.switchMode(ControlMode.resistance, resistance: 5.0);
      verify(() => trainerPort.setResistance(5.0)).called(1);
      expect(controller.state.resistanceLevel, 5.0);
    });

    test('switchMode(erg) without power → no setTargetPower sent', () async {
      await controller.switchMode(ControlMode.erg);
      verifyNever(() => trainerPort.setTargetPower(any()));
      expect(controller.state.mode, ControlMode.erg);
    });

    test('switchMode(erg, power: 250W) → sends power target', () async {
      await controller.switchMode(ControlMode.erg, power: const Watts(250));
      verify(() => trainerPort.setTargetPower(const Watts(250))).called(1);
    });

    test('switchMode with null port → stores state only, no throw', () async {
      controller.setTrainerPort(null);
      await expectLater(
        controller.switchMode(ControlMode.resistance, resistance: 4.0),
        completes,
      );
      expect(controller.state.mode, ControlMode.resistance);
    });
  });

  // -------------------------------------------------------------------------
  // Default resistance from callback
  // -------------------------------------------------------------------------

  test('uses getDefaultResistance callback for default mode', () async {
    double defaultResistance = 5.0;
    final c = TrainerModeController(
      eventBus: eventBus,
      getDefaultResistance: () => defaultResistance,
    );
    c.setTrainerPort(trainerPort);

    await c.switchMode(ControlMode.resistance);
    verify(() => trainerPort.setResistance(5.0)).called(1);

    // Change the callback's value and switch again.
    defaultResistance = 8.0;
    await c.switchMode(ControlMode.resistance);
    verify(() => trainerPort.setResistance(8.0)).called(1);

    c.dispose();
  });

  // -------------------------------------------------------------------------
  // No duplicate control writes when a workout drives the trainer
  // -------------------------------------------------------------------------

  group('single writer of TrainerPort control methods', () {
    test('WorkoutEngine drives setTargetPower once per step change; the '
        'controller never duplicates it', () async {
      final engine = WorkoutEngine(trainerPort: trainerPort, eventBus: eventBus);

      final workout = Workout(id: 'w1', name: 'W', steps: [
        _step(StepType.steadyState, powerPct: 60),
        _step(StepType.steadyState, powerPct: 80),
      ]);

      engine.start(workout, const Watts(200));
      await Future<void>.delayed(Duration.zero);

      // First step's target power (120 W = 60% of 200) sent exactly once —
      // by WorkoutEngine, not duplicated by the controller reacting to the
      // same WorkoutEvent.stepChanged.
      verify(() => trainerPort.setTargetPower(const Watts(120))).called(1);
      expect(controller.state.mode, ControlMode.erg);

      engine.skip();
      await Future<void>.delayed(Duration.zero);

      verify(() => trainerPort.setTargetPower(const Watts(160))).called(1);

      engine.dispose();
    });
  });
}
