import 'package:drift/drift.dart';

import 'generated_migrations/schema_versions.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Rides
// ---------------------------------------------------------------------------

@DataClassName('RideRow')
class Rides extends Table {
  TextColumn get id => text()();
  IntColumn get startTime => integer()(); // epoch ms
  IntColumn get endTime => integer().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get workoutId => text().nullable()();
  TextColumn get status => text()(); // idle / active / paused / finished

  // Cached metrics (computed on stop, stored for fast list queries).
  RealColumn get avgPower => real().nullable()();
  RealColumn get normalizedPower => real().nullable()();
  RealColumn get maxPower => real().nullable()();
  RealColumn get avgCadence => real().nullable()();
  RealColumn get avgHr => real().nullable()();
  RealColumn get maxHr => real().nullable()();
  RealColumn get totalDistance => real().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  IntColumn get pauseDurationSeconds => integer().nullable()();
  RealColumn get tss => real().nullable()();
  RealColumn get intensityFactor => real().nullable()();
  RealColumn get ftpAtTime => real().nullable()();
  RealColumn get elevationGainM => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Sensor Readings
// ---------------------------------------------------------------------------

@DataClassName('SensorReadingRow')
class SensorReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rideId => text().references(Rides, #id)();
  IntColumn get timestamp => integer()(); // epoch ms
  RealColumn get powerWatts => real().nullable()();
  RealColumn get cadenceRpm => real().nullable()();
  IntColumn get heartRateBpm => integer().nullable()();
  RealColumn get speedKmh => real().nullable()();
  RealColumn get distanceM => real().nullable()();
  RealColumn get gradePercent => real().nullable()();
}

// ---------------------------------------------------------------------------
// Laps
// ---------------------------------------------------------------------------

@DataClassName('LapRow')
class Laps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rideId => text().references(Rides, #id)();
  IntColumn get startIndex => integer()();
  IntColumn get endIndex => integer()();
  IntColumn get startTime => integer()(); // epoch ms
  IntColumn get durationMs => integer()();
}

// ---------------------------------------------------------------------------
// Workouts
// ---------------------------------------------------------------------------

@DataClassName('WorkoutRow')
class Workouts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get stepsJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Workout Steps
// ---------------------------------------------------------------------------

@DataClassName('WorkoutStepRow')
class WorkoutSteps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get workoutId => text().references(Workouts, #id)();
  IntColumn get orderIndex => integer()();
  TextColumn get type => text()();
  IntColumn get durationSeconds => integer()();
  RealColumn get powerTargetPercent => real()();
  RealColumn get powerLowPercent => real().nullable()();
  RealColumn get powerHighPercent => real().nullable()();
  IntColumn get cadenceTarget => integer().nullable()();
  IntColumn get repeatCount => integer().nullable()();
}

// ---------------------------------------------------------------------------
// User Profiles
// ---------------------------------------------------------------------------

@DataClassName('UserProfileRow')
class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get ftp => real()();
  IntColumn get maxHr => integer().nullable()();
  IntColumn get restHr => integer().nullable()();
  RealColumn get weight => real().nullable()();
  RealColumn get height => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Export Queue
// ---------------------------------------------------------------------------

@DataClassName('ExportQueueRow')
class ExportQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rideId => text().references(Rides, #id)();
  TextColumn get target => text()(); // strava / garmin / trainingpeaks
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // pending / uploading / success / failed
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get lastAttempt => integer().nullable()(); // epoch ms
  TextColumn get errorMessage => text().nullable()();
  IntColumn get createdAt => integer()(); // epoch ms
  // Local file path for file-export plugins (null for network-upload
  // plugins like Strava, which return a remote activity id instead).
  TextColumn get resultPath => text().nullable()();
}

// ---------------------------------------------------------------------------
// Scheduled Workouts (training calendar)
// ---------------------------------------------------------------------------

@DataClassName('ScheduledWorkoutRow')
class ScheduledWorkouts extends Table {
  TextColumn get id => text()();
  TextColumn get workoutId => text().references(Workouts, #id)();
  IntColumn get date => integer()(); // epoch ms, local midnight of that day
  TextColumn get completedRideId =>
      text().nullable().references(Rides, #id)();
  TextColumn get notes => text().nullable()();
  IntColumn get createdAt => integer()(); // epoch ms

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Personal Records (mean-max power cache)
// ---------------------------------------------------------------------------

@DataClassName('PersonalRecordRow')
class PersonalRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rideId => text().references(Rides, #id)();
  IntColumn get durationSeconds => integer()(); // 5, 60, 300, 1200
  RealColumn get watts => real()();
  IntColumn get achievedAt => integer()(); // epoch ms (ride start time)

  @override
  List<Set<Column>> get uniqueKeys => [
        {rideId, durationSeconds},
      ];
}

// ---------------------------------------------------------------------------
// FTP History
// ---------------------------------------------------------------------------

@DataClassName('FtpHistoryRow')
class FtpHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get effectiveDate => integer()(); // epoch ms
  RealColumn get ftp => real()();

  /// [FtpSource] name. Nullable because rows written before schema v6 have no
  /// recorded provenance — those read back as [FtpSource.manual], which is the
  /// conservative reading (they never count as a test for retest reminders).
  /// Stored as text rather than a drift `textEnum` so an unrecognised value
  /// from a future version degrades to `manual` instead of throwing on read.
  TextColumn get source => text().nullable()();
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [
  Rides,
  SensorReadings,
  Laps,
  Workouts,
  WorkoutSteps,
  UserProfiles,
  ExportQueue,
  ScheduledWorkouts,
  PersonalRecords,
  FtpHistory,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await createIndices();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // No incremental path exists for these pre-release schemas —
            // safe to rebuild since no released version ever shipped them.
            for (final table in allTables) {
              await m.deleteTable(table.actualTableName);
            }
            await m.createAll();
          } else {
            await stepByStep(
              from2To3: (m, schema) async {
                // No column/table changes between v2 and v3.
              },
              from3To4: (m, schema) async {
                await m.createTable(schema.scheduledWorkouts);
                await m.createTable(schema.personalRecords);
                await m.createTable(schema.ftpHistory);
              },
              from4To5: (m, schema) async {
                await m.addColumn(schema.rides, schema.rides.elevationGainM);
                await m.addColumn(
                    schema.exportQueue, schema.exportQueue.resultPath);
              },
              from5To6: (m, schema) async {
                await m.addColumn(schema.ftpHistory, schema.ftpHistory.source);
              },
            )(m, from, to);
          }
          await createIndices();
        },
      );

