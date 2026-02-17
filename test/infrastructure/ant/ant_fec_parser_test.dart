import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/infrastructure/ant/ant_fec_parser.dart';

void main() {
  late AntFecParser parser;

  setUp(() {
    parser = AntFecParser();
  });

  group('AntFecParser — getPageNumber', () {
    test('returns page number from byte 0', () {
      expect(parser.getPageNumber([16, 0, 0, 0, 0, 0, 0, 0]), 16);
      expect(parser.getPageNumber([25, 0, 0, 0, 0, 0, 0, 0]), 25);
      expect(parser.getPageNumber([80, 0, 0, 0, 0, 0, 0, 0]), 80);
    });

    test('returns -1 for empty payload', () {
      expect(parser.getPageNumber([]), -1);
    });
  });

  group('AntFecParser — page 16 (General FE)', () {
    test('parses speed and heart rate', () {
      // Speed = 10000 raw = 10.0 m/s = 36.0 km/h
      // HR = 140
      final data = [16, 0x05, 100, 50, 0x10, 0x27, 140, 0x00];
      final result = parser.parseGeneralFe(data);

      expect(result.equipmentType, 5);
      expect(result.elapsedTime, 25.0); // 100 * 0.25
      expect(result.distanceTraveled, 50);
      expect(result.speed, closeTo(36.0, 0.01));
      expect(result.heartRate, 140);
    });

    test('invalid speed (0xFFFF) returns null', () {
      final data = [16, 0, 0, 0, 0xFF, 0xFF, 80, 0];
      final result = parser.parseGeneralFe(data);
      expect(result.speed, isNull);
      expect(result.heartRate, 80);
    });

    test('invalid heart rate (0xFF) returns null', () {
      final data = [16, 0, 0, 0, 0x10, 0x27, 0xFF, 0];
      final result = parser.parseGeneralFe(data);
      expect(result.heartRate, isNull);
    });

    test('elapsed time uses 0.25s resolution', () {
      final data = [16, 0, 4, 0, 0, 0, 0xFF, 0];
      final result = parser.parseGeneralFe(data);
      expect(result.elapsedTime, 1.0); // 4 * 0.25
    });
  });

  group('AntFecParser — page 25 (Trainer Specific)', () {
    test('parses 200W power and 90 RPM cadence', () {
      // event count = 42, cadence = 90
      // accumulated power = 2000 (LE: 0xD0, 0x07)
      // instantaneous power = 200 (lower 12 bits of bytes 5-6)
      final data = [25, 42, 90, 0xD0, 0x07, 200, 0x00, 0x00];
      final result = parser.parseTrainerSpecific(data);

      expect(result.eventCount, 42);
      expect(result.instantaneousCadence, 90);
      expect(result.accumulatedPower, 2000);
      expect(result.instantaneousPower, 200);
    });

    test('invalid cadence (0xFF) returns null', () {
      final data = [25, 0, 0xFF, 0, 0, 100, 0, 0];
      final result = parser.parseTrainerSpecific(data);
      expect(result.instantaneousCadence, isNull);
    });

    test('invalid power (0xFFF) returns null', () {
      final data = [25, 0, 80, 0, 0, 0xFF, 0x0F, 0];
      final result = parser.parseTrainerSpecific(data);
      expect(result.instantaneousPower, isNull);
    });

    test('power extracted from 12-bit field correctly', () {
      // 300W = 0x12C, stored across bytes 5-6
      // byte 5 = 0x2C, byte 6 lower nibble = 0x01
      final data = [25, 0, 80, 0, 0, 0x2C, 0x01, 0];
      final result = parser.parseTrainerSpecific(data);
      expect(result.instantaneousPower, 300);
    });

    test('trainer status extracted from upper nibble of byte 6', () {
      // byte 6 = 0x30 → status bits = 0x3
      final data = [25, 0, 80, 0, 0, 0, 0x30, 0];
      final result = parser.parseTrainerSpecific(data);
      expect(result.trainerStatus, 3);
    });
  });

  group('AntFecParser — page 80 (Manufacturer)', () {
    test('parses manufacturer info', () {
      // HW rev = 5, mfg ID = 0x0059 (89), model = 0x0123 (291)
      final data = [80, 0xFF, 0xFF, 5, 0x59, 0x00, 0x23, 0x01];
      final result = parser.parseManufacturerInfo(data);
      expect(result.hardwareRevision, 5);
      expect(result.manufacturerId, 89);
      expect(result.modelNumber, 291);
    });
  });

  group('AntFecParser — page 81 (Product)', () {
    test('parses product info', () {
      // SW rev = 12, serial = 0x04030201
      final data = [81, 0xFF, 0xFF, 12, 0x01, 0x02, 0x03, 0x04];
      final result = parser.parseProductInfo(data);
      expect(result.softwareRevision, 12);
      expect(result.serialNumber, 0x04030201);
    });
  });

  group('AntFecParser — accumulatedDelta', () {
    test('simple delta without rollover', () {
      expect(AntFecParser.accumulatedDelta(100, 50, 256), 50);
    });

    test('handles 8-bit rollover (256)', () {
      expect(AntFecParser.accumulatedDelta(10, 250, 256), 16);
    });

    test('handles 16-bit rollover (65536)', () {
      expect(AntFecParser.accumulatedDelta(100, 65500, 65536), 136);
    });

    test('zero delta', () {
      expect(AntFecParser.accumulatedDelta(42, 42, 256), 0);
    });
  });
}
