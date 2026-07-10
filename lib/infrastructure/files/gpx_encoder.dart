import 'package:xml/xml.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/value_objects/value_objects.dart';

/// Encodes a [Ride] into GPX (GPS Exchange Format).
///
/// GPX track points require a lat/lon position, so this encoder can only
/// place readings on the map when the ride was recorded against a
/// simulated [Route] (see [GpxRouteParser]/[RouteSimulator]). Positions are
/// derived by interpolating the reading's cumulative distance along the
/// route's geometry. Callers without route data should use FIT/TCX instead
/// — [encode] throws [GpxExportUnsupported] rather than emitting an invalid
/// (position-less) `<trkpt>`.
class GpxEncoder {
  static const String _gpxtpxNs =
      'http://www.garmin.com/xmlschemas/TrackPointExtension/v1';
  static const String _pwrNs =
      'http://www.garmin.com/xmlschemas/PowerExtension/v1';

  /// Encodes [ride] to a GPX XML string, placing each reading on [route]'s
  /// geometry by matching cumulative distance.
  ///
  /// Throws [GpxExportUnsupported] if [route] has no points or [ride] has no
  /// readings with a recorded distance.
  String encode(Ride ride, Route route) {
    if (route.points.isEmpty) {
      throw GpxExportUnsupported('Route has no points to place track on.');
    }
    final located = ride.readings.where((r) => r.distance != null).toList();
    if (located.isEmpty) {
      throw GpxExportUnsupported(
        'Ride has no distance-tagged readings — GPX export requires a '
        'simulated route ride.',
      );
    }

    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('gpx', nest: () {
      builder.attribute('version', '1.1');
      builder.attribute('creator', 'OpenBike');
      builder.attribute('xmlns', 'http://www.topografix.com/GPX/1/1');
      builder.attribute('xmlns:gpxtpx', _gpxtpxNs);
      builder.attribute('xmlns:pwr', _pwrNs);

      builder.element('metadata', nest: () {
        builder.element('time',
            nest: ride.startTime.toUtc().toIso8601String());
      });

      builder.element('trk', nest: () {
        builder.element('name', nest: route.name);
        builder.element('trkseg', nest: () {
          for (final reading in located) {
            _writeTrackPoint(builder, route, reading);
          }
        });
      });
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }

  void _writeTrackPoint(
      XmlBuilder b, Route route, SensorReading reading) {
    final position = _positionAtDistance(route, reading.distance!.meters);

    b.element('trkpt', nest: () {
      b.attribute('lat', position.lat.toStringAsFixed(7));
      b.attribute('lon', position.lon.toStringAsFixed(7));
      if (position.elevation != null) {
        b.element('ele', nest: position.elevation!.toStringAsFixed(1));
      }
      b.element('time', nest: reading.timestamp.toUtc().toIso8601String());

      final hasExt = reading.heartRate != null ||
          reading.cadence != null ||
          reading.power != null;
      if (hasExt) {
        b.element('extensions', nest: () {
          if (reading.power != null) {
            b.element('pwr:PowerInWatts',
                nest: reading.power!.value.round().toString());
          }
          if (reading.heartRate != null || reading.cadence != null) {
            b.element('gpxtpx:TrackPointExtension', nest: () {
              if (reading.heartRate != null) {
                b.element('gpxtpx:hr',
                    nest: reading.heartRate!.bpm.toString());
              }
              if (reading.cadence != null) {
                b.element('gpxtpx:cad',
                    nest: reading.cadence!.rpm.round().toString());
              }
            });
          }
        });
      }
    });
  }

  /// Linearly interpolates a [GeoPoint] on [route] at cumulative [meters]
  /// from the start. Clamps to the first/last point if out of range.
  GeoPoint _positionAtDistance(Route route, double meters) {
    final points = route.points;
    if (meters <= points.first.distanceFromStart) {
      return _asGeoPoint(points.first);
    }
    if (meters >= points.last.distanceFromStart) {
      return _asGeoPoint(points.last);
    }

    var lo = 0;
    var hi = points.length - 1;
    while (hi - lo > 1) {
      final mid = (lo + hi) ~/ 2;
      if (points[mid].distanceFromStart <= meters) {
        lo = mid;
      } else {
        hi = mid;
      }
    }

    final a = points[lo];
    final c = points[hi];
    final span = c.distanceFromStart - a.distanceFromStart;
    final t = span <= 0 ? 0.0 : (meters - a.distanceFromStart) / span;

    return GeoPoint(
      lat: a.position.lat + (c.position.lat - a.position.lat) * t,
      lon: a.position.lon + (c.position.lon - a.position.lon) * t,
      elevation:
          a.smoothedElevation + (c.smoothedElevation - a.smoothedElevation) * t,
    );
  }

  GeoPoint _asGeoPoint(RoutePoint p) => GeoPoint(
        lat: p.position.lat,
        lon: p.position.lon,
        elevation: p.smoothedElevation,
      );
}

/// Thrown when a [Ride] cannot be exported to GPX (no route/position data).
class GpxExportUnsupported implements Exception {
  GpxExportUnsupported(this.message);
  final String message;

  @override
  String toString() => 'GpxExportUnsupported: $message';
}
