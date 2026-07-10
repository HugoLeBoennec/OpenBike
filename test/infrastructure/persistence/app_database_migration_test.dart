import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/generated_migrations/schema.dart';
import 'package:open_bike/infrastructure/persistence/generated_migrations/schema_v2.dart'
    as v2;
import 'package:open_bike/infrastructure/persistence/generated_migrations/schema_v3.dart'
    as v3;

void main() {
  final verifier = SchemaVerifier(GeneratedHelper());

  test('v2 -> v3 migration is a no-op that preserves existing data', () async {
    // Start with a real v2 database and insert a row directly, bypassing the
    // current (v3) AppDatabase so we know the data pre-dates the migration.
    final schema = await verifier.schemaAt(2);
    final oldDb = v2.DatabaseAtV2(schema.newConnection());
    await oldDb.into(oldDb.rides).insert(v2.RidesCompanion.insert(
          id: 'ride-pre-migration',
          startTime: 1000,
          status: 'finished',
        ));
    await oldDb.close();

    // Open the current AppDatabase (schemaVersion 3) against the same
    // underlying data and let it run its onUpgrade migration.
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);

    // The destructive drop-and-recreate path must not have run: the row
    // inserted under v2 must still be there after migrating to v3.
    final rows = await db.select(db.rides).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'ride-pre-migration');

    await db.close();
  });

  test('v3 -> v4 migration adds the new tables and preserves existing data',
      () async {
    // Start with a real v3 database and insert a row directly, bypassing the
    // current (v4) AppDatabase so we know the data pre-dates the migration.
    final schema = await verifier.schemaAt(3);
    final oldDb = v3.DatabaseAtV3(schema.newConnection());
    await oldDb.into(oldDb.rides).insert(v3.RidesCompanion.insert(
          id: 'ride-pre-v4',
          startTime: 2000,
          status: 'finished',
        ));
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);

    final rows = await db.select(db.rides).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'ride-pre-v4');

    // The new v4 tables exist and are usable.
    await db.into(db.scheduledWorkouts).insert(ScheduledWorkoutsCompanion.insert(
          id: 'sched-1',
          workoutId: 'w-1',
          date: 3000,
          createdAt: 3000,
        ));
    expect(await db.select(db.scheduledWorkouts).get(), hasLength(1));

    await db.close();
  });

  test('indices exist after a fresh create', () async {
    final db = AppDatabase(NativeDatabase.memory());
    // Force schema creation (onCreate is lazy until the first query).
    await db.select(db.rides).get();

    final indexNames = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'",
        )
        .map((row) => row.read<String>('name'))
        .get();

    expect(indexNames, containsAll(<String>[
      'idx_rides_start_time',
      'idx_sensor_readings_ride_ts',
      'idx_laps_ride',
      'idx_export_queue_ride',
      'idx_scheduled_workouts_date',
      'idx_personal_records_duration',
      'idx_ftp_history_date',
    ]));

    await db.close();
  });
}
