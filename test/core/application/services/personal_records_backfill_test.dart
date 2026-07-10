import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/personal_records_backfill.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';

List<SensorReading> _steadyPower(DateTime start, double watts, int seconds) {
  return [
    for (var i = 0; i < seconds; i++)
      SensorReading(
        timestamp: start.add(Duration(seconds: i)),
        power: Watts(watts),
      ),
  ];
}

void main() {
  late AppDatabase db;
  late DriftStorage storage;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    storage = DriftStorage(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('computes and persists records for every ride with readings',
      () async {
    final start = DateTime.utc(2026, 1, 1);
    final ride = Ride(
      id: 'ride-1',
      startTime: start,
      endTime: start.add(const Duration(minutes: 10)),
      status: RideStatus.finished,
    );
    await storage.saveRide(ride);
    await storage.saveSensorReadings(ride.id, _steadyPower(start, 250, 600));

    final count = await backfillPersonalRecords(storage);

    expect(count, 1);
    final records = await storage.getPersonalRecords();
    expect(records, isNotEmpty);
    expect(records.every((r) => r.rideId == 'ride-1'), isTrue);
  });

  test('skips rides with no sensor readings', () async {
    final ride = Ride(
      id: 'ride-empty',
      startTime: DateTime.utc(2026, 1, 1),
      status: RideStatus.finished,
    );
    await storage.saveRide(ride);

    final count = await backfillPersonalRecords(storage);

    expect(count, 0);
    expect(await storage.getPersonalRecords(), isEmpty);
  });

  test('running twice does not duplicate records (idempotent)', () async {
    final start = DateTime.utc(2026, 1, 1);
    final ride = Ride(
      id: 'ride-1',
      startTime: start,
      endTime: start.add(const Duration(minutes: 10)),
      status: RideStatus.finished,
    );
    await storage.saveRide(ride);
    await storage.saveSensorReadings(ride.id, _steadyPower(start, 250, 600));

    await backfillPersonalRecords(storage);
    final firstRunCount = (await storage.getPersonalRecords()).length;
    await backfillPersonalRecords(storage);
    final secondRunCount = (await storage.getPersonalRecords()).length;

    expect(secondRunCount, firstRunCount);
  });
}
