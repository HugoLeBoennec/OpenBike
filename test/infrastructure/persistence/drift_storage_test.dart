import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';

AppDatabase _createInMemoryDb() => AppDatabase(NativeDatabase.memory());

Ride _testRide({String id = 'ride-001'}) {
  final start = DateTime.utc(2025, 6, 15, 10, 0, 0);
  return Ride(
    id: id,
    startTime: start,
    endTime: start.add(const Duration(seconds: 60)),
    status: RideStatus.finished,
    readings: [
      SensorReading(
        timestamp: start,
        power: const Watts(200),
        heartRate: const HeartRate(140),
        cadence: const Cadence(90),
        speed: const Speed(32.5),
        distance: const Distance(120),
        grade: const Grade(4.5),
      ),
      SensorReading(
        timestamp: start.add(const Duration(seconds: 1)),
        power: const Watts(210),
        grade: const Grade(-2.0),
      ),
    ],
  );
}

void main() {
  late AppDatabase db;
  late DriftStorage storage;

  setUp(() {
    db = _createInMemoryDb();
    storage = DriftStorage(db);
  });

  tearDown(() async {
    await db.close();
  });

  // ===========================================================================
  // Rides
  // ===========================================================================

  group('DriftStorage — rides', () {
    test('saveRide then getRide round-trips core fields', () async {
      final ride = _testRide();
      await storage.saveRide(ride);

      final loaded = await storage.getRide(ride.id);
      expect(loaded, isNotNull);
      expect(loaded!.id, ride.id);
      expect(loaded.startTime.isAtSameMomentAs(ride.startTime), isTrue);
      expect(loaded.endTime!.isAtSameMomentAs(ride.endTime!), isTrue);
      expect(loaded.status, RideStatus.finished);
    });

    test('getRide returns null for unknown id', () async {
      final loaded = await storage.getRide('missing');
      expect(loaded, isNull);
    });

    test('getRides returns all rides ordered by start time descending',
        () async {
      final older = _testRide(id: 'ride-old');
      final newer = _testRide(id: 'ride-new').copyWith(
        startTime: older.startTime.add(const Duration(hours: 1)),
      );
      await storage.saveRide(older);
      await storage.saveRide(newer);

      final rides = await storage.getRides();
      expect(rides.map((r) => r.id).toList(), ['ride-new', 'ride-old']);
    });

    test('saveRide upserts on conflicting id', () async {
      final ride = _testRide();
      await storage.saveRide(ride);
      await storage.saveRide(ride.copyWith(status: RideStatus.active));

      final rides = await storage.getRides();
      expect(rides, hasLength(1));
      expect(rides.single.status, RideStatus.active);
    });
  });

  // ===========================================================================
  // Sensor readings — including gradePercent round-trip
  // ===========================================================================

  group('DriftStorage — sensor readings', () {
    test('saveSensorReadings then getSensorReadings round-trips grade',
        () async {
      final ride = _testRide();
      await storage.saveRide(ride);
      await storage.saveSensorReadings(ride.id, ride.readings);

      final readings = await storage.getSensorReadings(ride.id);
      expect(readings, hasLength(2));
      expect(readings[0].grade?.percent, closeTo(4.5, 0.0001));
      expect(readings[1].grade?.percent, closeTo(-2.0, 0.0001));
    });

    test('readings without grade round-trip as null', () async {
      final ride = _testRide();
      await storage.saveRide(ride);
      await storage.saveSensorReadings(ride.id, [
        SensorReading(timestamp: ride.startTime, power: const Watts(150)),
      ]);

      final readings = await storage.getSensorReadings(ride.id);
      expect(readings.single.grade, isNull);
    });

    test('other fields round-trip alongside grade', () async {
      final ride = _testRide();
      await storage.saveRide(ride);
      await storage.saveSensorReadings(ride.id, ride.readings);

      final readings = await storage.getSensorReadings(ride.id);
      expect(readings.first.power?.value, 200);
      expect(readings.first.heartRate?.bpm, 140);
      expect(readings.first.cadence?.rpm, 90);
      expect(readings.first.speed?.kmh, closeTo(32.5, 0.0001));
      expect(readings.first.distance?.meters, closeTo(120, 0.0001));
    });
  });

  // ===========================================================================
  // Laps
  // ===========================================================================

  group('DriftStorage — laps', () {
    test('saveLaps then getLaps round-trips', () async {
      final ride = _testRide();
      await storage.saveRide(ride);
      final laps = [
        Lap(
          startIndex: 0,
          endIndex: 29,
          startTime: ride.startTime,
          duration: const Duration(seconds: 30),
        ),
        Lap(
          startIndex: 30,
          endIndex: 59,
          startTime: ride.startTime.add(const Duration(seconds: 30)),
          duration: const Duration(seconds: 30),
        ),
      ];
      await storage.saveLaps(ride.id, laps);

      final loaded = await storage.getLaps(ride.id);
      expect(loaded, hasLength(2));
      expect(loaded[0].startIndex, 0);
      expect(loaded[1].startIndex, 30);
    });
  });

  // ===========================================================================
  // User profile
  // ===========================================================================

  group('DriftStorage — user profile', () {
    test('saveProfile then getProfile round-trips', () async {
      const profile = UserProfile(
        name: 'Test Rider',
        ftp: Watts(250),
        maxHr: HeartRate(190),
        restingHr: HeartRate(55),
        weight: 72.0,
        height: 1.8,
      );
      await storage.saveProfile(profile);

      final loaded = await storage.getProfile();
      expect(loaded, isNotNull);
      expect(loaded!.name, 'Test Rider');
      expect(loaded.ftp.value, 250);
      expect(loaded.maxHr.bpm, 190);
      expect(loaded.restingHr.bpm, 55);
      expect(loaded.weight, 72.0);
      expect(loaded.height, 1.8);
    });

    test('getProfile returns null when none saved', () async {
      final loaded = await storage.getProfile();
      expect(loaded, isNull);
    });

    test('saveProfile upserts the single default profile', () async {
      const profileA = UserProfile(
        name: 'A',
        ftp: Watts(200),
        maxHr: HeartRate(180),
        restingHr: HeartRate(60),
        weight: 70,
        height: 1.75,
      );
      const profileB = UserProfile(
        name: 'B',
        ftp: Watts(220),
        maxHr: HeartRate(185),
        restingHr: HeartRate(58),
        weight: 68,
        height: 1.7,
      );
      await storage.saveProfile(profileA);
      await storage.saveProfile(profileB);

      final loaded = await storage.getProfile();
      expect(loaded!.name, 'B');
      expect(loaded.ftp.value, 220);
    });
  });

  // ===========================================================================
  // Workouts
  // ===========================================================================

  group('DriftStorage — workouts', () {
    Workout testWorkout({String id = 'w-1'}) => Workout(
          id: id,
          name: 'Sweet Spot 3x12',
          description: 'Three 12-minute blocks',
          source: 'builder',
          steps: const [
            WorkoutStep(
              type: StepType.warmup,
              durationSeconds: 600,
              powerTargetPercent: 0,
              powerLowPercent: 40,
              powerHighPercent: 75,
            ),
            WorkoutStep(
              type: StepType.interval,
              durationSeconds: 720,
              offDurationSeconds: 300,
              powerTargetPercent: 90,
              powerLowPercent: 55,
              repeat: 3,
              cadenceTarget: 90,
              cadenceResting: 85,
            ),
          ],
          textEvents: const [
            TextEvent(offsetSeconds: 10, message: 'Go!', durationSeconds: 5),
          ],
        );

    test('saveWorkout then getWorkouts round-trips steps and text events',
        () async {
      final workout = testWorkout();
      await storage.saveWorkout(workout);

      final loaded = await storage.getWorkouts();
      expect(loaded, hasLength(1));
      final w = loaded.single;
      expect(w.id, workout.id);
      expect(w.name, workout.name);
      expect(w.description, workout.description);
      expect(w.steps, hasLength(2));
      expect(w.steps[0].type, StepType.warmup);
      expect(w.steps[0].powerLowPercent, 40);
      expect(w.steps[0].powerHighPercent, 75);
      expect(w.steps[1].type, StepType.interval);
      expect(w.steps[1].repeat, 3);
      expect(w.steps[1].offDurationSeconds, 300);
      expect(w.steps[1].cadenceResting, 85);
      expect(w.textEvents, hasLength(1));
      expect(w.textEvents.single.message, 'Go!');
    });

    test('saveWorkout upserts on conflicting id', () async {
      final workout = testWorkout();
      await storage.saveWorkout(workout);
      await storage.saveWorkout(workout.copyWith(name: 'Renamed'));

      final loaded = await storage.getWorkouts();
      expect(loaded, hasLength(1));
      expect(loaded.single.name, 'Renamed');
    });

    test('deleteWorkout removes only the targeted workout', () async {
      await storage.saveWorkout(testWorkout(id: 'w-1'));
      await storage.saveWorkout(testWorkout(id: 'w-2'));

      await storage.deleteWorkout('w-1');

      final loaded = await storage.getWorkouts();
      expect(loaded.map((w) => w.id), ['w-2']);
    });
  });

  // ===========================================================================
  // deleteRide cascade
  // ===========================================================================

  group('DriftStorage — deleteRide', () {
    test('removes the ride and all dependent rows', () async {
      final ride = _testRide();
      await storage.saveRide(ride);
      await storage.saveSensorReadings(ride.id, ride.readings);
      await storage.saveLaps(ride.id, [
        Lap(
          startIndex: 0,
          endIndex: 1,
          startTime: ride.startTime,
          duration: const Duration(seconds: 2),
        ),
      ]);

      await storage.deleteRide(ride.id);

      expect(await storage.getRide(ride.id), isNull);
      expect(await storage.getSensorReadings(ride.id), isEmpty);
      expect(await storage.getLaps(ride.id), isEmpty);
    });

    test('deleting one ride does not affect another', () async {
      final ride1 = _testRide(id: 'ride-1');
      final ride2 = _testRide(id: 'ride-2');
      await storage.saveRide(ride1);
      await storage.saveRide(ride2);
      await storage.saveSensorReadings(ride1.id, ride1.readings);
      await storage.saveSensorReadings(ride2.id, ride2.readings);

      await storage.deleteRide(ride1.id);

      expect(await storage.getRide(ride2.id), isNotNull);
      expect(await storage.getSensorReadings(ride2.id), hasLength(2));
    });
  });

  // ===========================================================================
  // FTP-at-time metrics on saveRide
  // ===========================================================================

  group('DriftStorage — saveRide with ftp', () {
    test('persists tss, intensityFactor, and ftpAtTime when ftp is given',
        () async {
      final ride = _testRide();
      await storage.saveRide(ride, ftp: const Watts(220));

      final loaded = await storage.getRide(ride.id);
      expect(loaded!.cachedIntensityFactor, isNotNull);
      expect(loaded.cachedTss, isNotNull);
      expect(loaded.cachedIntensityFactor, closeTo(ride.intensityFactor(const Watts(220)), 1e-9));
      expect(loaded.cachedTss, closeTo(ride.tss(const Watts(220)), 1e-9));
    });

    test('leaves tss/intensityFactor/ftpAtTime null when ftp is omitted',
        () async {
      final ride = _testRide();
      await storage.saveRide(ride);

      final loaded = await storage.getRide(ride.id);
      expect(loaded!.cachedTss, isNull);
      expect(loaded.cachedIntensityFactor, isNull);
    });
  });

  // ===========================================================================
  // FTP history
  // ===========================================================================

  group('DriftStorage — FTP history', () {
    test('saveProfile seeds an initial FTP history entry', () async {
      await storage.saveProfile(const UserProfile(
        name: 'A',
        ftp: Watts(200),
        maxHr: HeartRate(180),
        restingHr: HeartRate(60),
        weight: 70,
        height: 1.75,
      ));

      final history = await storage.getFtpHistory();
      expect(history, hasLength(1));
      expect(history.single.ftp.value, 200);
    });

    test('saveProfile appends a new entry only when ftp actually changes',
        () async {
      const base = UserProfile(
        name: 'A',
        ftp: Watts(200),
        maxHr: HeartRate(180),
        restingHr: HeartRate(60),
        weight: 70,
        height: 1.75,
      );
      await storage.saveProfile(base);
      // Same FTP, different name — should not add a second history entry.
      await storage.saveProfile(base.copyWith(name: 'B'));
      expect(await storage.getFtpHistory(), hasLength(1));

      // FTP actually changes — a new entry is appended.
      await storage.saveProfile(base.copyWith(ftp: const Watts(230)));
      final history = await storage.getFtpHistory();
      expect(history, hasLength(2));
      expect(history.last.ftp.value, 230);
    });
  });

  // ===========================================================================
  // Scheduled workouts (training calendar)
  // ===========================================================================

  group('DriftStorage — scheduled workouts', () {
    test('saveScheduledWorkout then getScheduledWorkouts round-trips',
        () async {
      final scheduled = ScheduledWorkout(
        id: 'sched-1',
        workoutId: 'w-1',
        date: DateTime(2026, 7, 15),
        notes: 'Race prep',
      );
      await storage.saveScheduledWorkout(scheduled);

      final loaded = await storage.getScheduledWorkouts();
      expect(loaded, hasLength(1));
      expect(loaded.single.id, 'sched-1');
      expect(loaded.single.workoutId, 'w-1');
      expect(loaded.single.date, DateTime(2026, 7, 15));
      expect(loaded.single.notes, 'Race prep');
      expect(loaded.single.completedRideId, isNull);
    });

    test('getScheduledWorkouts orders by date ascending', () async {
      await storage.saveScheduledWorkout(ScheduledWorkout(
        id: 'later',
        workoutId: 'w-1',
        date: DateTime(2026, 7, 20),
      ));
      await storage.saveScheduledWorkout(ScheduledWorkout(
        id: 'earlier',
        workoutId: 'w-1',
        date: DateTime(2026, 7, 10),
      ));

      final loaded = await storage.getScheduledWorkouts();
      expect(loaded.map((s) => s.id), ['earlier', 'later']);
    });

    test('linkCompletedRide sets the completedRideId', () async {
      final ride = _testRide();
      await storage.saveRide(ride);
      await storage.saveScheduledWorkout(ScheduledWorkout(
        id: 'sched-1',
        workoutId: 'w-1',
        date: DateTime(2026, 7, 15),
      ));

      await storage.linkCompletedRide('sched-1', ride.id);

      final loaded = await storage.getScheduledWorkouts();
      expect(loaded.single.completedRideId, ride.id);
    });

    test('deleteScheduledWorkout removes only the targeted entry', () async {
      await storage.saveScheduledWorkout(ScheduledWorkout(
        id: 'keep',
        workoutId: 'w-1',
        date: DateTime(2026, 7, 10),
      ));
      await storage.saveScheduledWorkout(ScheduledWorkout(
        id: 'remove',
        workoutId: 'w-1',
        date: DateTime(2026, 7, 11),
      ));

      await storage.deleteScheduledWorkout('remove');

      final loaded = await storage.getScheduledWorkouts();
      expect(loaded.map((s) => s.id), ['keep']);
    });

    test('deleting the completed ride clears completedRideId, not the entry',
        () async {
      final ride = _testRide();
      await storage.saveRide(ride);
      await storage.saveScheduledWorkout(ScheduledWorkout(
        id: 'sched-1',
        workoutId: 'w-1',
        date: DateTime(2026, 7, 15),
      ));
      await storage.linkCompletedRide('sched-1', ride.id);

      await storage.deleteRide(ride.id);

      final loaded = await storage.getScheduledWorkouts();
      expect(loaded, hasLength(1));
      expect(loaded.single.completedRideId, isNull);
    });
  });

  // ===========================================================================
  // Personal records
  // ===========================================================================

  group('DriftStorage — personal records', () {
    test('savePersonalRecords then getPersonalRecords round-trips', () async {
      final ride = _testRide();
      await storage.saveRide(ride);

      await storage.savePersonalRecords([
        PersonalRecord(
          rideId: ride.id,
          durationSeconds: 300,
          watts: const Watts(280),
          achievedAt: ride.startTime,
        ),
        PersonalRecord(
          rideId: ride.id,
          durationSeconds: 1200,
          watts: const Watts(230),
          achievedAt: ride.startTime,
        ),
      ]);

      final records = await storage.getPersonalRecords();
      expect(records, hasLength(2));
      expect(records.map((r) => r.durationSeconds), containsAll([300, 1200]));
    });

    test('upserts on (rideId, durationSeconds) instead of duplicating',
        () async {
      final ride = _testRide();
      await storage.saveRide(ride);

      await storage.savePersonalRecords([
        PersonalRecord(
          rideId: ride.id,
          durationSeconds: 300,
          watts: const Watts(280),
          achievedAt: ride.startTime,
        ),
      ]);
      await storage.savePersonalRecords([
        PersonalRecord(
          rideId: ride.id,
          durationSeconds: 300,
          watts: const Watts(295), // re-computed, slightly different value
          achievedAt: ride.startTime,
        ),
      ]);

      final records = await storage.getPersonalRecords();
      expect(records, hasLength(1));
      expect(records.single.watts.value, 295);
    });

    test('deleteRide removes that ride personal records', () async {
      final ride = _testRide();
      await storage.saveRide(ride);
      await storage.savePersonalRecords([
        PersonalRecord(
          rideId: ride.id,
          durationSeconds: 300,
          watts: const Watts(280),
          achievedAt: ride.startTime,
        ),
      ]);

      await storage.deleteRide(ride.id);

      expect(await storage.getPersonalRecords(), isEmpty);
    });

    test('savePersonalRecords with an empty list is a no-op', () async {
      await storage.savePersonalRecords([]);
      expect(await storage.getPersonalRecords(), isEmpty);
    });
  });
}
