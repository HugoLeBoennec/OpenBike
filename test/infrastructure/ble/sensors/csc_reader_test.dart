import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/infrastructure/ble/sensors/csc_reader.dart';

void main() {
  late CscReader reader;

  setUp(() {
    reader = CscReader();
  });

  group('CscReader — parse', () {
    // -----------------------------------------------------------------------
    // Edge cases
    // -----------------------------------------------------------------------

    test('returns null for empty payload', () {
      expect(reader.parse([]), isNull);
    });

    // -----------------------------------------------------------------------
    // No data flags — only flags byte
    // -----------------------------------------------------------------------

    test('parses flags-only payload (no wheel, no crank)', () {
      final raw = [0x00]; // no optional data

      final result = reader.parse(raw)!;
      expect(result.wheelRevolutions, isNull);
      expect(result.lastWheelEventTime, isNull);
      expect(result.crankRevolutions, isNull);
      expect(result.lastCrankEventTime, isNull);
    });

    // -----------------------------------------------------------------------
    // Wheel Revolution Data only (bit 0) — speed sensor
    // -----------------------------------------------------------------------
    //
    // Flags: 0x01 → wheel data present
    // Wheel revs: 5000 (UINT32 LE)
    // Last wheel event: 2048 (UINT16 LE, in 1/1024 s = 2.0 s)

    test('parses wheel-only data (speed sensor)', () {
      final raw = [
        0x01, // flags
        0x88, 0x13, 0x00, 0x00, // wheel revs: 5000
        0x00, 0x08, // last wheel event: 2048
      ];

      final result = reader.parse(raw)!;
      expect(result.wheelRevolutions, 5000);
      expect(result.lastWheelEventTime, 2048);
      expect(result.crankRevolutions, isNull);
      expect(result.lastCrankEventTime, isNull);
    });

    // -----------------------------------------------------------------------
    // Crank Revolution Data only (bit 1) — cadence sensor
    // -----------------------------------------------------------------------
    //
    // Flags: 0x02 → crank data present
    // Crank revs: 300 (UINT16 LE)
    // Last crank event: 4096 (UINT16 LE, in 1/1024 s = 4.0 s)

    test('parses crank-only data (cadence sensor)', () {
      final raw = [
        0x02, // flags
        0x2C, 0x01, // crank revs: 300
        0x00, 0x10, // last crank event: 4096
      ];

      final result = reader.parse(raw)!;
      expect(result.wheelRevolutions, isNull);
      expect(result.crankRevolutions, 300);
      expect(result.lastCrankEventTime, 4096);
    });

    // -----------------------------------------------------------------------
    // Both wheel + crank data (bit 0 + bit 1) — combo sensor (Wahoo SC)
    // -----------------------------------------------------------------------

    test('parses both wheel and crank data (Wahoo SC combo)', () {
      final raw = [
        0x03, // flags: wheel + crank
        0xE8, 0x03, 0x00, 0x00, // wheel revs: 1000
        0x00, 0x04, // last wheel event: 1024
        0xC8, 0x00, // crank revs: 200
        0x00, 0x08, // last crank event: 2048
      ];

      final result = reader.parse(raw)!;
      expect(result.wheelRevolutions, 1000);
      expect(result.lastWheelEventTime, 1024);
      expect(result.crankRevolutions, 200);
      expect(result.lastCrankEventTime, 2048);
    });

    // -----------------------------------------------------------------------
    // Truncated payloads
    // -----------------------------------------------------------------------

    test('returns null for truncated wheel data', () {
      // Flags say wheel data (bit 0) but only 3 bytes follow (need 6)
      final raw = [0x01, 0xE8, 0x03, 0x00];

      expect(reader.parse(raw), isNull);
    });

    test('returns null for truncated crank data', () {
      // Flags say crank data (bit 1) but only 2 bytes follow (need 4)
      final raw = [0x02, 0xC8, 0x00];

      expect(reader.parse(raw), isNull);
    });
  });

  // =========================================================================
  // computeSpeed
  // =========================================================================

  group('CscReader — computeSpeed', () {
    test('returns null on first call (seeds state)', () {
      const data = CscMeasurement(
        wheelRevolutions: 1000,
        lastWheelEventTime: 2048,
      );

      expect(reader.computeSpeed(data), isNull);
    });

    test('returns null when no wheel data present', () {
      const data = CscMeasurement(crankRevolutions: 100, lastCrankEventTime: 1024);

      expect(reader.computeSpeed(data), isNull);
    });

    test('computes speed at ~30 km/h', () {
      // 30 km/h = 8.333 m/s
      // With 2.105m circumference: 8.333 / 2.105 ≈ 3.958 rev/s
      // In 2 seconds: ~7.917 revolutions → round to 8 revs in 2048 time units

      const first = CscMeasurement(
        wheelRevolutions: 1000,
        lastWheelEventTime: 10000,
      );
      expect(reader.computeSpeed(first), isNull);

      // 8 wheel revs in 2 seconds (2048 time units)
      // distance = 8 × 2.105 = 16.84 m
      // time = 2048 / 1024 = 2.0 s
      // speed = (16.84 / 2.0) × 3.6 = 30.312 km/h
      const second = CscMeasurement(
        wheelRevolutions: 1008,
        lastWheelEventTime: 12048,
      );
      expect(reader.computeSpeed(second), closeTo(30.312, 0.1));
    });

    test('computes speed with default wheel circumference (2.105m)', () {
      const first = CscMeasurement(
        wheelRevolutions: 0,
        lastWheelEventTime: 0,
      );
      expect(reader.computeSpeed(first), isNull);

      // 1 revolution in exactly 1 second
      // distance = 1 × 2.105 = 2.105 m
      // speed = 2.105 m/s × 3.6 = 7.578 km/h
      const second = CscMeasurement(
        wheelRevolutions: 1,
        lastWheelEventTime: 1024,
      );
      expect(reader.computeSpeed(second), closeTo(7.578, 0.01));
    });

    test('uses custom wheel circumference', () {
      final customReader = CscReader(wheelCircumference: 2.0);

      const first = CscMeasurement(
        wheelRevolutions: 0,
        lastWheelEventTime: 0,
      );
      expect(customReader.computeSpeed(first), isNull);

      // 1 rev in 1 sec with 2.0m circumference → 2.0 m/s → 7.2 km/h
      const second = CscMeasurement(
        wheelRevolutions: 1,
        lastWheelEventTime: 1024,
      );
      expect(customReader.computeSpeed(second), closeTo(7.2, 0.01));
    });

    test('handles UINT32 rollover for wheel revolutions', () {
      const first = CscMeasurement(
        wheelRevolutions: 4294967294, // 2^32 - 2
        lastWheelEventTime: 1024,
      );
      expect(reader.computeSpeed(first), isNull);

      // Rollover: 4294967294 → 1 (Δ = 3 after adding 2^32)
      // Δtime = 1024 → 1 second
      // distance = 3 × 2.105 = 6.315 m
      // speed = 6.315 × 3.6 = 22.734 km/h
      const second = CscMeasurement(
        wheelRevolutions: 1,
        lastWheelEventTime: 2048,
      );
      expect(reader.computeSpeed(second), closeTo(22.734, 0.1));
    });

    test('handles UINT16 rollover for wheel event time', () {
      const first = CscMeasurement(
        wheelRevolutions: 100,
        lastWheelEventTime: 65000,
      );
      expect(reader.computeSpeed(first), isNull);

      // Time rollover: 65000 → 488 (Δ = 65536 - 65000 + 488 = 1024 → 1 sec)
      // 5 revolutions → distance = 5 × 2.105 = 10.525 m
      // speed = 10.525 × 3.6 = 37.89 km/h
      const second = CscMeasurement(
        wheelRevolutions: 105,
        lastWheelEventTime: 488,
      );
      expect(reader.computeSpeed(second), closeTo(37.89, 0.1));
    });

    test('returns null for zero delta revolutions (stopped)', () {
      const first = CscMeasurement(
        wheelRevolutions: 100,
        lastWheelEventTime: 1024,
      );
      expect(reader.computeSpeed(first), isNull);

      const second = CscMeasurement(
        wheelRevolutions: 100, // no movement
        lastWheelEventTime: 2048,
      );
      expect(reader.computeSpeed(second), isNull);
    });

    test('rejects speed above 150 km/h', () {
      const first = CscMeasurement(
        wheelRevolutions: 100,
        lastWheelEventTime: 1024,
      );
      expect(reader.computeSpeed(first), isNull);

      // 100 revs in 1 second → distance = 100 × 2.105 = 210.5 m
      // speed = 210.5 × 3.6 = 757.8 km/h → rejected
      const second = CscMeasurement(
        wheelRevolutions: 200,
        lastWheelEventTime: 2048,
      );
      expect(reader.computeSpeed(second), isNull);
    });
  });

  // =========================================================================
  // computeCadence
  // =========================================================================

  group('CscReader — computeCadence', () {
    test('returns null on first call', () {
      const data = CscMeasurement(
        crankRevolutions: 50,
        lastCrankEventTime: 1024,
      );

      expect(reader.computeCadence(data), isNull);
    });

    test('returns null when no crank data present', () {
      const data = CscMeasurement(
        wheelRevolutions: 100,
        lastWheelEventTime: 2048,
      );

      expect(reader.computeCadence(data), isNull);
    });

    test('computes 90 RPM cadence', () {
      const first = CscMeasurement(
        crankRevolutions: 100,
        lastCrankEventTime: 1024,
      );
      expect(reader.computeCadence(first), isNull);

      // 3 revolutions in 2 seconds → cadence = (3/2) × 60 = 90 RPM
      const second = CscMeasurement(
        crankRevolutions: 103,
        lastCrankEventTime: 3072, // Δ = 2048 = 2.0 s
      );
      expect(reader.computeCadence(second), closeTo(90.0, 0.1));
    });

    test('handles UINT16 rollover for crank revolutions', () {
      const first = CscMeasurement(
        crankRevolutions: 65534,
        lastCrankEventTime: 1024,
      );
      expect(reader.computeCadence(first), isNull);

      // 65534 → 0 (Δ = 2), Δtime = 1024 → 1 sec
      // cadence = (2/1) × 60 = 120 RPM
      const second = CscMeasurement(
        crankRevolutions: 0,
        lastCrankEventTime: 2048,
      );
      expect(reader.computeCadence(second), closeTo(120.0, 0.1));
    });

    test('rejects cadence above 250 RPM', () {
      const first = CscMeasurement(
        crankRevolutions: 100,
        lastCrankEventTime: 1024,
      );
      expect(reader.computeCadence(first), isNull);

      // 10 revolutions in 1 second = 600 RPM → rejected
      const second = CscMeasurement(
        crankRevolutions: 110,
        lastCrankEventTime: 2048,
      );
      expect(reader.computeCadence(second), isNull);
    });

    test('returns null for zero delta (no pedaling)', () {
      const first = CscMeasurement(
        crankRevolutions: 100,
        lastCrankEventTime: 1024,
      );
      expect(reader.computeCadence(first), isNull);

      const second = CscMeasurement(
        crankRevolutions: 100,
        lastCrankEventTime: 2048,
      );
      expect(reader.computeCadence(second), isNull);
    });
  });

  // =========================================================================
  // toSensorReading
  // =========================================================================

  group('CscReader — toSensorReading', () {
    test('maps speed and cadence to domain SensorReading', () {
      final reading = reader.toSensorReading(speedKmh: 30.0, cadence: 90.0);

      expect(reading.speed?.kmh, 30.0);
      expect(reading.cadence?.rpm, 90.0);
      expect(reading.power, isNull);
      expect(reading.heartRate, isNull);
    });

    test('maps speed only', () {
      final reading = reader.toSensorReading(speedKmh: 25.0);

      expect(reading.speed?.kmh, 25.0);
      expect(reading.cadence, isNull);
    });

    test('maps cadence only', () {
      final reading = reader.toSensorReading(cadence: 85.0);

      expect(reading.speed, isNull);
      expect(reading.cadence?.rpm, 85.0);
    });
  });

  // =========================================================================
  // reset
  // =========================================================================

  group('CscReader — reset', () {
    test('reset clears all internal state', () {
      // Seed both wheel and crank state.
      const first = CscMeasurement(
        wheelRevolutions: 100,
        lastWheelEventTime: 1024,
        crankRevolutions: 50,
        lastCrankEventTime: 1024,
      );
      reader.computeSpeed(first);
      reader.computeCadence(first);

      reader.reset();

      // After reset, should return null (seeding again).
      const second = CscMeasurement(
        wheelRevolutions: 200,
        lastWheelEventTime: 5120,
        crankRevolutions: 100,
        lastCrankEventTime: 5120,
      );
      expect(reader.computeSpeed(second), isNull);
      expect(reader.computeCadence(second), isNull);
    });
  });
}
