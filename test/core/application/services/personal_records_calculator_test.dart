import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/personal_records_calculator.dart';
import 'package:open_bike/core/domain/entities/sensor_reading.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';

List<SensorReading> _readingsFromPowers(List<double> powers) {
  final start = DateTime.utc(2026, 1, 1);
  return [
    for (var i = 0; i < powers.length; i++)
      SensorReading(
        timestamp: start.add(Duration(seconds: i)),
        power: Watts(powers[i]),
      ),
  ];
}

void main() {
  final calculator = PersonalRecordsCalculator();

  group('PersonalRecordsCalculator — computeMeanMax', () {
    test('finds the best 5 s window when it is not at the start', () {
      final powers = <double>[
        100, 100, 100, 100, 100, // 5 s @ 100 W
        500, 500, 500, 500, 500, // 5 s @ 500 W (the true best window)
      ];
      final readings = _readingsFromPowers(powers);

      final result = calculator.computeMeanMax(readings);

      final fiveSec = result.firstWhere((r) => r.durationSeconds == 5);
      expect(fiveSec.watts.value, closeTo(500, 0.001));
    });

    test('window exactly matching reading length averages everything', () {
      final powers = List.generate(5, (i) => 200.0 + i); // 200..204
      final readings = _readingsFromPowers(powers);

      final result = calculator.computeMeanMax(readings);

      final fiveSec = result.firstWhere((r) => r.durationSeconds == 5);
      expect(fiveSec.watts.value, closeTo(202, 0.001)); // mean of 200..204
    });

    test('skips duration buckets longer than the ride', () {
      final readings = _readingsFromPowers(List.filled(10, 150.0));

      final result = calculator.computeMeanMax(readings);

      expect(result.map((r) => r.durationSeconds), [5]);
    });

    test('returns nothing for a ride shorter than every bucket', () {
      final readings = _readingsFromPowers([100, 120, 90]);

      final result = calculator.computeMeanMax(readings);

      expect(result, isEmpty);
    });

    test('treats missing power samples as zero', () {
      final readings = [
        SensorReading(timestamp: DateTime.utc(2026), power: const Watts(200)),
        SensorReading(timestamp: DateTime.utc(2026), power: null),
        SensorReading(timestamp: DateTime.utc(2026), power: const Watts(200)),
        SensorReading(timestamp: DateTime.utc(2026), power: const Watts(200)),
        SensorReading(timestamp: DateTime.utc(2026), power: const Watts(200)),
      ];

      final result = calculator.computeMeanMax(readings);

      final fiveSec = result.firstWhere((r) => r.durationSeconds == 5);
      // (200+0+200+200+200)/5 = 160
      expect(fiveSec.watts.value, closeTo(160, 0.001));
    });

    test('computes all four buckets for a long enough ride', () {
      final readings = _readingsFromPowers(List.filled(1300, 210.0));

      final result = calculator.computeMeanMax(readings);

      expect(result.map((r) => r.durationSeconds).toSet(), {5, 60, 300, 1200});
      for (final r in result) {
        expect(r.watts.value, closeTo(210, 0.001));
      }
    });
  });

  group('PersonalRecordsCalculator — computeRecords', () {
    test('stamps every candidate with the given rideId and achievedAt', () {
      final readings = _readingsFromPowers(List.filled(10, 300.0));
      final achievedAt = DateTime.utc(2026, 3, 4);

      final records = calculator.computeRecords(
        rideId: 'ride-42',
        achievedAt: achievedAt,
        readings: readings,
      );

      expect(records, isNotEmpty);
      for (final r in records) {
        expect(r.rideId, 'ride-42');
        expect(r.achievedAt, achievedAt);
      }
      expect(records.single.durationSeconds, 5);
      expect(records.single.watts.value, closeTo(300, 0.001));
    });
  });
}
