import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/fitness_calculator.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';

DateTime _d(int y, int m, int d) => DateTime(y, m, d);

void main() {
  final calc = FitnessCalculator();

  group('FitnessCalculator — calculate', () {
    test('empty input returns no points', () {
      expect(calc.calculate({}), isEmpty);
    });

    test('single day: TSB starts at 0, CTL/ATL follow the EWMA formula', () {
      final points = calc.calculate({_d(2026, 1, 1): 100});

      expect(points, hasLength(1));
      final p = points.single;
      expect(p.tsb, 0); // no prior load
      expect(p.ctl, closeTo(100 / 42, 1e-9));
      expect(p.atl, closeTo(100 / 7, 1e-9));
    });

    test('hand-computed two-day sequence with a rest day', () {
      // Day 1: 100 TSS. Day 2: gap (0 TSS).
      final points = calc.calculate({
        _d(2026, 1, 1): 100.0,
        _d(2026, 1, 3): 0.0, // explicit zero — same as a gap day
      });

      // Fills the gap day (Jan 2) automatically between the two dates.
      expect(points.map((p) => p.date), [_d(2026, 1, 1), _d(2026, 1, 2), _d(2026, 1, 3)]);

      final day1 = points[0];
      final ctl1 = 100 / 42;
      final atl1 = 100 / 7;
      expect(day1.tsb, 0);
      expect(day1.ctl, closeTo(ctl1, 1e-9));
      expect(day1.atl, closeTo(atl1, 1e-9));

      final day2 = points[1];
      final ctl2 = ctl1 + (0 - ctl1) / 42;
      final atl2 = atl1 + (0 - atl1) / 7;
      expect(day2.tsb, closeTo(ctl1 - atl1, 1e-9));
      expect(day2.ctl, closeTo(ctl2, 1e-9));
      expect(day2.atl, closeTo(atl2, 1e-9));

      final day3 = points[2];
      expect(day3.tsb, closeTo(ctl2 - atl2, 1e-9));
    });

    test('gap days between explicit entries are filled with 0 TSS', () {
      final points = calc.calculate({
        _d(2026, 2, 1): 50,
        _d(2026, 2, 5): 50,
      });

      expect(points, hasLength(5));
      expect(points[1].tss, 0);
      expect(points[2].tss, 0);
      expect(points[3].tss, 0);
    });

    test('a single very high TSS day decays over time (ATL faster than CTL)',
        () {
      // ATL starts far above CTL (short time constant reacts fully to the
      // spike) but decays proportionally faster, so given enough rest days
      // it eventually drops below CTL.
      final input = <DateTime, double>{_d(2026, 3, 1): 300};
      for (var i = 1; i <= 30; i++) {
        input[_d(2026, 3, 1).add(Duration(days: i))] = 0;
      }
      final points = calc.calculate(input);

      final spikeDay = points.first;
      expect(spikeDay.atl, greaterThan(spikeDay.ctl));

      final last = points.last;
      expect(last.atl, lessThan(last.ctl));
    });

    test('duplicate keys at different times of day collapse to one day', () {
      final points = calc.calculate({
        DateTime(2026, 4, 1, 6): 40,
        DateTime(2026, 4, 1, 20): 60,
      });

      expect(points, hasLength(1));
      expect(points.single.tss, 100);
    });
  });

  group('dailyTssFromRides', () {
    Ride finishedRide({
      required String id,
      required DateTime start,
      required List<SensorReading> readings,
    }) {
      return Ride(
        id: id,
        startTime: start,
        endTime: start.add(Duration(seconds: readings.length)),
        status: RideStatus.finished,
        readings: readings,
      );
    }

    List<SensorReading> steadyPower(DateTime start, double watts, int seconds) {
      return [
        for (var i = 0; i < seconds; i++)
          SensorReading(
            timestamp: start.add(Duration(seconds: i)),
            power: Watts(watts),
          ),
      ];
    }

    test('scores each ride against the FTP effective on its own date', () {
      final oldRideDate = _d(2025, 1, 1);
      final newRideDate = _d(2026, 1, 1);

      // FTP was 200 W in 2025, raised to 250 W partway through 2025.
      final ftpHistory = [
        FtpHistoryEntry(effectiveDate: _d(2024, 1, 1), ftp: const Watts(200)),
        FtpHistoryEntry(effectiveDate: _d(2025, 6, 1), ftp: const Watts(250)),
      ];

      final oldRide = finishedRide(
        id: 'old',
        start: oldRideDate,
        readings: steadyPower(oldRideDate, 200, 600),
      );
      final newRide = finishedRide(
        id: 'new',
        start: newRideDate,
        readings: steadyPower(newRideDate, 250, 600),
      );

      final daily = dailyTssFromRides(
        [oldRide, newRide],
        ftpHistory: ftpHistory,
        currentFtp: const Watts(300), // simulates a later FTP bump
      );

      // oldRide predates every history entry with effectiveDate <= its date
      // except the 2024 one, so it's scored against 200 W: TSS should equal
      // riding exactly at FTP for 10 minutes => IF 1.0, TSS ~= 16.67.
      final oldTss = daily[oldRideDate]!;
      expect(oldTss, closeTo((600 / 3600) * 100, 0.5));

      // newRide is scored against the 250 W entry (effective mid-2025),
      // also riding at FTP => same duration-scaled TSS, not skewed by the
      // later currentFtp=300 bump.
      final newTss = daily[newRideDate]!;
      expect(newTss, closeTo((600 / 3600) * 100, 0.5));
    });

    test('falls back to currentFtp when there is no FTP history at all', () {
      final date = _d(2026, 5, 1);
      final ride = finishedRide(
        id: 'r1',
        start: date,
        readings: steadyPower(date, 200, 600),
      );

      final daily = dailyTssFromRides(
        [ride],
        ftpHistory: const [],
        currentFtp: const Watts(200),
      );

      expect(daily[date], closeTo((600 / 3600) * 100, 0.5));
    });

    test('ignores non-finished rides', () {
      final date = _d(2026, 6, 1);
      final ride = Ride(
        id: 'active',
        startTime: date,
        status: RideStatus.active,
        readings: steadyPower(date, 200, 600),
      );

      final daily = dailyTssFromRides(
        [ride],
        ftpHistory: const [],
        currentFtp: const Watts(200),
      );

      expect(daily, isEmpty);
    });

    test('sums multiple rides on the same day', () {
      final date = _d(2026, 7, 1);
      final ride1 = finishedRide(
        id: 'a',
        start: date,
        readings: steadyPower(date, 200, 600),
      );
      final ride2 = finishedRide(
        id: 'b',
        start: date.add(const Duration(hours: 5)),
        readings: steadyPower(date, 200, 600),
      );

      final daily = dailyTssFromRides(
        [ride1, ride2],
        ftpHistory: const [],
        currentFtp: const Watts(200),
      );

      expect(daily[date], closeTo(2 * (600 / 3600) * 100, 1));
    });
  });
}
