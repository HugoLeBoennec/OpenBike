import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/application/services/workout_engine.dart';
import '../state/providers.dart';

/// Pauses recording and, if a workout is active, the [WorkoutEngine] too —
/// shared by [RideHeaderBar]'s pause button and the auto-pause prompt so
/// both paths keep ERG targets and the recorded timeline in sync.
void pauseRide(WidgetRef ref) {
  ref.read(recordingEngineProvider).pause();
  if (ref.read(currentWorkoutProvider) != null) {
    final engine = ref.read(workoutEngineProvider);
    if (engine.state == WorkoutEngineState.running) engine.pause();
  }
}

/// Resumes recording and, if a workout is active, the [WorkoutEngine] too.
void resumeRide(WidgetRef ref) {
  ref.read(recordingEngineProvider).resume();
  if (ref.read(currentWorkoutProvider) != null) {
    final engine = ref.read(workoutEngineProvider);
    if (engine.state == WorkoutEngineState.paused) engine.resume();
  }
}
