import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/bundled_workouts.dart';
import 'package:open_bike/core/application/services/workout_builder.dart';
import 'package:open_bike/core/domain/entities/workout_step.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';

void main() {
  late AppDatabase db;
  late DriftStorage storage;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    storage = DriftStorage(db);
  });

  tearDown(() async => db.close());

  group('BundledWorkouts', () {
    test('defines between 10 and 15 workouts including both FTP tests', () {
      expect(BundledWorkouts.all.length, inInclusiveRange(10, 15));
      expect(BundledWorkouts.all.map((w) => w.id),
          contains(BundledWorkouts.rampTestId));
      expect(BundledWorkouts.all.map((w) => w.id),
          contains(BundledWorkouts.twentyMinTestId));
    });

    test('every bundled workout has a unique id and at least one step', () {
      final ids = BundledWorkouts.all.map((w) => w.id).toSet();
      expect(ids.length, BundledWorkouts.all.length);
      for (final w in BundledWorkouts.all) {
        expect(w.steps, isNotEmpty, reason: '${w.name} has no steps');
      }
    });

    test('seedIfNeeded on a fresh install stores every bundled workout',
        () async {
      await BundledWorkouts.seedIfNeeded(storage);

      final stored = await storage.getWorkouts();
      expect(stored.map((w) => w.id).toSet(),
          BundledWorkouts.all.map((w) => w.id).toSet());
    });

    test('re-running seedIfNeeded does not duplicate workouts', () async {
      await BundledWorkouts.seedIfNeeded(storage);
      await BundledWorkouts.seedIfNeeded(storage);

      final stored = await storage.getWorkouts();
      expect(stored.length, BundledWorkouts.all.length);
    });

    test('the ramp test climbs every minute, then cools down', () {
      final steps = BundledWorkouts.rampTest.steps;
      expect(steps.last.type, StepType.cooldown);
      final ramp = steps.take(steps.length - 1);
      expect(ramp.map((s) => s.type).toSet(), {StepType.steadyState});
      expect(ramp.map((s) => s.powerTargetPercent),
          [for (var i = 0; i < 25; i++) 50.0 + i * 10]);
    });

    test('seedIfNeeded gives an unedited ramp test its cooldown', () async {
      // The ramp test as earlier builds seeded it.
      var builder = WorkoutBuilder(
        'Ramp Test',
        description:
            'Steps up every minute until you can no longer hold cadence.',
      );
      for (var i = 0; i < 25; i++) {
        builder = builder.steady(duration: 60, percent: 50 + i * 10);
      }
      await storage.saveWorkout(
          builder.build().copyWith(id: BundledWorkouts.rampTestId));

      await BundledWorkouts.seedIfNeeded(storage);

      final ramp = (await storage.getWorkouts())
          .firstWhere((w) => w.id == BundledWorkouts.rampTestId);
      expect(ramp.steps, BundledWorkouts.rampTest.steps);
    });

    test('re-running seedIfNeeded preserves a user edit to a bundled workout',
        () async {
      await BundledWorkouts.seedIfNeeded(storage);

      final edited = (await storage.getWorkouts())
          .firstWhere((w) => w.id == BundledWorkouts.rampTestId)
          .copyWith(name: 'My custom ramp test');
      await storage.saveWorkout(edited);

      await BundledWorkouts.seedIfNeeded(storage);

      final stored = await storage.getWorkouts();
      final ramp = stored.firstWhere((w) => w.id == BundledWorkouts.rampTestId);
      expect(ramp.name, 'My custom ramp test');
    });
  });
}
