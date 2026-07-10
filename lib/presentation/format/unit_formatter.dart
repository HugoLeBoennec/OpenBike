import '../../core/domain/value_objects/value_objects.dart';

/// Display unit system — mirrors the two values persisted by
/// [AppPreferences.unitSystem] ('metric' / 'imperial').
enum UnitSystem { metric, imperial }

UnitSystem unitSystemFromString(String value) =>
    value == 'imperial' ? UnitSystem.imperial : UnitSystem.metric;

/// Single source of truth for metric/imperial display formatting.
///
/// Widgets should read this via `unitFormatterProvider` (see
/// `presentation/state/providers.dart`) rather than converting
/// [Distance]/[Speed]/weight/height values inline — that inline pattern is
/// what left most of the app hard-coded to metric before P7.
class UnitFormatter {
  const UnitFormatter(this.system);

  final UnitSystem system;

  bool get isImperial => system == UnitSystem.imperial;

  /// Unit suffix for [distance] — 'km' or 'mi'.
  String get distanceUnit => isImperial ? 'mi' : 'km';

  /// Unit suffix for [speed] — 'km/h' or 'mph'.
  String get speedUnit => isImperial ? 'mph' : 'km/h';

  /// Unit suffix for [weightKg] — 'kg' or 'lb'.
  String get weightUnit => isImperial ? 'lb' : 'kg';

  /// Unit suffix for [elevationM] — 'm' or 'ft'.
  String get elevationUnit => isImperial ? 'ft' : 'm';

  /// Raw numeric distance value in the active unit system (no suffix).
  double distanceValue(Distance d) => isImperial ? d.miles : d.km;

  /// Raw numeric speed value in the active unit system (no suffix).
  double speedValue(Speed s) => isImperial ? s.mph : s.kmh;

  /// Raw numeric weight value (kg input) in the active unit system.
  double weightValue(double kg) => isImperial ? kg * _kgToLb : kg;

  /// Raw numeric elevation/short-distance value (meters input) in the
  /// active unit system.
  double elevationValue(double meters) => isImperial ? meters * _mToFt : meters;

  /// "12.4 km" / "7.7 mi".
  String distance(Distance d, {int decimals = 1}) =>
      '${distanceValue(d).toStringAsFixed(decimals)} $distanceUnit';

  /// "28.3 km/h" / "17.6 mph".
  String speed(Speed s, {int decimals = 1}) =>
      '${speedValue(s).toStringAsFixed(decimals)} $speedUnit';

  /// "75.0 kg" / "165.3 lb".
  String weightKg(double kg, {int decimals = 1}) =>
      '${weightValue(kg).toStringAsFixed(decimals)} $weightUnit';

  /// "178 cm" / "5'10"" (feet/inches, rounded to the nearest inch).
  String heightCm(double cm) {
    if (!isImperial) return '${cm.round()} cm';
    final totalInches = cm / _cmPerInch;
    final feet = totalInches ~/ 12;
    final inches = (totalInches - feet * 12).round();
    return "$feet'$inches\"";
  }

  /// "120 m" / "394 ft" — for elevation/grade-adjacent short distances
  /// (route profile, elevation gain) where km/mi would be too coarse.
  String elevationM(double meters) =>
      '${elevationValue(meters).round()} $elevationUnit';

  static const _kgToLb = 2.2046226218;
  static const _cmPerInch = 2.54;
  static const _mToFt = 3.28084;
}
