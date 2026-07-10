import 'dart:math';

import '../../domain/entities/workout_step.dart';

/// Estimates a workout's Training Stress Score from its planned step power
/// targets — no recorded readings needed.
///
/// Mirrors `Ride.tss()`'s NP/IF/TSS formula: a duration-weighted 4th-power
/// average of the step targets stands in for Normalized Power (an ERG-driven
/// step holds its target closely, so this is a good proxy), then
/// `TSS = duration_s * NP * IF / (FTP * 3600) * 100` with target power
/// already expressed as %FTP (so `FTP` in that formula is `100`).
double estimateWorkoutTss(List<WorkoutStep> steps) {
  final segments = <_Segment>[
    for (final step in steps) ..._segmentsFor(step),
  ];

  final totalDuration = segments.fold<int>(0, (sum, s) => sum + s.durationSeconds);
  if (totalDuration == 0) return 0;

  final weightedPow4 = segments.fold<double>(
    0,
    (sum, s) => sum + s.durationSeconds * pow(s.powerPercent, 4),
  );
  final npEstimate = pow(weightedPow4 / totalDuration, 0.25).toDouble();

  final intensityFactor = npEstimate / 100.0;
  return (totalDuration * npEstimate * intensityFactor) / (100.0 * 3600) * 100;
}

class _Segment {
  const _Segment(this.durationSeconds, this.powerPercent);
  final int durationSeconds;
  final double powerPercent;
}

List<_Segment> _segmentsFor(WorkoutStep step) {
  switch (step.type) {
    case StepType.interval:
      final repeat = step.repeat ?? 1;
      final onPower = step.powerTargetPercent;
      final offPower = step.powerLowPercent ?? 0;
      final offDuration = step.offDurationSeconds ?? 0;
      final segments = <_Segment>[];
      for (var i = 0; i < repeat; i++) {
        segments.add(_Segment(step.durationSeconds, onPower));
        if (offDuration > 0) segments.add(_Segment(offDuration, offPower));
      }
      return segments;

    case StepType.warmup:
    case StepType.cooldown:
    case StepType.ramp:
      final low = step.powerLowPercent ?? 0;
      final high = step.powerHighPercent ?? 0;
      return [_Segment(step.durationSeconds, (low + high) / 2)];

    case StepType.freeRide:
      return [_Segment(step.durationSeconds, 0)];

    case StepType.steadyState:
      return [_Segment(step.durationSeconds, step.powerTargetPercent)];
  }
}
