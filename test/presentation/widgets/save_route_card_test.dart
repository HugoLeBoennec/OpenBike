import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/application/services/route_library.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/save_route_card.dart';

final _gpx = '<?xml version="1.0" encoding="UTF-8"?>'
    '<gpx version="1.1" creator="test" xmlns="http://www.topografix.com/GPX/1/1">'
    '<trk><name>Galibier</name><trkseg>'
    '<trkpt lat="45.0" lon="6.0"><ele>1000</ele></trkpt>'
    '<trkpt lat="45.01" lon="6.0"><ele>1050</ele></trkpt>'
    '</trkseg></trk></gpx>';

void main() {
  late AppDatabase db;
  late DriftStorage storage;
  late AppPreferences appPrefs;
  late RouteDraft draft;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    storage = DriftStorage(db);
    SharedPreferences.setMockInitialValues({});
    appPrefs = AppPreferences(await SharedPreferences.getInstance());
    draft = RouteLibrary(storage: storage).read(_gpx);
    await storage.saveRide(Ride(id: 'ride-1', startTime: DateTime(2026, 10, 23)));
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpCard(WidgetTester tester, {String rideId = 'ride-1'}) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(storage),
        appPreferencesProvider.overrideWithValue(appPrefs),
        unsavedRouteRideProvider
            .overrideWith((ref) => (rideId: 'ride-1', draft: draft)),
      ],
      child: MaterialApp(
        home: Scaffold(body: SaveRouteCard(rideId: rideId)),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('saves the route and links the ride to it', (tester) async {
    await pumpCard(tester);
    expect(find.text('Galibier'), findsOneWidget);

    await tester.tap(find.byKey(const Key('saveRouteFromRideButton')));
    await tester.pumpAndSettle();

    final saved = (await storage.getSavedRoutes()).single;
    expect(saved.name, 'Galibier');
    expect((await storage.getRide('ride-1'))!.routeId, saved.id);
    expect(find.byKey(const Key('saveRouteCard')), findsNothing);
    expect(find.text('“Galibier” is in your library.'), findsOneWidget);
  });

  testWidgets('links to a copy saved in the meantime instead of saving twice',
      (tester) async {
    final existing =
        await RouteLibrary(storage: storage).save(draft, name: 'Mine');
    await pumpCard(tester);

    await tester.tap(find.byKey(const Key('saveRouteFromRideButton')));
    await tester.pumpAndSettle();

    expect(await storage.getSavedRoutes(), hasLength(1));
    expect((await storage.getRide('ride-1'))!.routeId, existing.id);
  });

  testWidgets('shows nothing on another ride\'s summary', (tester) async {
    await pumpCard(tester, rideId: 'ride-2');

    expect(find.byKey(const Key('saveRouteCard')), findsNothing);
  });
}
