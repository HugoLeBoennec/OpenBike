import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/workout_builder.dart';
import 'package:open_bike/core/domain/entities/workout_step.dart';

void main() {
  group('WorkoutBuilder', () {
    test('builds a complete workout', () {
      final workout = WorkoutBuilder('Sweet Spot', description: 'Test workout')
          .warmup(duration: 600, fromPercent: 25, toPercent: 75)
          .steady(duration: 1200, percent: 88, cadence: 90)
          .intervals(
            repeat: 3,
            onDuration: 60,
            offDuration: 120,
            onPercent: 120,
            offPercent: 55,
            cadence: 100,
            cadenceResting: 85,
          )
          .cooldown(duration: 300, fromPercent: 75, toPercent: 25)
          .build();

      expect(workout.name, 'Sweet Spot');
      expect(workout.description, 'Test workout');
      expect(workout.id, isNotEmpty);
      expect(workout.steps, hasLength(4));
    });

    test('warmup step has correct properties', () {
      final workout = WorkoutBuilder('Test')
          .warmup(duration: 600, fromPercent: 25, toPercent: 75)
          .build();

      final step = workout.steps.first;
      expect(step.type, StepType.warmup);
      expect(step.durationSeconds, 600);
      expect(step.powerLowPercent, 25);
      expect(step.powerHighPercent, 75);
    });

    test('steady step has correct power', () {
      final workout = WorkoutBuilder('Test')
          .steady(duration: 1200, percent: 88)
          .build();

      final step = workout.steps.first;
      expect(step.type, StepType.steadyState);
      expect(step.powerTargetPercent, 88);
    });

    test('interval step has on/off durations', () {
      final workout = WorkoutBuilder('Test')
          .intervals(
            repeat: 5,
            onDuration: 60,
            offDuration: 120,
            onPercent: 120,
            offPercent: 55,
          )
          .build();

      final step = workout.steps.first;
      expect(step.type, StepType.interval);
      expect(step.repeat, 5);
      expect(step.durationSeconds, 60);
      expect(step.offDurationSeconds, 120);
      expect(step.powerTargetPercent, 120);
      expect(step.powerLowPercent, 55);
      expect(step.totalDurationSeconds, 900); // 5 × (60 + 120)
    });

    test('freeRide step', () {
      final workout = WorkoutBuilder('Test')
          .freeRide(duration: 300)
          .build();

      expect(workout.steps.first.type, StepType.freeRide);
      expect(workout.steps.first.durationSeconds, 300);
    });

    test('ramp step', () {
      final workout = WorkoutBuilder('Test')
          .ramp(duration: 120, fromPercent: 60, toPercent: 100)
          .build();

      final step = workout.steps.first;
      expect(step.type, StepType.ramp);
      expect(step.powerLowPercent, 60);
      expect(step.powerHighPercent, 100);
    });

    test('text events are included', () {
      final workout = WorkoutBuilder('Test')
          .steady(duration: 600, percent: 88)
          .text('Push hard!', offsetSeconds: 10, duration: 15)
          .text('Almost there!', offsetSeconds: 550)
          .build();

      expect(workout.textEvents, hasLength(2));
      expect(workout.textEvents[0].message, 'Push hard!');
      expect(workout.textEvents[0].offsetSeconds, 10);
      expect(workout.textEvents[0].durationSeconds, 15);
      expect(workout.textEvents[1].message, 'Almost there!');
    });

    test('total duration accounts for interval repeats', () {
      final workout = WorkoutBuilder('Test')
          .warmup(duration: 300, fromPercent: 25, toPercent: 75)
          .intervals(
            repeat: 5,
            onDuration: 60,
            offDuration: 60,
            onPercent: 120,
            offPercent: 55,
          )
          .cooldown(duration: 300, fromPercent: 75, toPercent: 25)
          .build();

      // 300 + 5×(60+60) + 300 = 1200s
      expect(workout.totalDuration, const Duration(seconds: 1200));
    });
  });
}
