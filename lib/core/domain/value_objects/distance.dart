import 'package:freezed_annotation/freezed_annotation.dart';

part 'distance.freezed.dart';

/// Distance in meters.
@freezed
class Distance with _$Distance {
  const Distance._();

  const factory Distance(double meters) = _Distance;

  double get km => meters / 1000;
  double get miles => meters / 1609.344;

  Distance operator +(Distance other) => Distance(meters + other.meters);

  static const zero = Distance(0);
}
