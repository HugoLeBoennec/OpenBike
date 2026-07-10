import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/ftp_estimator.dart';
import 'package:open_bike/core/domain/entities/sensor_reading.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';

List<SensorReading> _constantPower(double watts, int seconds) {
  final start = DateTime.utc(2026, 1, 1);
  return List.generate(
    seconds,
    (i) => SensorReading(
      timestamp: start.add(Duration(seconds: i)),
      power: Watts(watts),
    ),
  );
}

void main() {
  group('FtpEstimator.bestAveragePower', () {
    test('constant power over exactly the window returns that power', () {
      final readings = _constantPower(250, 60);
      expect(FtpEstimator.bestAveragePower(readings, 60), closeTo(250, 0.01));
    });

    test('finds the best rolling window, ignoring a low tail', () {
      // 90s @ 300W then 30s @ 100W — best 1-min window should still be 300W.
      final readings = [
        ..._constantPower(300, 90),
        ..._constantPower(100, 30),
      ];
      expect(FtpEstimator.bestAveragePower(readings, 60), closeTo(300, 0.01));
    });

    test('shorter than window falls back to overall average', () {
      final readings = _constantPower(200, 30);
      expect(FtpEstimator.bestAveragePower(readings, 60), closeTo(200, 0.01));
    });

    test('empty readings → 0', () {
      expect(FtpEstimator.bestAveragePower(const [], 60), 0);
    });
  });

  group('FtpEstimator.estimateFromRamp', () {
    test('75% of best 1-minute power', () {
      final readings = _constantPower(300, 90);
      final ftp = FtpEstimator.estimateFromRamp(readings);
      expect(ftp.value, closeTo(300 * 0.75, 0.01));
    });
  });

  group('FtpEstimator.estimateFrom20Min', () {
    test('95% of best 20-minute average power', () {
      final readings = _constantPower(250, 25 * 60); // 25 min ride
      final ftp = FtpEstimator.estimateFrom20Min(readings);
      expect(ftp.value, closeTo(250 * 0.95, 0.01));
    });

    test('warmup/cooldown at lower power do not drag the best window down',
        () {
      final readings = [
        ..._constantPower(120, 10 * 60), // warmup
        ..._constantPower(280, 20 * 60), // the actual test effort
        ..._constantPower(100, 5 * 60), // cooldown
      ];
      final ftp = FtpEstimator.estimateFrom20Min(readings);
      expect(ftp.value, closeTo(280 * 0.95, 0.01));
    });
  });
}
