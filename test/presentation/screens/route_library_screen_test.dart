import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/models/ride_extra.dart';
import 'package:open_bike/presentation/screens/route_library_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/theme/app_theme.dart';

class MockTrainerPort extends Mock implements TrainerPort {}

/// About 1.1 km due north, climbing 50 m.
final _gpx = '<?xml version="1.0" encoding="UTF-8"?>'
    '<gpx version="1.1" creator="test" xmlns="http://www.topografix.com/GPX/1/1">'
    '<trk><trkseg>'
    '${[
  for (var i = 0; i <= 10; i++)
    '<trkpt lat="${45.0 + 0.001 * i}" lon="6.0"><ele>${1000 + 5 * i}</ele></trkpt>'
].join()}'
    '</trkseg></trk></gpx>';

SavedRoute _route(
  String id,
  String name, {
  double km = 10,
  double ascent = 100,
  DateTime? createdAt,
}) =>
    SavedRoute(
      id: id,
      name: name,
      fingerprint: '{"d":0,"p":[]}',
      distance: Distance(km * 1000),
      ascent: ascent,
      profile: const [1000, 1020, 1050],
      createdAt: createdAt ?? DateTime(2026, 10, 1),
    );

void main() {
  late AppDatabase db;
  late DriftStorage storage;
  late AppPreferences appPrefs;
  RideExtra? rideExtra;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    storage = DriftStorage(db);
    SharedPreferences.setMockInitialValues({});
    appPrefs = AppPreferences(await SharedPreferences.getInstance());
    rideExtra = null;
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpLibrary(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/routes',
      routes: [
        GoRoute(
            path: '/routes', builder: (_, __) => const RouteLibraryScreen()),
        GoRoute(
          path: '/ride',
          builder: (_, state) {
            rideExtra = state.extra as RideExtra?;
            return const Scaffold(body: Text('ride screen'));
          },
        ),
        GoRoute(
            path: '/scan',
            builder: (_, __) => const Scaffold(body: Text('scan screen'))),
      ],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(storage),
        appPreferencesProvider.overrideWithValue(appPrefs),
        ...overrides,
      ],
      child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  List<String> tileNames(WidgetTester tester) => tester
      .widgetList<ListTile>(find.byType(ListTile))
      .map((t) => (t.title as Text).data!)
      .toList();

  testWidgets('says how to start when the library is empty', (tester) async {
    await pumpLibrary(tester);

    expect(find.textContaining('No saved routes yet.'), findsOneWidget);
    expect(find.byKey(const Key('importRouteFab')), findsOneWidget);
  });

  testWidgets('lists routes most recently used first, with their stats',
      (tester) async {
    await storage.saveRoute(
        _route('old', 'Old climb', createdAt: DateTime(2026, 9, 1)), _gpx);
    await storage.saveRoute(
        _route('new', 'New climb', km: 18.1, ascent: 1245), _gpx);
    // Riding the old route makes it the most recently used.
    await storage.saveRide(Ride(id: 'ride', startTime: DateTime(2026, 10, 5)));
    await storage.linkRideToRoute('ride', 'old');

    await pumpLibrary(tester);

    expect(tileNames(tester), ['Old climb', 'New climb']);
    expect(find.textContaining('18.1 km'), findsOneWidget);
    expect(find.textContaining('↑1245 m'), findsOneWidget);
    expect(find.textContaining('Not ridden yet'), findsOneWidget);
    expect(find.textContaining('1× · '), findsOneWidget);
  });

  testWidgets('sorting by name reorders the list and is remembered',
      (tester) async {
    await storage.saveRoute(_route('b', 'Ventoux'), _gpx);
    await storage.saveRoute(
        _route('a', 'Alpe d\'Huez', createdAt: DateTime(2026, 9, 1)), _gpx);
    await pumpLibrary(tester);
    expect(tileNames(tester), ['Ventoux', 'Alpe d\'Huez']);

    await tester.tap(find.byKey(const Key('routeSortButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('routeSort-name')));
    await tester.pumpAndSettle();

    expect(tileNames(tester), ['Alpe d\'Huez', 'Ventoux']);
    expect(appPrefs.routeSort, 'name');
  });

  testWidgets('search filters by name', (tester) async {
    await storage.saveRoute(_route('a', 'Col du Galibier'), _gpx);
    await storage.saveRoute(_route('b', 'Mont Ventoux'), _gpx);
    await pumpLibrary(tester);

    await tester.enterText(find.byKey(const Key('routeSearchField')), 'galib');
    await tester.pumpAndSettle();
    expect(tileNames(tester), ['Col du Galibier']);

    await tester.enterText(find.byKey(const Key('routeSearchField')), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No routes match “zzz”.'), findsOneWidget);
  });

  testWidgets('rename from the long-press menu', (tester) async {
    await storage.saveRoute(_route('a', 'Galibier'), _gpx);
    await pumpLibrary(tester);

    await tester.longPress(find.text('Galibier'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('renameRouteTile')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('renameRouteField')), 'Col du Galibier');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tileNames(tester), ['Col du Galibier']);
    expect((await storage.getSavedRoutes()).single.name, 'Col du Galibier');
  });

  testWidgets('delete warns about the rides that used the route',
      (tester) async {
    await storage.saveRoute(_route('a', 'Galibier'), _gpx);
    await storage.saveRide(Ride(id: 'ride', startTime: DateTime(2026, 10, 5)));
    await storage.linkRideToRoute('ride', 'a');
    await pumpLibrary(tester);

    await tester.longPress(find.text('Galibier'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteRouteTile')));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 ride used this route.'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No saved routes yet.'), findsOneWidget);
    expect((await storage.getRide('ride'))!.routeId, isNull);
  });

  testWidgets('tapping a route previews it and Start ride rides it',
      (tester) async {
    await storage.saveRoute(_route('a', 'Galibier'), _gpx);
    await pumpLibrary(tester, overrides: [
      activeTrainerPortProvider.overrideWith((ref) => MockTrainerPort()),
    ]);

    await tester.tap(find.text('Galibier'));
    await tester.pumpAndSettle();
    expect(find.text('Not ridden yet'), findsOneWidget);
    expect(find.text('Max grade'), findsOneWidget);

    await tester.tap(find.byKey(const Key('startRouteRideButton')));
    await tester.pumpAndSettle();

    expect(find.text('ride screen'), findsOneWidget);
    expect(rideExtra!.savedRouteId, 'a');
    expect(rideExtra!.route!.id, 'a');
    expect(rideExtra!.route!.name, 'Galibier');
    expect(rideExtra!.route!.points, hasLength(11));
    expect(rideExtra!.routeDraft, isNull);
  });

  testWidgets('without a trainer, Start ride asks to pair one first',
      (tester) async {
    await storage.saveRoute(_route('a', 'Galibier'), _gpx);
    await pumpLibrary(tester);

    await tester.tap(find.text('Galibier'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('startRouteRideButton')));
    await tester.pumpAndSettle();

    expect(find.text('Connect a trainer'), findsOneWidget);
    expect(rideExtra, isNull);
  });

  testWidgets('a saved route lists its rides and marks the best finish',
      (tester) async {
    // _gpx is about 1.1 km long.
    await storage.saveRoute(_route('a', 'Galibier', km: 1.1), _gpx);
    Ride ride(String id, int day, int minutes, double meters) => Ride(
          id: id,
          startTime: DateTime(2026, 10, day, 8),
          endTime: DateTime(2026, 10, day, 8).add(Duration(minutes: minutes)),
          status: RideStatus.finished,
          cachedTotalDistance: Distance(meters),
        );
    await storage.saveRide(ride('slow', 1, 50, 1100));
    await storage.saveRide(ride('fast', 2, 40, 1100));
    // Quickest of all, but stopped half-way: not a finish.
    await storage.saveRide(ride('partial', 3, 10, 550));
    for (final id in ['slow', 'fast', 'partial']) {
      await storage.linkRideToRoute(id, 'a');
    }
    await pumpLibrary(tester);

    await tester.tap(find.text('Galibier'));
    await tester.pumpAndSettle();

    expect(find.text('YOUR RIDES ON THIS ROUTE'), findsOneWidget);
    for (final id in ['slow', 'fast', 'partial']) {
      expect(find.byKey(Key('routeRide-$id')), findsOneWidget);
    }
    final best = find.descendant(
      of: find.byKey(const Key('routeRide-fast')),
      matching: find.byIcon(Icons.emoji_events),
    );
    expect(best, findsOneWidget);
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
