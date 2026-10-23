import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/route_library.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/infrastructure/files/gpx_parser.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';

typedef _Pt = (double lat, double lon, double ele);

String _gpx(List<_Pt> points, {String? trackName, String? metadataName}) {
  final metadata =
      metadataName == null ? '' : '<metadata><name>$metadataName</name></metadata>';
  final name = trackName == null ? '' : '<name>$trackName</name>';
  final pts = points
      .map((p) => '<trkpt lat="${p.$1}" lon="${p.$2}"><ele>${p.$3}</ele></trkpt>')
      .join();
  return '<?xml version="1.0" encoding="UTF-8"?>'
      '<gpx version="1.1" creator="test" xmlns="http://www.topografix.com/GPX/1/1">'
      '$metadata<trk>$name<trkseg>$pts</trkseg></trk></gpx>';
}

/// About 11 km due north, climbing 500 m: [count] points evenly spaced.
List<_Pt> _climb({int count = 101}) => [
      for (var i = 0; i < count; i++)
        (45.0 + 0.1 * i / (count - 1), 6.0, 1000 + 500 * i / (count - 1)),
    ];

void main() {
  late AppDatabase db;
  late DriftStorage storage;
  late RouteLibrary library;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    storage = DriftStorage(db);
    library = RouteLibrary(
      storage: storage,
      now: () => DateTime.utc(2026, 10, 23),
    );
  });

  tearDown(() => db.close());

  group('read', () {
    test('names the route from the file, then from the file name', () {
      expect(
        library.read(_gpx(_climb(), trackName: 'Galibier')).route.name,
        'Galibier',
      );
      expect(
        library.read(_gpx(_climb()), fileName: 'Col du Galibier.gpx').route.name,
        'Col du Galibier',
      );
      expect(library.read(_gpx(_climb())).route.name, 'Unnamed Route');
    });

    test('summarises the profile along the route', () {
      final draft = library.read(_gpx(_climb()));

      expect(draft.profile, hasLength(RouteLibrary.profileSamples));
      // Smoothing flattens the very ends a little.
      expect(draft.profile.first, closeTo(1000, 15));
      expect(draft.profile.last, closeTo(1500, 15));
      expect(draft.profile[32], closeTo(1250, 15));
    });

    test('refuses a file with nothing to ride', () {
      expect(() => library.read(_gpx(const [])),
          throwsA(isA<EmptyRouteException>()));
    });
  });

  group('findDuplicate', () {
    late SavedRoute saved;

    setUp(() async {
      saved = await library.save(library.read(_gpx(_climb())));
    });

    test('matches the same road spaced differently by another app', () {
      // Three times the points, each nudged a few metres sideways.
      final dense = [
        for (final (i, p) in _climb(count: 301).indexed)
          (p.$1, p.$2 + (i.isEven ? 0.00003 : -0.00003), p.$3),
      ];
      final draft = library.read(_gpx(dense));

      expect(library.findDuplicate(draft, [saved])?.id, saved.id);
    });

    test('does not match the same road ridden the other way', () {
      final draft = library.read(_gpx(_climb().reversed.toList()));

      expect(library.findDuplicate(draft, [saved]), isNull);
    });

    test('does not match a detour with the same start and end', () {
      // Bulges about 400 m east half-way: nearly the same length.
      final detour = [
        for (var i = 0; i <= 100; i++)
          (
            45.0 + 0.001 * i,
            6.0 + 0.005 * (1 - (i - 50).abs() / 50),
            1000.0 + 5 * i,
          ),
      ];
      final draft = library.read(_gpx(detour));

      expect(library.findDuplicate(draft, [saved]), isNull);
    });

    test('ignores a route whose fingerprint it cannot read', () {
      final draft = library.read(_gpx(_climb()));

      expect(
        library.findDuplicate(draft, [saved.copyWith(fingerprint: 'nope')]),
        isNull,
      );
    });
  });

  test('a shape survives encoding', () {
    final shape = library.read(_gpx(_climb())).shape;
    final decoded = RouteShape.decode(shape.encode())!;

    expect(decoded.matches(shape), isTrue);
    for (var i = 0; i < shape.points.length; i++) {
      expect(GpxRouteParser.haversine(decoded.points[i], shape.points[i]),
          lessThan(1));
    }
  });

  group('save and load', () {
    test('stores the summary and the file', () async {
      final gpx = _gpx(_climb(), trackName: 'Galibier');
      final draft = library.read(gpx);

      final saved = await library.save(draft, name: '  Col du Galibier ');

      expect(saved.name, 'Col du Galibier');
      expect(saved.createdAt, DateTime.utc(2026, 10, 23));
      expect(saved.distance.meters, closeTo(11120, 20));
      expect(saved.ascent, draft.route.totalAscent);
      expect(RouteShape.decode(saved.fingerprint), isNotNull);
      expect((await storage.getSavedRoutes()).single.id, saved.id);
      expect(await storage.getRouteGpx(saved.id), gpx);
    });

    test('a blank name keeps the route\'s own', () async {
      final draft = library.read(_gpx(_climb(), trackName: 'Galibier'));

      expect((await library.save(draft, name: ' ')).name, 'Galibier');
    });

    test('loads a route carrying the saved id and current name', () async {
      final saved = await library.save(library.read(_gpx(_climb())));
      await storage.renameRoute(saved.id, 'Renamed');
      final current = (await storage.getSavedRoutes()).single;

      final route = await library.load(current);

      expect(route!.id, saved.id);
      expect(route.name, 'Renamed');
      expect(route.points, hasLength(101));
      expect(route.totalDistance, saved.distance);
    });

    test('loads nothing for a deleted route', () async {
      final saved = await library.save(library.read(_gpx(_climb())));
      await storage.deleteRoute(saved.id);

      expect(await library.load(saved), isNull);
    });
  });

  test('elevationProfile of a route with no points is empty', () {
    expect(
      elevationProfile(
          const Route(id: 'r', name: 'empty', points: []), 64),
      isEmpty,
    );
  });
}
