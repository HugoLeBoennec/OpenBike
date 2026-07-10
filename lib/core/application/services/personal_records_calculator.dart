import '../../domain/entities/personal_record.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../domain/value_objects/value_objects.dart';

/// A single duration bucket's best (mean-max) power for one ride.
class MeanMaxPower {
  const MeanMaxPower({required this.durationSeconds, required this.watts});

  final int durationSeconds;
  final Watts watts;
}

/// Computes mean-max power (the highest rolling-average power sustained for
/// a fixed duration) for the standard personal-record windows: 5 s, 1 min,
/// 5 min, 20 min.
///
/// Readings are assumed to be the ~1 Hz samples [RecordingEngine] produces —
/// a rolling window sum is a good approximation of a true mean-max power
/// curve at that sampling rate.
class PersonalRecordsCalculator {
  /// Returns one [MeanMaxPower] per duration in [personalRecordDurations]
  /// that the ride is long enough to have data for.
  List<MeanMaxPower> computeMeanMax(List<SensorReading> readings) {
    final powers = readings.map((r) => r.power?.value ?? 0.0).toList();
    final results = <MeanMaxPower>[];

    for (final duration in personalRecordDurations) {
      if (powers.length < duration) continue;

      double windowSum = 0;
      for (var i = 0; i < duration; i++) {
        windowSum += powers[i];
      }
      double best = windowSum;
      for (var i = duration; i < powers.length; i++) {
        windowSum += powers[i] - powers[i - duration];
        if (windowSum > best) best = windowSum;
      }

      results.add(MeanMaxPower(
        durationSeconds: duration,
        watts: Watts(best / duration),
      ));
    }

    return results;
  }

  /// Converts this ride's mean-max powers into [PersonalRecord] rows ready
  /// to persist.
  List<PersonalRecord> computeRecords({
    required String rideId,
    required DateTime achievedAt,
    required List<SensorReading> readings,
  }) {
    return computeMeanMax(readings)
        .map((mm) => PersonalRecord(
              rideId: rideId,
              durationSeconds: mm.durationSeconds,
              watts: mm.watts,
              achievedAt: achievedAt,
            ))
        .toList();
  }
}
