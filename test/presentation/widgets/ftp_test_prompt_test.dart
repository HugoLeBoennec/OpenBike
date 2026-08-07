import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/application/services/ftp_test_planner.dart';
import 'package:open_bike/core/domain/entities/ftp_history_entry.dart';
import 'package:open_bike/core/domain/entities/ride.dart';
import 'package:open_bike/core/domain/entities/sensor_reading.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/ftp_test_prompt.dart';

Ride _rampTestRide() {
  final start = DateTime.utc(2026, 1, 1);
  return Ride(
    id: 'r1',
    startTime: start,
    endTime: start.add(const Duration(minutes: 2)),
    status: RideStatus.finished,
    readings: List.generate(
      90,
      (i) => SensorReading(
        timestamp: start.add(Duration(seconds: i)),
        power: const Watts(300),
      ),
    ),
  );
}

void main() {
  testWidgets(
      'shows the update-profile prompt once a ramp-test ride loads, and '
      'Update persists the detected FTP', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final storage = DriftStorage(db);
    final ride = _rampTestRide();

    final container = ProviderContainer(overrides: [
      storageProvider.overrideWithValue(storage),
      activeFtpTestProvider.overrideWith((ref) => FtpTestProtocol.ramp),
      rideDetailProvider(ride.id).overrideWith((ref) async => ride),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: Scaffold(body: FtpTestPrompt(rideId: ride.id))),
      ),
    );
    await tester.pumpAndSettle();

    // 75% of the best 1-minute power (300 W held for 90 s) = 225 W.
    expect(find.textContaining('New FTP: 225 W'), findsOneWidget);

    await tester.tap(find.byKey(const Key('updateFtpButton')));
    await tester.pumpAndSettle();

    expect(container.read(userProfileProvider)?.ftp.value, 225);
    final saved = await storage.getProfile();
    expect(saved?.ftp.value, 225);

    // Tagged as a measured ramp test, which is what resets the retest clock
    // and adds a point to the progression chart.
    final history = await storage.getFtpHistory();
    expect(history.last.source, FtpSource.rampTest);
    expect(history.last.ftp.value, 225);

    // Consumed exactly once — cleared so it won't fire again on rebuild.
    expect(container.read(activeFtpTestProvider), isNull);
  });

  testWidgets('does nothing when no FTP test is pending', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final storage = DriftStorage(db);
    final ride = _rampTestRide();

    final container = ProviderContainer(overrides: [
      storageProvider.overrideWithValue(storage),
      activeFtpTestProvider.overrideWith((ref) => null),
      rideDetailProvider(ride.id).overrideWith((ref) async => ride),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: Scaffold(body: FtpTestPrompt(rideId: ride.id))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('New FTP'), findsNothing);
  });
}
