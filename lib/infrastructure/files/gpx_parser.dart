import 'dart:math';

import 'package:gpx/gpx.dart' as gpx_lib;
import 'package:uuid/uuid.dart';

import '../../core/domain/entities/route.dart';
import '../../core/domain/entities/route_point.dart';
import '../../core/domain/value_objects/value_objects.dart';

class GpxRouteParser {
  GpxRouteParser({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  /// Parses a GPX string into a [Route] with Haversine distances,
  /// 5-point smoothed elevations, and clamped grades.
  Route parse(String gpxContent, {String? name}) {
    final gpx = gpx_lib.GpxReader().fromString(gpxContent);

    // Collect raw geo points from tracks, then routes.
    final rawPoints = <GeoPoint>[];
    for (final track in gpx.trks) {
      for (final segment in track.trksegs) {
        for (final pt in segment.trkpts) {
          rawPoints.add(GeoPoint(
            lat: pt.lat!,
            lon: pt.lon!,
            elevation: pt.ele,
          ));
        }
      }
    }
    // Fall back to route points if no track points found.
    if (rawPoints.isEmpty) {
      for (final route in gpx.rtes) {
        for (final pt in route.rtepts) {
          rawPoints.add(GeoPoint(
            lat: pt.lat!,
            lon: pt.lon!,
            elevation: pt.ele,
          ));
        }
      }
    }

    if (rawPoints.isEmpty) {
      return Route(
        id: _uuid.v4(),
        name: name ?? 'Unnamed Route',
        points: const [],
      );
    }

    // Cumulative Haversine distances.
    final distances = <double>[0.0];
    for (var i = 1; i < rawPoints.length; i++) {
      distances.add(
          distances[i - 1] + _haversine(rawPoints[i - 1], rawPoints[i]));
    }

    // Raw elevations (default 0 if null).
    final rawElevations =
        rawPoints.map((p) => p.elevation ?? 0.0).toList();

    // 5-point moving average on elevations.
    final smoothed = _smoothElevations(rawElevations, 5);

    // Build route points with grade.
    final points = <RoutePoint>[];
    for (var i = 0; i < rawPoints.length; i++) {
      Grade grade;
      if (i == 0) {
        grade = Grade.flat;
      } else {
        final dist = distances[i] - distances[i - 1];
        if (dist < 0.1) {
          grade = Grade.flat;
        } else {
          final dElev = smoothed[i] - smoothed[i - 1];
          final pct = (dElev / dist) * 100;
          grade = Grade(pct.clamp(-30.0, 30.0));
        }
      }
      points.add(RoutePoint(
        position: rawPoints[i],
        distanceFromStart: distances[i],
        smoothedElevation: smoothed[i],
        grade: grade,
      ));
    }

    // Determine name: parameter > GPX track name > GPX metadata name.
    final gpxName = name ??
        (gpx.trks.isNotEmpty && gpx.trks.first.name != null
            ? gpx.trks.first.name!
            : (gpx.metadata?.name ?? 'Unnamed Route'));

    return Route(
      id: _uuid.v4(),
      name: gpxName,
      description: gpx.metadata?.desc,
      points: points,
    );
  }

  /// Public Haversine distance in meters between two geo points.
  static double haversine(GeoPoint a, GeoPoint b) => _haversine(a, b);

  static double _haversine(GeoPoint a, GeoPoint b) {
    const r = 6371000.0; // Earth radius in meters
    final dLat = _toRad(b.lat - a.lat);
    final dLon = _toRad(b.lon - a.lon);
    final lat1 = _toRad(a.lat);
    final lat2 = _toRad(b.lat);

    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * r * atan2(sqrt(h), sqrt(1 - h));
  }

  static double _toRad(double deg) => deg * pi / 180;

  /// [window]-point moving average on elevations.
  static List<double> _smoothElevations(List<double> raw, int window) {
    if (raw.length < window) return List.of(raw);
    final half = window ~/ 2;
    final result = List<double>.filled(raw.length, 0);
    for (var i = 0; i < raw.length; i++) {
      final lo = (i - half).clamp(0, raw.length - 1);
      final hi = (i + half).clamp(0, raw.length - 1);
      var sum = 0.0;
      var count = 0;
      for (var j = lo; j <= hi; j++) {
        sum += raw[j];
        count++;
      }
      result[i] = sum / count;
    }
    return result;
  }
}
