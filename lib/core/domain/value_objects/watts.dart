import 'package:freezed_annotation/freezed_annotation.dart';

part 'watts.freezed.dart';

@freezed
class Watts with _$Watts {
  const Watts._();

  const factory Watts(double value) = _Watts;

  /// FTMS Indoor Bike Data: power in watts, resolution 1 W.
  static Watts fromFtmsRaw(int raw) => Watts(raw.toDouble());

  Watts operator +(Watts other) => Watts(value + other.value);
  Watts operator -(Watts other) => Watts(value - other.value);
  Watts operator *(double factor) => Watts(value * factor);

  bool operator >(Watts other) => value > other.value;
  bool operator <(Watts other) => value < other.value;
  bool operator >=(Watts other) => value >= other.value;
  bool operator <=(Watts other) => value <= other.value;

  static const zero = Watts(0);
}
