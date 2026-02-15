import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/domain/entities/ride.dart';
import 'package:open_bike/core/domain/entities/sensor_reading.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';

/// Helper to build a list of [SensorReading]s with the given power values,
/// spaced 1 second apart starting from [start].
List<SensorReading> _powerReadings(
  List<double> watts, {
  DateTime? start,
}) {
  final origin = start ?? DateTime(2024, 1, 1);
  return [
    for (var i = 0; i < watts.length; i++)
      SensorReading(
        timestamp: origin.add(Duration(seconds: i)),
        power: Watts(watts[i]),
      ),
  ];
}

Ride _rideWithReadings(
  List<SensorReading> readings, {
  Duration pauseDuration = Duration.zero,
}) {
  final start = readings.isNotEmpty
      ? readings.first.timestamp
      : DateTime(2024, 1, 1);
  final end = readings.isNotEmpty
      ? readings.last.timestamp.add(const Duration(seconds: 1))
      : start.add(const Duration(seconds: 1));
  return Ride(
    id: 'test-ride',
    startTime: start,
    endTime: end,
    status: RideStatus.finished,
    readings: readings,
    pauseDuration: pauseDuration,
  );
}

void main() {
  // =========================================================================
  // Average Power
  // =========================================================================

  group('Ride — averagePower', () {
    test('constant 200 W → avg 200 W', () {
      final ride = _rideWithReadings(
        _powerReadings(List.filled(60, 200)),
      );
      expect(ride.averagePower.value, closeTo(200, 0.01));
    });

    test('alternating 100/300 W → avg 200 W', () {
      final watts = List.generate(60, (i) => i.isEven ? 100.0 : 300.0);
      final ride = _rideWithReadings(_powerReadings(watts));
      expect(ride.averagePower.value, closeTo(200, 0.01));
    });

    test('no readings → zero', () {
      final ride = _rideWithReadings([]);
      expect(ride.averagePower, Watts.zero);
    });
  });

  // =========================================================================
  // Max Power
  // =========================================================================

  group('Ride — maxPower', () {
    test('finds the peak value', () {
      final watts = List.filled(60, 150.0)..[30] = 400;
      final ride = _rideWithReadings(_powerReadings(watts));
      expect(ride.maxPower.value, closeTo(400, 0.01));
    });

    test('no readings → zero', () {
      final ride = _rideWithReadings([]);
      expect(ride.maxPower, Watts.zero);
    });
  });

  // =========================================================================
  // Max HR
  // =========================================================================

  group('Ride — maxHr', () {
    test('finds the peak HR', () {
      final start = DateTime(2024, 1, 1);
      final readings = [
        for (var i = 0; i < 10; i++)
          SensorReading(
            timestamp: start.add(Duration(seconds: i)),
            heartRate: HeartRate(140 + i),
          ),
      ];
      final ride = _rideWithReadings(readings);
      expect(ride.maxHr.bpm, 149); // 140 + 9
    });

    test('no HR data → zero', () {
      final ride = _rideWithReadings(
        _powerReadings(List.filled(10, 200)),
      );
      expect(ride.maxHr, HeartRate.zero);
    });
  });

  // =========================================================================
  // Normalized Power
  // =========================================================================

  group('Ride — normalizedPower', () {
    test('constant power → NP equals average', () {
      // 60 seconds of constant 200 W.
      // Rolling 30-sec avg = 200 for every window → NP = 200.
      final ride = _rideWithReadings(
        _powerReadings(List.filled(60, 200)),
      );
      expect(ride.normalizedPower.value, closeTo(200, 0.1));
    });

    test('block-variable power → NP is higher than average', () {
      // 30 seconds at 100 W, then 30 seconds at 300 W.
      // Average = 200 W. Rolling 30s windows transition from 100→300,
      // so they vary. The 4th-power weighting amplifies higher values → NP > 200.
      final watts = [
        ...List.filled(30, 100.0),
        ...List.filled(30, 300.0),
      ];
      final ride = _rideWithReadings(_powerReadings(watts));

      expect(ride.averagePower.value, closeTo(200, 0.1));
      expect(ride.normalizedPower.value, greaterThan(200));
    });

    test('even alternation → NP equals average (rolling avg smooths it)', () {
      // Alternating 100/300 every second for 60 seconds.
      // Each 30s window contains exactly 15×100 + 15×300 = avg 200.
      // All rolling averages are 200 → NP = 200.
      final watts = List.generate(60, (i) => i.isEven ? 100.0 : 300.0);
      final ride = _rideWithReadings(_powerReadings(watts));

      expect(ride.averagePower.value, closeTo(200, 0.1));
      expect(ride.normalizedPower.value, closeTo(200, 0.5));
    });

    test('fewer than 30 readings → falls back to average power', () {
      final ride = _rideWithReadings(
        _powerReadings(List.filled(20, 250)),
      );
      // < 30 readings → NP = average power = 250.
      expect(ride.normalizedPower.value, closeTo(250, 0.01));
    });

    test('spiky power increases NP relative to average', () {
      // 30s at 50 W + 30s at 350 W → avg = 200 W, NP > 200 W.
      final watts = [
        ...List.filled(30, 50.0),
        ...List.filled(30, 350.0),
      ];
      final ride = _rideWithReadings(_powerReadings(watts));
      expect(ride.averagePower.value, closeTo(200, 0.1));
      expect(ride.normalizedPower.value, greaterThan(200));
    });

    test('1 hour constant 250 W → NP = 250', () {
      final ride = _rideWithReadings(
        _powerReadings(List.filled(3600, 250)),
      );
      expect(ride.normalizedPower.value, closeTo(250, 0.1));
    });
  });

  // =========================================================================
  // Intensity Factor
  // =========================================================================

  group('Ride — intensityFactor', () {
    test('NP = FTP → IF = 1.0', () {
      final ride = _rideWithReadings(
        _powerReadings(List.filled(60, 250)),
      );
      expect(ride.intensityFactor(const Watts(250)), closeTo(1.0, 0.01));
    });

    test('NP = 200, FTP = 250 → IF = 0.8', () {
      final ride = _rideWithReadings(
        _powerReadings(List.filled(60, 200)),
      );
      expect(ride.intensityFactor(const Watts(250)), closeTo(0.8, 0.01));
    });

    test('zero FTP → IF = 0', () {
      final ride = _rideWithReadings(
        _powerReadings(List.filled(60, 200)),
      );
      expect(ride.intensityFactor(Watts.zero), 0);
    });
  });

  // =========================================================================
  // TSS
  // =========================================================================

  group('Ride — tss', () {
    test('1 hour at FTP → TSS = 100', () {
      // 3600 seconds at exactly FTP (250 W).
      // NP = 250, IF = 1.0.
      // TSS = (3600 × 250 × 1.0) / (250 × 3600) × 100 = 100.
      final readings = _powerReadings(List.filled(3600, 250));
      final ride = _rideWithReadings(readings);
      expect(ride.tss(const Watts(250)), closeTo(100, 1));
    });

    test('30 min at IF 0.75 → TSS ≈ 28.1', () {
      // FTP = 200, riding at 150 W constant → NP ≈ 150, IF = 0.75.
      // TSS = (1800 × 150 × 0.75) / (200 × 3600) × 100 = 28.125.
      final readings = _powerReadings(List.filled(1800, 150));
      final ride = _rideWithReadings(readings);
      expect(ride.tss(const Watts(200)), closeTo(28.1, 0.5));
    });

    test('zero FTP → TSS = 0', () {
      final ride = _rideWithReadings(
        _powerReadings(List.filled(60, 200)),
      );
      expect(ride.tss(Watts.zero), 0);
    });

    test('no readings → TSS = 0', () {
      final ride = _rideWithReadings([]);
      expect(ride.tss(const Watts(250)), 0);
    });

    test('pause duration excluded from TSS', () {
      // 1800s of readings at 250W, but total wall-clock = 2400s (600s paused).
      // activeDuration = 2400 - 600 = 1800s.
      // TSS = (1800 × 250 × 1.0) / (250 × 3600) × 100 = 50.
      final readings = _powerReadings(List.filled(1800, 250));
      final start = readings.first.timestamp;
      final ride = Ride(
        id: 'pause-test',
        startTime: start,
        endTime: start.add(const Duration(seconds: 2400)), // 40 min wall clock
        status: RideStatus.finished,
        readings: readings,
        pauseDuration: const Duration(seconds: 600), // 10 min paused
      );
      // activeDuration = 2400 - 600 = 1800s.
      expect(ride.activeDuration.inSeconds, 1800);
      expect(ride.tss(const Watts(250)), closeTo(50, 1));
    });
  });

  // =========================================================================
  // Average Cadence / Average HR / Total Distance
  // =========================================================================

  group('Ride — derived metrics', () {
    test('averageCadence from mixed readings', () {
      final start = DateTime(2024, 1, 1);
      final readings = [
        SensorReading(timestamp: start, cadence: const Cadence(80)),
        SensorReading(
            timestamp: start.add(const Duration(seconds: 1)),
            cadence: const Cadence(100)),
        SensorReading(
            timestamp: start.add(const Duration(seconds: 2))), // no cadence
      ];
      final ride = _rideWithReadings(readings);
      expect(ride.averageCadence.rpm, closeTo(90, 0.01));
    });

    test('averageHr from mixed readings', () {
      final start = DateTime(2024, 1, 1);
      final readings = [
        SensorReading(timestamp: start, heartRate: const HeartRate(140)),
        SensorReading(
            timestamp: start.add(const Duration(seconds: 1)),
            heartRate: const HeartRate(160)),
      ];
      final ride = _rideWithReadings(readings);
      expect(ride.averageHr.bpm, 150);
    });

    test('totalDistance uses last reading', () {
      final start = DateTime(2024, 1, 1);
      final readings = [
        SensorReading(
            timestamp: start, distance: const Distance(0)),
        SensorReading(
            timestamp: start.add(const Duration(seconds: 1)),
            distance: const Distance(100)),
        SensorReading(
            timestamp: start.add(const Duration(seconds: 2)),
            distance: const Distance(250)),
      ];
      final ride = _rideWithReadings(readings);
      expect(ride.totalDistance.meters, 250);
    });
  });

  // =========================================================================
  // activeDuration
  // =========================================================================

  group('Ride — activeDuration', () {
    test('equals duration when no pauses', () {
      final start = DateTime(2024, 1, 1);
      final ride = Ride(
        id: 'test',
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
        status: RideStatus.finished,
      );
      expect(ride.activeDuration, const Duration(hours: 1));
    });

    test('subtracts pause duration', () {
      final start = DateTime(2024, 1, 1);
      final ride = Ride(
        id: 'test',
        startTime: start,
        endTime: start.add(const Duration(minutes: 45)),
        status: RideStatus.finished,
        pauseDuration: const Duration(minutes: 15),
      );
      expect(ride.activeDuration, const Duration(minutes: 30));
    });
  });

  // =========================================================================
  // NP mathematical validation
  // =========================================================================

  group('Ride — NP mathematical properties', () {
    test('NP close to avg for random data (smoothing effect)', () {
      // The 30s rolling average smooths data before the 4th-power step,
      // so NP can be very slightly below raw average in edge cases.
      // For realistic data, NP should be within a few % of average.
      final rng = Random(42);
      final watts = List.generate(120, (_) => 100.0 + rng.nextDouble() * 200);
      final ride = _rideWithReadings(_powerReadings(watts));

      final np = ride.normalizedPower.value;
      final avg = ride.averagePower.value;
      // NP should be within 5% of average for low-variance uniform data.
      expect((np - avg).abs() / avg, lessThan(0.05));
    });

    test('NP = avg when power is constant (no variance)', () {
      final ride = _rideWithReadings(
        _powerReadings(List.filled(120, 175)),
      );
      expect(
        ride.normalizedPower.value,
        closeTo(ride.averagePower.value, 0.01),
      );
    });

    test('NP > avg for block-structured intervals', () {
      // 60s at 150 W, 60s at 350 W. Average = 250 W.
      // The transition creates varying 30s rolling averages → NP > avg.
      final watts = [
        ...List.filled(60, 150.0),
        ...List.filled(60, 350.0),
      ];
      final ride = _rideWithReadings(_powerReadings(watts));
      expect(ride.normalizedPower.value, greaterThan(ride.averagePower.value));
    });
  });
}
