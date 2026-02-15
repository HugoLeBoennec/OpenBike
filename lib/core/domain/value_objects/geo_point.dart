import 'package:freezed_annotation/freezed_annotation.dart';

part 'geo_point.freezed.dart';

@freezed
class GeoPoint with _$GeoPoint {
  const GeoPoint._();

  const factory GeoPoint({
    required double lat,
    required double lon,
    double? elevation,
  }) = _GeoPoint;
}
