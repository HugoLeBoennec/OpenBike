import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/application/services/route_library.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/models/ride_extra.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/theme/app_theme.dart';
import 'package:open_bike/presentation/widgets/route_preview_sheet.dart';

class MockTrainerPort extends Mock implements TrainerPort {}

/// About 1.1 km due north, climbing 50 m.
final _gpx = '<?xml version="1.0" encoding="UTF-8"?>'
    '<gpx version="1.1" creator="test" xmlns="http://www.topografix.com/GPX/1/1">'
    '<trk><name>Galibier</name><trkseg>'
    '${[
  for (var i = 0; i <= 10; i++)
    '<trkpt lat="${45.0 + 0.001 * i}" lon="6.0"><ele>${1000 + 5 * i}</ele></trkpt>'
].join()}'
    '</trkseg></trk></gpx>';

void main() {
  late AppDatabase db;
  late DriftStorage storage;
  late RouteLibrary library;
  late RouteDraft draft;
  RideExtra? rideExtra;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    storage = DriftStorage(db);
    library = RouteLibrary(storage: storage);
    draft = library.read(_gpx);
    rideExtra = null;
  });

  tearDown(() async {
    await db.close();
  });

  /// Opens the import preview for [draft]; [prefs] seeds SharedPreferences.
  Future<AppPreferences> openImport(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
    SavedRoute? duplicate,
    bool trainer = false,
  }) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(prefs);
    final appPrefs = AppPreferences(await SharedPreferences.getInstance());
    final router = GoRouter(
      initialLocation: '/routes',
      routes: [
        GoRoute(
          path: '/routes',
          builder: (context, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showImportedRoutePreview(
                  context,
                  draft: draft,
                  duplicate: duplicate,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
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
        if (trainer)
          activeTrainerPortProvider.overrideWith((ref) => MockTrainerPort()),
      ],
      child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return appPrefs;
  }

  SwitchListTile saveSwitch(WidgetTester tester) =>
      tester.widget(find.byKey(const Key('saveRouteSwitch')));

  testWidgets('the save switch starts on and remembers being turned off',
      (tester) async {
    final appPrefs = await openImport(tester);
    expect(saveSwitch(tester).value, isTrue);
    expect(find.byKey(const Key('saveRouteOnlyButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('saveRouteSwitch')));
    await tester.pumpAndSettle();

    expect(saveSwitch(tester).value, isFalse);
    expect(appPrefs.saveImportedRoutes, isFalse);
    // Nothing to name or save while the switch is off.
    expect(
      tester.widget<TextField>(find.byKey(const Key('routeNameField'))).enabled,
      isFalse,
    );
    expect(find.byKey(const Key('saveRouteOnlyButton')), findsNothing);
  });

  testWidgets('the switch opens where it was left', (tester) async {
    await openImport(tester, prefs: {'save_imported_routes': false});

    expect(saveSwitch(tester).value, isFalse);
  });

  testWidgets('Save without riding keeps the route under the typed name',
      (tester) async {
    await openImport(tester);
    expect(find.text('Galibier'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('routeNameField')), 'Col du Galibier');
    await tester.tap(find.byKey(const Key('saveRouteOnlyButton')));
    await tester.pumpAndSettle();

    expect(find.text('Saved to your library.'), findsOneWidget);
    expect(find.byKey(const Key('saveRouteSwitch')), findsNothing);
    final saved = (await storage.getSavedRoutes()).single;
    expect(saved.name, 'Col du Galibier');
    expect(await storage.getRouteGpx(saved.id), _gpx);
  });

  testWidgets('a duplicate says where it is and rides the saved copy',
      (tester) async {
    final existing = await library.save(draft, name: 'My Galibier');

    await openImport(tester, duplicate: existing, trainer: true);
    expect(find.text('Already in your library as “My Galibier”.'),
        findsOneWidget);
    expect(find.byKey(const Key('saveRouteSwitch')), findsNothing);

    await tester.tap(find.byKey(const Key('startRouteRideButton')));
    await tester.pumpAndSettle();

    expect(rideExtra!.savedRouteId, existing.id);
    expect(rideExtra!.route!.name, 'My Galibier');
    expect(await storage.getSavedRoutes(), hasLength(1));
  });

  testWidgets('with the switch on, Start ride saves before asking for a '
      'trainer', (tester) async {
    await openImport(tester);

    await tester.tap(find.byKey(const Key('startRouteRideButton')));
    await tester.pumpAndSettle();

    expect(find.text('Connect a trainer'), findsOneWidget);
    expect((await storage.getSavedRoutes()).single.name, 'Galibier');
  });

  testWidgets('with the switch off, Start ride rides it without saving',
      (tester) async {
    await openImport(
      tester,
      prefs: {'save_imported_routes': false},
      trainer: true,
    );

    await tester.tap(find.byKey(const Key('startRouteRideButton')));
    await tester.pumpAndSettle();

    expect(find.text('ride screen'), findsOneWidget);
    expect(rideExtra!.savedRouteId, isNull);
    expect(rideExtra!.routeDraft, same(draft));
    expect(rideExtra!.route, draft.route);
    expect(await storage.getSavedRoutes(), isEmpty);
  });
}
