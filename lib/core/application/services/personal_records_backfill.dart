import '../../domain/ports/storage_port.dart';
import 'personal_records_calculator.dart';

/// Computes and persists mean-max power [PersonalRecord]s for every ride
/// that has recorded sensor readings.
///
/// Idempotent: [StoragePort.savePersonalRecords] upserts on the
/// (rideId, durationSeconds) unique key, so running this more than once (or
/// after new rides already have records) never duplicates rows — it's safe
/// to invoke on every app start, though callers typically gate it behind a
/// one-time preference flag to avoid recomputing for every ride on every
/// launch.
///
/// Returns the number of rides that contributed at least one record.
Future<int> backfillPersonalRecords(
  StoragePort storage, {
  PersonalRecordsCalculator? calculator,
}) async {
  final calc = calculator ?? PersonalRecordsCalculator();
  final rides = await storage.getRides();

  var ridesWithRecords = 0;
  for (final ride in rides) {
    final readings = await storage.getSensorReadings(ride.id);
    if (readings.isEmpty) continue;

    final records = calc.computeRecords(
      rideId: ride.id,
      achievedAt: ride.startTime,
      readings: readings,
    );
    if (records.isEmpty) continue;

    await storage.savePersonalRecords(records);
    ridesWithRecords++;
  }

  return ridesWithRecords;
}
