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
import 'package:open_bike/presentation/models/ride_extra.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/start_ride_actions.dart';

class _MockTrainerPort extends Mock implements TrainerPort {}

const _workout = Workout(
  id: 'w-1',
  name: 'Sweet Spot 3x12',
  steps: [
    WorkoutStep(
      type: StepType.steadyState,
      durationSeconds: 720,
      powerTargetPercent: 90,
    ),
  ],
);

void main() {
  late AppDatabase db;
  late DriftStorage storage;
  RideExtra? opened;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    storage = DriftStorage(db);
    opened = null;
  });

  tearDown(() async => db.close());

  /// A library-style start: no scheduledWorkoutId passed in.
  Future<void> startFromLibrary(WidgetTester tester) async {
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Consumer(
          builder: (context, ref, _) => TextButton(
            onPressed: () => startWorkoutRide(context, ref, _workout),
            child: const Text('Start Workout'),
          ),
        ),
      ),
      GoRoute(
        path: '/ride',
        builder: (_, state) {
          opened = state.extra as RideExtra?;
          return const Text('ride screen');
        },
      ),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(storage),
        activeTrainerPortProvider.overrideWith((ref) => _MockTrainerPort()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.tap(find.text('Start Workout'));
    await tester.pumpAndSettle();
  }

  DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  testWidgets("picks up today's plan for the workout", (tester) async {
    await storage.saveScheduledWorkout(
        ScheduledWorkout(id: 'sched-1', workoutId: 'w-1', date: today()));

    await startFromLibrary(tester);

    expect(opened?.workout, _workout);
    expect(opened?.scheduledWorkoutId, 'sched-1');
  });

  testWidgets('leaves plans for other days or workouts alone', (tester) async {
    await storage.saveScheduledWorkout(ScheduledWorkout(
        id: 'tomorrow',
        workoutId: 'w-1',
        date: today().add(const Duration(days: 1))));
    await storage.saveScheduledWorkout(
        ScheduledWorkout(id: 'other', workoutId: 'w-2', date: today()));

    await startFromLibrary(tester);

    expect(opened?.workout, _workout);
    expect(opened?.scheduledWorkoutId, isNull);
  });
}
