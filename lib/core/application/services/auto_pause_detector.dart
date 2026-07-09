/// Detects a sustained low-speed condition during a ride, used to prompt the
/// rider to pause recording (e.g. stopped at a light, took a break).
///
/// Feed it a speed sample on every tick via [onSpeedSample]. It returns
/// `true` once the speed has stayed below [speedThresholdKmh] continuously
/// for [triggerAfter], then resets so it won't retrigger every subsequent
/// tick until the speed rises above the threshold and drops again.
class AutoPauseDetector {
  AutoPauseDetector({
    this.speedThresholdKmh = 2.0,
    this.triggerAfter = const Duration(seconds: 5),
  });

  final double speedThresholdKmh;
  final Duration triggerAfter;

  DateTime? _belowThresholdSince;

  bool onSpeedSample(double speedKmh, DateTime now) {
    if (speedKmh >= speedThresholdKmh) {
      _belowThresholdSince = null;
      return false;
    }

    _belowThresholdSince ??= now;
    if (now.difference(_belowThresholdSince!) >= triggerAfter) {
      _belowThresholdSince = null;
      return true;
    }
    return false;
  }

  void reset() => _belowThresholdSince = null;
}
