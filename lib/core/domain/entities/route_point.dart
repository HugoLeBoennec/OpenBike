import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/value_objects.dart';

part 'route_point.freezed.dart';

@freezed
class RoutePoint with _$RoutePoint {
  const RoutePoint._();

  const factory RoutePoint({
    required GeoPoint position,
    required double distanceFromStart,
    required double smoothedElevation,
    required Grade grade,
  }) = _RoutePoint;
}