  // -------------------------------------------------------------------------
  // Custom indices (created after table creation).
  // -------------------------------------------------------------------------

  @override
  List<TableInfo> get allTables => super.allTables.toList();

  Future<void> createIndices() async {
    await _createIndexIfTableExists(
      'rides',
      'CREATE INDEX IF NOT EXISTS idx_rides_start_time ON rides (start_time)',
    );
    await _createIndexIfTableExists(
      'sensor_readings',
      'CREATE INDEX IF NOT EXISTS idx_sensor_readings_ride_ts '
      'ON sensor_readings (ride_id, timestamp)',
    );
    await _createIndexIfTableExists(
      'laps',
      'CREATE INDEX IF NOT EXISTS idx_laps_ride ON laps (ride_id)',
    );
    await _createIndexIfTableExists(
      'export_queue',
      'CREATE INDEX IF NOT EXISTS idx_export_queue_ride ON export_queue (ride_id)',
    );
    await _createIndexIfTableExists(
      'scheduled_workouts',
      'CREATE INDEX IF NOT EXISTS idx_scheduled_workouts_date '
      'ON scheduled_workouts (date)',
    );
    await _createIndexIfTableExists(
      'personal_records',
      'CREATE INDEX IF NOT EXISTS idx_personal_records_duration '
      'ON personal_records (duration_seconds, watts)',
    );
    await _createIndexIfTableExists(
      'ftp_history',
      'CREATE INDEX IF NOT EXISTS idx_ftp_history_date '
      'ON ftp_history (effective_date)',
    );
  }

  /// Guards index creation against tables that don't exist yet — relevant
  /// when a migration is validated against an intermediate target version
  /// (see [SchemaVerifier] usage in the migration tests), where a later
  /// version's tables genuinely aren't present.
  Future<void> _createIndexIfTableExists(
    String tableName,
    String createIndexSql,
  ) async {
    final exists = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable.withString(tableName)],
    ).getSingleOrNull();
    if (exists != null) {
      await customStatement(createIndexSql);
    }
  }
}
