import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/infrastructure/ble/sensors/heart_rate_reader.dart';

void main() {
  const reader = HeartRateReader();

  group('HeartRateReader', () {
    // -----------------------------------------------------------------------
    // Edge cases
    // -----------------------------------------------------------------------

    test('returns null for empty payload', () {
      expect(reader.parse([]), isNull);
    });

    // -----------------------------------------------------------------------
    // Wahoo TICKR — typical HR-only payload (UINT8)
    // -----------------------------------------------------------------------
    //
    // Flags: 0x00 → HR is UINT8, no contact status, no energy, no RR
    // HR: 72 BPM

    test('parses UINT8 HR (Wahoo TICKR idle)', () {
      final raw = [0x00, 72];

      final result = reader.parse(raw)!;
      expect(result.heartRate, 72);
      expect(result.sensorContact, isNull); // contact not supported
      expect(result.energyExpended, isNull);
      expect(result.rrIntervals, isEmpty);
    });

    // -----------------------------------------------------------------------
    // UINT16 HR (rare, but possible at HR > 255)
    // -----------------------------------------------------------------------

    test('parses UINT16 HR format', () {
      // Flags: 0x01 → HR is UINT16
      // HR: 260 BPM (0x04, 0x01 LE)
      final raw = [0x01, 0x04, 0x01];

      final result = reader.parse(raw)!;
      expect(result.heartRate, 260);
    });

    // -----------------------------------------------------------------------
    // Sensor contact supported, detected
    // -----------------------------------------------------------------------

    test('parses sensor contact detected', () {
      // Flags: 0x06 → bit 0=0 (UINT8), bits 1-2=0b11 (contact detected)
      // HR: 155 BPM
      final raw = [0x06, 155];

      final result = reader.parse(raw)!;
      expect(result.heartRate, 155);
      expect(result.sensorContact, isTrue);
    });

    // -----------------------------------------------------------------------
    // Sensor contact supported, NOT detected
    // -----------------------------------------------------------------------

    test('parses sensor contact not detected', () {
      // Flags: 0x04 → bits 1-2=0b10 (supported but no contact)
      final raw = [0x04, 0];

      final result = reader.parse(raw)!;
      expect(result.heartRate, 0);
      expect(result.sensorContact, isFalse);
    });

    // -----------------------------------------------------------------------
    // Energy expended present
    // -----------------------------------------------------------------------

    test('parses energy expended', () {
      // Flags: 0x08 → bit 3 set (energy present)
      // HR: 142
      // Energy: 1500 kJ (0xDC, 0x05 LE)
      final raw = [0x08, 142, 0xDC, 0x05];

      final result = reader.parse(raw)!;
      expect(result.heartRate, 142);
      expect(result.energyExpended, 1500);
    });

    // -----------------------------------------------------------------------
    // RR-interval(s) present — Wahoo TICKR X
    // -----------------------------------------------------------------------
    //
    // Real Wahoo TICKR X payload with 1 RR-interval:
    //   Flags: 0x16 → bit 0=0 (UINT8), bits 1-2=0b11 (contact), bit 4=1 (RR)
    //   HR: 68 BPM
    //   RR: 903 ms (raw 925 in 1/1024 s → 925 * 1000 / 1024 ≈ 903 ms)

    test('parses single RR-interval (Wahoo TICKR X)', () {
      // Flags: 0x16 = 0b00010110
      //   bit 0 = 0 → UINT8
      //   bit 1-2 = 0b11 → contact detected
      //   bit 4 = 1 → RR present
      final raw = [0x16, 68, 0x9D, 0x03]; // RR raw = 0x039D = 925

      final result = reader.parse(raw)!;
      expect(result.heartRate, 68);
      expect(result.sensorContact, isTrue);
      // 925 * 1000 / 1024 = 903
      expect(result.rrIntervals, [903]);
    });

    // -----------------------------------------------------------------------
    // Multiple RR-intervals in one notification
    // -----------------------------------------------------------------------

    test('parses multiple RR-intervals', () {
      // Flags: 0x10 → bit 4 (RR present), UINT8 HR
      // HR: 80
      // RR1: 768 raw → 768 * 1000 / 1024 = 750 ms
      // RR2: 820 raw → 820 * 1000 / 1024 = 800 ms (truncated int)
      final raw = [
        0x10,
        80,
        0x00, 0x03, // RR1: 768
        0x34, 0x03, // RR2: 820
      ];

      final result = reader.parse(raw)!;
      expect(result.heartRate, 80);
      expect(result.rrIntervals, hasLength(2));
      expect(result.rrIntervals[0], 750); // 768 * 1000 ~/ 1024
      expect(result.rrIntervals[1], 800); // 820 * 1000 ~/ 1024
    });

    // -----------------------------------------------------------------------
    // Full payload: UINT8 HR + contact + energy + RR
    // -----------------------------------------------------------------------

    test('parses full payload with all fields', () {
      // Flags: 0x1E = 0b00011110
      //   bit 0 = 0 → UINT8
      //   bit 1-2 = 0b11 → contact
      //   bit 3 = 1 → energy
      //   bit 4 = 1 → RR
      final raw = [
        0x1E,
        145, // HR
        0xE8, 0x03, // energy: 1000 kJ
        0x00, 0x04, // RR: 1024 raw → 1000 ms
      ];

      final result = reader.parse(raw)!;
      expect(result.heartRate, 145);
      expect(result.sensorContact, isTrue);
      expect(result.energyExpended, 1000);
      expect(result.rrIntervals, [1000]); // 1024 * 1000 ~/ 1024 = 1000
    });

    // -----------------------------------------------------------------------
    // toSensorReading
    // -----------------------------------------------------------------------

    test('toSensorReading maps heartRate to domain', () {
      const data = HeartRateMeasurement(
        heartRate: 165,
        sensorContact: true,
      );

      final reading = reader.toSensorReading(data);
      expect(reading.heartRate?.bpm, 165);
      expect(reading.power, isNull);
      expect(reading.cadence, isNull);
    });

    // -----------------------------------------------------------------------
    // Truncated payload
    // -----------------------------------------------------------------------

    test('returns null for truncated UINT16 HR', () {
      // Flags say UINT16 but only 1 byte follows
      final raw = [0x01, 72];
      // This is actually valid — 72 is the low byte, but we need 2 bytes
      // after the flags. raw.length = 2, offset=1, need offset+2=3 > 2
      expect(reader.parse(raw), isNull);
    });
  });
}
