import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../domain/entities/route.dart';
import '../../domain/entities/route_point.dart';
import '../../domain/entities/saved_route.dart';
import '../../domain/ports/storage_port.dart';
import '../../domain/value_objects/value_objects.dart';
import '../../../infrastructure/files/gpx_parser.dart';

/// A GPX file read and summarised: ready to ride, and to save if the rider
/// wants to keep it.
class RouteDraft {
  const RouteDraft({
    required this.route,
    required this.gpx,
    required this.shape,
    required this.profile,
  });

  final Route route;
  final String gpx;
  final RouteShape shape;
  final List<double> profile;
}

/// Thrown by [RouteLibrary.read] for a file with no track or route points
/// to ride.
class EmptyRouteException implements Exception {
  const EmptyRouteException();

  @override
  String toString() => 'This file has no track or route points to ride.';
}

/// Reads GPX files into [RouteDraft]s and keeps the rider's saved routes.
class RouteLibrary {
  RouteLibrary({
    required StoragePort storage,
    GpxRouteParser? parser,
    Uuid? uuid,
    DateTime Function()? now,
  })  : _storage = storage,
        _parser = parser ?? GpxRouteParser(),
        _uuid = uuid ?? const Uuid(),
        _now = now ?? DateTime.now;

  final StoragePort _storage;
  final GpxRouteParser _parser;
  final Uuid _uuid;
  final DateTime Function() _now;

  /// Elevation samples kept per route for list thumbnails.
  static const profileSamples = 64;

  /// Parses [gpx]; [fileName] names the route when the file doesn't.
  ///
  /// Throws [EmptyRouteException] when there is nothing to ride, and the
  /// GPX reader's own exception when [gpx] isn't GPX at all.
  RouteDraft read(String gpx, {String? fileName}) {
    final route = _parser.parse(gpx, fallbackName: _baseName(fileName));
    if (route.points.length < 2) throw const EmptyRouteException();
    return RouteDraft(
      route: route,
      gpx: gpx,
      shape: RouteShape.of(route),
      profile: elevationProfile(route, profileSamples),
    );
  }

  /// The route in [saved] that [draft] duplicates, if any.
  SavedRoute? findDuplicate(RouteDraft draft, Iterable<SavedRoute> saved) {
    for (final route in saved) {
      final shape = RouteShape.decode(route.fingerprint);
      if (shape != null && shape.matches(draft.shape)) return route;
    }
    return null;
  }

  /// Saves [draft] as a new route named [name], or the draft's own name
  /// when [name] is null or blank.
  Future<SavedRoute> save(RouteDraft draft, {String? name}) async {
    final trimmed = name?.trim() ?? '';
    final saved = SavedRoute(
      id: _uuid.v4(),
      name: trimmed.isEmpty ? draft.route.name : trimmed,
      fingerprint: draft.shape.encode(),
      distance: draft.route.totalDistance,
      ascent: draft.route.totalAscent,
      profile: draft.profile,
      createdAt: _now(),
    );
    await _storage.saveRoute(saved, draft.gpx);
    return saved;
  }

  /// The [Route] to ride for [saved] — carrying its id and name — or null
  /// when the route is no longer stored.
  Future<Route?> load(SavedRoute saved) async {
    final gpx = await _storage.getRouteGpx(saved.id);
    if (gpx == null) return null;
    return _parser.parse(gpx, name: saved.name).copyWith(id: saved.id);
  }

  /// [load] for the saved route [id], or null when there is none.
  Future<Route?> loadById(String id) async {
    for (final saved in await _storage.getSavedRoutes()) {
      if (saved.id == id) return load(saved);
    }
    return null;
  }

  static String? _baseName(String? fileName) {
    if (fileName == null) return null;
    final dot = fileName.lastIndexOf('.');
    return dot > 0 ? fileName.substring(0, dot) : fileName;
  }
}

/// [samples] smoothed elevations spread evenly along [route]'s distance.
List<double> elevationProfile(Route route, int samples) {
  final points = route.points;
  if (points.isEmpty) return const [];
  final total = route.totalDistance.meters;
  return [
    for (var i = 0; i < samples; i++)
      _round(_at(points, total * i / (samples - 1)).elevation, 1),
  ];
}

/// Five points spread evenly along a route — start, quarters, end — and its
/// length: enough to tell whether two files hold the same route, even when
/// they come from different apps that space their points differently.
class RouteShape {
  const RouteShape({required this.distance, required this.points});

  /// Metres.
  final double distance;
  final List<GeoPoint> points;

  static const _fractions = [0.0, 0.25, 0.5, 0.75, 1.0];

  factory RouteShape.of(Route route) {
    final total = route.totalDistance.meters;
    return RouteShape(
      distance: total,
      points: [
        for (final f in _fractions) _at(route.points, total * f).position,
      ],
    );
  }

  /// Whether [other] is the same route: lengths within 3 %, and each point
  /// within 1 % of the length (at least 150 m) of its counterpart. Apps
  /// measure the same road a little differently, which shifts the points.
  /// A route ridden the other way round doesn't match.
  bool matches(RouteShape other) {
    if (points.length != other.points.length) return false;
    final longer = max(distance, other.distance);
    if ((distance - other.distance).abs() > longer * 0.03) return false;
    final tolerance = max(150.0, longer * 0.01);
    for (var i = 0; i < points.length; i++) {
      if (GpxRouteParser.haversine(points[i], other.points[i]) > tolerance) {
        return false;
      }
    }
    return true;
  }

  String encode() => jsonEncode({
        'd': distance.round(),
        'p': [
          for (final p in points) [_round(p.lat, 5), _round(p.lon, 5)],
        ],
      });

  /// Null for anything [encode] didn't produce.
  static RouteShape? decode(String encoded) {
    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      return RouteShape(
        distance: (json['d'] as num).toDouble(),
        points: [
          for (final p in json['p'] as List)
            GeoPoint(
              lat: ((p as List)[0] as num).toDouble(),
              lon: (p[1] as num).toDouble(),
            ),
        ],
      );
    } catch (_) {
      return null;
    }
  }
}

/// Position and smoothed elevation [d] metres along [points], interpolated
/// between the two points either side.
({GeoPoint position, double elevation}) _at(List<RoutePoint> points, double d) {
  // Last point at or before d.
  var lo = 0;
  var hi = points.length - 1;
  while (lo < hi) {
    final mid = (lo + hi + 1) >> 1;
    if (points[mid].distanceFromStart <= d) {
      lo = mid;
    } else {
      hi = mid - 1;
    }
  }
  final a = points[lo];
  if (lo == points.length - 1) {
    return (position: a.position, elevation: a.smoothedElevation);
  }
  final b = points[lo + 1];
  final span = b.distanceFromStart - a.distanceFromStart;
  final t = span > 0 ? ((d - a.distanceFromStart) / span).clamp(0.0, 1.0) : 0.0;
  return (
    position: GeoPoint(
      lat: a.position.lat + (b.position.lat - a.position.lat) * t,
      lon: a.position.lon + (b.position.lon - a.position.lon) * t,
    ),
    elevation:
        a.smoothedElevation + (b.smoothedElevation - a.smoothedElevation) * t,
  );
}

double _round(double value, int decimals) {
  final factor = pow(10, decimals);
  return (value * factor).roundToDouble() / factor;
}
