import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';

void main() {
  group('Ride — detail metrics for history display', () {
    Ride makeRide({
      required List<SensorReading> readings,
      Duration pauseDuration = Duration.zero,
    }) {
      final start = DateTime.utc(2025, 6, 15, 10, 0, 0);
      return Ride(
        id: 'ride-test',
        startTime: start,
        endTime: start.add(const Duration(minutes: 30)),
        status: RideStatus.finished,
        readings: readings,
        pauseDuration: pauseDuration,
      );
    }

    test('averagePower computes correctly', () {
      final ride = makeRide(readings: [
        SensorReading(
          timestamp: DateTime.utc(2025, 6, 15, 10, 0, 0),
          power: const Watts(200),
        ),
        SensorReading(
          timestamp: DateTime.utc(2025, 6, 15, 10, 0, 1),
          power: const Watts(300),
        ),
      ]);
      expect(ride.averagePower.value, 250.0);
    });

    test('maxPower returns highest reading', () {
      final ride = makeRide(readings: [
        SensorReading(
          timestamp: DateTime.utc(2025, 6, 15, 10, 0, 0),
          power: const Watts(100),
        ),
        SensorReading(
          timestamp: DateTime.utc(2025, 6, 15, 10, 0, 1),
          power: const Watts(400),
        ),
        SensorReading(
          timestamp: DateTime.utc(2025, 6, 15, 10, 0, 2),
          power: const Watts(250),
        ),
      ]);
      expect(ride.maxPower.value, 400.0);
    });

    test('tss and intensityFactor with known FTP', () {
      final readings = List.generate(
        60,
        (i) => SensorReading(
          timestamp:
              DateTime.utc(2025, 6, 15, 10, 0, 0).add(Duration(seconds: i)),
          power: const Watts(200),
        ),
      );
      final ride = makeRide(readings: readings);
      const ftp = Watts(200);
      // IF should be ~1.0 (NP ≈ avg when constant)
      expect(ride.intensityFactor(ftp), closeTo(1.0, 0.1));
      // TSS for 30 min at IF=1.0 ≈ 50
      expect(ride.tss(ftp), greaterThan(0));
    });

    test('empty readings produce zero metrics', () {
      final ride = makeRide(readings: []);
      expect(ride.averagePower, Watts.zero);
      expect(ride.maxPower, Watts.zero);
      expect(ride.averageHr, HeartRate.zero);
      expect(ride.totalDistance, Distance.zero);
    });

    test('activeDuration excludes pauses', () {
      final ride = makeRide(
        readings: [],
        pauseDuration: const Duration(minutes: 5),
      );
      expect(ride.activeDuration, const Duration(minutes: 25));
    });
  });
}
