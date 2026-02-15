import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/infrastructure/ble/ftms/ftms_data_parser.dart';

void main() {
  const parser = FtmsDataParser();

  group('FtmsDataParser', () {
    // -----------------------------------------------------------------------
    // Edge cases
    // -----------------------------------------------------------------------

    test('returns null for empty payload', () {
      expect(parser.parseIndoorBikeData([]), isNull);
    });

    test('returns null for single-byte payload', () {
      expect(parser.parseIndoorBikeData([0x00]), isNull);
    });

    // -----------------------------------------------------------------------
    // Wahoo KICKR typical payloads
    // -----------------------------------------------------------------------
    //
    // The Wahoo KICKR v5/v6 typically sends Indoor Bike Data with:
    //   Flags: speed + cadence + power  →  0x0044
    //     Bit 0 = 0 → Instantaneous Speed present
    //     Bit 2 = 1 → Instantaneous Cadence present
    //     Bit 6 = 1 → Instantaneous Power present
    //
    // Example: 30 km/h, 90 RPM, 200W
    //   Flags:  0x44, 0x00        (little-endian: 0x0044)
    //   Speed:  0xB8, 0x0B        (3000 → 30.00 km/h)
    //   Cadence:0xB4, 0x00        (180 → 90.0 RPM)
    //   Power:  0xC8, 0x00        (200W)

    test('parses Wahoo KICKR: speed + cadence + power (30kmh, 90rpm, 200W)',
        () {
      final raw = [
        0x44, 0x00, // flags: speed + cadence + power
        0xB8, 0x0B, // speed: 3000 → 30.00 km/h
        0xB4, 0x00, // cadence: 180 → 90.0 RPM
        0xC8, 0x00, // power: 200 W
      ];

      final result = parser.parseIndoorBikeData(raw);
      expect(result, isNotNull);
      expect(result!.instantaneousSpeed, closeTo(30.0, 0.01));
      expect(result.instantaneousCadence, closeTo(90.0, 0.1));
      expect(result.instantaneousPower, 200);
      expect(result.averageSpeed, isNull);
      expect(result.heartRate, isNull);
      expect(result.totalDistance, isNull);
    });

    // -----------------------------------------------------------------------
    // KICKR with all common fields
    // -----------------------------------------------------------------------
    //
    // Flags: speed + cadence + total distance + power + heart rate
    //   0x0254 = bits 0(off→speed), 2(cadence), 4(distance), 6(power), 9(HR)
    //   Actually: 0x0254 = 0b 0000 0010 0101 0100
    //     Bit 2 = 1 → cadence
    //     Bit 4 = 1 → total distance
    //     Bit 6 = 1 → power
    //     Bit 9 = 1 → heart rate
    //   Bit 0 = 0 → speed IS present

    test('parses speed + cadence + distance + power + HR', () {
      final raw = [
        0x54, 0x02, // flags: 0x0254
        0xE8, 0x03, // speed: 1000 → 10.00 km/h
        0x78, 0x00, // cadence: 120 → 60.0 RPM
        0xA0, 0x0F, 0x00, // distance: 4000 meters (UINT24)
        0x96, 0x00, // power: 150 W
        0x8C, // heart rate: 140 BPM
      ];

      final result = parser.parseIndoorBikeData(raw);
      expect(result, isNotNull);
      expect(result!.instantaneousSpeed, closeTo(10.0, 0.01));
      expect(result.instantaneousCadence, closeTo(60.0, 0.1));
      expect(result.totalDistance, 4000);
      expect(result.instantaneousPower, 150);
      expect(result.heartRate, 140);
    });

    // -----------------------------------------------------------------------
    // Speed-only (flags = 0x0000, just speed present)
    // -----------------------------------------------------------------------

    test('parses speed-only payload', () {
      final raw = [
        0x00, 0x00, // flags: only bit 0 = 0 → speed present
        0xD0, 0x07, // speed: 2000 → 20.00 km/h
      ];

      final result = parser.parseIndoorBikeData(raw);
      expect(result, isNotNull);
      expect(result!.instantaneousSpeed, closeTo(20.0, 0.01));
      expect(result.instantaneousCadence, isNull);
      expect(result.instantaneousPower, isNull);
    });

    // -----------------------------------------------------------------------
    // No speed (bit 0 = 1), just power
    // -----------------------------------------------------------------------

    test('parses power-only (no speed, bit 0 set)', () {
      // Flags: 0x0041  →  bit 0=1 (no speed), bit 6=1 (power)
      final raw = [
        0x41, 0x00, // flags
        0x2C, 0x01, // power: 300 W (SINT16)
      ];

      final result = parser.parseIndoorBikeData(raw);
      expect(result, isNotNull);
      expect(result!.instantaneousSpeed, isNull);
      expect(result.instantaneousPower, 300);
    });

    // -----------------------------------------------------------------------
    // Resistance level + average power
    // -----------------------------------------------------------------------

    test('parses resistance level and average power', () {
      // Flags: 0x00A1 → bit 0=1 (no speed), bit 5=1 (resistance), bit 7=1 (avg power)
      final raw = [
        0xA1, 0x00, // flags
        0x32, 0x00, // resistance: 50 → 5.0
        0xFA, 0x00, // average power: 250 W
      ];

      final result = parser.parseIndoorBikeData(raw);
      expect(result, isNotNull);
      expect(result!.instantaneousSpeed, isNull);
      expect(result.resistanceLevel, closeTo(5.0, 0.1));
      expect(result.averagePower, 250);
    });

    // -----------------------------------------------------------------------
    // Expended energy block (5 bytes)
    // -----------------------------------------------------------------------

    test('parses expended energy fields', () {
      // Flags: 0x0101 → bit 0=1 (no speed), bit 8=1 (expended energy)
      final raw = [
        0x01, 0x01, // flags
        0xF4, 0x01, // total energy: 500 kcal
        0xE8, 0x03, // energy/hour: 1000 kcal
        0x64, // energy/minute: 100 → 10.0 kcal
      ];

      final result = parser.parseIndoorBikeData(raw);
      expect(result, isNotNull);
      expect(result!.totalEnergy, 500);
      expect(result.energyPerHour, 1000);
      expect(result.energyPerMinute, closeTo(10.0, 0.1));
    });

    // -----------------------------------------------------------------------
    // Elapsed time and remaining time
    // -----------------------------------------------------------------------

    test('parses elapsed and remaining time', () {
      // Flags: 0x1801 → bit 0=1 (no speed), bit 11=1 (elapsed), bit 12=1 (remaining)
      final raw = [
        0x01, 0x18, // flags: 0x1801
        0x2C, 0x01, // elapsed: 300 seconds
        0x58, 0x02, // remaining: 600 seconds
      ];

      final result = parser.parseIndoorBikeData(raw);
      expect(result, isNotNull);
      expect(result!.elapsedTime, 300);
      expect(result.remainingTime, 600);
    });

    // -----------------------------------------------------------------------
    // Full Wahoo KICKR v5 payload — all fields
    // -----------------------------------------------------------------------
    //
    // Flags: 0x1FFF (all bits 0-12 set except bit 0 which means "no speed"…
    //   wait, bit 0 set means "more data = no speed")
    //   Let's use: 0x1FFE → all bits 1-12 set, bit 0=0 → speed present
    //
    //   0x1FFE = 0b 0001 1111 1111 1110
    //   Bit 0  = 0 → speed present
    //   Bit 1  = 1 → average speed
    //   Bit 2  = 1 → cadence
    //   Bit 3  = 1 → average cadence
    //   Bit 4  = 1 → total distance
    //   Bit 5  = 1 → resistance level
    //   Bit 6  = 1 → instantaneous power
    //   Bit 7  = 1 → average power
    //   Bit 8  = 1 → expended energy
    //   Bit 9  = 1 → heart rate
    //   Bit 10 = 1 → metabolic equivalent
    //   Bit 11 = 1 → elapsed time
    //   Bit 12 = 1 → remaining time

    test('parses full payload with all fields present', () {
      final raw = [
        0xFE, 0x1F, // flags: 0x1FFE
        0xB8, 0x0B, // inst speed: 3000 → 30.00 km/h
        0x90, 0x0D, // avg speed: 3472 → 34.72 km/h
        0xB4, 0x00, // inst cadence: 180 → 90.0 RPM
        0xAA, 0x00, // avg cadence: 170 → 85.0 RPM
        0x10, 0x27, 0x00, // total distance: 10000 m
        0x64, 0x00, // resistance: 100 → 10.0
        0xC8, 0x00, // inst power: 200 W
        0xBE, 0x00, // avg power: 190 W
        0xF4, 0x01, // total energy: 500 kcal
        0xE8, 0x03, // energy/hour: 1000 kcal
        0x64, // energy/minute: 100 → 10.0 kcal
        0x8A, // heart rate: 138 BPM
        0x46, // metabolic eq: 70 → 7.0
        0x84, 0x03, // elapsed: 900 s
        0xB4, 0x00, // remaining: 180 s
      ];

      final result = parser.parseIndoorBikeData(raw);
      expect(result, isNotNull);
      expect(result!.instantaneousSpeed, closeTo(30.0, 0.01));
      expect(result.averageSpeed, closeTo(34.72, 0.01));
      expect(result.instantaneousCadence, closeTo(90.0, 0.1));
      expect(result.averageCadence, closeTo(85.0, 0.1));
      expect(result.totalDistance, 10000);
      expect(result.resistanceLevel, closeTo(10.0, 0.1));
      expect(result.instantaneousPower, 200);
      expect(result.averagePower, 190);
      expect(result.totalEnergy, 500);
      expect(result.energyPerHour, 1000);
      expect(result.energyPerMinute, closeTo(10.0, 0.1));
      expect(result.heartRate, 138);
      expect(result.metabolicEquivalent, closeTo(7.0, 0.1));
      expect(result.elapsedTime, 900);
      expect(result.remainingTime, 180);
    });

    // -----------------------------------------------------------------------
    // Negative power (signed)
    // -----------------------------------------------------------------------

    test('handles negative power (SINT16)', () {
      // Flags: 0x0041 → bit 0=1 (no speed), bit 6=1 (power)
      // Power: -10 W as SINT16 LE → 0xF6, 0xFF
      final raw = [
        0x41, 0x00,
        0xF6, 0xFF, // -10 as signed int16 LE
      ];

      final result = parser.parseIndoorBikeData(raw);
      expect(result, isNotNull);
      expect(result!.instantaneousPower, -10);
    });

    // -----------------------------------------------------------------------
    // toSensorReading conversion
    // -----------------------------------------------------------------------

    test('toSensorReading maps fields to domain value objects', () {
      const data = FtmsIndoorBikeData(
        instantaneousSpeed: 25.5,
        instantaneousCadence: 85.0,
        instantaneousPower: 220,
        heartRate: 155,
        totalDistance: 5000,
      );

      final reading = parser.toSensorReading(data);

      expect(reading.power?.value, 220.0);
      expect(reading.cadence?.rpm, 85.0);
      expect(reading.speed?.kmh, 25.5);
      expect(reading.heartRate?.bpm, 155);
      expect(reading.distance?.meters, 5000.0);
      expect(reading.timestamp, isNotNull);
    });

    test('toSensorReading handles null fields', () {
      const data = FtmsIndoorBikeData(
        instantaneousPower: 150,
      );

      final reading = parser.toSensorReading(data);

      expect(reading.power?.value, 150.0);
      expect(reading.cadence, isNull);
      expect(reading.speed, isNull);
      expect(reading.heartRate, isNull);
      expect(reading.distance, isNull);
    });

    // -----------------------------------------------------------------------
    // Truncated payload
    // -----------------------------------------------------------------------

    test('returns null for truncated payload (flags claim more data)', () {
      // Flags say speed + cadence present but only speed bytes provided
      final raw = [
        0x04, 0x00, // flags: speed + cadence
        0xB8, 0x0B, // speed only — cadence bytes missing
      ];

      final result = parser.parseIndoorBikeData(raw);
      expect(result, isNull);
    });

    // -----------------------------------------------------------------------
    // Zero values
    // -----------------------------------------------------------------------

    test('parses zero speed, zero cadence, zero power correctly', () {
      final raw = [
        0x44, 0x00, // flags: speed + cadence + power
        0x00, 0x00, // speed: 0
        0x00, 0x00, // cadence: 0
        0x00, 0x00, // power: 0
      ];

      final result = parser.parseIndoorBikeData(raw);
      expect(result, isNotNull);
      expect(result!.instantaneousSpeed, 0.0);
      expect(result.instantaneousCadence, 0.0);
      expect(result.instantaneousPower, 0);
    });

    // -----------------------------------------------------------------------
    // High values (KICKR max sprint)
    // -----------------------------------------------------------------------

    test('parses high power values (2000W sprint)', () {
      final raw = [
        0x44, 0x00, // flags: speed + cadence + power
        0x40, 0x1F, // speed: 8000 → 80.00 km/h
        0x00, 0x01, // cadence: 256 → 128.0 RPM
        0xD0, 0x07, // power: 2000 W
      ];

      final result = parser.parseIndoorBikeData(raw);
      expect(result, isNotNull);
      expect(result!.instantaneousSpeed, closeTo(80.0, 0.01));
      expect(result.instantaneousCadence, closeTo(128.0, 0.1));
      expect(result.instantaneousPower, 2000);
    });
  });
}
