import '../../domain/value_objects/value_objects.dart';
import 'ftp_estimator.dart';

/// Tells when a ramp test is over: for [graceSeconds] in a row the rider
/// couldn't keep the pedals turning at [minCadenceRpm], or couldn't make
/// [minPowerFraction] of the step's target.
///
/// A rider failing a ramp in ERG doesn't stop cleanly. The trainer holds the
/// watts as the cadence falls, so each pedal stroke takes more force — at
/// 285 W, 35 rpm is 2.4 times the force of 82 rpm — until the pedals barely
/// turn. Ending the ramp there drops the trainer to the cooldown instead of
/// leaving the rider to grind or to skip into harder steps.
///
/// Armed from the step where a result can count ([FtpEstimator.minRampSteps]):
/// before it, ending the ramp would throw the test away, and an easy step
/// ridden at a lazy cadence isn't a failure. A reading without cadence or
/// power (sensor dropout) leaves that half of the check out.
class RampFailureDetector {
  static const minCadenceRpm = 60.0;
  static const minPowerFraction = 0.8;
  static const graceSeconds = 10;

  int _strugglingSeconds = 0;

  /// Feeds one recorded second of the ramp step [stepIndex]; returns true
  /// once the ramp is over.
  bool addSecond({
    required int stepIndex,
    required Watts target,
    Watts? power,
    Cadence? cadence,
  }) {
    final armed = stepIndex + 1 >= FtpEstimator.minRampSteps;
    final lowCadence = cadence != null && cadence.rpm < minCadenceRpm;
    final lowPower =
        power != null && power.value < target.value * minPowerFraction;
    _strugglingSeconds =
        armed && (lowCadence || lowPower) ? _strugglingSeconds + 1 : 0;
    return _strugglingSeconds >= graceSeconds;
  }
}
