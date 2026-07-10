import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/bundled_workouts.dart';
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
