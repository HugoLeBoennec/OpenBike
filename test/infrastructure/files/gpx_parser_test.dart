import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/files/gpx_parser.dart';

// =============================================================================
// Sample GPX data
// =============================================================================

/// Simple 3-point GPX track with known coordinates.
const _simple3Point = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test">
  <metadata>
    <name>Test Route</name>
    <desc>A simple test route</desc>
  </metadata>
  <trk>
    <name>Test Track</name>
    <trkseg>
      <trkpt lat="48.8566" lon="2.3522"><ele>35</ele></trkpt>
      <trkpt lat="48.8576" lon="2.3522"><ele>40</ele></trkpt>
      <trkpt lat="48.8586" lon="2.3522"><ele>45</ele></trkpt>
    </trkseg>
  </trk>
</gpx>
''';

/// GPX with elevation spike to test smoothing.
const _spikeElevation = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1">
  <trk><trkseg>
    <trkpt lat="48.8566" lon="2.3522"><ele>100</ele></trkpt>
    <trkpt lat="48.8570" lon="2.3522"><ele>100</ele></trkpt>
    <trkpt lat="48.8574" lon="2.3522"><ele>100</ele></trkpt>
    <trkpt lat="48.8578" lon="2.3522"><ele>200</ele></trkpt>
    <trkpt lat="48.8582" lon="2.3522"><ele>100</ele></trkpt>
    <trkpt lat="48.8586" lon="2.3522"><ele>100</ele></trkpt>
    <trkpt lat="48.8590" lon="2.3522"><ele>100</ele></trkpt>
  </trkseg></trk>
</gpx>
''';

/// GPX with steep grade to test clamping.
const _steepGrade = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1">
  <trk><trkseg>
    <trkpt lat="48.8566" lon="2.3522"><ele>0</ele></trkpt>
    <trkpt lat="48.85661" lon="2.3522"><ele>100</ele></trkpt>
  </trkseg></trk>
</gpx>
''';

/// Empty GPX.
const _emptyGpx = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1">
  <trk><trkseg></trkseg></trk>
</gpx>
''';

/// GPX with no elevation.
const _noElevation = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1">
  <trk><trkseg>
    <trkpt lat="48.8566" lon="2.3522"/>
    <trkpt lat="48.8576" lon="2.3522"/>
  </trkseg></trk>
</gpx>
''';

/// GPX with route points (rte) instead of track points.
const _routePoints = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1">
  <rte>
    <rtept lat="48.8566" lon="2.3522"><ele>35</ele></rtept>
    <rtept lat="48.8576" lon="2.3522"><ele>40</ele></rtept>
  </rte>
</gpx>
''';

void main() {
  late GpxRouteParser parser;

  setUp(() {
    parser = GpxRouteParser();
  });

  // ===========================================================================
  // Haversine
  // ===========================================================================

  group('GpxRouteParser — Haversine', () {
    test('Paris to north Paris ≈ 111m per 0.001° latitude', () {
      final d = GpxRouteParser.haversine(
        const GeoPoint(lat: 48.8566, lon: 2.3522),
        const GeoPoint(lat: 48.8576, lon: 2.3522),
      );
      // 0.001° latitude ≈ 111m
      expect(d, closeTo(111, 5));
    });

    test('same point yields 0', () {
      final d = GpxRouteParser.haversine(
        const GeoPoint(lat: 48.8566, lon: 2.3522),
        const GeoPoint(lat: 48.8566, lon: 2.3522),
      );
      expect(d, 0);
    });

    test('Paris to London ≈ 343 km', () {
      final d = GpxRouteParser.haversine(
        const GeoPoint(lat: 48.8566, lon: 2.3522),
        const GeoPoint(lat: 51.5074, lon: -0.1278),
      );
      expect(d / 1000, closeTo(343, 10));
    });
  });

  // ===========================================================================
  // Simple 3-point parse
  // ===========================================================================

  group('GpxRouteParser — simple 3-point', () {
    test('parses name and description', () {
      final route = parser.parse(_simple3Point);
      expect(route.name, 'Test Track'); // trk name takes priority
      expect(route.description, 'A simple test route');
    });

    test('has 3 points', () {
      final route = parser.parse(_simple3Point);
      expect(route.points, hasLength(3));
    });

    test('cumulative distances are increasing', () {
      final route = parser.parse(_simple3Point);
      expect(route.points[0].distanceFromStart, 0);
      expect(
        route.points[1].distanceFromStart,
        greaterThan(0),
      );
      expect(
        route.points[2].distanceFromStart,
        greaterThan(route.points[1].distanceFromStart),
      );
    });

    test('smoothed elevations are close to raw', () {
      final route = parser.parse(_simple3Point);
      // With only 3 points (< 5 window), smoothing is identity.
      expect(route.points[0].smoothedElevation, closeTo(35, 1));
      expect(route.points[1].smoothedElevation, closeTo(40, 1));
      expect(route.points[2].smoothedElevation, closeTo(45, 1));
    });

    test('grade is positive (uphill)', () {
      final route = parser.parse(_simple3Point);
      // Points go from 35m to 45m over ~222m → ~4.5% grade.
      for (var i = 1; i < route.points.length; i++) {
        expect(route.points[i].grade.percent, greaterThan(0));
      }
    });

    test('first point grade is flat', () {
      final route = parser.parse(_simple3Point);
      expect(route.points[0].grade.percent, 0);
    });

    test('totalDistance matches last point distance', () {
      final route = parser.parse(_simple3Point);
      expect(
        route.totalDistance.meters,
        closeTo(route.points.last.distanceFromStart, 0.01),
      );
    });

    test('totalAscent ≈ 10m', () {
      final route = parser.parse(_simple3Point);
      expect(route.totalAscent, closeTo(10, 2));
    });
  });

  // ===========================================================================
  // Elevation smoothing
  // ===========================================================================

  group('GpxRouteParser — elevation smoothing', () {
    test('spike is flattened by 5-point average', () {
      final route = parser.parse(_spikeElevation);
      // The raw spike is at index 3 (200m). After smoothing, it should be
      // significantly reduced.
      final smoothedSpike = route.points[3].smoothedElevation;
      expect(smoothedSpike, lessThan(180));
      expect(smoothedSpike, greaterThan(100));
    });
  });

  // ===========================================================================
  // Grade clamping
  // ===========================================================================

  group('GpxRouteParser — grade clamping', () {
    test('very steep grade is clamped to ±30%', () {
      final route = parser.parse(_steepGrade);
      for (final point in route.points) {
        expect(point.grade.percent, greaterThanOrEqualTo(-30));
        expect(point.grade.percent, lessThanOrEqualTo(30));
      }
    });
  });

  // ===========================================================================
  // Edge cases
  // ===========================================================================

  group('GpxRouteParser — edge cases', () {
    test('empty GPX returns empty route', () {
      final route = parser.parse(_emptyGpx);
      expect(route.points, isEmpty);
      expect(route.totalDistance.meters, 0);
    });

    test('no elevation defaults to 0, grade is flat', () {
      final route = parser.parse(_noElevation);
      expect(route.points, hasLength(2));
      expect(route.points[0].smoothedElevation, 0);
      expect(route.points[1].smoothedElevation, 0);
      expect(route.points[1].grade.percent, 0);
    });

    test('name parameter overrides GPX name', () {
      final route = parser.parse(_simple3Point, name: 'My Custom Name');
      expect(route.name, 'My Custom Name');
    });

    test('route points (rte) are parsed when no tracks', () {
      final route = parser.parse(_routePoints);
      expect(route.points, hasLength(2));
    });
  });
}
