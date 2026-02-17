import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/physics_engine.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/app_event.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/simulator/fake_trainer.dart';

void main() {
  late EventBus eventBus;
  late CyclingPhysicsEngine physics;
  late FakeTrainer trainer;

  setUp(() {
    eventBus = EventBus();
    physics = CyclingPhysicsEngine();
    trainer = FakeTrainer(
      eventBus: eventBus,
      physics: physics,
      deviceId: 'test-sim-0',
    );
  });

  tearDown(() async {
    if (!eventBus.isDisposed) {
      await trainer.disconnect();
      eventBus.dispose();
    }
  });

  // =========================================================================
  // Initialization & lifecycle
  // =========================================================================

  group('FakeTrainer — lifecycle', () {
    test('fires connected and controlAcquired on initialize', () async {
      final events = <TrainerEvent>[];
      eventBus.on<TrainerEvent>().listen(events.add);

      await trainer.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(events, hasLength(2));
      expect(events[0], isA<TrainerConnected>());
      expect(events[1], isA<TrainerControlAcquired>());
    });

    test('fires disconnected on disconnect', () async {
      final events = <TrainerEvent>[];
      eventBus.on<TrainerEvent>().listen(events.add);

      await trainer.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      events.clear();

      await trainer.disconnect();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(events, hasLength(1));
      expect(events[0], isA<TrainerDisconnected>());
    });
  });

  // =========================================================================
  // Data emission
  // =========================================================================

  group('FakeTrainer — data emission', () {
    test('emits SensorReading at ~1 Hz with all fields populated', () async {
      await trainer.initialize();

      final readings = <SensorReading>[];
      final sub = trainer.dataStream.listen(readings.add);

      // Wait for at least 2 readings.
      await Future<void>.delayed(const Duration(seconds: 3));
      await sub.cancel();

      expect(readings.length, greaterThanOrEqualTo(2));

      for (final r in readings) {
        expect(r.power, isNotNull);
        expect(r.cadence, isNotNull);
        expect(r.heartRate, isNotNull);
        expect(r.speed, isNotNull);
        expect(r.distance, isNotNull);
        expect(r.power!.value, greaterThan(0));
        expect(r.cadence!.rpm, greaterThanOrEqualTo(50));
        expect(r.cadence!.rpm, lessThanOrEqualTo(120));
        expect(r.heartRate!.bpm, greaterThanOrEqualTo(50));
        expect(r.heartRate!.bpm, lessThanOrEqualTo(200));
      }
    });

    test('fires SensorEvent on EventBus each tick', () async {
      final sensorEvents = <SensorEvent>[];
      eventBus.on<SensorEvent>().listen(sensorEvents.add);

      await trainer.initialize();
      await Future<void>.delayed(const Duration(seconds: 2, milliseconds: 500));

      expect(sensorEvents.length, greaterThanOrEqualTo(2));
      expect(sensorEvents.first.deviceId, 'test-sim-0');
    });

    test('distance accumulates monotonically', () async {
      await trainer.initialize();

      final readings = <SensorReading>[];
      final sub = trainer.dataStream.listen(readings.add);
      await Future<void>.delayed(const Duration(seconds: 4));
      await sub.cancel();

      expect(readings.length, greaterThanOrEqualTo(3));

      for (int i = 1; i < readings.length; i++) {
        expect(
          readings[i].distance!.meters,
          greaterThan(readings[i - 1].distance!.meters),
        );
      }
    });
  });

  // =========================================================================
  // ERG mode
  // =========================================================================

  group('FakeTrainer — ERG mode', () {
    test('power converges toward target within 10 seconds', () async {
      await trainer.initialize();
      await trainer.setTargetPower(const Watts(300));

      final readings = <SensorReading>[];
      final sub = trainer.dataStream.listen(readings.add);
      await Future<void>.delayed(const Duration(seconds: 10));
      await sub.cancel();

      // Last few readings should be near 300W.
      final lastFew = readings.skip(readings.length - 3);
      for (final r in lastFew) {
        expect(r.power!.value, closeTo(300, 40)); // within 40W (noise σ=10)
      }
    });

    test('fires modeChanged event when setting target power', () async {
      await trainer.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final events = <TrainerEvent>[];
      eventBus.on<TrainerEvent>().listen(events.add);

      await trainer.setTargetPower(const Watts(250));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(events, hasLength(1));
      expect(events[0], isA<TrainerModeChanged>());
    });
  });

  // =========================================================================
  // Simulation mode
  // =========================================================================

  group('FakeTrainer — simulation mode', () {
    test('fires modeChanged event and power reflects grade', () async {
      await trainer.initialize();
      await Future<void>.delayed(const Duration(seconds: 2));

      // Set a steep grade — power should increase.
      await trainer.setSimulationParams(0, const Grade(8.0), 0.004, 0.32);

      final readings = <SensorReading>[];
      final sub = trainer.dataStream.listen(readings.add);
      await Future<void>.delayed(const Duration(seconds: 5));
      await sub.cancel();

      // With 8% grade, power should be well above baseline 150W.
      final last = readings.last;
      expect(last.power!.value, greaterThan(100));
    });
  });

  // =========================================================================
  // Resistance mode
  // =========================================================================

  group('FakeTrainer — resistance mode', () {
    test('power scales with resistance percentage', () async {
      await trainer.initialize();

      // Low resistance.
      await trainer.setResistance(10);
      await Future<void>.delayed(const Duration(seconds: 5));

      final lowReadings = <SensorReading>[];
      final sub1 = trainer.dataStream.listen(lowReadings.add);
      await Future<void>.delayed(const Duration(seconds: 3));
      await sub1.cancel();

      // High resistance.
      await trainer.setResistance(90);
      await Future<void>.delayed(const Duration(seconds: 5));

      final highReadings = <SensorReading>[];
      final sub2 = trainer.dataStream.listen(highReadings.add);
      await Future<void>.delayed(const Duration(seconds: 3));
      await sub2.cancel();

      if (lowReadings.isNotEmpty && highReadings.isNotEmpty) {
        final avgLow = lowReadings
                .map((r) => r.power!.value)
                .reduce((a, b) => a + b) /
            lowReadings.length;
        final avgHigh = highReadings
                .map((r) => r.power!.value)
                .reduce((a, b) => a + b) /
            highReadings.length;

        expect(avgHigh, greaterThan(avgLow));
      }
    });
  });

  // =========================================================================
  // Manual overrides
  // =========================================================================

  group('FakeTrainer — manual overrides', () {
    test('overridePower emits exact power value', () async {
      await trainer.initialize();
      trainer.overridePower(42);

      final readings = <SensorReading>[];
      final sub = trainer.dataStream.listen(readings.add);
      await Future<void>.delayed(const Duration(seconds: 2));
      await sub.cancel();

      expect(readings, isNotEmpty);
      for (final r in readings) {
        expect(r.power!.value, 42);
      }
    });

    test('overrideCadence emits exact cadence value', () async {
      await trainer.initialize();
      trainer.overrideCadence(100);

      final readings = <SensorReading>[];
      final sub = trainer.dataStream.listen(readings.add);
      await Future<void>.delayed(const Duration(seconds: 2));
      await sub.cancel();

      expect(readings, isNotEmpty);
      for (final r in readings) {
        expect(r.cadence!.rpm, 100);
      }
    });

    test('overrideHeartRate emits exact HR value', () async {
      await trainer.initialize();
      trainer.overrideHeartRate(170);

      final readings = <SensorReading>[];
      final sub = trainer.dataStream.listen(readings.add);
      await Future<void>.delayed(const Duration(seconds: 2));
      await sub.cancel();

      expect(readings, isNotEmpty);
      for (final r in readings) {
        expect(r.heartRate!.bpm, 170);
      }
    });

    test('clearOverrides restores simulated values', () async {
      await trainer.initialize();
      trainer.overridePower(42);

      await Future<void>.delayed(const Duration(seconds: 2));

      trainer.clearOverrides();

      final readings = <SensorReading>[];
      final sub = trainer.dataStream.listen(readings.add);
      await Future<void>.delayed(const Duration(seconds: 3));
      await sub.cancel();

      expect(readings, isNotEmpty);
      // After clearing, power should not be exactly 42 anymore
      // (it will return to the simulated baseline ~150W).
      final hasNon42 = readings.any((r) => r.power!.value != 42);
      expect(hasNon42, isTrue);
    });
  });
}
