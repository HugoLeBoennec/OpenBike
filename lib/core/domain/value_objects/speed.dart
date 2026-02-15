import 'package:freezed_annotation/freezed_annotation.dart';

part 'speed.freezed.dart';

/// Speed in km/h.
@freezed
class Speed with _$Speed {
  const Speed._();

  const factory Speed(double kmh) = _Speed;

  /// FTMS Indoor Bike Data: speed field has resolution 0.01 km/h.
  static Speed fromFtmsRaw(int raw) => Speed(raw / 100.0);

  double get mps => kmh / 3.6;
  double get mph => kmh * 0.621371;

  static const zero = Speed(0);
}
