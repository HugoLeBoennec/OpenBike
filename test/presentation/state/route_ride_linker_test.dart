import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/application/services/route_library.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/events/app_event.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/presentation/state/providers.dart';

final _gpx = '<?xml version="1.0" encoding="UTF-8"?>'
    '<gpx version="1.1" creator="test" xmlns="http://www.topografix.com/GPX/1/1">'
    '<trk><name>Galibier</name><trkseg>'
    '<trkpt lat="45.0" lon="6.0"><ele>1000</ele></trkpt>'
    '<trkpt lat="45.01" lon="6.0"><ele>1050</ele></trkpt>'
    '</trkseg></trk></gpx>';

void main() {
  late AppDatabase db;
  late DriftStorage storage;
  late EventBus eventBus;
  late ProviderContainer container;
  late Ride ride;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    storage = DriftStorage(db);
    eventBus = EventBus();
    container = ProviderContainer(overrides: [
      storageProvider.overrideWithValue(storage),
      eventBusProvider.overrideWithValue(eventBus),
    ]);
    container.read(routeRideLinkerProvider);

    ride = Ride(id: 'ride-1', startTime: DateTime(2026, 10, 23));
    await storage.saveRide(ride);
  });

  tearDown(() async {
    container.dispose();
    eventBus.dispose();
    await db.close();
  });

  Future<void> stopRide() async {
    eventBus.fire(RideEvent.stopped(ride));
    // Let the event and the storage write land.
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }

  test('links a ride on a saved route and forgets the route', () async {
    final library = RouteLibrary(storage: storage);
    final saved = await library.save(library.read(_gpx));
    container.read(activeRouteProvider.notifier).state =
        ActiveRoute(savedRouteId: saved.id);

    await stopRide();

    expect((await storage.getRide('ride-1'))!.routeId, saved.id);
    expect(container.read(activeRouteProvider), isNull);
    expect(container.read(unsavedRouteRideProvider), isNull);
  });

  test('keeps an unsaved route for the summary to offer saving', () async {
    final draft = RouteLibrary(storage: storage).read(_gpx);
    container.read(activeRouteProvider.notifier).state =
        ActiveRoute(draft: draft);

    await stopRide();

    expect((await storage.getRide('ride-1'))!.routeId, isNull);
    final unsaved = container.read(unsavedRouteRideProvider);
    expect(unsaved?.rideId, 'ride-1');
    expect(unsaved?.draft, same(draft));
  });

  test('leaves a ride without a route alone', () async {
    await stopRide();

    expect((await storage.getRide('ride-1'))!.routeId, isNull);
    expect(container.read(unsavedRouteRideProvider), isNull);
  });
}
