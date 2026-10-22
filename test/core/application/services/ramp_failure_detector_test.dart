import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/ramp_failure_detector.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';

void main() {
  const target = Watts(285);
  // The 15th ramp step, well past the point where a result counts.
  const step = 14;

  bool feed(
    RampFailureDetector detector, {
    int stepIndex = step,
    double? rpm = 90,
    double? watts = 285,
  }) =>
      detector.addSecond(
        stepIndex: stepIndex,
        target: target,
        power: watts == null ? null : Watts(watts),
        cadence: rpm == null ? null : Cadence(rpm),
      );

  group('RampFailureDetector', () {
    test('ends the ramp after 10 s below 60 rpm', () {
      final detector = RampFailureDetector();
      for (var i = 0; i < 9; i++) {
        expect(feed(detector, rpm: 45), isFalse);
      }
      expect(feed(detector, rpm: 45), isTrue);
    });

    test('ends the ramp after 10 s under 80% of the target', () {
      final detector = RampFailureDetector();
      for (var i = 0; i < 9; i++) {
        expect(feed(detector, watts: 220), isFalse);
      }
      expect(feed(detector, watts: 220), isTrue);
    });

    test('a second back on target starts the count again', () {
      final detector = RampFailureDetector();
      for (var i = 0; i < 9; i++) {
        feed(detector, rpm: 45);
      }
      expect(feed(detector), isFalse);
      for (var i = 0; i < 9; i++) {
        expect(feed(detector, rpm: 45), isFalse);
      }
      expect(feed(detector, rpm: 45), isTrue);
    });

    test('is not armed before the step where a result counts', () {
      final detector = RampFailureDetector();
      for (var i = 0; i < 30; i++) {
        expect(feed(detector, stepIndex: 6, rpm: 45, watts: 0), isFalse);
      }
    });

    test('a missing cadence or power leaves that half of the check out', () {
      final detector = RampFailureDetector();
      for (var i = 0; i < 30; i++) {
        expect(feed(detector, rpm: null), isFalse);
        expect(feed(detector, watts: null), isFalse);
      }
    });

    test('ends the 285 W step of a real failed ramp before the pedals lock',
        () {
      // Seconds 20-60 of the step the rider failed: cadence sagged from the
      // high 70s, fell under 60 at second 19 and below 35 by second 26,
      // while ERG held the watts.
      const power = [
        283, 289, 285, 283, 282, 275, 275, 290, 294, 288, //
        283, 283, 285, 285, 283, 281, 282, 278, 266, 274,
        274, 276, 272, 260, 264, 259, 242, 226, 236, 246,
        272, 281, 273, 254, 213, 213, 162, 53, 41, 125,
      ];
      const cadence = [
        76, 75, 75, 77, 78, 76, 72, 67, 66, 69, //
        74, 74, 73, 73, 73, 72, 70, 67, 63, 58,
        53, 49, 47, 43, 40, 38, 35, 33, 32, 32,
        32, 31, 32, 34, 35, 33, 33, 30, 32, 44,
      ];
      final detector = RampFailureDetector();
      final ended = [
        for (var i = 0; i < power.length; i++)
          feed(detector,
              rpm: cadence[i].toDouble(), watts: power[i].toDouble()),
      ];
      expect(ended.indexOf(true), 28);
    });
  });
}
