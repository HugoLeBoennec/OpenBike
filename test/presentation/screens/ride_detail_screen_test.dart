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
import 'package:open_bike/plugins/exports/gpx_file_export_plugin.dart';
import 'package:open_bike/presentation/screens/ride_detail_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';

void main() {
  late AppDatabase db;
  late DriftStorage storage;
  late AppPreferences appPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    appPrefs = AppPreferences(await SharedPreferences.getInstance());
    db = AppDatabase(NativeDatabase.memory());
    storage = DriftStorage(db);
    final start = DateTime.now().subtract(const Duration(hours: 2));
    await storage.saveRide(
      Ride(
        id: 'ride-1',
        startTime: start,
        endTime: start.add(const Duration(minutes: 30)),
        status: RideStatus.finished,
      ),
      ftp: const Watts(200),
    );
    await storage.saveScheduledWorkout(ScheduledWorkout(
        id: 'sched-1', workoutId: 'w-1', date: start));
    await storage.linkCompletedRide('sched-1', 'ride-1');
  });

  tearDown(() async => db.close());

  Future<void> pumpRidePage(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    final router = GoRouter(initialLocation: '/history/ride-1', routes: [
      GoRoute(
        path: '/history',
        builder: (_, __) => const Scaffold(body: Text('history list')),
      ),
      GoRoute(
        path: '/history/:id',
        builder: (_, state) =>
            RideDetailScreen(rideId: state.pathParameters['id']!),
      ),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(storage),
        appPreferencesProvider.overrideWithValue(appPrefs),
        exportPluginsProvider.overrideWithValue(const {}),
        exportQueueProvider.overrideWith((ref) => Stream.value(const [])),
        ...overrides,
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('deletes the ride from its History page after confirming',
      (tester) async {
    await pumpRidePage(tester);

    await tester.tap(find.byKey(const Key('deleteRideButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmDeleteRideButton')));
    await tester.pumpAndSettle();

    expect(find.text('history list'), findsOneWidget);
    expect(await storage.getRide('ride-1'), isNull);
    // The plan it completed is open again.
    final plan = (await storage.getScheduledWorkouts()).single;
    expect(plan.completedRideId, isNull);
  });

  testWidgets('keeps the ride when the deletion is cancelled', (tester) async {
    await pumpRidePage(tester);

    await tester.tap(find.byKey(const Key('deleteRideButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Ride Detail'), findsOneWidget);
    expect(await storage.getRide('ride-1'), isNotNull);
  });

  group('route rides', () {
    // Tall enough for the export section at the bottom of the list to build.
    setUp(() {
      final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
      view.physicalSize = const Size(1000, 2400);
      view.devicePixelRatio = 1.0;
      addTearDown(view.resetPhysicalSize);
      addTearDown(view.resetDevicePixelRatio);
    });

    final gpxOnly = [
      exportPluginsProvider.overrideWithValue({
        'gpx-file-export': GpxFileExportPlugin(loadRoute: (_) async => null),
      }),
    ];

    testWidgets('show their route and offer GPX export', (tester) async {
      await storage.saveRoute(
        SavedRoute(
          id: 'route-1',
          name: 'Galibier',
          fingerprint: '',
          distance: const Distance(18100),
          ascent: 1245,
          createdAt: DateTime(2026, 10, 1),
        ),
        '<gpx/>',
      );
      await storage.linkRideToRoute('ride-1', 'route-1');

      await pumpRidePage(tester, overrides: gpxOnly);

      expect(find.byKey(const Key('rideRouteTile')), findsOneWidget);
      expect(find.text('Galibier'), findsOneWidget);
      expect(find.text('GPX File'), findsOneWidget);
    });

    testWidgets('a ride without a route offers no GPX export', (tester) async {
      await pumpRidePage(tester, overrides: gpxOnly);

      expect(find.byKey(const Key('rideRouteTile')), findsNothing);
      expect(find.text('GPX File'), findsNothing);
    });
  });
}
