import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/bundled_workouts.dart';
import 'package:open_bike/core/domain/entities/workout_step.dart';
import 'package:open_bike/presentation/widgets/workout_mini_profile.dart';

void main() {
  group('profileSegments', () {
    test('warm-up ramp is one sloped segment', () {
      final segments = profileSegments(const [
        WorkoutStep(
          type: StepType.warmup,
          durationSeconds: 600,
          powerTargetPercent: 0,
          powerLowPercent: 40,
          powerHighPercent: 75,
        ),
      ]);

      expect(segments, hasLength(1));
      expect(segments.single.startSeconds, 0);
      expect(segments.single.endSeconds, 600);
      expect(segments.single.startPercent, 40);
      expect(segments.single.endPercent, 75);
    });

    test('repeated intervals alternate on and off segments', () {
      final segments = profileSegments(const [
        WorkoutStep(
          type: StepType.interval,
          durationSeconds: 720,
          offDurationSeconds: 300,
          powerTargetPercent: 90,
          powerLowPercent: 55,
          repeat: 3,
        ),
      ]);

      expect(segments, hasLength(6));
      expect(segments.map((s) => s.isRest), [false, true, false, true, false, true]);
      expect(segments.map((s) => s.startPercent), [90, 55, 90, 55, 90, 55]);
      expect(segments.last.endSeconds, 3 * (720 + 300));
    });

    test('free ride stays visible', () {
      final segments = profileSegments(const [
        WorkoutStep(
          type: StepType.freeRide,
          durationSeconds: 300,
          powerTargetPercent: 0,
        ),
      ]);

      expect(segments.single.startPercent, greaterThan(0));
    });

    test('segments are contiguous and sum to the workout duration for every '
        'bundled workout', () {
      for (final workout in BundledWorkouts.all) {
        final segments = profileSegments(workout.steps);

        var cursor = 0;
        for (final seg in segments) {
          expect(seg.startSeconds, cursor, reason: workout.name);
          cursor = seg.endSeconds;
        }
        expect(cursor, workout.totalDuration.inSeconds, reason: workout.name);
      }
    });
  });
}
