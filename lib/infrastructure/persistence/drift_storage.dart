import 'package:drift/drift.dart';

import '../../core/domain/entities/ftp_history_entry.dart';
import '../../core/domain/entities/lap.dart';
import '../../core/domain/entities/personal_record.dart';
import '../../core/domain/entities/ride.dart';
import '../../core/domain/entities/scheduled_workout.dart';
import '../../core/domain/entities/sensor_reading.dart';
import '../../core/domain/entities/user_profile.dart';
import '../../core/domain/entities/workout.dart';
import '../../core/domain/ports/storage_port.dart';
import '../../core/domain/value_objects/value_objects.dart';
import 'app_database.dart';
import 'workout_json.dart';

/// [StoragePort] implementation backed by Drift (SQLite).
class DriftStorage implements StoragePort {
  final AppDatabase _db;

  DriftStorage(this._db);

  // -------------------------------------------------------------------------
  // Rides
  // -------------------------------------------------------------------------

  @override
  Future<void> saveRide(Ride ride, {Watts? ftp}) async {
    await _db.into(_db.rides).insertOnConflictUpdate(
          RidesCompanion.insert(
            id: ride.id,
            startTime: ride.startTime.millisecondsSinceEpoch,
            endTime: Value(ride.endTime?.millisecondsSinceEpoch),
            status: ride.status.name,
            avgPower: Value(ride.averagePower.value),
            normalizedPower: Value(ride.normalizedPower.value),
            maxPower: Value(ride.maxPower.value),
            avgCadence: Value(ride.averageCadence.rpm),
            avgHr: Value(ride.averageHr.bpm.toDouble()),
            maxHr: Value(ride.maxHr.bpm.toDouble()),
            totalDistance: Value(ride.totalDistance.meters),
            durationSeconds: Value(ride.activeDuration.inSeconds),
            pauseDurationSeconds: Value(ride.pauseDuration.inSeconds),
            tss: Value(ftp != null ? ride.tss(ftp) : null),
            intensityFactor: Value(ftp != null ? ride.intensityFactor(ftp) : null),
            ftpAtTime: Value(ftp?.value),
          ),
        );
  }

