import 'package:freezed_annotation/freezed_annotation.dart';

part 'cadence.freezed.dart';

@freezed
class Cadence with _$Cadence {
  const Cadence._();

  const factory Cadence(double rpm) = _Cadence;

  /// FTMS Indoor Bike Data: cadence field has resolution 0.5 RPM.
  static Cadence fromFtmsRaw(int raw) => Cadence(raw / 2.0);

  static const zero = Cadence(0.0);
}
