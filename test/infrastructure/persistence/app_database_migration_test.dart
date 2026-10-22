import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/generated_migrations/schema.dart';
import 'package:open_bike/infrastructure/persistence/generated_migrations/schema_v2.dart'
    as v2;
import 'package:open_bike/infrastructure/persistence/generated_migrations/schema_v3.dart'
    as v3;
import 'package:open_bike/infrastructure/persistence/generated_migrations/schema_v4.dart'
    as v4;
import 'package:open_bike/infrastructure/persistence/generated_migrations/schema_v5.dart'
    as v5;
import 'package:open_bike/infrastructure/persistence/generated_migrations/schema_v6.dart'
    as v6;

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

  test('v4 -> v5 migration adds the new columns and preserves existing data',
      () async {
    // Start with a real v4 database and insert a row directly, bypassing the
    // current (v5) AppDatabase so we know the data pre-dates the migration.
    final schema = await verifier.schemaAt(4);
    final oldDb = v4.DatabaseAtV4(schema.newConnection());
    await oldDb.into(oldDb.rides).insert(v4.RidesCompanion.insert(
          id: 'ride-pre-v5',
          startTime: 4000,
          status: 'finished',
        ));
    await oldDb.into(oldDb.exportQueue).insert(v4.ExportQueueCompanion.insert(
          rideId: 'ride-pre-v5',
          target: 'tcx-file-export',
          createdAt: 4000,
        ));
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 5);

    final rides = await db.select(db.rides).get();
    expect(rides, hasLength(1));
    expect(rides.single.id, 'ride-pre-v5');
    expect(rides.single.elevationGainM, isNull);

    final queue = await db.select(db.exportQueue).get();
    expect(queue, hasLength(1));
    expect(queue.single.resultPath, isNull);

    // The new columns are usable going forward.
    await (db.update(db.rides)..where((t) => t.id.equals('ride-pre-v5')))
        .write(const RidesCompanion(elevationGainM: Value(123.4)));
    final updated =
        await (db.select(db.rides)..where((t) => t.id.equals('ride-pre-v5')))
            .getSingle();
    expect(updated.elevationGainM, 123.4);

    await db.close();
  });

  test('v5 -> v6 migration adds ftp_history.source and preserves entries',
      () async {
    // Start with a real v5 database and insert an FTP history row directly,
    // bypassing the current (v6) AppDatabase so we know it pre-dates the
    // migration and therefore has no recorded source.
    final schema = await verifier.schemaAt(5);
    final oldDb = v5.DatabaseAtV5(schema.newConnection());
    await oldDb.into(oldDb.ftpHistory).insert(v5.FtpHistoryCompanion.insert(
          effectiveDate: 5000,
          ftp: 240,
        ));
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 6);

    final entries = await db.select(db.ftpHistory).get();
    expect(entries, hasLength(1));
    expect(entries.single.ftp, 240);
    // Pre-v6 rows carry no provenance — the storage layer reads these back as
    // FtpSource.manual so they never reset the retest clock.
    expect(entries.single.source, isNull);

    // The new column is usable going forward.
    await db.into(db.ftpHistory).insert(FtpHistoryCompanion.insert(
          effectiveDate: 6000,
          ftp: 255,
          source: const Value('rampTest'),
        ));
    final latest = await (db.select(db.ftpHistory)
          ..orderBy([(t) => OrderingTerm.desc(t.effectiveDate)])
          ..limit(1))
        .getSingle();
    expect(latest.source, 'rampTest');

    await db.close();
  });

  test('opening a v6 database keeps one copy of each duplicated reading',
      () async {
    // Every 30-second auto-save wrote all of a ride's readings again, so a
    // v6 database holds the start of each ride many times over.
    final schema = await verifier.schemaAt(6);
    final oldDb = v6.DatabaseAtV6(schema.newConnection());
    await oldDb.customStatement(
      'CREATE INDEX idx_sensor_readings_ride_ts '
      'ON sensor_readings (ride_id, timestamp)',
    );
    await oldDb.customStatement(
      "INSERT INTO rides (id, start_time, status) "
      "VALUES ('ride-dup', 0, 'finished')",
    );
    Future<void> insertReading(int timestamp, double power) =>
        oldDb.customStatement(
          'INSERT INTO sensor_readings (ride_id, timestamp, power_watts) '
          "VALUES ('ride-dup', $timestamp, $power)",
        );
    // Three auto-saves of a growing ride: 1 s, then 2 s, then 3 s recorded.
    await insertReading(0, 100);
    await insertReading(0, 100);
    await insertReading(1000, 110);
    await insertReading(0, 100);
    await insertReading(1000, 110);
    await insertReading(2000, 120);
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 6);

    final readings = await (db.select(db.sensorReadings)
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
    expect(readings.map((r) => r.timestamp), [0, 1000, 2000]);
    expect(readings.map((r) => r.powerWatts), [100, 110, 120]);

    final indexNames = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND tbl_name = 'sensor_readings' AND name LIKE 'idx_%'",
        )
        .map((row) => row.read<String>('name'))
        .get();
    expect(indexNames, ['idx_sensor_readings_ride_ts_unique']);

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
      'idx_sensor_readings_ride_ts_unique',
      'idx_laps_ride',
      'idx_export_queue_ride',
      'idx_scheduled_workouts_date',
      'idx_personal_records_duration',
      'idx_ftp_history_date',
    ]));

    await db.close();
  });
}
