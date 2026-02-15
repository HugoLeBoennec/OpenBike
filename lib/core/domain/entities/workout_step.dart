import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_step.freezed.dart';

enum StepType { warmup, cooldown, steadyState, interval, freeRide, ramp }

@freezed
class WorkoutStep with _$WorkoutStep {
  const WorkoutStep._();

  const factory WorkoutStep({
    required StepType type,
    required int durationSeconds,
    required double powerTargetPercent,
    double? powerLowPercent,
    double? powerHighPercent,
    int? cadenceTarget,
    int? repeat,

    /// Duration of the "off" / rest phase for interval steps (seconds).
    int? offDurationSeconds,

    /// Cadence target during the rest phase of interval steps.
    int? cadenceResting,
  }) = _WorkoutStep;

  /// Total duration including all repeats and off-phases for interval steps.
  int get totalDurationSeconds {
    if (type == StepType.interval && repeat != null && repeat! > 0) {
      final onDur = durationSeconds;
      final offDur = offDurationSeconds ?? 0;
      return (repeat! * (onDur + offDur)).toInt();
    }
    return durationSeconds;
  }
}
