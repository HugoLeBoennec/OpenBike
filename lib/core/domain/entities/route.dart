import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/value_objects.dart';
import 'route_point.dart';

part 'route.freezed.dart';

@freezed
class Route with _$Route {
  const Route._();

  const factory Route({
    required String id,
    required String name,
    String? description,
    required List<RoutePoint> points,
  }) = _Route;

  Distance get totalDistance => points.isEmpty
      ? Distance.zero
      : Distance(points.last.distanceFromStart);

  double get totalAscent {
    var ascent = 0.0;
    for (var i = 1; i < points.length; i++) {
      final delta =
          points[i].smoothedElevation - points[i - 1].smoothedElevation;
      if (delta > 0) ascent += delta;
    }
    return ascent;
  }

  double get totalDescent {
    var descent = 0.0;
    for (var i = 1; i < points.length; i++) {
      final delta =
          points[i].smoothedElevation - points[i - 1].smoothedElevation;
      if (delta < 0) descent += delta.abs();
    }
    return descent;
  }
}
