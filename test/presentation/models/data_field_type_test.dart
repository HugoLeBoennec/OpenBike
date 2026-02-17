import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/presentation/models/data_field_type.dart';

void main() {
  // ===========================================================================
  // Labels
  // ===========================================================================

  group('DataFieldType — label', () {
    test('power label', () {
      expect(DataFieldType.power.label, 'POWER');
    });

    test('avgPower label', () {
      expect(DataFieldType.avgPower.label, 'AVG POWER');
    });

    test('normalizedPower label', () {
      expect(DataFieldType.normalizedPower.label, 'NP');
    });

    test('threeSecAvgPower label', () {
      expect(DataFieldType.threeSecAvgPower.label, '3s POWER');
    });

    test('cadence label', () {
      expect(DataFieldType.cadence.label, 'CADENCE');
    });

    test('heartRate label', () {
      expect(DataFieldType.heartRate.label, 'HEART RATE');
    });

    test('speed label', () {
      expect(DataFieldType.speed.label, 'SPEED');
    });

    test('distance label', () {
      expect(DataFieldType.distance.label, 'DISTANCE');
    });

    test('elapsedTime label', () {
      expect(DataFieldType.elapsedTime.label, 'TIME');
    });

    test('calories label', () {
      expect(DataFieldType.calories.label, 'CALORIES');
    });

    test('tss label', () {
      expect(DataFieldType.tss.label, 'TSS');
    });

    test('intensityFactor label', () {
      expect(DataFieldType.intensityFactor.label, 'IF');
    });

    test('grade label', () {
      expect(DataFieldType.grade.label, 'GRADE');
    });

    test('elevation label', () {
      expect(DataFieldType.elevation.label, 'ELEVATION');
    });
  });

  // ===========================================================================
  // Units
  // ===========================================================================

  group('DataFieldType — unit', () {
    test('power fields have unit "w"', () {
      expect(DataFieldType.power.unit, 'w');
      expect(DataFieldType.avgPower.unit, 'w');
      expect(DataFieldType.normalizedPower.unit, 'w');
      expect(DataFieldType.threeSecAvgPower.unit, 'w');
    });

    test('cadence unit is "rpm"', () {
      expect(DataFieldType.cadence.unit, 'rpm');
    });

    test('heartRate unit is "bpm"', () {
      expect(DataFieldType.heartRate.unit, 'bpm');
    });

    test('speed unit is "km/h"', () {
      expect(DataFieldType.speed.unit, 'km/h');
    });

    test('distance unit is "km"', () {
      expect(DataFieldType.distance.unit, 'km');
    });

    test('elapsedTime has empty unit', () {
      expect(DataFieldType.elapsedTime.unit, '');
    });

    test('calories unit is "kcal"', () {
      expect(DataFieldType.calories.unit, 'kcal');
    });

    test('tss has empty unit', () {
      expect(DataFieldType.tss.unit, '');
    });

    test('intensityFactor has empty unit', () {
      expect(DataFieldType.intensityFactor.unit, '');
    });

    test('grade unit is "%"', () {
      expect(DataFieldType.grade.unit, '%');
    });

    test('elevation unit is "m"', () {
      expect(DataFieldType.elevation.unit, 'm');
    });
  });

  // ===========================================================================
  // isPowerField
  // ===========================================================================

  group('DataFieldType — isPowerField', () {
    test('power fields return true', () {
      expect(DataFieldType.power.isPowerField, isTrue);
      expect(DataFieldType.avgPower.isPowerField, isTrue);
      expect(DataFieldType.normalizedPower.isPowerField, isTrue);
      expect(DataFieldType.threeSecAvgPower.isPowerField, isTrue);
    });

    test('non-power fields return false', () {
      expect(DataFieldType.cadence.isPowerField, isFalse);
      expect(DataFieldType.heartRate.isPowerField, isFalse);
      expect(DataFieldType.speed.isPowerField, isFalse);
      expect(DataFieldType.distance.isPowerField, isFalse);
      expect(DataFieldType.elapsedTime.isPowerField, isFalse);
      expect(DataFieldType.calories.isPowerField, isFalse);
      expect(DataFieldType.tss.isPowerField, isFalse);
      expect(DataFieldType.intensityFactor.isPowerField, isFalse);
      expect(DataFieldType.grade.isPowerField, isFalse);
      expect(DataFieldType.elevation.isPowerField, isFalse);
    });
  });

  // ===========================================================================
  // Enum completeness
  // ===========================================================================

  group('DataFieldType — completeness', () {
    test('has 14 values', () {
      expect(DataFieldType.values.length, 14);
    });

    test('every value has a non-empty label', () {
      for (final type in DataFieldType.values) {
        expect(type.label, isNotEmpty, reason: '$type should have a label');
      }
    });
  });
}
