import 'ant_constants.dart';

/// Builds ANT+ FE-C control page payloads (8 bytes each).
///
/// Sent as acknowledged data messages to the trainer.
class AntFecControl {
  AntFecControl._();

  /// Page 48: Basic Resistance (0–100%, 0.5% resolution).
  static List<int> basicResistance(double percent) {
    final value = (percent * 2).round().clamp(0, 200);
    return [
      AntConstants.pageBasicResistance,
      0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
      value,
    ];
  }

  /// Page 49: Target Power (0–4000 W, 0.25 W resolution).
  static List<int> targetPower(int watts) {
    final value = (watts * 4).clamp(0, 16000);
    return [
      AntConstants.pageTargetPower,
      0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
      value & 0xFF,
      (value >> 8) & 0xFF,
    ];
  }

  /// Page 50: Wind Resistance.
  ///
  /// [windSpeed] in km/h (-127 to 127), [crr] rolling resistance coefficient,
  /// [cda] drag area in kg/m.
  static List<int> windResistance(double windSpeed, double crr, double cda) {
    final windByte = (windSpeed + 127).round().clamp(0, 254);
    final crrByte = (crr / 0.00005).round().clamp(0, 254);
    final cdaByte = (cda / 0.01).round().clamp(0, 186);
    return [
      AntConstants.pageWindResistance,
      0xFF, 0xFF, 0xFF, 0xFF,
      windByte,
      crrByte,
      cdaByte,
    ];
  }

  /// Page 51: Track Resistance.
  ///
  /// [grade] in percent (-200 to +200, 0.01% resolution).
  /// [crr] rolling resistance coefficient.
  static List<int> trackResistance(double grade, double crr) {
    final gradeValue = ((grade + 200) / 0.01).round().clamp(0, 40000);
    final crrByte = (crr / 0.00005).round().clamp(0, 254);
    return [
      AntConstants.pageTrackResistance,
      0xFF, 0xFF, 0xFF, 0xFF,
      gradeValue & 0xFF,
      (gradeValue >> 8) & 0xFF,
      crrByte,
    ];
  }
}
