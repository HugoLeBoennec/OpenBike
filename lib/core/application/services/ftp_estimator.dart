import '../../domain/entities/sensor_reading.dart';
import '../../domain/value_objects/value_objects.dart';
import 'ftp_test_planner.dart';

/// Estimates FTP from a completed ride's recorded power readings, per the
/// two bundled FTP test protocols (see `BundledWorkouts`).
class FtpEstimator {
  /// Best average power over any rolling window of [windowSeconds],
  /// assuming ~1 Hz readings (one sample per second, as produced by
  /// `RecordingEngine`). Falls back to the overall average if the ride is
  /// shorter than the window (e.g. the user stopped a ramp test early).
  static double bestAveragePower(
    List<SensorReading> readings,
    int windowSeconds,
  ) {
    final powers = readings.map((r) => r.power?.value ?? 0).toList();
    if (powers.isEmpty) return 0;
    if (powers.length < windowSeconds) {
      return powers.reduce((a, b) => a + b) / powers.length;
    }

    double windowSum = 0;
    for (var i = 0; i < windowSeconds; i++) {
      windowSum += powers[i];
    }
    double best = windowSum / windowSeconds;
    for (var i = windowSeconds; i < powers.length; i++) {
      windowSum += powers[i] - powers[i - windowSeconds];
      final avg = windowSum / windowSeconds;
      if (avg > best) best = avg;
    }
    return best;
  }

  /// Ramp test: FTP ≈ 75% of best 1-minute power.
  static Watts estimateFromRamp(List<SensorReading> readings) {
    return Watts(bestAveragePower(readings, 60) * 0.75);
  }

  /// 20-minute test: FTP ≈ 95% of best 20-minute average power.
  static Watts estimateFrom20Min(List<SensorReading> readings) {
    return Watts(bestAveragePower(readings, 20 * 60) * 0.95);
  }

  /// Ramp steps a test has to reach before its result counts. The ramp
  /// climbs 10% of FTP a minute from 50%, so the 8th step asks for 120%:
  /// stopping before it means the test was abandoned, not ridden to failure.
  static const minRampSteps = 8;

  /// Whether a test ride went far enough for its estimate to mean anything —
  /// the ramp for at least [minRampSteps] steps, or the 20-minute test past
  /// the end of its free-ride block ([testBlockStep]) with at least 20
  /// minutes recorded (skipping the block also gets past it). Without this,
  /// a ramp stopped after two minutes offered an FTP of a third of the
  /// rider's real one.
  static bool isCompleteTest(
    FtpTestProtocol protocol, {
    required int furthestStep,
    required int? testBlockStep,
    required int recordedSeconds,
  }) {
    return switch (protocol) {
      FtpTestProtocol.ramp => furthestStep + 1 >= minRampSteps,
      FtpTestProtocol.twentyMinute => testBlockStep != null &&
          furthestStep > testBlockStep &&
          recordedSeconds >= 20 * 60,
    };
  }
}
