import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_bike/core/application/services/personal_records_calculator.dart';
import 'package:open_bike/core/application/services/recording_engine.dart';
import 'package:open_bike/core/domain/entities/lap.dart';
import 'package:open_bike/core/domain/entities/personal_record.dart';
import 'package:open_bike/core/domain/entities/ride.dart';
import 'package:open_bike/core/domain/entities/route_point.dart';
import 'package:open_bike/core/domain/entities/sensor_reading.dart';
import 'package:open_bike/core/domain/ports/storage_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/app_event.dart';
import 'package:open_bike/core/events/event_bus.dart';

// ---------------------------------------------------------------------------
// Mocks & fakes
// ---------------------------------------------------------------------------

class MockStoragePort extends Mock implements StoragePort {}

class FakeRide extends Fake implements Ride {}

class FakeSensorReading extends Fake implements SensorReading {}

class FakeLap extends Fake implements Lap {}

/// Always returns a fixed set of records regardless of input — lets tests
/// exercise the stop()-persists-records wiring without waiting several
/// wall-clock seconds for a real ride to accumulate enough 1 Hz readings.
class _FixedRecordsCalculator extends PersonalRecordsCalculator {
  _FixedRecordsCalculator(this.records);
  final List<PersonalRecord> records;

  @override
  List<PersonalRecord> computeRecords({
    required String rideId,
    required DateTime achievedAt,
    required List<SensorReading> readings,
  }) =>
      records;
}

