import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/physics_engine.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';

void main() {
  late CyclingPhysicsEngine engine;

  setUp(() {
    engine = CyclingPhysicsEngine();
  });

  // ===========================================================================
  // calculateSpeed — flat road
  // ===========================================================================

  group('CyclingPhysicsEngine — flat road speed', () {
    test('300W on flat ≈ 38 km/h', () {
      final speed = engine.calculateSpeed(
        power: const Watts(300),
        grade: Grade.flat,
        mass: 80,
      );
      expect(speed.kmh, closeTo(38, 3));
    });

    test('200W on flat ≈ 32 km/h', () {
      final speed = engine.calculateSpeed(
        power: const Watts(200),
        grade: Grade.flat,
        mass: 80,
      );
      expect(speed.kmh, closeTo(32, 3));
    });

    test('0W yields 0 km/h', () {
      final speed = engine.calculateSpeed(
        power: Watts.zero,
        grade: Grade.flat,
      );
      expect(speed.kmh, 0);
    });
  });

  // ===========================================================================
  // calculateSpeed — climbing
  // ===========================================================================

  group('CyclingPhysicsEngine — climbing', () {
    test('200W on 8% grade ≈ 11 km/h', () {
      final speed = engine.calculateSpeed(
        power: const Watts(200),
        grade: const Grade(8),
        mass: 80,
      );
      expect(speed.kmh, closeTo(11, 3));
    });

    test('300W on 5% grade ≈ 21 km/h', () {
      final speed = engine.calculateSpeed(
        power: const Watts(300),
        grade: const Grade(5),
        mass: 80,
      );
      // Martin model with drivetrain efficiency yields ~21 km/h.
      expect(speed.kmh, closeTo(21, 3));
    });
  });

  // ===========================================================================
  // calculateSpeed — descending
  // ===========================================================================

  group('CyclingPhysicsEngine — descending', () {
    test('100W on -5% grade yields faster than flat', () {
      final flatSpeed = engine.calculateSpeed(
        power: const Watts(100),
        grade: Grade.flat,
        mass: 80,
      );
      final downhillSpeed = engine.calculateSpeed(
        power: const Watts(100),
        grade: const Grade(-5),
        mass: 80,
      );
      expect(downhillSpeed.kmh, greaterThan(flatSpeed.kmh));
    });
  });

  // ===========================================================================
  // Newton-Raphson convergence
  // ===========================================================================

  group('CyclingPhysicsEngine — Newton-Raphson convergence', () {
    test('converges for very low power', () {
      final speed = engine.calculateSpeed(
        power: const Watts(10),
        grade: Grade.flat,
      );
      expect(speed.kmh, greaterThan(0));
    });

    test('converges for very high power', () {
      final speed = engine.calculateSpeed(
        power: const Watts(1500),
        grade: Grade.flat,
      );
      expect(speed.kmh, greaterThan(0));
    });

    test('converges on steep grade', () {
      final speed = engine.calculateSpeed(
        power: const Watts(300),
        grade: const Grade(20),
        mass: 80,
      );
      expect(speed.kmh, greaterThan(0));
    });
  });

  // ===========================================================================
  // calculateRequiredPower
  // ===========================================================================

  group('CyclingPhysicsEngine — calculateRequiredPower', () {
    test('0 speed requires 0 power', () {
      final power = engine.calculateRequiredPower(
        speed: Speed.zero,
        grade: Grade.flat,
      );
      expect(power.value, 0);
    });

    test('power at 38 km/h flat ≈ 300W', () {
      final power = engine.calculateRequiredPower(
        speed: const Speed(38),
        grade: Grade.flat,
        mass: 80,
      );
      expect(power.value, closeTo(300, 30));
    });
  });

  // ===========================================================================
  // Round-trip consistency
  // ===========================================================================

  group('CyclingPhysicsEngine — round-trip', () {
    test('speed → power → speed is consistent', () {
      const inputPower = Watts(250);
      const grade = Grade(3);

      final speed = engine.calculateSpeed(
        power: inputPower,
        grade: grade,
        mass: 75,
      );
      final recoveredPower = engine.calculateRequiredPower(
        speed: speed,
        grade: grade,
        mass: 75,
      );
      expect(recoveredPower.value, closeTo(inputPower.value, 2));
    });

    test('power → speed → power is consistent', () {
      const inputSpeed = Speed(30);
      const grade = Grade(-2);

      final power = engine.calculateRequiredPower(
        speed: inputSpeed,
        grade: grade,
        mass: 80,
      );
      final recoveredSpeed = engine.calculateSpeed(
        power: power,
        grade: grade,
        mass: 80,
      );
      expect(recoveredSpeed.kmh, closeTo(inputSpeed.kmh, 0.5));
    });
  });

  // ===========================================================================
  // Backward-compatible wrappers
  // ===========================================================================

  group('CyclingPhysicsEngine — legacy wrappers', () {
    test('estimateSpeed delegates to calculateSpeed', () {
      final a = engine.calculateSpeed(
        power: const Watts(200),
        grade: Grade.flat,
        mass: 80,
      );
      final b = engine.estimateSpeed(
        power: const Watts(200),
        grade: Grade.flat,
        weight: 80,
      );
      expect(a.kmh, b.kmh);
    });

    test('estimatePower delegates to calculateRequiredPower', () {
      final a = engine.calculateRequiredPower(
        speed: const Speed(30),
        grade: Grade.flat,
        mass: 80,
      );
      final b = engine.estimatePower(
        speed: const Speed(30),
        grade: Grade.flat,
        weight: 80,
      );
      expect(a.value, b.value);
    });
  });

  // ===========================================================================
  // Wind
  // ===========================================================================

  group('CyclingPhysicsEngine — wind effect', () {
    test('headwind reduces speed', () {
      final noWind = engine.calculateSpeed(
        power: const Watts(200),
        grade: Grade.flat,
      );
      final headwind = engine.calculateSpeed(
        power: const Watts(200),
        grade: Grade.flat,
        windSpeed: 5,
      );
      expect(headwind.kmh, lessThan(noWind.kmh));
    });

    test('tailwind increases speed', () {
      final noWind = engine.calculateSpeed(
        power: const Watts(200),
        grade: Grade.flat,
      );
      final tailwind = engine.calculateSpeed(
        power: const Watts(200),
        grade: Grade.flat,
        windSpeed: -5,
      );
      expect(tailwind.kmh, greaterThan(noWind.kmh));
    });
  });
}