  @override
  Future<Ride?> getRide(String id) async {
    final row = await (_db.select(_db.rides)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _rideFromRow(row);
  }

  @override
  Future<List<Ride>> getRides() async {
    final rows = await (_db.select(_db.rides)
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
    return rows.map(_rideFromRow).toList();
  }

  @override
  Future<void> deleteRide(String id) async {
    // Delete dependent rows first (no cascading FK in SQLite by default).
    await (_db.delete(_db.sensorReadings)
          ..where((t) => t.rideId.equals(id)))
        .go();
    await (_db.delete(_db.laps)..where((t) => t.rideId.equals(id))).go();
    await (_db.delete(_db.exportQueue)..where((t) => t.rideId.equals(id)))
        .go();
    await (_db.delete(_db.personalRecords)..where((t) => t.rideId.equals(id)))
        .go();
    await (_db.update(_db.scheduledWorkouts)
          ..where((t) => t.completedRideId.equals(id)))
        .write(const ScheduledWorkoutsCompanion(completedRideId: Value(null)));
    await (_db.delete(_db.rides)..where((t) => t.id.equals(id))).go();
  }

  Ride _rideFromRow(RideRow row) {
    return Ride(
      id: row.id,
      startTime: DateTime.fromMillisecondsSinceEpoch(row.startTime),
      endTime: row.endTime != null
          ? DateTime.fromMillisecondsSinceEpoch(row.endTime!)
          : null,
      status: RideStatus.values.byName(row.status),
      pauseDuration: Duration(seconds: row.pauseDurationSeconds ?? 0),
      // Cached summary metrics — avoids loading all readings for list views.
      cachedAvgPower: row.avgPower != null ? Watts(row.avgPower!) : null,
      cachedNormalizedPower:
          row.normalizedPower != null ? Watts(row.normalizedPower!) : null,
      cachedMaxPower: row.maxPower != null ? Watts(row.maxPower!) : null,
      cachedAvgCadence:
          row.avgCadence != null ? Cadence(row.avgCadence!) : null,
      cachedAvgHr:
          row.avgHr != null ? HeartRate(row.avgHr!.round()) : null,
      cachedMaxHr:
          row.maxHr != null ? HeartRate(row.maxHr!.round()) : null,
      cachedTotalDistance:
          row.totalDistance != null ? Distance(row.totalDistance!) : null,
      cachedTss: row.tss,
      cachedIntensityFactor: row.intensityFactor,
    );
  }

  // -------------------------------------------------------------------------
  // Sensor Readings
  // -------------------------------------------------------------------------

  @override
  Future<void> saveSensorReadings(
    String rideId,
    List<SensorReading> readings,
  ) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.sensorReadings,
        readings.map(
          (r) => SensorReadingsCompanion.insert(
            rideId: rideId,
            timestamp: r.timestamp.millisecondsSinceEpoch,
            powerWatts: Value(r.power?.value),
            cadenceRpm: Value(r.cadence?.rpm),
            heartRateBpm: Value(r.heartRate?.bpm),
            speedKmh: Value(r.speed?.kmh),
            distanceM: Value(r.distance?.meters),
            gradePercent: Value(r.grade?.percent),
          ),
        ),
      );
    });
  }

  @override
  Future<List<SensorReading>> getSensorReadings(String rideId) async {
    final rows = await (_db.select(_db.sensorReadings)
          ..where((t) => t.rideId.equals(rideId))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
    return rows.map(_sensorReadingFromRow).toList();
  }

  SensorReading _sensorReadingFromRow(SensorReadingRow row) {
    return SensorReading(
      timestamp: DateTime.fromMillisecondsSinceEpoch(row.timestamp),
      power: row.powerWatts != null ? Watts(row.powerWatts!) : null,
      cadence: row.cadenceRpm != null ? Cadence(row.cadenceRpm!) : null,
      heartRate:
          row.heartRateBpm != null ? HeartRate(row.heartRateBpm!) : null,
      speed: row.speedKmh != null ? Speed(row.speedKmh!) : null,
      distance: row.distanceM != null ? Distance(row.distanceM!) : null,
      grade: row.gradePercent != null ? Grade(row.gradePercent!) : null,
    );
  }

  // -------------------------------------------------------------------------
  // Laps
  // -------------------------------------------------------------------------

  @override
  Future<void> saveLaps(String rideId, List<Lap> laps) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.laps,
        laps.map(
          (l) => LapsCompanion.insert(
            rideId: rideId,
            startIndex: l.startIndex,
            endIndex: l.endIndex,
            startTime: l.startTime.millisecondsSinceEpoch,
            durationMs: l.duration.inMilliseconds,
          ),
        ),
      );
    });
  }

  @override
  Future<List<Lap>> getLaps(String rideId) async {
    final rows = await (_db.select(_db.laps)
          ..where((t) => t.rideId.equals(rideId))
          ..orderBy([(t) => OrderingTerm.asc(t.startIndex)]))
        .get();
    return rows
        .map((r) => Lap(
              startIndex: r.startIndex,
              endIndex: r.endIndex,
              startTime: DateTime.fromMillisecondsSinceEpoch(r.startTime),
              duration: Duration(milliseconds: r.durationMs),
            ))
        .toList();
  }

  // -------------------------------------------------------------------------
  // Workouts
  // -------------------------------------------------------------------------

  @override
  Future<void> saveWorkout(Workout workout) async {
    await _db.into(_db.workouts).insertOnConflictUpdate(
          WorkoutsCompanion.insert(
            id: workout.id,
            name: workout.name,
            description: Value(workout.description),
            stepsJson: WorkoutJson.encode(workout.steps, workout.textEvents),
          ),
        );
  }

  @override
  Future<List<Workout>> getWorkouts() async {
    final rows = await _db.select(_db.workouts).get();
    return rows.map(_workoutFromRow).toList();
  }

  @override
  Future<void> deleteWorkout(String id) async {
    await (_db.delete(_db.workouts)..where((t) => t.id.equals(id))).go();
  }

  Workout _workoutFromRow(WorkoutRow row) {
    final (steps, textEvents) = WorkoutJson.decode(row.stepsJson);
    return Workout(
      id: row.id,
      name: row.name,
      description: row.description,
      steps: steps,
      textEvents: textEvents,
    );
  }

  // -------------------------------------------------------------------------
  // User Profile
  // -------------------------------------------------------------------------

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _recordFtpChangeIfNeeded(profile.ftp);
    await _db.into(_db.userProfiles).insertOnConflictUpdate(
          UserProfilesCompanion.insert(
            id: 'default',
            name: profile.name,
            ftp: profile.ftp.value,
            maxHr: Value(profile.maxHr.bpm),
            restHr: Value(profile.restingHr.bpm),
            weight: Value(profile.weight),
            height: Value(profile.height),
          ),
        );
  }

  @override
  Future<UserProfile?> getProfile() async {
    final row = await _db.select(_db.userProfiles).getSingleOrNull();
    if (row == null) return null;
    return UserProfile(
      name: row.name,
      ftp: Watts(row.ftp),
      maxHr: HeartRate(row.maxHr ?? 190),
      restingHr: HeartRate(row.restHr ?? 60),
      weight: row.weight ?? 75.0,
      height: row.height ?? 1.75,
    );
  }

  /// Appends a dated FTP history entry when [ftp] differs from the last
  /// recorded value (or none has been recorded yet), so PMC calculations can
  /// later look up the FTP that was actually in effect on any given date.
  Future<void> _recordFtpChangeIfNeeded(Watts ftp) async {
    final last = await (_db.select(_db.ftpHistory)
          ..orderBy([(t) => OrderingTerm.desc(t.effectiveDate)])
          ..limit(1))
        .getSingleOrNull();
    if (last != null && last.ftp == ftp.value) return;

    await _db.into(_db.ftpHistory).insert(
          FtpHistoryCompanion.insert(
            effectiveDate: DateTime.now().millisecondsSinceEpoch,
            ftp: ftp.value,
          ),
        );
  }

  // -------------------------------------------------------------------------
  // Scheduled workouts (training calendar)
  // -------------------------------------------------------------------------

  @override
  Future<void> saveScheduledWorkout(ScheduledWorkout scheduled) async {
    await _db.into(_db.scheduledWorkouts).insertOnConflictUpdate(
          ScheduledWorkoutsCompanion.insert(
            id: scheduled.id,
            workoutId: scheduled.workoutId,
            date: scheduled.date.millisecondsSinceEpoch,
            completedRideId: Value(scheduled.completedRideId),
            notes: Value(scheduled.notes),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  @override
  Future<List<ScheduledWorkout>> getScheduledWorkouts() async {
    final rows = await (_db.select(_db.scheduledWorkouts)
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
    return rows.map(_scheduledWorkoutFromRow).toList();
  }

  @override
  Future<void> deleteScheduledWorkout(String id) async {
    await (_db.delete(_db.scheduledWorkouts)..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<void> linkCompletedRide(
    String scheduledWorkoutId,
    String rideId,
  ) async {
    await (_db.update(_db.scheduledWorkouts)
          ..where((t) => t.id.equals(scheduledWorkoutId)))
        .write(ScheduledWorkoutsCompanion(completedRideId: Value(rideId)));
  }

  ScheduledWorkout _scheduledWorkoutFromRow(ScheduledWorkoutRow row) {
    return ScheduledWorkout(
      id: row.id,
      workoutId: row.workoutId,
      date: DateTime.fromMillisecondsSinceEpoch(row.date),
      completedRideId: row.completedRideId,
      notes: row.notes,
    );
  }

  // -------------------------------------------------------------------------
  // Personal records (mean-max power cache)
  // -------------------------------------------------------------------------

  @override
  Future<void> savePersonalRecords(List<PersonalRecord> records) async {
    if (records.isEmpty) return;
    await _db.batch((batch) {
      // `insertAllOnConflictUpdate` only resolves conflicts on the primary
      // key (the autoincrement `id`, which never collides). The row we
      // actually want to upsert on is the (rideId, durationSeconds) unique
      // index, so use INSERT OR REPLACE — it resolves against any unique
      // constraint, including that one.
      batch.insertAll(
        _db.personalRecords,
        records.map(
          (r) => PersonalRecordsCompanion.insert(
            rideId: r.rideId,
            durationSeconds: r.durationSeconds,
            watts: r.watts.value,
            achievedAt: r.achievedAt.millisecondsSinceEpoch,
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  @override
  Future<List<PersonalRecord>> getPersonalRecords() async {
    final rows = await _db.select(_db.personalRecords).get();
    return rows
        .map((r) => PersonalRecord(
              rideId: r.rideId,
              durationSeconds: r.durationSeconds,
              watts: Watts(r.watts),
              achievedAt: DateTime.fromMillisecondsSinceEpoch(r.achievedAt),
            ))
        .toList();
  }

  // -------------------------------------------------------------------------
  // FTP history
  // -------------------------------------------------------------------------

  @override
  Future<List<FtpHistoryEntry>> getFtpHistory() async {
    final rows = await (_db.select(_db.ftpHistory)
          ..orderBy([(t) => OrderingTerm.asc(t.effectiveDate)]))
        .get();
    return rows
        .map((r) => FtpHistoryEntry(
              effectiveDate: DateTime.fromMillisecondsSinceEpoch(r.effectiveDate),
              ftp: Watts(r.ftp),
            ))
        .toList();
  }
}
