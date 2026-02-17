import 'package:uuid/uuid.dart';

import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_step.dart';

/// Fluent builder for creating [Workout]s programmatically.
///
/// ```dart
/// final workout = WorkoutBuilder('Sweet Spot')
///   .warmup(duration: 600, fromPercent: 25, toPercent: 75)
///   .steady(duration: 1200, percent: 88)
///   .intervals(repeat: 3, onDuration: 300, offDuration: 120,
///              onPercent: 95, offPercent: 55)
///   .cooldown(duration: 300, fromPercent: 75, toPercent: 25)
///   .build();
/// ```
class WorkoutBuilder {
  WorkoutBuilder(this._name, {String? description, Uuid? uuid})
      : _description = description,
        _uuid = uuid ?? Uuid();

  final String _name;
  final String? _description;
  final Uuid _uuid;
  final _steps = <WorkoutStep>[];
  final _textEvents = <TextEvent>[];

  /// Adds a warmup ramp from [fromPercent] → [toPercent] % FTP.
  WorkoutBuilder warmup({
    required int duration,
    required double fromPercent,
    required double toPercent,
    int? cadence,
  }) {
    _steps.add(WorkoutStep(
      type: StepType.warmup,
      durationSeconds: duration,
      powerTargetPercent: 0,
      powerLowPercent: fromPercent,
      powerHighPercent: toPercent,
      cadenceTarget: cadence,
    ));
    return this;
  }

  /// Adds a steady-state block at [percent] % FTP.
  WorkoutBuilder steady({
    required int duration,
    required double percent,
    int? cadence,
  }) {
    _steps.add(WorkoutStep(
      type: StepType.steadyState,
      durationSeconds: duration,
      powerTargetPercent: percent,
      cadenceTarget: cadence,
    ));
    return this;
  }

  /// Adds an interval block: [repeat] × ([onDuration]s at [onPercent]% +
  /// [offDuration]s at [offPercent]%).
  WorkoutBuilder intervals({
    required int repeat,
    required int onDuration,
    required int offDuration,
    required double onPercent,
    required double offPercent,
    int? cadence,
    int? cadenceResting,
  }) {
    _steps.add(WorkoutStep(
      type: StepType.interval,
      durationSeconds: onDuration,
      offDurationSeconds: offDuration,
      powerTargetPercent: onPercent,
      powerLowPercent: offPercent,
      repeat: repeat,
      cadenceTarget: cadence,
      cadenceResting: cadenceResting,
    ));
    return this;
  }

  /// Adds a cooldown ramp from [fromPercent] → [toPercent] % FTP.
  WorkoutBuilder cooldown({
    required int duration,
    required double fromPercent,
    required double toPercent,
    int? cadence,
  }) {
    _steps.add(WorkoutStep(
      type: StepType.cooldown,
      durationSeconds: duration,
      powerTargetPercent: 0,
      powerLowPercent: fromPercent,
      powerHighPercent: toPercent,
      cadenceTarget: cadence,
    ));
    return this;
  }

  /// Adds a free-ride block (no ERG target).
  WorkoutBuilder freeRide({required int duration}) {
    _steps.add(WorkoutStep(
      type: StepType.freeRide,
      durationSeconds: duration,
      powerTargetPercent: 0,
    ));
    return this;
  }

  /// Adds a generic ramp block.
  WorkoutBuilder ramp({
    required int duration,
    required double fromPercent,
    required double toPercent,
    int? cadence,
  }) {
    _steps.add(WorkoutStep(
      type: StepType.ramp,
      durationSeconds: duration,
      powerTargetPercent: 0,
      powerLowPercent: fromPercent,
      powerHighPercent: toPercent,
      cadenceTarget: cadence,
    ));
    return this;
  }

  /// Adds a text event at [offsetSeconds] from workout start.
  WorkoutBuilder text(String message, {required int offsetSeconds, int duration = 10}) {
    _textEvents.add(TextEvent(
      offsetSeconds: offsetSeconds,
      message: message,
      durationSeconds: duration,
    ));
    return this;
  }

  /// Builds the final [Workout].
  Workout build() {
    return Workout(
      id: _uuid.v4(),
      name: _name,
      description: _description,
      steps: List.unmodifiable(_steps),
      textEvents: List.unmodifiable(_textEvents),
    );
  }
}
