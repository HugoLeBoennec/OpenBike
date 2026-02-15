import 'package:freezed_annotation/freezed_annotation.dart';
import 'workout_step.dart';

part 'workout.freezed.dart';

/// A timed text message displayed during a workout (e.g. ZWO `<textevent>`).
class TextEvent {
  const TextEvent({
    required this.offsetSeconds,
    required this.message,
    this.durationSeconds = 10,
  });

  /// Seconds from the start of the parent step.
  final int offsetSeconds;

  /// The message to display.
  final String message;

  /// How long the message stays on screen (default 10 s).
  final int durationSeconds;

  @override
  String toString() => 'TextEvent($offsetSeconds s: "$message")';
}

@freezed
class Workout with _$Workout {
  const Workout._();

  const factory Workout({
    required String id,
    required String name,
    String? description,
    required List<WorkoutStep> steps,
    String? source,
    @Default([]) List<TextEvent> textEvents,
  }) = _Workout;

  /// Total duration including interval repeats and off-phases.
  Duration get totalDuration => Duration(
      seconds:
          steps.fold<int>(0, (sum, step) => sum + step.totalDurationSeconds));
}
