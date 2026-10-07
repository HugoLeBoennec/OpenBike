import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/application/services/route_simulator.dart';
import 'package:open_bike/core/application/services/trainer_mode_controller.dart';
import 'package:open_bike/core/application/services/workout_engine.dart';
import 'package:open_bike/core/domain/entities/trainer_device.dart';
import 'package:open_bike/core/domain/entities/workout.dart';
import 'package:open_bike/core/domain/entities/workout_step.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/ble/ftms/ftms_control_client.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/manual_trainer_controls.dart';

/// Records every [switchMode] call so tests can assert on the exact
/// mode/watts/resistance passed by the widget, in addition to the resulting
/// [TrainerModeController.state].
class RecordingTrainerModeController extends TrainerModeController {
  RecordingTrainerModeController({required super.eventBus});

  final calls = <({ControlMode mode, Watts? power, double? resistance})>[];

  @override
  Future<void> switchMode(
    ControlMode mode, {
    Watts? power,
    Grade? grade,
    double? resistance,
  }) {
    calls.add((mode: mode, power: power, resistance: resistance));
    return super.switchMode(mode, power: power, grade: grade, resistance: resistance);
  }
}

Future<AppPreferences> _fakePrefs() async {
  SharedPreferences.setMockInitialValues({});
  return AppPreferences(await SharedPreferences.getInstance());
}

Widget _wrap(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(home: Scaffold(body: ManualTrainerControls())),
  );
}

