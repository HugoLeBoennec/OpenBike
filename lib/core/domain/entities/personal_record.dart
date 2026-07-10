import 'package:freezed_annotation/freezed_annotation.dart';

import '../value_objects/value_objects.dart';

part 'personal_record.freezed.dart';

/// A mean-max power reading for one ride over a fixed [durationSeconds]
/// window (e.g. best 5-minute power). One row is cached per (ride, duration)
/// so all-time and last-90-day bests can be derived by querying rather than
/// maintained as separate running-best state.
@freezed
class PersonalRecord with _$PersonalRecord {
  const factory PersonalRecord({
    required String rideId,
    required int durationSeconds,
    required Watts watts,
    required DateTime achievedAt,
  }) = _PersonalRecord;
}

/// Standard mean-max windows tracked for personal records: 5 s, 1 min,
/// 5 min, 20 min.
const personalRecordDurations = [5, 60, 300, 1200];
