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

class _MiniProfilePainter extends CustomPainter {
  _MiniProfilePainter(this.steps, this.progressFraction);
  final List<WorkoutStep> steps;
  final double? progressFraction;

  @override
  void paint(Canvas canvas, Size size) {
    if (steps.isEmpty) return;

    final maxPower = steps.fold<double>(
      0,
      (prev, s) => s.powerTargetPercent > prev ? s.powerTargetPercent : prev,
    );
    if (maxPower <= 0) return;

    final totalDur = steps.fold<int>(0, (s, step) => s + step.totalDurationSeconds);
    if (totalDur <= 0) return;

    double x = 0;
    for (final step in steps) {
      final w = (step.totalDurationSeconds / totalDur) * size.width;
      final h = (step.powerTargetPercent / maxPower) * size.height;
      final y = size.height - h;

      final color = _stepColor(step.type);
      canvas.drawRect(
        Rect.fromLTWH(x, y, w.clamp(1, size.width), h),
        Paint()..color = color,
      );
      x += w;
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
