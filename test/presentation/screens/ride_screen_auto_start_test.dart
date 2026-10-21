import 'package:flutter/material.dart' hide Route;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/application/services/background_recording_service.dart';
import 'package:open_bike/core/application/services/bundled_workouts.dart';
import 'package:open_bike/core/application/services/recording_engine.dart';
import 'package:open_bike/core/application/services/route_simulator.dart';
import 'package:open_bike/core/application/services/trainer_mode_controller.dart';
import 'package:open_bike/core/application/services/workout_engine.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/models/ride_extra.dart';
import 'package:open_bike/presentation/screens/ride_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/live_chart.dart';
import 'package:open_bike/presentation/widgets/route_profile_pane.dart';

class _MockRecordingEngine extends Mock implements RecordingEngine {}

class _MockWorkoutEngine extends Mock implements WorkoutEngine {}

class _MockRouteSimulator extends Mock implements RouteSimulator {}

class _MockBackgroundService extends Mock implements BackgroundRecordingService {}

class _FakeWorkout extends Fake implements Workout {}

class _FakeRoute extends Fake implements Route {}

void main() {
  late _MockRecordingEngine recorder;
  late _MockWorkoutEngine workoutEngine;
  late _MockRouteSimulator simulator;

  setUpAll(() {
    registerFallbackValue(_FakeWorkout());
    registerFallbackValue(_FakeRoute());
    registerFallbackValue(Watts.zero);
  });

  setUp(() {
    recorder = _MockRecordingEngine();
    workoutEngine = _MockWorkoutEngine();
    simulator = _MockRouteSimulator();
    when(() => recorder.state).thenReturn(RecordingState.idle);
    when(() => recorder.start()).thenAnswer(
      (_) async => Ride(id: 'r', startTime: DateTime(2026), status: RideStatus.active),
    );
    when(() => workoutEngine.state).thenReturn(WorkoutEngineState.idle);
    when(() => simulator.state).thenReturn(SimulationState.idle);
  });

  Future<void> pumpRideScreen(WidgetTester tester, RideExtra? extra) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = AppPreferences(await SharedPreferences.getInstance());

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(prefs),
        recordingEngineProvider.overrideWithValue(recorder),
        workoutEngineProvider.overrideWithValue(workoutEngine),
        routeSimulatorProvider.overrideWithValue(simulator),
        recordingStateProvider
            .overrideWith((ref) => Stream.value(RecordingState.idle)),
        workoutEngineStateProvider
            .overrideWith((ref) => Stream.value(WorkoutEngineState.running)),
        workoutProgressProvider.overrideWith((ref) => const Stream.empty()),
        simulationStateProvider
            .overrideWith((ref) => Stream.value(SimulationState.idle)),
        roleConnectionProvider.overrideWithValue(const {}),
        trainerModeControllerProvider
            .overrideWith((ref) => TrainerModeController(eventBus: EventBus())),
        rideElapsedProvider.overrideWith((ref) => Stream.value(Duration.zero)),
        currentRideProvider.overrideWith((ref) => Stream.value(null)),
        liveSensorBridgeProvider.overrideWith((ref) {}),
        powerHistoryUpdaterProvider.overrideWith((ref) {}),
        hrHistoryUpdaterProvider.overrideWith((ref) {}),
        scheduledWorkoutLinkerProvider.overrideWith((ref) {}),
        autoUploadProvider.overrideWith((ref) {}),
        backgroundRecordingServiceProvider
            .overrideWithValue(_MockBackgroundService()),
      ],
      child: MaterialApp(home: RideScreen(extra: extra)),
    ));
    await tester.pump();
  }

  testWidgets('starting a workout starts the recording with it',
      (tester) async {
    final workout = BundledWorkouts.all.first;
    await pumpRideScreen(tester, RideExtra(workout: workout));

    verify(() => workoutEngine.start(workout, any())).called(1);
    verify(() => recorder.start()).called(1);
  });

  testWidgets('starting a route simulation starts the recording with it',
      (tester) async {
    const route = Route(id: 'route-1', name: 'Alpe', points: []);
    await pumpRideScreen(tester, const RideExtra(route: route));

    verify(() => simulator.start(route)).called(1);
    verify(() => recorder.start()).called(1);
  });

  testWidgets('a route ride shows the live chart under the elevation profile',
      (tester) async {
    const route = Route(id: 'route-1', name: 'Alpe', points: []);
    await pumpRideScreen(tester, const RideExtra(route: route));

    expect(find.byType(RouteProfilePane), findsOneWidget);
    expect(find.byType(LiveChart), findsOneWidget);
  });

  testWidgets('a free ride still waits for the play button', (tester) async {
    await pumpRideScreen(tester, null);

    verifyNever(() => recorder.start());
  });
}
