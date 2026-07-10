import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/tss_estimator.dart';
import 'package:open_bike/core/domain/entities/workout_step.dart';

void main() {
  group('estimateWorkoutTss', () {
    test('empty steps → 0', () {
      expect(estimateWorkoutTss(const []), 0);
    });

    test('single 1-hour steady step at 100% FTP → TSS 100', () {
      const steps = [
        WorkoutStep(
          type: StepType.steadyState,
          durationSeconds: 3600,
          powerTargetPercent: 100,
        ),
      ];
      expect(estimateWorkoutTss(steps), closeTo(100, 0.01));
    });

    test('30-minute steady step at 100% FTP → TSS 50', () {
      const steps = [
        WorkoutStep(
          type: StepType.steadyState,
          durationSeconds: 1800,
          powerTargetPercent: 100,
        ),
      ];
      expect(estimateWorkoutTss(steps), closeTo(50, 0.01));
    });

    test('interval step expands on/off phases across all repeats', () {
      // 2 x (5 min @ 105% / 1 min @ 50%) — matches the editor widget test's
      // hand-computed value below.
      const steps = [
        WorkoutStep(
          type: StepType.interval,
          durationSeconds: 300,
          offDurationSeconds: 60,
          powerTargetPercent: 105,
          powerLowPercent: 50,
          repeat: 2,
        ),
      ];

      // NP = (Σ duration·power⁴ / Σ duration)^(1/4)
      const onDur = 300.0, offDur = 60.0, onPow = 105.0, offPow = 50.0;
      final totalDur = 2 * (onDur + offDur);
      final weighted = 2 * (onDur * pow(onPow, 4) + offDur * pow(offPow, 4));
      final np = pow(weighted / totalDur, 0.25).toDouble();
      final ifactor = np / 100.0;
      final expectedTss = (totalDur * np * ifactor) / (100.0 * 3600) * 100;

      expect(estimateWorkoutTss(steps), closeTo(expectedTss, 0.01));
    });

    test('freeRide contributes duration but zero intensity', () {
      const steps = [
        WorkoutStep(
          type: StepType.freeRide,
          durationSeconds: 600,
          powerTargetPercent: 0,
        ),
      ];
      expect(estimateWorkoutTss(steps), 0);
    });

    test('ramp step uses the midpoint of low/high as its intensity', () {
      const steps = [
        WorkoutStep(
          type: StepType.ramp,
          durationSeconds: 3600,
          powerTargetPercent: 0,
          powerLowPercent: 80,
          powerHighPercent: 120,
        ),
      ];
      // Midpoint = 100% FTP for 1 hour → TSS 100.
      expect(estimateWorkoutTss(steps), closeTo(100, 0.01));
    });
  });
}
