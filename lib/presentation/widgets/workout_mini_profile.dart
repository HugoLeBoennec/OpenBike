import 'package:flutter/material.dart';

import '../../core/domain/entities/workout_step.dart';

/// Compact bar-chart preview of a workout's step power profile.
///
/// Used by the workout builder/detail screens (static preview) and the
/// in-ride [WorkoutHudWidget] (with [progressFraction] drawing a cursor at
/// the current position in the workout).
class WorkoutMiniProfile extends StatelessWidget {
  const WorkoutMiniProfile({
    super.key,
    required this.steps,
    this.progressFraction,
    this.size = const Size(48, 32),
  });

  final List<WorkoutStep> steps;

  /// 0.0-1.0 position cursor. Null hides the cursor.
  final double? progressFraction;

  final Size size;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    return CustomPaint(
      painter: _MiniProfilePainter(steps, progressFraction),
      size: size,
    );
  }
}

/// One straight-line piece of the power profile: power runs from
/// [startPercent] to [endPercent] (% FTP) between [startSeconds] and
/// [endSeconds]. Ramps are sloped; steady blocks and interval phases are flat.
class ProfileSegment {
  const ProfileSegment({
    required this.type,
    required this.startSeconds,
    required this.endSeconds,
    required this.startPercent,
    required this.endPercent,
    this.isRest = false,
  });

  final StepType type;
  final int startSeconds;
  final int endSeconds;
  final double startPercent;
  final double endPercent;

  /// True for the "off" phase of an interval repeat.
  final bool isRest;

  @override
  String toString() =>
      'ProfileSegment($type, $startSeconds-${endSeconds}s, '
      '$startPercent→$endPercent%${isRest ? ', rest' : ''})';
}

/// Free-ride blocks have no power target; they're drawn at this level so
/// they stay visible instead of collapsing to zero height.
const double _freeRidePlaceholderPercent = 30;

/// Expands [steps] into the segments the painter draws, mirroring how
/// `WorkoutEngine` derives its target power: warm-up/cool-down/ramp go from
/// `powerLowPercent` to `powerHighPercent`, intervals alternate
/// `powerTargetPercent` (on) and `powerLowPercent` (off). Segment durations
/// add up to `Workout.totalDuration`.
@visibleForTesting
List<ProfileSegment> profileSegments(List<WorkoutStep> steps) {
  final segments = <ProfileSegment>[];
  var t = 0;

  void add(
    StepType type,
    int duration,
    double from,
    double to, {
    bool isRest = false,
  }) {
    if (duration <= 0) return;
    segments.add(ProfileSegment(
      type: type,
      startSeconds: t,
      endSeconds: t + duration,
      startPercent: from,
      endPercent: to,
      isRest: isRest,
    ));
    t += duration;
  }

  for (final step in steps) {
    switch (step.type) {
      case StepType.warmup:
      case StepType.cooldown:
      case StepType.ramp:
        add(
          step.type,
          step.durationSeconds,
          step.powerLowPercent ?? step.powerTargetPercent,
          step.powerHighPercent ?? step.powerTargetPercent,
        );
      case StepType.steadyState:
        add(step.type, step.durationSeconds, step.powerTargetPercent,
            step.powerTargetPercent);
      case StepType.interval:
        final repeat = step.repeat ?? 0;
        if (repeat <= 0) {
          add(step.type, step.durationSeconds, step.powerTargetPercent,
              step.powerTargetPercent);
          break;
        }
        final off = step.powerLowPercent ?? step.powerTargetPercent;
        for (var i = 0; i < repeat; i++) {
          add(step.type, step.durationSeconds, step.powerTargetPercent,
              step.powerTargetPercent);
          add(step.type, step.offDurationSeconds ?? 0, off, off,
              isRest: true);
        }
      case StepType.freeRide:
        add(step.type, step.durationSeconds, _freeRidePlaceholderPercent,
            _freeRidePlaceholderPercent);
    }
  }
  return segments;
}

class _MiniProfilePainter extends CustomPainter {
  _MiniProfilePainter(this.steps, this.progressFraction);
  final List<WorkoutStep> steps;
  final double? progressFraction;

  @override
  void paint(Canvas canvas, Size size) {
    if (steps.isEmpty) return;

    final segments = profileSegments(steps);
    if (segments.isEmpty) return;

    final maxPower = segments.fold<double>(
      0,
      (prev, s) => [prev, s.startPercent, s.endPercent]
          .reduce((a, b) => a > b ? a : b),
    );
    if (maxPower <= 0) return;

    final totalDur = segments.last.endSeconds;
    if (totalDur <= 0) return;

    double xAt(int seconds) => seconds / totalDur * size.width;
    double yAt(double percent) =>
        size.height - (percent / maxPower) * size.height;

    for (final seg in segments) {
      final x0 = xAt(seg.startSeconds);
      final x1 = xAt(seg.endSeconds);
      final path = Path()
        ..moveTo(x0, size.height)
        ..lineTo(x0, yAt(seg.startPercent))
        ..lineTo(x1, yAt(seg.endPercent))
        ..lineTo(x1, size.height)
        ..close();

      final color = _stepColor(seg.type);
      canvas.drawPath(
        path,
        Paint()..color = seg.isRest ? color.withValues(alpha: 0.45) : color,
      );
    }

    if (progressFraction != null) {
      final cursorX = progressFraction!.clamp(0.0, 1.0) * size.width;
      canvas.drawLine(
        Offset(cursorX, 0),
        Offset(cursorX, size.height),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5,
      );
    }
  }

  Color _stepColor(StepType type) {
    switch (type) {
      case StepType.warmup:
        return Colors.blue;
      case StepType.cooldown:
        return Colors.blue;
      case StepType.steadyState:
        return Colors.green;
      case StepType.interval:
        return Colors.orange;
      case StepType.freeRide:
        return Colors.grey;
      case StepType.ramp:
        return Colors.teal;
    }
  }

  @override
  bool shouldRepaint(covariant _MiniProfilePainter old) =>
      old.steps != steps || old.progressFraction != progressFraction;
}
