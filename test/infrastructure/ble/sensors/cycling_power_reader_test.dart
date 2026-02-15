import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/infrastructure/ble/sensors/cycling_power_reader.dart';

void main() {
  late CyclingPowerReader reader;

  setUp(() {
    reader = CyclingPowerReader();
  });

  group('CyclingPowerReader — parse', () {
    // -----------------------------------------------------------------------
    // Edge cases
    // -----------------------------------------------------------------------

    test('returns null for payload shorter than 4 bytes', () {
      expect(reader.parse([0x00, 0x00]), isNull); // 2 bytes — too short
      expect(reader.parse([0x00, 0x00, 0xC8]), isNull); // 3 bytes
    });

    // -----------------------------------------------------------------------
    // Wahoo KICKR — power-only (most common case)
    // -----------------------------------------------------------------------
    //
    // Flags: 0x0000 → no optional fields
    // Power: 200 W (0xC8, 0x00 LE)

    test('parses power-only payload (Wahoo KICKR)', () {
      final raw = [0x00, 0x00, 0xC8, 0x00]; // flags LE + power LE

      final result = reader.parse(raw)!;
      expect(result.instantaneousPower, 200);
      expect(result.pedalPowerBalance, isNull);
      expect(result.accumulatedTorque, isNull);
      expect(result.wheelRevolutions, isNull);
      expect(result.crankRevolutions, isNull);
    });

    // -----------------------------------------------------------------------
    // Negative power (SINT16 — possible during freewheeling on some PMs)
    // -----------------------------------------------------------------------

    test('parses negative power (SINT16)', () {
      // Flags: 0x0000, Power: -10 W (0xF6, 0xFF LE → signed = -10)
      final raw = [0x00, 0x00, 0xF6, 0xFF];

      final result = reader.parse(raw)!;
      expect(result.instantaneousPower, -10);
    });

    // -----------------------------------------------------------------------
    // Pedal Power Balance present (bit 0)
    // -----------------------------------------------------------------------
    //
    // Flags: 0x0001 → pedal balance present
    // Power: 250 W
    // Balance: 52 → 52 / 2 = 26.0%

    test('parses pedal power balance', () {
      final raw = [0x01, 0x00, 0xFA, 0x00, 52];

      final result = reader.parse(raw)!;
      expect(result.instantaneousPower, 250);
      expect(result.pedalPowerBalance, 26.0);
    });

    // -----------------------------------------------------------------------
    // Accumulated Torque present (bit 2)
    // -----------------------------------------------------------------------
    //
    // Flags: 0x0004 → accumulated torque
    // Power: 180 W
    // Torque: 640 raw → 640 / 32.0 = 20.0 Nm

    test('parses accumulated torque', () {
      final raw = [0x04, 0x00, 0xB4, 0x00, 0x80, 0x02]; // torque: 640 LE

      final result = reader.parse(raw)!;
      expect(result.instantaneousPower, 180);
      expect(result.accumulatedTorque, 20.0);
    });

    // -----------------------------------------------------------------------
    // Wheel Revolution Data present (bit 4)
    // -----------------------------------------------------------------------
    //
    // Flags: 0x0010 → wheel data
    // Power: 150 W
    // Wheel revs: 1000 (UINT32), Last event: 2048 (UINT16)

    test('parses wheel revolution data', () {
      final raw = [
        0x10, 0x00, // flags
        0x96, 0x00, // power: 150
        0xE8, 0x03, 0x00, 0x00, // wheel revs: 1000 (UINT32 LE)
        0x00, 0x08, // last wheel event: 2048
      ];

      final result = reader.parse(raw)!;
      expect(result.instantaneousPower, 150);
      expect(result.wheelRevolutions, 1000);
      expect(result.lastWheelEventTime, 2048);
    });

    // -----------------------------------------------------------------------
    // Crank Revolution Data present (bit 5) — Stages / 4iiii power meter
    // -----------------------------------------------------------------------
    //
    // Flags: 0x0020 → crank data
    // Power: 220 W
    // Crank revs: 500 (UINT16), Last event: 3072 (UINT16, 1/1024 s)

    test('parses crank revolution data (Stages PM)', () {
      final raw = [
        0x20, 0x00, // flags
        0xDC, 0x00, // power: 220
        0xF4, 0x01, // crank revs: 500
        0x00, 0x0C, // last crank event: 3072
      ];

      final result = reader.parse(raw)!;
      expect(result.instantaneousPower, 220);
      expect(result.crankRevolutions, 500);
      expect(result.lastCrankEventTime, 3072);
    });

    // -----------------------------------------------------------------------
    // Full payload: balance + torque + wheel + crank
    // -----------------------------------------------------------------------

    test('parses full payload with all optional fields', () {
      final raw = [
        0x35, 0x00, // flags: 0x0035 = bits 0,2,4,5
        0x2C, 0x01, // power: 300
        48, // pedal balance: 48 → 24.0%
        0x00, 0x01, // torque: 256 → 8.0 Nm
        0x10, 0x27, 0x00, 0x00, // wheel revs: 10000
        0x00, 0x04, // last wheel event: 1024
        0xC8, 0x00, // crank revs: 200
        0x00, 0x08, // last crank event: 2048
      ];

      final result = reader.parse(raw)!;
      expect(result.instantaneousPower, 300);
      expect(result.pedalPowerBalance, 24.0);
      expect(result.accumulatedTorque, 8.0);
      expect(result.wheelRevolutions, 10000);
      expect(result.lastWheelEventTime, 1024);
      expect(result.crankRevolutions, 200);
      expect(result.lastCrankEventTime, 2048);
    });

    // -----------------------------------------------------------------------
    // Truncated payload
    // -----------------------------------------------------------------------

    test('returns null for truncated crank data', () {
      // Flags say crank data present (bit 5), but not enough bytes
      final raw = [0x20, 0x00, 0xDC, 0x00, 0xF4, 0x01]; // missing 2 bytes

      expect(reader.parse(raw), isNull);
    });
  });

  // =========================================================================
  // computeCadence
  // =========================================================================

  group('CyclingPowerReader — computeCadence', () {
    test('returns null on first call (no previous data)', () {
      const data = CyclingPowerMeasurement(
        instantaneousPower: 200,
        crankRevolutions: 100,
        lastCrankEventTime: 1024,
      );

      expect(reader.computeCadence(data), isNull);
    });

    test('returns null when no crank data present', () {
      const data = CyclingPowerMeasurement(instantaneousPower: 200);

      expect(reader.computeCadence(data), isNull);
    });

    test('computes cadence from two successive readings', () {
      // First reading — seeds state, returns null.
      const first = CyclingPowerMeasurement(
        instantaneousPower: 200,
        crankRevolutions: 100,
        lastCrankEventTime: 1024, // 1.0 s
      );
      expect(reader.computeCadence(first), isNull);

      // Second reading: 1 revolution later, 1 second later.
      // Δrev = 1, Δtime = 1024 → 1 s → cadence = 1 / 1 × 60 = 60 RPM
      const second = CyclingPowerMeasurement(
        instantaneousPower: 210,
        crankRevolutions: 101,
        lastCrankEventTime: 2048, // 2.0 s
      );
      expect(reader.computeCadence(second), closeTo(60.0, 0.1));
    });

    test('computes 90 RPM typical scenario', () {
      // 90 RPM = 1.5 revs/sec = 1 rev per 0.667s
      // In 1/1024 units: 0.667s × 1024 ≈ 683
      const first = CyclingPowerMeasurement(
        instantaneousPower: 200,
        crankRevolutions: 500,
        lastCrankEventTime: 10000,
      );
      expect(reader.computeCadence(first), isNull);

      // 3 revolutions over 3 × 683 ≈ 2048 time units = 2.0 seconds
      // cadence = (3 / (2048/1024)) × 60 = (3 / 2) × 60 = 90 RPM
      const second = CyclingPowerMeasurement(
        instantaneousPower: 200,
        crankRevolutions: 503,
        lastCrankEventTime: 12048,
      );
      expect(reader.computeCadence(second), closeTo(90.0, 0.1));
    });

    test('handles UINT16 rollover for crank revolutions', () {
      const first = CyclingPowerMeasurement(
        instantaneousPower: 200,
        crankRevolutions: 65534,
        lastCrankEventTime: 1024,
      );
      expect(reader.computeCadence(first), isNull);

      // Rolls over: 65534 → 1 (Δ = 3 after rollover via 65536)
      // Δtime = 1024 → 1 second
      // cadence = (3 / 1) × 60 = 180 RPM
      const second = CyclingPowerMeasurement(
        instantaneousPower: 200,
        crankRevolutions: 1,
        lastCrankEventTime: 2048,
      );
      expect(reader.computeCadence(second), closeTo(180.0, 0.1));
    });

    test('handles UINT16 rollover for crank event time', () {
      const first = CyclingPowerMeasurement(
        instantaneousPower: 200,
        crankRevolutions: 100,
        lastCrankEventTime: 65000,
      );
      expect(reader.computeCadence(first), isNull);

      // Time rolls over: 65000 → 488 (Δ = 65536 - 65000 + 488 = 1024)
      // Δrev = 1, Δtime = 1024 → 1 s → cadence = 60 RPM
      const second = CyclingPowerMeasurement(
        instantaneousPower: 200,
        crankRevolutions: 101,
        lastCrankEventTime: 488,
      );
      expect(reader.computeCadence(second), closeTo(60.0, 0.1));
    });

    test('returns null for zero delta revolutions (coasting)', () {
      const first = CyclingPowerMeasurement(
        instantaneousPower: 0,
        crankRevolutions: 100,
        lastCrankEventTime: 1024,
      );
      expect(reader.computeCadence(first), isNull);

      const second = CyclingPowerMeasurement(
        instantaneousPower: 0,
        crankRevolutions: 100, // same — no rotation
        lastCrankEventTime: 2048,
      );
      expect(reader.computeCadence(second), isNull);
    });

    test('rejects cadence above 250 RPM', () {
      const first = CyclingPowerMeasurement(
        instantaneousPower: 200,
        crankRevolutions: 100,
        lastCrankEventTime: 1024,
      );
      expect(reader.computeCadence(first), isNull);

      // 10 revolutions in 1 second = 600 RPM → rejected
      const second = CyclingPowerMeasurement(
        instantaneousPower: 200,
        crankRevolutions: 110,
        lastCrankEventTime: 2048,
      );
      expect(reader.computeCadence(second), isNull);
    });

    test('reset clears previous state', () {
      const first = CyclingPowerMeasurement(
        instantaneousPower: 200,
        crankRevolutions: 100,
        lastCrankEventTime: 1024,
      );
      reader.computeCadence(first);

      reader.reset();

      // After reset, first call should return null again.
      const second = CyclingPowerMeasurement(
        instantaneousPower: 200,
        crankRevolutions: 200,
        lastCrankEventTime: 5120,
      );
      expect(reader.computeCadence(second), isNull);
    });
  });

  // =========================================================================
  // toSensorReading
  // =========================================================================

  group('CyclingPowerReader — toSensorReading', () {
    test('maps power and cadence to domain SensorReading', () {
      const data = CyclingPowerMeasurement(instantaneousPower: 275);
      final reading = reader.toSensorReading(data, cadence: 92.0);

      expect(reading.power?.value, 275.0);
      expect(reading.cadence?.rpm, 92.0);
      expect(reading.heartRate, isNull);
      expect(reading.speed, isNull);
    });

    test('maps power without cadence', () {
      const data = CyclingPowerMeasurement(instantaneousPower: 150);
      final reading = reader.toSensorReading(data);

      expect(reading.power?.value, 150.0);
      expect(reading.cadence, isNull);
    });
  });
}
