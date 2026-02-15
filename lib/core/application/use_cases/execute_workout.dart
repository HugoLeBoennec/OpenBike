import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_step.dart';
import '../../domain/ports/trainer_port.dart';
import '../../domain/value_objects/value_objects.dart';

class ExecuteWorkout {
  final TrainerPort _trainerPort;
  final Watts _ftp;

  ExecuteWorkout(this._trainerPort, this._ftp);

  Stream<WorkoutProgress> call(Workout workout) async* {
    for (var i = 0; i < workout.steps.length; i++) {
      final step = workout.steps[i];
      final targetWatts = Watts(_ftp.value * step.powerTargetPercent / 100);
      await _trainerPort.setTargetPower(targetWatts);

      final stepDuration = Duration(seconds: step.durationSeconds);
      final start = DateTime.now();
      while (DateTime.now().difference(start) < stepDuration) {
        yield WorkoutProgress(
          currentStepIndex: i,
          currentStep: step,
          elapsed: DateTime.now().difference(start),
          totalSteps: workout.steps.length,
        );
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
  }
}

class WorkoutProgress {
  final int currentStepIndex;
  final WorkoutStep currentStep;
  final Duration elapsed;
  final int totalSteps;

  const WorkoutProgress({
    required this.currentStepIndex,
    required this.currentStep,
    required this.elapsed,
    required this.totalSteps,
  });

  double get stepProgress {
    final stepMs = currentStep.durationSeconds * 1000;
    if (stepMs == 0) return 1;
    return elapsed.inMilliseconds / stepMs;
  }

  double get overallProgress => (currentStepIndex + stepProgress) / totalSteps;
}
