import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/screens/trends_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';

List<SensorReading> _steadyPower(DateTime start, double watts, int seconds) {
  return [
    for (var i = 0; i < seconds; i++)
      SensorReading(
        timestamp: start.add(Duration(seconds: i)),
        power: Watts(watts),
      ),
  ];
}

Widget _wrap(DriftStorage storage, AppPreferences appPrefs) {
  return ProviderScope(
    overrides: [
      storageProvider.overrideWithValue(storage),
      appPreferencesProvider.overrideWithValue(appPrefs),
    ],
    child: const MaterialApp(home: TrendsScreen()),
  );
}

void main() {
  late AppDatabase db;
  late DriftStorage storage;
  late AppPreferences appPrefs;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    storage = DriftStorage(db);
    SharedPreferences.setMockInitialValues({});
    appPrefs = AppPreferences(await SharedPreferences.getInstance());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('shows an empty-state message with no ride history', (tester) async {
    await tester.pumpWidget(_wrap(storage, appPrefs));
    await tester.pumpAndSettle();

    expect(find.textContaining('No ride history yet'), findsOneWidget);
  });

  testWidgets('renders the PMC chart, weekly TSS, and totals from ride history',
      (tester) async {
    final start = DateTime.now().subtract(const Duration(days: 2));
    final ride = Ride(
      id: 'ride-1',
      startTime: start,
      endTime: start.add(const Duration(minutes: 10)),
      status: RideStatus.finished,
      readings: _steadyPower(start, 200, 600),
    );
    await storage.saveRide(ride, ftp: const Watts(200));
    await storage.saveSensorReadings(ride.id, ride.readings);

    await tester.pumpWidget(_wrap(storage, appPrefs));
    await tester.pumpAndSettle();

    expect(find.text('FITNESS / FATIGUE / FORM'), findsOneWidget);
    expect(find.text('CTL (Fitness)'), findsOneWidget);
    expect(find.text('ATL (Fatigue)'), findsOneWidget);
    expect(find.text('TSB (Form)'), findsOneWidget);

    // The rest of the page is below the fold in the test viewport.
    await tester.scrollUntilVisible(find.text('WEEKLY TSS'), 200);
    expect(find.text('WEEKLY TSS'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('PERSONAL RECORDS'), 200);
    expect(find.text('PERSONAL RECORDS'), findsOneWidget);
  });

  testWidgets('range selector switches between 1M/3M/6M/12M', (tester) async {
    final start = DateTime.now().subtract(const Duration(days: 2));
    final ride = Ride(
      id: 'ride-1',
      startTime: start,
      endTime: start.add(const Duration(minutes: 10)),
      status: RideStatus.finished,
      readings: _steadyPower(start, 200, 600),
    );
    await storage.saveRide(ride, ftp: const Watts(200));
    await storage.saveSensorReadings(ride.id, ride.readings);

    await tester.pumpWidget(_wrap(storage, appPrefs));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('range-3M')), findsOneWidget);
    await tester.tap(find.byKey(const Key('range-12M')));
    await tester.pumpAndSettle();

    // Still renders successfully after switching range.
    expect(find.text('FITNESS / FATIGUE / FORM'), findsOneWidget);
  });

  testWidgets('shows personal records once a ride has mean-max power cached',
      (tester) async {
    final start = DateTime.now().subtract(const Duration(days: 1));
    final ride = Ride(
      id: 'ride-1',
      startTime: start,
      endTime: start.add(const Duration(minutes: 10)),
      status: RideStatus.finished,
      readings: _steadyPower(start, 200, 600),
    );
    await storage.saveRide(ride, ftp: const Watts(200));
    await storage.savePersonalRecords([
      PersonalRecord(
        rideId: 'ride-1',
        durationSeconds: 300,
        watts: const Watts(280),
        achievedAt: start,
      ),
    ]);

    await tester.pumpWidget(_wrap(storage, appPrefs));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('PERSONAL RECORDS'), 200);
    expect(find.text('280'), findsOneWidget);
    expect(find.text('5 MIN'), findsOneWidget);
  });
}
