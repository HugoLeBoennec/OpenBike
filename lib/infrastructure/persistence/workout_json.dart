import 'dart:convert';

import '../../core/domain/entities/workout.dart';
import '../../core/domain/entities/workout_step.dart';

/// Manual JSON (de)serialization for [Workout]/[WorkoutStep]/[TextEvent].
///
/// The freezed entities aren't `json_serializable`-annotated, so this hand
/// rolls the mapping used to pack a workout's steps + text events into the
/// single `Workouts.stepsJson` column (see [DriftStorage]).
class WorkoutJson {
  /// Encodes [steps] and [textEvents] into the JSON blob stored in
  /// `Workouts.stepsJson`.
  static String encode(List<WorkoutStep> steps, List<TextEvent> textEvents) {
    return jsonEncode({
      'steps': steps.map(_stepToJson).toList(),
      'textEvents': textEvents.map(_textEventToJson).toList(),
    });
  }

  /// Decodes a `Workouts.stepsJson` blob back into steps + text events.
  static (List<WorkoutStep>, List<TextEvent>) decode(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    final steps = (map['steps'] as List<dynamic>? ?? [])
        .map((e) => _stepFromJson(e as Map<String, dynamic>))
        .toList();
    final textEvents = (map['textEvents'] as List<dynamic>? ?? [])
        .map((e) => _textEventFromJson(e as Map<String, dynamic>))
        .toList();
    return (steps, textEvents);
  }

  static Map<String, dynamic> _stepToJson(WorkoutStep step) => {
        'type': step.type.name,
        'durationSeconds': step.durationSeconds,
        'powerTargetPercent': step.powerTargetPercent,
        'powerLowPercent': step.powerLowPercent,
        'powerHighPercent': step.powerHighPercent,
        'cadenceTarget': step.cadenceTarget,
        'repeat': step.repeat,
        'offDurationSeconds': step.offDurationSeconds,
        'cadenceResting': step.cadenceResting,
      };

  static WorkoutStep _stepFromJson(Map<String, dynamic> json) => WorkoutStep(
        type: StepType.values.byName(json['type'] as String),
        durationSeconds: json['durationSeconds'] as int,
        powerTargetPercent: (json['powerTargetPercent'] as num).toDouble(),
        powerLowPercent: (json['powerLowPercent'] as num?)?.toDouble(),
        powerHighPercent: (json['powerHighPercent'] as num?)?.toDouble(),
        cadenceTarget: json['cadenceTarget'] as int?,
        repeat: json['repeat'] as int?,
        offDurationSeconds: json['offDurationSeconds'] as int?,
        cadenceResting: json['cadenceResting'] as int?,
      );

  static Map<String, dynamic> _textEventToJson(TextEvent event) => {
        'offsetSeconds': event.offsetSeconds,
        'message': event.message,
        'durationSeconds': event.durationSeconds,
      };

  static TextEvent _textEventFromJson(Map<String, dynamic> json) => TextEvent(
        offsetSeconds: json['offsetSeconds'] as int,
        message: json['message'] as String,
        durationSeconds: json['durationSeconds'] as int? ?? 10,
      );
}
