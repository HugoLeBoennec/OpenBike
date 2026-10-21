import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/presentation/state/providers.dart';

Ride _ride(String id, DateTime start) => Ride(
      id: id,
      startTime: start,
      endTime: start.add(const Duration(minutes: 30)),
      status: RideStatus.finished,
      readings: [
        for (var i = 0; i < 1800; i++)
          SensorReading(
            timestamp: start.add(Duration(seconds: i)),
            power: const Watts(200),
          ),
      ],
    );

void main() {
  late AppDatabase db;
  late DriftStorage storage;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    storage = DriftStorage(db);
    container = ProviderContainer(overrides: [
      storageProvider.overrideWithValue(storage),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  test('runs to today, not to the last ride', () async {
    await storage.saveRide(
        _ride('r1', today().subtract(const Duration(days: 5, hours: -9))),
        ftp: const Watts(200));

    final points = await container.read(fitnessHistoryProvider.future);

    expect(points.last.date, today());
    expect(points.last.tss, 0);
  });

  test('picks up a newly saved ride once the ride history refreshes',
      () async {
    await storage.saveRide(
        _ride('r1', today().subtract(const Duration(days: 3, hours: -9))),
        ftp: const Watts(200));
    final before = await container.read(fitnessHistoryProvider.future);

    // What finishing a ride does: save it, then invalidate the history.
    await storage.saveRide(_ride('r2', today().add(const Duration(hours: 7))),
        ftp: const Watts(200));
    container.invalidate(rideHistoryProvider);
    final after = await container.read(fitnessHistoryProvider.future);

    expect(before.last.tss, 0);
    expect(after.last.tss, greaterThan(0));
    expect(after.last.ctl, greaterThan(before.last.ctl));
  });
}
