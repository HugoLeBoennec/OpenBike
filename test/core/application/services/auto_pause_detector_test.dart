import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/auto_pause_detector.dart';

void main() {
  group('AutoPauseDetector', () {
    late AutoPauseDetector detector;
    final t0 = DateTime(2026, 1, 1, 12, 0, 0);

    setUp(() {
      detector = AutoPauseDetector(
        speedThresholdKmh: 2.0,
        triggerAfter: const Duration(seconds: 5),
      );
    });

    test('does not trigger while speed stays above threshold', () {
      for (var i = 0; i < 10; i++) {
        final trigger =
            detector.onSpeedSample(20.0, t0.add(Duration(seconds: i)));
        expect(trigger, isFalse);
      }
    });

    test('does not trigger before the low-speed condition persists long enough', () {
      expect(detector.onSpeedSample(0.5, t0), isFalse);
      expect(detector.onSpeedSample(0.5, t0.add(const Duration(seconds: 2))),
          isFalse);
      expect(detector.onSpeedSample(0.5, t0.add(const Duration(seconds: 4))),
          isFalse);
    });

    test('triggers once low speed has persisted for triggerAfter', () {
      detector.onSpeedSample(0.5, t0);
      detector.onSpeedSample(0.5, t0.add(const Duration(seconds: 2)));
      final trigger =
          detector.onSpeedSample(0.5, t0.add(const Duration(seconds: 5)));
      expect(trigger, isTrue);
    });

    test('does not retrigger immediately after firing', () {
      detector.onSpeedSample(0.5, t0);
      final firstTrigger =
          detector.onSpeedSample(0.5, t0.add(const Duration(seconds: 5)));
      expect(firstTrigger, isTrue);

      final secondSample =
          detector.onSpeedSample(0.5, t0.add(const Duration(seconds: 6)));
      expect(secondSample, isFalse);
    });

    test('speed rising above threshold resets the low-speed window', () {
      detector.onSpeedSample(0.5, t0);
      detector.onSpeedSample(0.5, t0.add(const Duration(seconds: 3)));
      // Speed picks back up — resets the clock.
      detector.onSpeedSample(15.0, t0.add(const Duration(seconds: 4)));

      final trigger =
          detector.onSpeedSample(0.5, t0.add(const Duration(seconds: 6)));
      expect(trigger, isFalse,
          reason: 'Only 2s of low speed have elapsed since the reset');
    });

    test('reset() clears the tracked window', () {
      detector.onSpeedSample(0.5, t0);
      detector.reset();
      final trigger =
          detector.onSpeedSample(0.5, t0.add(const Duration(seconds: 5)));
      expect(trigger, isFalse);
    });

    test('exactly at threshold speed counts as moving (no trigger)', () {
      for (var i = 0; i <= 6; i++) {
        final trigger =
            detector.onSpeedSample(2.0, t0.add(Duration(seconds: i)));
        expect(trigger, isFalse);
      }
    });
  });
}
