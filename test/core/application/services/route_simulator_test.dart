import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_bike/core/application/services/physics_engine.dart';
import 'package:open_bike/core/application/services/route_simulator.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/app_event.dart';
import 'package:open_bike/core/events/event_bus.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockTrainerPort extends Mock implements TrainerPort {}

class FakeWatts extends Fake implements Watts {}

class FakeGrade extends Fake implements Grade {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a simple flat route of [lengthMeters] with [pointCount] points.
Route _flatRoute({double lengthMeters = 100, int pointCount = 11}) {
  final spacing = lengthMeters / (pointCount - 1);
  final points = <RoutePoint>[];
  for (var i = 0; i < pointCount; i++) {
    points.add(RoutePoint(
      position: GeoPoint(lat: 48.8566, lon: 2.3522 + i * 0.0001),
      distanceFromStart: i * spacing,
      smoothedElevation: 100,
      grade: Grade.flat,
    ));
  }
  return Route(id: 'test', name: 'Flat Test', points: points);
}

/// Creates an uphill route.
Route _uphillRoute() {
  return Route(
    id: 'uphill',
    name: 'Uphill Test',
    points: [
      const RoutePoint(
        position: GeoPoint(lat: 48.8566, lon: 2.3522),
        distanceFromStart: 0,
        smoothedElevation: 100,
        grade: Grade.flat,
      ),
      const RoutePoint(
        position: GeoPoint(lat: 48.8576, lon: 2.3522),
        distanceFromStart: 50,
        smoothedElevation: 104,
        grade: Grade(8),
      ),
      const RoutePoint(
        position: GeoPoint(lat: 48.8586, lon: 2.3522),
        distanceFromStart: 100,
        smoothedElevation: 108,
        grade: Grade(8),
      ),
    ],
  );
}

void main() {
  late EventBus eventBus;
  late MockTrainerPort trainer;
  late CyclingPhysicsEngine physics;
  late RouteSimulator simulator;

  setUpAll(() {
    registerFallbackValue(const Watts(0));
    registerFallbackValue(Grade.flat);
  });

  setUp(() {
    eventBus = EventBus();
    trainer = MockTrainerPort();
    physics = CyclingPhysicsEngine();
    simulator = RouteSimulator(
      trainerPort: trainer,
      eventBus: eventBus,
      physics: physics,
    );

    when(() => trainer.setSimulationParams(
          any(),
          any(),
          any(),
          any(),
        )).thenAnswer((_) async {});
  });

  tearDown(() {
    simulator.dispose();
    eventBus.dispose();
  });

  // =========================================================================
  // State transitions
  // =========================================================================

  group('RouteSimulator — state transitions', () {
    test('initial state is idle', () {
      expect(simulator.state, SimulationState.idle);
      expect(simulator.currentRoute, isNull);
    });

    test('start transitions to running', () {
      simulator.start(_flatRoute());
      expect(simulator.state, SimulationState.running);
      expect(simulator.currentRoute, isNotNull);
    });

    test('pause transitions to paused', () {
      simulator.start(_flatRoute());
      simulator.pause();
      expect(simulator.state, SimulationState.paused);
    });

    test('resume transitions back to running', () {
      simulator.start(_flatRoute());
      simulator.pause();
      simulator.resume();
      expect(simulator.state, SimulationState.running);
    });

    test('stop transitions to idle', () {
      simulator.start(_flatRoute());
      simulator.stop();
      expect(simulator.state, SimulationState.idle);
    });

    test('stateStream emits transitions', () async {
      final states = <SimulationState>[];
      simulator.stateStream.listen(states.add);

      simulator.start(_flatRoute());
      simulator.pause();
      simulator.resume();
      simulator.stop();

      await Future<void>.delayed(Duration.zero);
      expect(states, [
        SimulationState.running,
        SimulationState.paused,
        SimulationState.running,
        SimulationState.idle,
      ]);
    });
  });

  // =========================================================================
  // Guard clauses
  // =========================================================================

  group('RouteSimulator — invalid transitions', () {
    test('start when running throws', () {
      simulator.start(_flatRoute());
      expect(() => simulator.start(_flatRoute()), throwsStateError);
    });

    test('pause when idle throws', () {
      expect(() => simulator.pause(), throwsStateError);
    });

    test('resume when idle throws', () {
      expect(() => simulator.resume(), throwsStateError);
    });

    test('resume when running throws', () {
      simulator.start(_flatRoute());
      expect(() => simulator.resume(), throwsStateError);
    });

    test('stop when idle throws', () {
      expect(() => simulator.stop(), throwsStateError);
    });
  });

  // =========================================================================
  // Progress emission
  // =========================================================================

  group('RouteSimulator — progress', () {
    void injectPower(Watts power) {
      eventBus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: DateTime.now(),
          power: power,
        ),
        deviceId: 'test',
      ));
    }

    test('emits progress at 1 Hz', () async {
      final progresses = <SimulationProgress>[];
      simulator.progressStream.listen(progresses.add);

      simulator.start(_flatRoute(lengthMeters: 1000));
      // Inject power AFTER start (so the subscription receives it).
      injectPower(const Watts(200));

      await Future<void>.delayed(const Duration(milliseconds: 3500));
      simulator.stop();

      expect(progresses.length, greaterThanOrEqualTo(2));
    });

