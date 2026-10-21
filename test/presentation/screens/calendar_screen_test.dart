import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/presentation/screens/calendar_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';

class MockTrainerPort extends Mock implements TrainerPort {}

Workout _testWorkout({String id = 'w-1'}) => Workout(
      id: id,
      name: 'Sweet Spot 3x12',
      steps: const [
        WorkoutStep(
          type: StepType.steadyState,
          durationSeconds: 720,
          powerTargetPercent: 90,
        ),
      ],
    );

Widget _wrap(DriftStorage storage, {List<Override> extraOverrides = const []}) {
  final router = GoRouter(
    initialLocation: '/calendar',
    routes: [
      GoRoute(
        path: '/calendar',
        builder: (_, __) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/ride',
        builder: (_, __) => const Scaffold(body: Text('ride screen')),
      ),
      GoRoute(
        path: '/history/:id',
        builder: (_, __) => const Scaffold(body: Text('ride detail')),
      ),
      GoRoute(
        path: '/scan',
        builder: (_, __) => const Scaffold(body: Text('scan screen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      storageProvider.overrideWithValue(storage),
      ...extraOverrides,
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late AppDatabase db;
  late DriftStorage storage;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    storage = DriftStorage(db);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('scheduling a workout from the library shows it in the day list',
      (tester) async {
    final workout = _testWorkout();
    await storage.saveWorkout(workout);

    await tester.pumpWidget(_wrap(
      storage,
      extraOverrides: [
        workoutListProvider.overrideWith((ref) => [workout]),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Nothing scheduled.\nTap + to plan a workout.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('scheduleWorkoutFab')));
    await tester.pumpAndSettle();

    expect(find.text('Sweet Spot 3x12'), findsOneWidget);
    await tester.tap(find.text('Sweet Spot 3x12'));
    await tester.pumpAndSettle();

    expect(find.text('Sweet Spot 3x12'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    final scheduled = await storage.getScheduledWorkouts();
    expect(scheduled, hasLength(1));
    expect(scheduled.single.workoutId, workout.id);
  });

  testWidgets('a completed scheduled workout shows a check mark instead of Start',
      (tester) async {
    final workout = _testWorkout();
    await storage.saveWorkout(workout);
    await storage.saveRide(Ride(
      id: 'ride-1',
      startTime: DateTime.now(),
      status: RideStatus.finished,
    ));
    final today = DateTime.now();
    await storage.saveScheduledWorkout(ScheduledWorkout(
      id: 'sched-1',
      workoutId: workout.id,
      date: DateTime(today.year, today.month, today.day),
    ));
    await storage.linkCompletedRide('sched-1', 'ride-1');

    await tester.pumpWidget(_wrap(
      storage,
      extraOverrides: [
        workoutListProvider.overrideWith((ref) => [workout]),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Start'), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('deleting a scheduled workout removes it from the day list',
      (tester) async {
    final workout = _testWorkout();
    await storage.saveWorkout(workout);
    final today = DateTime.now();
    await storage.saveScheduledWorkout(ScheduledWorkout(
      id: 'sched-1',
      workoutId: workout.id,
      date: DateTime(today.year, today.month, today.day),
    ));

    await tester.pumpWidget(_wrap(
      storage,
      extraOverrides: [
        workoutListProvider.overrideWith((ref) => [workout]),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Sweet Spot 3x12'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Nothing scheduled.\nTap + to plan a workout.'), findsOneWidget);
    expect(await storage.getScheduledWorkouts(), isEmpty);
  });

  group('starting a scheduled workout', () {
    Future<void> scheduleToday(Workout workout) async {
      await storage.saveWorkout(workout);
      final today = DateTime.now();
      await storage.saveScheduledWorkout(ScheduledWorkout(
        id: 'sched-1',
        workoutId: workout.id,
        date: DateTime(today.year, today.month, today.day),
      ));
    }

    testWidgets('without a trainer asks to connect one instead of riding',
        (tester) async {
      final workout = _testWorkout();
      await scheduleToday(workout);

      await tester.pumpWidget(_wrap(
        storage,
        extraOverrides: [
          workoutListProvider.overrideWith((ref) => [workout]),
        ],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(find.text('Connect a trainer'), findsOneWidget);
      expect(find.text('ride screen'), findsNothing);

      await tester.tap(find.text('Connect Device'));
      await tester.pumpAndSettle();

      expect(find.text('scan screen'), findsOneWidget);
    });

    testWidgets('with a trainer goes straight to the ride', (tester) async {
      final workout = _testWorkout();
      await scheduleToday(workout);

      await tester.pumpWidget(_wrap(
        storage,
        extraOverrides: [
          workoutListProvider.overrideWith((ref) => [workout]),
          activeTrainerPortProvider.overrideWith((ref) => MockTrainerPort()),
        ],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(find.text('Connect a trainer'), findsNothing);
      expect(find.text('ride screen'), findsOneWidget);
    });
  });
}
