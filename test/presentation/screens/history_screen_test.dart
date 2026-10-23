import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/screens/history_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';

void main() {
  group('Ride — detail metrics for history display', () {
    Ride makeRide({
      required List<SensorReading> readings,
      Duration pauseDuration = Duration.zero,
    }) {
      final start = DateTime.utc(2025, 6, 15, 10, 0, 0);
      return Ride(
        id: 'ride-test',
        startTime: start,
        endTime: start.add(const Duration(minutes: 30)),
        status: RideStatus.finished,
        readings: readings,
        pauseDuration: pauseDuration,
      );
    }

    test('averagePower computes correctly', () {
      final ride = makeRide(readings: [
        SensorReading(
          timestamp: DateTime.utc(2025, 6, 15, 10, 0, 0),
          power: const Watts(200),
        ),
        SensorReading(
          timestamp: DateTime.utc(2025, 6, 15, 10, 0, 1),
          power: const Watts(300),
        ),
      ]);
      expect(ride.averagePower.value, 250.0);
    });

    test('maxPower returns highest reading', () {
      final ride = makeRide(readings: [
        SensorReading(
          timestamp: DateTime.utc(2025, 6, 15, 10, 0, 0),
          power: const Watts(100),
        ),
        SensorReading(
          timestamp: DateTime.utc(2025, 6, 15, 10, 0, 1),
          power: const Watts(400),
        ),
        SensorReading(
          timestamp: DateTime.utc(2025, 6, 15, 10, 0, 2),
          power: const Watts(250),
        ),
      ]);
      expect(ride.maxPower.value, 400.0);
    });

    test('tss and intensityFactor with known FTP', () {
      final readings = List.generate(
        60,
        (i) => SensorReading(
          timestamp:
              DateTime.utc(2025, 6, 15, 10, 0, 0).add(Duration(seconds: i)),
          power: const Watts(200),
        ),
      );
      final ride = makeRide(readings: readings);
      const ftp = Watts(200);
      // IF should be ~1.0 (NP ≈ avg when constant)
      expect(ride.intensityFactor(ftp), closeTo(1.0, 0.1));
      // TSS for 30 min at IF=1.0 ≈ 50
      expect(ride.tss(ftp), greaterThan(0));
    });

    test('empty readings produce zero metrics', () {
      final ride = makeRide(readings: []);
      expect(ride.averagePower, Watts.zero);
      expect(ride.maxPower, Watts.zero);
      expect(ride.averageHr, HeartRate.zero);
      expect(ride.totalDistance, Distance.zero);
    });

    test('activeDuration excludes pauses', () {
      final ride = makeRide(
        readings: [],
        pauseDuration: const Duration(minutes: 5),
      );
      expect(ride.activeDuration, const Duration(minutes: 25));
    });
  });

  testWidgets('a route ride is listed under its route name, with its date',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final appPrefs = AppPreferences(await SharedPreferences.getInstance());
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final storage = DriftStorage(db);
    final start = DateTime(2026, 10, 23, 8);
    for (final id in ['route-ride', 'free-ride']) {
      await storage.saveRide(Ride(
        id: id,
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
        status: RideStatus.finished,
      ));
    }
    await storage.saveRoute(
      SavedRoute(
        id: 'route-1',
        name: 'Col du Galibier',
        fingerprint: '',
        distance: const Distance(18100),
        ascent: 1245,
        createdAt: start,
      ),
      '<gpx/>',
    );
    await storage.linkRideToRoute('route-ride', 'route-1');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(storage),
        appPreferencesProvider.overrideWithValue(appPrefs),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/history',
          routes: [
            GoRoute(
                path: '/history', builder: (_, __) => const HistoryScreen()),
          ],
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Col du Galibier'), findsOneWidget);
    // The route ride's date moves to the second line; the free ride keeps
    // it as its title.
    expect(find.text('Oct 23, 2026'), findsNWidgets(2));
  });
}