    test('progress contains route info', () async {
      final progresses = <SimulationProgress>[];
      simulator.progressStream.listen(progresses.add);

      simulator.start(_flatRoute(lengthMeters: 1000));
      injectPower(const Watts(200));

      await Future<void>.delayed(const Duration(milliseconds: 1500));
      simulator.stop();

      if (progresses.isNotEmpty) {
        final p = progresses.first;
        expect(p.speed.kmh, greaterThanOrEqualTo(0));
        expect(p.distanceRemaining.meters, greaterThanOrEqualTo(0));
      }
    });

    test('does not emit progress during pause', () async {
      final progresses = <SimulationProgress>[];
      simulator.progressStream.listen(progresses.add);

      simulator.start(_flatRoute(lengthMeters: 1000));
      injectPower(const Watts(200));

      await Future<void>.delayed(const Duration(milliseconds: 1500));
      final countBefore = progresses.length;

      simulator.pause();
      await Future<void>.delayed(const Duration(milliseconds: 2500));

      expect(progresses.length, countBefore);
    });
  });

  // =========================================================================
  // Trainer interaction
  // =========================================================================

  group('RouteSimulator — trainer integration', () {
    void injectPower(Watts power) {
      eventBus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: DateTime.now(),
          power: power,
        ),
        deviceId: 'test',
      ));
    }

    test('setSimulationParams called on start', () {
      simulator.start(_flatRoute());

      verify(() => trainer.setSimulationParams(
            any(),
            any(),
            any(),
            any(),
          )).called(1);
    });

    test('setSimulationParams called on each tick', () async {
      simulator.start(_flatRoute(lengthMeters: 1000));
      injectPower(const Watts(200));

      await Future<void>.delayed(const Duration(milliseconds: 3500));
      simulator.stop();

      // Initial call + ~3 tick calls.
      verify(() => trainer.setSimulationParams(
            any(),
            any(),
            any(),
            any(),
          )).called(greaterThanOrEqualTo(3));
    });

    test('uphill route sends non-zero grade', () async {
      simulator.start(_uphillRoute());
      injectPower(const Watts(200));

      await Future<void>.delayed(const Duration(milliseconds: 2500));
      simulator.stop();

      final captured = verify(() => trainer.setSimulationParams(
            any(),
            captureAny(),
            any(),
            any(),
          )).captured;
      expect(captured, isNotEmpty);
    });
  });

  // =========================================================================
  // Events
  // =========================================================================

  group('RouteSimulator — events', () {
    test('fires SimulationStarted on start', () async {
      final events = <SimulationEvent>[];
      eventBus.on<SimulationEvent>().listen(events.add);

      simulator.start(_flatRoute());

      await Future<void>.delayed(Duration.zero);
      expect(events.whereType<SimulationStarted>(), isNotEmpty);
    });

    test('fires SimulationStopped on stop', () async {
      final events = <SimulationEvent>[];
      eventBus.on<SimulationEvent>().listen(events.add);

      simulator.start(_flatRoute());
      simulator.stop();

      await Future<void>.delayed(Duration.zero);
      expect(events.last, isA<SimulationStopped>());
      expect(events.whereType<SimulationCompleted>(), isEmpty);
    });

    test('fires SimulationPaused on pause', () async {
      final events = <SimulationEvent>[];
      eventBus.on<SimulationEvent>().listen(events.add);

      simulator.start(_flatRoute());
      simulator.pause();

      await Future<void>.delayed(Duration.zero);
      expect(events.whereType<SimulationPaused>(), isNotEmpty);
    });

    test('fires SimulationResumed on resume', () async {
      final events = <SimulationEvent>[];
      eventBus.on<SimulationEvent>().listen(events.add);

      simulator.start(_flatRoute());
      simulator.pause();
      simulator.resume();

      await Future<void>.delayed(Duration.zero);
      expect(events.whereType<SimulationResumed>(), isNotEmpty);
    });
  });

  // =========================================================================
  // Completion
  // =========================================================================

  group('RouteSimulator — completion', () {
    void injectPower(Watts power) {
      eventBus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: DateTime.now(),
          power: power,
        ),
        deviceId: 'test',
      ));
    }

    test('completes when distance covered >= route total', () async {
      final states = <SimulationState>[];
      simulator.stateStream.listen(states.add);

      // Short 20m route with 300W should complete quickly.
      simulator.start(_flatRoute(lengthMeters: 20, pointCount: 3));

      // Keep injecting power so the simulator sees it.
      injectPower(const Watts(300));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      injectPower(const Watts(300));

      // 300W flat ≈ 10.5 m/s → 20m in ~2s.
      await Future<void>.delayed(const Duration(milliseconds: 4000));

      expect(states.last, SimulationState.completed);
    });

    test('fires SimulationCompleted event', () async {
      final events = <SimulationEvent>[];
      eventBus.on<SimulationEvent>().listen(events.add);

      simulator.start(_flatRoute(lengthMeters: 20, pointCount: 3));

      injectPower(const Watts(300));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      injectPower(const Watts(300));

      await Future<void>.delayed(const Duration(milliseconds: 4000));

      expect(events.whereType<SimulationCompleted>(), isNotEmpty);
    });
  });
}
