import 'package:freezed_annotation/freezed_annotation.dart';

part 'scheduled_workout.freezed.dart';

/// A workout placed on the training calendar for a given day.
///
/// [completedRideId] is set once a ride started from this entry finishes,
/// linking the plan to what actually happened.
@freezed
class ScheduledWorkout with _$ScheduledWorkout {
  const factory ScheduledWorkout({
    required String id,
    required String workoutId,
    required DateTime date,
    String? completedRideId,
    String? notes,
  }) = _ScheduledWorkout;
}