void main() {
  late EventBus eventBus;
  late RecordingTrainerModeController controller;
  late AppPreferences prefs;

  setUp(() async {
    eventBus = EventBus();
    controller = RecordingTrainerModeController(eventBus: eventBus);
    prefs = await _fakePrefs();
  });

  tearDown(() {
    // Not disposing `controller` here: ProviderScope already disposed it
    // when the widget tree was torn down (StateNotifierProvider owns and
    // disposes any notifier handed to it via overrideWith).
    eventBus.dispose();
  });

  List<Override> baseOverrides({
    Workout? workout,
    WorkoutEngineState workoutState = WorkoutEngineState.running,
    SimulationState? simState,
    WorkoutProgress? progress,
  }) =>
      [
        appPreferencesProvider.overrideWithValue(prefs),
        trainerModeControllerProvider.overrideWith((ref) => controller),
        currentWorkoutProvider.overrideWith((ref) => workout),
        workoutEngineStateProvider
            .overrideWith((ref) => Stream.value(workoutState)),
        simulationStateProvider
            .overrideWith((ref) => Stream.value(simState ?? SimulationState.idle)),
        if (progress != null)
          workoutProgressProvider.overrideWith((ref) => Stream.value(progress)),
      ];

  group('free ride (no workout, no route)', () {
    testWidgets('shows the ERG/Resistance mode toggle', (tester) async {
      await tester.pumpWidget(_wrap(baseOverrides()));
      await tester.pump();

      expect(find.text('ERG'), findsOneWidget);
      expect(find.text('Resistance'), findsOneWidget);
    });

    testWidgets('tapping ERG fires switchMode with the current ERG watts',
        (tester) async {
      await tester.pumpWidget(_wrap([
        ...baseOverrides(),
        ergTargetWattsProvider.overrideWith((ref) => 180.0),
      ]));
      await tester.pump();

      await tester.tap(find.text('ERG'));
      await tester.pump();

      expect(controller.calls, isNotEmpty);
      final call = controller.calls.last;
      expect(call.mode, ControlMode.erg);
      expect(call.power, const Watts(180));
      expect(controller.state.mode, ControlMode.erg);
    });

    testWidgets('adjusting the ERG stepper fires switchMode with the new watts',
        (tester) async {
      await tester.pumpWidget(_wrap([
        ...baseOverrides(),
        ergTargetWattsProvider.overrideWith((ref) => 200.0),
      ]));
      await tester.pump();

      // Switch into ERG mode first (stepper only renders in ERG mode).
      await tester.tap(find.text('ERG'));
      await tester.pump();
      controller.calls.clear();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(controller.calls, isNotEmpty);
      final call = controller.calls.last;
      expect(call.mode, ControlMode.erg);
      expect(call.power, isNotNull);
      expect(call.power!.value, greaterThan(200));
    });

    testWidgets('tapping Resistance fires switchMode with the current level',
        (tester) async {
      await tester.pumpWidget(_wrap([
        ...baseOverrides(),
        resistanceLevelProvider.overrideWith((ref) => 6.0),
      ]));
      await tester.pump();

      await tester.tap(find.text('Resistance'));
      await tester.pump();

      final call = controller.calls.last;
      expect(call.mode, ControlMode.resistance);
      expect(call.resistance, 6.0);
    });

    testWidgets(
        'ERG stepper clamps to a fake capability set (0-800W, 5W steps)',
        (tester) async {
      await tester.pumpWidget(_wrap([
        ...baseOverrides(),
        ergTargetWattsProvider.overrideWith((ref) => 798.0),
        ergPowerRangeProvider.overrideWithValue(
          const PowerRange(minWatts: 0, maxWatts: 800, incrementWatts: 5),
        ),
      ]));
      await tester.pump();

      await tester.tap(find.text('ERG'));
      await tester.pump();
      controller.calls.clear();

      // 798 + 5 = 803, clamped down to the reported max of 800 W.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      final call = controller.calls.last;
      expect(call.power!.value, 800);
    });

    testWidgets(
        'Resistance slider clamps to a fake capability set (0-10, step 0.5)',
        (tester) async {
      await tester.pumpWidget(_wrap([
        ...baseOverrides(),
        resistanceLevelProvider.overrideWith((ref) => 9.8),
        resistanceRangeProvider.overrideWithValue(
          const ResistanceLevelRange(min: 0, max: 10, increment: 0.5),
        ),
      ]));
      await tester.pump();

      await tester.tap(find.text('Resistance'));
      await tester.pump();
      controller.calls.clear();

      // 9.8 + 0.5 = 10.3, clamped down to the reported max of 10.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      final call = controller.calls.last;
      expect(call.resistance, 10.0);
    });
  });

  group('structured workout active', () {
    testWidgets('controls hidden while a workout step is running',
        (tester) async {
      final workout = Workout(id: 'w1', name: 'W', steps: const [
        WorkoutStep(
          type: StepType.steadyState,
          durationSeconds: 60,
          powerTargetPercent: 100,
        ),
      ]);

      await tester.pumpWidget(_wrap(baseOverrides(
        workout: workout,
        workoutState: WorkoutEngineState.running,
      )));
      await tester.pump();

      // Mode toggle / ERG stepper / resistance slider must not render —
      // only the status banner (which never renders the bare "ERG" label,
      // always "ERG · <watts> W").
      expect(find.text('ERG'), findsNothing);
      expect(find.text('Resistance'), findsNothing);
      expect(find.byType(Slider), findsNothing);
      expect(find.textContaining('·'), findsOneWidget);
    });

    testWidgets('ERG banner shows the workout target, not the manual value',
        (tester) async {
      const step = WorkoutStep(
        type: StepType.steadyState,
        durationSeconds: 60,
        powerTargetPercent: 100,
      );
      final workout = Workout(id: 'w1', name: 'W', steps: const [step]);
      await controller.switchMode(ControlMode.erg, power: const Watts(150));

      await tester.pumpWidget(_wrap([
        ...baseOverrides(
          workout: workout,
          workoutState: WorkoutEngineState.running,
          progress: const WorkoutProgress(
            currentStepIndex: 0,
            currentStep: step,
            elapsedInStep: Duration(seconds: 10),
            stepDuration: Duration(seconds: 60),
            totalSteps: 1,
            targetPower: Watts(226),
            totalElapsed: Duration(seconds: 10),
            totalDuration: Duration(seconds: 60),
          ),
        ),
        ergTargetWattsProvider.overrideWith((ref) => 150.0),
      ]));
      await tester.pump();

      expect(find.text('ERG · 226 W'), findsOneWidget);
      expect(find.text('ERG · 150 W'), findsNothing);
    });

    testWidgets('controls reappear as an override while the workout is paused',
        (tester) async {
      final workout = Workout(id: 'w1', name: 'W', steps: const [
        WorkoutStep(
          type: StepType.steadyState,
          durationSeconds: 60,
          powerTargetPercent: 100,
        ),
      ]);

      await tester.pumpWidget(_wrap(baseOverrides(
        workout: workout,
        workoutState: WorkoutEngineState.paused,
      )));
      await tester.pump();

      expect(find.text('ERG'), findsOneWidget);
      expect(find.text('Resistance'), findsOneWidget);
    });
  });

  group('GPX route active', () {
    testWidgets('shows only the difficulty slider, not ERG/Resistance controls',
        (tester) async {
      await tester.pumpWidget(_wrap(baseOverrides(
        simState: SimulationState.running,
      )));
      await tester.pump();

      expect(find.text('ERG'), findsNothing);
      expect(find.text('Resistance'), findsNothing);
      expect(find.byIcon(Icons.terrain), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });
  });
}
