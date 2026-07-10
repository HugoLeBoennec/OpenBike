import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/application/services/workout_engine.dart';
import '../../core/domain/entities/workout.dart';
import '../../core/domain/entities/workout_step.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import 'workout_mini_profile.dart';

/// In-ride HUD for a structured workout: current step + target, countdown,
/// next-step preview, ERG compliance, and a whole-workout mini profile.
///
/// Shown on the ride screen whenever a workout is active. Renders nothing
/// when there is no current workout or no progress has been emitted yet.
class WorkoutHudWidget extends ConsumerWidget {
  const WorkoutHudWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(currentWorkoutProvider);
    if (workout == null) return const SizedBox.shrink();

    final progressAsync = ref.watch(workoutProgressProvider);

    return progressAsync.when(
      data: (progress) => _WorkoutHudContent(workout: workout, progress: progress),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _WorkoutHudContent extends ConsumerWidget {
  const _WorkoutHudContent({required this.workout, required this.progress});

  final Workout workout;
  final WorkoutProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ftp = ref.watch(ftpProvider);
    final avgPower = ref.watch(threeSecondAvgPowerProvider);

    final step = progress.currentStep;
    final targetPct = ftp.value > 0
        ? (progress.targetPower.value / ftp.value * 100).round()
        : 0;

    final nextStep = progress.currentStepIndex + 1 < workout.steps.length
        ? workout.steps[progress.currentStepIndex + 1]
        : null;

    return Container(
      color: context.tokens.rideSurfaceDeep,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _stepLabel(step.type),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${progress.targetPower.value.round()} W',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '  $targetPct% FTP',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ComplianceBadge(
                    avgPower: avgPower,
                    targetPower: progress.targetPower,
                  ),
                  const SizedBox(width: 8),
                  _SkipButton(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Step progress bar + countdown.
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress.stepProgress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    valueColor:
                        const AlwaysStoppedAnimation(Colors.greenAccent),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatCountdown(progress.remainingInStep),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Next step preview.
          Text(
            nextStep != null
                ? 'Next: ${_formatNextStep(nextStep, ftp)}'
                : 'Last step',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),

          const SizedBox(height: 8),

          // Whole-workout mini profile with position cursor.
          SizedBox(
            height: 28,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return WorkoutMiniProfile(
                  steps: workout.steps,
                  progressFraction: progress.overallProgress,
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                );
              },
            ),
          ),

          if (progress.textEvent != null) ...[
            const SizedBox(height: 8),
            _TextEventToast(message: progress.textEvent!.message),
          ],
        ],
      ),
    );
  }

  String _stepLabel(StepType type) {
    switch (type) {
      case StepType.warmup:
        return 'WARM UP';
      case StepType.cooldown:
        return 'COOL DOWN';
      case StepType.steadyState:
        return 'STEADY STATE';
      case StepType.interval:
        return 'INTERVAL';
      case StepType.freeRide:
        return 'FREE RIDE';
      case StepType.ramp:
        return 'RAMP';
    }
  }

  String _formatCountdown(Duration d) {
    final clamped = d.isNegative ? Duration.zero : d;
    final m = clamped.inMinutes;
    final s = clamped.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _formatNextStep(WorkoutStep step, Watts ftp) {
    final watts = _stepDisplayPower(step, ftp).round();
    final duration = Duration(seconds: step.totalDurationSeconds);
    final mins = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    final durText =
        mins > 0 ? '$mins min${secs > 0 ? ' ${secs}s' : ''}' : '${secs}s';
    return '$durText @ $watts W';
  }

  /// Estimated target power for a not-yet-active step, using the same
  /// conversion [WorkoutEngine] applies once the step becomes current.
  double _stepDisplayPower(WorkoutStep step, Watts ftp) {
    switch (step.type) {
      case StepType.steadyState:
      case StepType.interval:
        return step.powerTargetPercent / 100 * ftp.value;
      case StepType.warmup:
      case StepType.cooldown:
      case StepType.ramp:
        final low = step.powerLowPercent ?? step.powerTargetPercent;
        final high = step.powerHighPercent ?? step.powerTargetPercent;
        return (low + high) / 2 / 100 * ftp.value;
      case StepType.freeRide:
        return 0;
    }
  }
}

// ---------------------------------------------------------------------------
// ERG compliance badge — 3s avg power vs target, colored on/under/over
// ---------------------------------------------------------------------------

class _ComplianceBadge extends StatelessWidget {
  const _ComplianceBadge({required this.avgPower, required this.targetPower});

  final Watts avgPower;
  final Watts targetPower;

  static const _toleranceFraction = 0.05;

  @override
  Widget build(BuildContext context) {
    if (targetPower.value <= 0) return const SizedBox.shrink();

    final delta = avgPower.value - targetPower.value;
    final tolerance = targetPower.value * _toleranceFraction;

    final Color color;
    final String label;
    if (delta.abs() <= tolerance) {
      color = Colors.greenAccent;
      label = 'ON';
    } else if (delta < 0) {
      color = Colors.blueAccent;
      label = 'UNDER';
    } else {
      color = Colors.redAccent;
      label = 'OVER';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skip step button
// ---------------------------------------------------------------------------

class _SkipButton extends ConsumerWidget {
  const _SkipButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.skip_next, color: Colors.white70, size: 22),
      tooltip: 'Skip step',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: () {
        final engine = ref.read(workoutEngineProvider);
        if (engine.state == WorkoutEngineState.running ||
            engine.state == WorkoutEngineState.paused) {
          engine.skip();
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Text-event toast
// ---------------------------------------------------------------------------

class _TextEventToast extends StatelessWidget {
  const _TextEventToast({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.amber, fontSize: 12),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
