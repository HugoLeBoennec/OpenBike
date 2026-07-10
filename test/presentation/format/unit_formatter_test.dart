import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/presentation/format/unit_formatter.dart';

void main() {
  group('unitSystemFromString', () {
    test('parses imperial', () {
      expect(unitSystemFromString('imperial'), UnitSystem.imperial);
    });

    test('defaults everything else to metric', () {
      expect(unitSystemFromString('metric'), UnitSystem.metric);
      expect(unitSystemFromString('bogus'), UnitSystem.metric);
    });
  });

  group('UnitFormatter — metric', () {
    const formatter = UnitFormatter(UnitSystem.metric);

    test('distance formats km', () {
      expect(formatter.distance(const Distance(12400)), '12.4 km');
    });

    test('speed formats km/h', () {
      expect(formatter.speed(const Speed(28.34)), '28.3 km/h');
    });

    test('weightKg passes through kg', () {
      expect(formatter.weightKg(75), '75.0 kg');
    });

    test('heightCm passes through cm', () {
      expect(formatter.heightCm(178), '178 cm');
    });

    test('elevationM passes through meters', () {
      expect(formatter.elevationM(120.4), '120 m');
    });

    test('unit suffix getters', () {
      expect(formatter.distanceUnit, 'km');
      expect(formatter.speedUnit, 'km/h');
      expect(formatter.weightUnit, 'kg');
      expect(formatter.elevationUnit, 'm');
    });
  });

  group('UnitFormatter — imperial', () {
    const formatter = UnitFormatter(UnitSystem.imperial);

    test('distance converts km to miles', () {
      // 12.4 km ≈ 7.7 mi
      expect(formatter.distance(const Distance(12400)), '7.7 mi');
    });

    test('speed converts km/h to mph', () {
      // 28.34 km/h ≈ 17.6 mph
      expect(formatter.speed(const Speed(28.34)), '17.6 mph');
    });

    test('weightKg converts kg to lb', () {
      // 75 kg ≈ 165.3 lb
      expect(formatter.weightKg(75), '165.3 lb');
    });

    test('heightCm converts to feet/inches', () {
      // 178 cm ≈ 5'10"
      expect(formatter.heightCm(178), "5'10\"");
    });

    test('heightCm rounds inches up to next foot at the boundary', () {
      // 182.88 cm = exactly 6'0"
      expect(formatter.heightCm(182.88), "6'0\"");
    });

    test('elevationM converts meters to feet', () {
      // 120 m ≈ 394 ft
      expect(formatter.elevationM(120), '394 ft');
    });

    test('unit suffix getters', () {
      expect(formatter.distanceUnit, 'mi');
      expect(formatter.speedUnit, 'mph');
      expect(formatter.weightUnit, 'lb');
      expect(formatter.elevationUnit, 'ft');
    });
  });
}
