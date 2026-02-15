import 'package:drift/drift.dart';

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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Pre-release: drop everything and recreate.
          // Replace with incremental migrations once shipped.
          if (from < 2) {
            for (final table in allTables) {
              await m.deleteTable(table.actualTableName);
            }
            await m.createAll();
          }
        },
      );

  // -------------------------------------------------------------------------
  // Custom indices (created after table creation).
  // -------------------------------------------------------------------------

  @override
  List<TableInfo> get allTables => super.allTables.toList();

  Future<void> createIndices() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_rides_start_time ON rides (start_time)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sensor_readings_ride_ts '
      'ON sensor_readings (ride_id, timestamp)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_laps_ride ON laps (ride_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_export_queue_ride ON export_queue (ride_id)',
    );
  }
}