void main() {
  late EventBus eventBus;
  late MockStoragePort storage;
  late RecordingEngine engine;

  setUpAll(() {
    registerFallbackValue(FakeRide());
    registerFallbackValue(<SensorReading>[]);
    registerFallbackValue(<Lap>[]);
  });

  setUp(() {
    eventBus = EventBus();
    storage = MockStoragePort();

    // Default stubs — succeed silently.
    when(() => storage.saveRide(any())).thenAnswer((_) async {});
    when(() => storage.saveRide(any(), ftp: any(named: 'ftp')))
        .thenAnswer((_) async {});
    when(() => storage.saveSensorReadings(any(), any()))
        .thenAnswer((_) async {});
    when(() => storage.saveLaps(any(), any())).thenAnswer((_) async {});
    when(() => storage.savePersonalRecords(any())).thenAnswer((_) async {});

    engine = RecordingEngine(
      eventBus: eventBus,
      storage: storage,
    );
  });

  tearDown(() async {
    await engine.dispose();
    eventBus.dispose();
  });

  // =========================================================================
  // liveRide
  // =========================================================================

  group('RecordingEngine — liveRide', () {
    test('is null when idle', () {
      expect(engine.liveRide, isNull);
    });

    test('carries the samples recorded so far', () async {
      await engine.start();
      eventBus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: DateTime.now(),
          power: const Watts(200),
          distance: const Distance(1500),
        ),
        deviceId: 'test-trainer',
      ));
      await Future<void>.delayed(const Duration(milliseconds: 2200));

      final live = engine.liveRide!;
      expect(live.readings.length, greaterThanOrEqualTo(2));
      expect(live.averagePower, const Watts(200));
      // The trainer's counter never moved, so nothing was ridden.
      expect(live.totalDistance.meters, 0);
      // The ride as created at start stays empty.
      expect(engine.currentRide!.readings, isEmpty);
    });

    test('active duration freezes while paused and excludes the pause',
        () async {
      await engine.start();
      engine.pause();

      // activeDuration reads the clock, so sample it at the same moment as
      // the snapshot it belongs to.
      final first = engine.liveRide!;
      final firstActive = first.activeDuration;
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final second = engine.liveRide!;
      final secondActive = second.activeDuration;

      expect(second.pauseDuration - first.pauseDuration,
          greaterThanOrEqualTo(const Duration(milliseconds: 250)));
      expect(
        (secondActive - firstActive).abs(),
        lessThan(const Duration(milliseconds: 50)),
      );

      engine.resume();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(engine.liveRide!.pauseDuration,
          greaterThanOrEqualTo(const Duration(milliseconds: 300)));
    });
  });

  // =========================================================================
  // discard
  // =========================================================================

  group('RecordingEngine — discard', () {
    test('returns to idle, deletes the auto-saved ride, fires no RideStopped',
        () async {
      when(() => storage.deleteRide(any())).thenAnswer((_) async {});
      final events = <RideEvent>[];
      eventBus.on<RideEvent>().listen(events.add);

      final ride = await engine.start();
      await engine.discard();
      await Future<void>.delayed(Duration.zero);

      expect(engine.state, RecordingState.idle);
      verify(() => storage.deleteRide(ride.id)).called(1);
      expect(events.whereType<RideStopped>(), isEmpty);
    });

    test('allows starting a new ride afterwards', () async {
      when(() => storage.deleteRide(any())).thenAnswer((_) async {});

      await engine.start();
      await engine.discard();
      final next = await engine.start();

      expect(engine.state, RecordingState.recording);
      expect(next.id, isNotEmpty);
    });

    test('works while paused', () async {
      when(() => storage.deleteRide(any())).thenAnswer((_) async {});

      await engine.start();
      engine.pause();
      await engine.discard();

      expect(engine.state, RecordingState.idle);
    });

    test('when idle throws', () {
      expect(() => engine.discard(), throwsStateError);
    });
  });

  // =========================================================================
  // State machine
  // =========================================================================

  group('RecordingEngine — state transitions', () {
    test('initial state is idle', () {
      expect(engine.state, RecordingState.idle);
      expect(engine.currentRide, isNull);
    });

    test('start transitions to recording', () async {
      final ride = await engine.start();

      expect(engine.state, RecordingState.recording);
      expect(ride.status, RideStatus.active);
      expect(engine.currentRide, isNotNull);
    });

    test('start fires RideEvent.started', () async {
      final events = <RideEvent>[];
      eventBus.on<RideEvent>().listen(events.add);

      await engine.start();

      await Future<void>.delayed(Duration.zero);
      expect(events, hasLength(1));
      expect(events.first, isA<RideStarted>());
    });

    test('pause transitions to paused', () async {
      await engine.start();
      engine.pause();

      expect(engine.state, RecordingState.paused);
    });

    test('pause fires RideEvent.paused', () async {
      await engine.start();

      final events = <RideEvent>[];
      eventBus.on<RideEvent>().listen(events.add);

      engine.pause();

      await Future<void>.delayed(Duration.zero);
      expect(events.first, isA<RidePaused>());
    });

    test('resume transitions back to recording', () async {
      await engine.start();
      engine.pause();
      engine.resume();

      expect(engine.state, RecordingState.recording);
    });

    test('stop transitions to idle and returns finished ride', () async {
      await engine.start();
      final ride = await engine.stop();

      expect(engine.state, RecordingState.idle);
      expect(ride.status, RideStatus.finished);
      expect(ride.endTime, isNotNull);
      expect(engine.currentRide, isNull);
    });

    test('stop fires RideEvent.stopped', () async {
      await engine.start();

      final events = <RideEvent>[];
      eventBus.on<RideEvent>().listen(events.add);

      await engine.stop();

      await Future<void>.delayed(Duration.zero);
      expect(events.any((e) => e is RideStopped), isTrue);
    });

    test('stateStream emits state transitions', () async {
      final states = <RecordingState>[];
      engine.stateStream.listen(states.add);

      await engine.start();
      engine.pause();
      engine.resume();
      await engine.stop();

      await Future<void>.delayed(Duration.zero);
      expect(states, [
        RecordingState.recording,
        RecordingState.paused,
        RecordingState.recording,
        RecordingState.idle,
      ]);
    });
  });

  // =========================================================================
  // Guard clauses
  // =========================================================================

  group('RecordingEngine — invalid transitions', () {
    test('start when already recording throws', () async {
      await engine.start();
      expect(() => engine.start(), throwsStateError);
    });

    test('pause when idle throws', () {
      expect(() => engine.pause(), throwsStateError);
    });

    test('resume when idle throws', () {
      expect(() => engine.resume(), throwsStateError);
    });

    test('resume when recording throws', () async {
      await engine.start();
      expect(() => engine.resume(), throwsStateError);
    });

    test('stop when idle throws', () {
      expect(() => engine.stop(), throwsStateError);
    });

    test('markLap when idle throws', () {
      expect(() => engine.markLap(), throwsStateError);
    });
  });

  // =========================================================================
  // 1 Hz data collection
  // =========================================================================

  group('RecordingEngine — data collection', () {
    test('collects sensor readings at 1 Hz', () async {
      await engine.start();

      // Emit a sensor event.
      eventBus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: DateTime.now(),
          power: const Watts(200),
          cadence: const Cadence(90),
        ),
        deviceId: 'test-sensor',
      ));

      // Wait for 2 ticks (2 seconds).
      await Future<void>.delayed(const Duration(milliseconds: 2200));

      final ride = await engine.stop();
      // Should have at least 2 readings (one per tick).
      expect(ride.readings.length, greaterThanOrEqualTo(2));
      expect(ride.readings.first.power?.value, 200);
      expect(ride.readings.first.cadence?.rpm, 90);
    });

    test('does not collect during pause', () async {
      await engine.start();

      eventBus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: DateTime.now(),
          power: const Watts(200),
        ),
        deviceId: 'test-sensor',
      ));

      // Collect 1 reading, then pause.
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      engine.pause();
      final readingsAtPause = engine.latestReading;
      expect(readingsAtPause, isNotNull);

      // Wait 2 seconds while paused.
      await Future<void>.delayed(const Duration(milliseconds: 2200));

      // Resume and collect 1 more.
      engine.resume();
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      final ride = await engine.stop();
      // Should have ~2 readings (1 before pause + 1 after), not 4-5.
      expect(ride.readings.length, lessThanOrEqualTo(3));
    });
  });

  // =========================================================================
  // Pause duration tracking
  // =========================================================================

  group('RecordingEngine — pause duration', () {
    test('tracks total pause duration', () async {
      await engine.start();

      // Pause for ~1 second.
      engine.pause();
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      engine.resume();

      // Pause again for ~1 second.
      engine.pause();
      await Future<void>.delayed(const Duration(milliseconds: 1100));

      final ride = await engine.stop();
      // pauseDuration should be ~2 seconds.
      expect(ride.pauseDuration.inMilliseconds, greaterThan(1500));
    });

    test('stop while paused closes the pause interval', () async {
      await engine.start();

      engine.pause();
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final ride = await engine.stop();
      expect(ride.pauseDuration.inMilliseconds, greaterThan(300));
    });
  });

  // =========================================================================
  // Laps
  // =========================================================================

  group('RecordingEngine — laps', () {
    test('markLap creates a lap with correct indices', () async {
      await engine.start();

      // Emit data and wait for readings to accumulate.
      eventBus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: DateTime.now(),
          power: const Watts(200),
        ),
        deviceId: 'test',
      ));
      await Future<void>.delayed(const Duration(milliseconds: 2200));

      final lap = engine.markLap();
      expect(lap.startIndex, 0);
      expect(lap.endIndex, greaterThanOrEqualTo(1));

      // Wait for more readings after the lap so stop() auto-closes a 2nd lap.
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      final ride = await engine.stop();
      // 1 manual lap + 1 auto-closed final lap.
      expect(ride.laps.length, 2);
    });

    test('markLap while paused works', () async {
      await engine.start();

      eventBus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: DateTime.now(),
          power: const Watts(100),
        ),
        deviceId: 'test',
      ));
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      engine.pause();
      final lap = engine.markLap();
      expect(lap.startIndex, 0);

      engine.resume();
      await engine.stop();
    });

    test('avgPowerForLap averages power over the lap reading range', () async {
      await engine.start();

      // First lap: 3 readings at 100 W.
      for (var i = 0; i < 3; i++) {
        eventBus.fire(SensorEvent(
          reading: SensorReading(
            timestamp: DateTime.now(),
            power: const Watts(100),
          ),
          deviceId: 'test',
        ));
        await Future<void>.delayed(const Duration(milliseconds: 1100));
      }
      final lap1 = engine.markLap();
      expect(engine.avgPowerForLap(lap1).value, closeTo(100, 1));

      // Second lap: 3 readings at 300 W — first lap's average must not
      // shift once later readings are appended.
      for (var i = 0; i < 3; i++) {
        eventBus.fire(SensorEvent(
          reading: SensorReading(
            timestamp: DateTime.now(),
            power: const Watts(300),
          ),
          deviceId: 'test',
        ));
        await Future<void>.delayed(const Duration(milliseconds: 1100));
      }
      final lap2 = engine.markLap();

      expect(engine.avgPowerForLap(lap1).value, closeTo(100, 1));
      expect(engine.avgPowerForLap(lap2).value, closeTo(300, 1));

      await engine.stop();
    });

    test('avgPowerForLap returns zero when there are no readings', () async {
      await engine.start();
      final lap = engine.markLap();
      expect(engine.avgPowerForLap(lap), Watts.zero);
      await engine.stop();
    });
  });

  // =========================================================================
  // Persistence
  // =========================================================================

  group('RecordingEngine — persistence', () {
    test('start saves initial ride', () async {
      await engine.start();

      verify(() => storage.saveRide(any())).called(1);
    });

    test('stop saves ride, readings, and laps', () async {
      await engine.start();

      eventBus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: DateTime.now(),
          power: const Watts(200),
        ),
        deviceId: 'test',
      ));
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      await engine.stop();

      // saveRide: once on start + once on stop = 2.
      verify(() => storage.saveRide(any())).called(2);
      verify(() => storage.saveSensorReadings(any(), any())).called(1);
      verify(() => storage.saveLaps(any(), any())).called(1);
    });

    test('auto-saves on its interval and stores each reading once', () async {
      final engine = RecordingEngine(
        eventBus: eventBus,
        storage: storage,
        autoSaveInterval: const Duration(seconds: 2),
      );
      await engine.start();
      eventBus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: DateTime.now(),
          power: const Watts(200),
        ),
        deviceId: 'test',
      ));
      await Future<void>.delayed(const Duration(milliseconds: 5200));
      final ride = await engine.stop();
      await engine.dispose();

      final saved = verify(
        () => storage.saveSensorReadings(any(), captureAny()),
      ).captured.cast<List<SensorReading>>();
      // Auto-saves after 2 and 4 s, then the stop saves the 5th second.
      expect(saved.map((chunk) => chunk.length), [2, 2, 1]);
      expect(saved.expand((chunk) => chunk), ride.readings);
    });

    test('a failed auto-save is retried by the next save', () async {
      var calls = 0;
      when(() => storage.saveSensorReadings(any(), any())).thenAnswer((_) {
        calls++;
        if (calls == 1) throw Exception('disk full');
        return Future<void>.value();
      });
      final engine = RecordingEngine(
        eventBus: eventBus,
        storage: storage,
        autoSaveInterval: const Duration(seconds: 2),
      );
      await engine.start();
      eventBus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: DateTime.now(),
          power: const Watts(200),
        ),
        deviceId: 'test',
      ));
      await Future<void>.delayed(const Duration(milliseconds: 3200));
      await engine.stop();
      await engine.dispose();

      final saved = verify(
        () => storage.saveSensorReadings(any(), captureAny()),
      ).captured.cast<List<SensorReading>>();
      expect(saved.map((chunk) => chunk.length), [2, 3]);
    });
  });

  // =========================================================================
  // Metrics on stop
  // =========================================================================

  group('RecordingEngine — metrics', () {
    test('stopped ride contains power metrics', () async {
      await engine.start();

      // Feed 5 readings at 250 W.
      for (var i = 0; i < 5; i++) {
        eventBus.fire(SensorEvent(
          reading: SensorReading(
            timestamp: DateTime.now(),
            power: const Watts(250),
            cadence: const Cadence(90),
            heartRate: const HeartRate(155),
          ),
          deviceId: 'test',
        ));
        await Future<void>.delayed(const Duration(milliseconds: 1100));
      }

      final ride = await engine.stop();

      expect(ride.readings, isNotEmpty);
      expect(ride.averagePower.value, closeTo(250, 1));
      expect(ride.maxPower.value, closeTo(250, 1));
      expect(ride.averageCadence.rpm, closeTo(90, 1));
      expect(ride.averageHr.bpm, closeTo(155, 1));
    });
  });

  // =========================================================================
  // FTP-at-time persistence (data hygiene for longitudinal metrics)
  // =========================================================================

  group('RecordingEngine — FTP-at-time metrics', () {
    test('stop with ftp persists the ride with that ftp', () async {
      await engine.start();
      await engine.stop(ftp: const Watts(200));

      verify(() => storage.saveRide(any(), ftp: const Watts(200))).called(1);
    });

    test('stop without ftp saves the ride without a named ftp argument',
        () async {
      await engine.start();
      await engine.stop();

      // start() + stop() both hit the no-ftp overload.
      verify(() => storage.saveRide(any())).called(2);
      verifyNever(() => storage.saveRide(any(), ftp: any(named: 'ftp')));
    });
  });

  // =========================================================================
  // Route simulation — distance/elevation fallback
  // =========================================================================

  group('RecordingEngine — route simulation', () {
    RoutePoint point({required double distance, required double elevation}) =>
        RoutePoint(
          position: const GeoPoint(lat: 45.0, lon: 6.0),
          distanceFromStart: distance,
          smoothedElevation: elevation,
          grade: const Grade(2.0),
        );

    test(
        'falls back to the simulator distance when the sensor reports none',
        () async {
      await engine.start();

      // Trainer reports power and speed but no distance (common for many
      // FTMS trainers) — the simulator's own physics-driven distance
      // should be stamped onto the reading instead of the trainer's speed
      // added up.
      eventBus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: DateTime.now(),
          power: const Watts(200),
          speed: const Speed(36),
        ),
        deviceId: 'test-trainer',
      ));
      eventBus.fire(SimulationEvent.positionChanged(
        point(distance: 123.4, elevation: 500),
        const Speed(8),
        123.4,
        5.0,
      ));
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      final ride = await engine.stop();
      expect(ride.readings.first.distance?.meters, closeTo(123.4, 0.01));
    });

    test('sensor-reported distance takes priority over the simulator',
        () async {
      await engine.start();

      eventBus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: DateTime.now(),
          power: const Watts(200),
          distance: const Distance(999),
        ),
        deviceId: 'test-trainer',
      ));
      eventBus.fire(SimulationEvent.positionChanged(
        point(distance: 123.4, elevation: 500),
        const Speed(8),
        123.4,
        5.0,
      ));
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      final ride = await engine.stop();
      // The trainer's distance (from the start of the ride, so 0 on the
      // first sample), not the simulator's 123.4.
      expect(ride.readings.first.distance?.meters, 0);
    });

    test('stop persists the latest simulator elevation gain on the ride',
        () async {
      await engine.start();

      eventBus.fire(SimulationEvent.positionChanged(
        point(distance: 50, elevation: 505),
        const Speed(8),
        50,
        5.0,
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      eventBus.fire(SimulationEvent.positionChanged(
        point(distance: 150, elevation: 520),
        const Speed(8),
        150,
        18.0,
      ));
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      final ride = await engine.stop();
      expect(ride.elevationGain?.meters, 18.0);
    });

    test('elevation gain is null for a ride with no route', () async {
      await engine.start();
      eventBus.fire(SensorEvent(
        reading: SensorReading(timestamp: DateTime.now(), power: const Watts(200)),
        deviceId: 'test-trainer',
      ));
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      final ride = await engine.stop();
      expect(ride.elevationGain, isNull);
    });
  });

  // =========================================================================
  // Personal records
  // =========================================================================

  group('RecordingEngine — personal records', () {
    test('stop persists personal-record candidates from the calculator',
        () async {
      final fixedRecords = [
        PersonalRecord(
          rideId: 'placeholder',
          durationSeconds: 300,
          watts: const Watts(280),
          achievedAt: DateTime(2026, 1, 1),
        ),
      ];
      final customEngine = RecordingEngine(
        eventBus: eventBus,
        storage: storage,
        personalRecordsCalculator: _FixedRecordsCalculator(fixedRecords),
      );

      await customEngine.start();
      await customEngine.stop();

      verify(() => storage.savePersonalRecords(fixedRecords)).called(1);

      await customEngine.dispose();
    });

    test('stop skips savePersonalRecords when there are no candidates',
        () async {
      await engine.start();
      await engine.stop();

      // The default engine's calculator sees far fewer than 5 readings in
      // this short test, so no duration bucket has enough data.
      verifyNever(() => storage.savePersonalRecords(any()));
    });
  });

  // =========================================================================
  // Distance — ridden since start, not the trainer's running counter
  // =========================================================================

  group('RecordingEngine — distance', () {
    void trainerAt(double meters) => eventBus.fire(SensorEvent(
          reading: SensorReading(
            timestamp: DateTime.now(),
            power: const Watts(200),
            distance: Distance(meters),
          ),
          deviceId: 'test-trainer',
        ));

    test('counts from the start of the ride, not the trainer counter',
        () async {
      await engine.start();
      // The trainer has been on for a while: its counter is far from 0.
      trainerAt(10000);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      trainerAt(10250);
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      final ride = await engine.stop();
      expect(ride.readings.map((r) => r.distance?.meters), [0, 250]);
      expect(ride.totalDistance.meters, 250);
    });

    test('leaves out distance pedalled while paused', () async {
      await engine.start();
      trainerAt(10000);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      engine.pause();
      trainerAt(10500);
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      engine.resume();
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      trainerAt(10600);
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      final ride = await engine.stop();
      expect(ride.totalDistance.meters, 100);
    });

    test('keeps counting when the trainer counter resets', () async {
      await engine.start();
      trainerAt(5000);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      trainerAt(5100);
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      // Reconnected: the counter starts again from 0.
      trainerAt(30);
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      final ride = await engine.stop();
      expect(ride.totalDistance.meters, 130);
    });

    void trainerSpeed(double kmh, {double? counter}) =>
        eventBus.fire(SensorEvent(
          reading: SensorReading(
            timestamp: DateTime.now(),
            power: const Watts(200),
            speed: Speed(kmh),
            distance: counter != null ? Distance(counter) : null,
          ),
          deviceId: 'test-trainer',
        ));

    test('adds up speed when the trainer sends no distance', () async {
      await engine.start();
      trainerSpeed(36); // 10 m/s
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      trainerSpeed(18); // 5 m/s
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      final ride = await engine.stop();
      expect(ride.readings.map((r) => r.distance?.meters),
          [closeTo(10, 1e-9), closeTo(15, 1e-9)]);
      expect(ride.totalDistance.meters, closeTo(15, 1e-9));
    });

    test('does not add speed to a counter sent in some notifications only',
        () async {
      await engine.start();
      trainerSpeed(36, counter: 1000);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      // A notification without the counter: its distance comes with the
      // next one.
      trainerSpeed(36);
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      trainerSpeed(36, counter: 1020);
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      final ride = await engine.stop();
      expect(ride.readings.map((r) => r.distance?.meters), [0, null, 20]);
      expect(ride.totalDistance.meters, 20);
    });
  });

  // =========================================================================
  // sampleStream
  // =========================================================================

  group('RecordingEngine — sampleStream', () {
    test('emits each reading as it is recorded, none while paused',
        () async {
      final samples = <SensorReading>[];
      engine.sampleStream.listen(samples.add);

      await engine.start();
      eventBus.fire(SensorEvent(
        reading: SensorReading(timestamp: DateTime.now(), power: const Watts(180)),
        deviceId: 'test-trainer',
      ));
      await Future<void>.delayed(const Duration(milliseconds: 2200));
      engine.pause();
      final atPause = samples.length;
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      expect(atPause, 2);
      expect(samples.length, atPause);
      expect(samples.first.power, const Watts(180));
      expect(samples, engine.liveRide!.readings);
    });
  });
}
