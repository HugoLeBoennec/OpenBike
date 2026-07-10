import '../../domain/entities/ftp_history_entry.dart';
import '../../domain/entities/ride.dart';
import '../../domain/value_objects/value_objects.dart';

/// One day's point on the Performance Management Chart.
class FitnessDataPoint {
  const FitnessDataPoint({
    required this.date,
    required this.tss,
    required this.ctl,
    required this.atl,
    required this.tsb,
  });

  /// Local midnight for this day.
  final DateTime date;

  /// Total TSS logged on this day (0 on rest/gap days).
  final double tss;

  /// Chronic Training Load — 42-day exponentially weighted average of TSS.
  final double ctl;

  /// Acute Training Load — 7-day exponentially weighted average of TSS.
  final double atl;

  /// Training Stress Balance — CTL minus ATL, computed from the *previous*
  /// day's fitness/fatigue (the form a rider carries into today, before
  /// today's training is added to the load).
  final double tsb;
}

/// Computes the Performance Management Chart (CTL/ATL/TSB) from daily TSS
/// totals.
///
/// Pure Dart — no I/O. Seed it with a date-keyed TSS map built from ride
/// history (see [dailyTssFromRides]); gap days with no rides are treated as
/// 0 TSS so fitness/fatigue decay correctly across rest days.
class FitnessCalculator {
  static const ctlTimeConstant = 42;
  static const atlTimeConstant = 7;

  /// Builds one [FitnessDataPoint] per day from the earliest to the latest
  /// date present in [dailyTss] (inclusive), filling any gap day with 0 TSS.
  List<FitnessDataPoint> calculate(Map<DateTime, double> dailyTss) {
    if (dailyTss.isEmpty) return [];

    final normalized = <DateTime, double>{};
    for (final entry in dailyTss.entries) {
      final day = _dateOnly(entry.key);
      normalized[day] = (normalized[day] ?? 0) + entry.value;
    }

    final dates = normalized.keys.toList()..sort();
    final start = dates.first;
    final end = dates.last;

    final points = <FitnessDataPoint>[];
    double ctl = 0;
    double atl = 0;

    for (var day = start;
        !day.isAfter(end);
        day = day.add(const Duration(days: 1))) {
      // TSB reflects the form carried *into* today, before today's load.
      final tsb = ctl - atl;
      final tss = normalized[day] ?? 0;
      ctl = ctl + (tss - ctl) / ctlTimeConstant;
      atl = atl + (tss - atl) / atlTimeConstant;

      points.add(FitnessDataPoint(
        date: day,
        tss: tss,
        ctl: ctl,
        atl: atl,
        tsb: tsb,
      ));
    }

    return points;
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}

/// Builds a date-keyed daily-TSS map from ride history, scoring each ride
/// against the FTP that was actually in effect on its date (from
/// [ftpHistory]) rather than today's profile FTP — this keeps past days'
/// PMC values stable even after the rider's FTP later changes.
///
/// [ftpHistory] should be sorted ascending by [FtpHistoryEntry.effectiveDate]
/// (as returned by `StoragePort.getFtpHistory()`); [currentFtp] is the
/// fallback used when a ride predates every history entry.
Map<DateTime, double> dailyTssFromRides(
  List<Ride> rides, {
  required List<FtpHistoryEntry> ftpHistory,
  required Watts currentFtp,
}) {
  final daily = <DateTime, double>{};
  for (final ride in rides) {
    if (ride.status != RideStatus.finished) continue;
    final ftpAtRide = _ftpEffectiveAt(ride.startTime, ftpHistory, currentFtp);
    final day = DateTime(
      ride.startTime.year,
      ride.startTime.month,
      ride.startTime.day,
    );
    daily[day] = (daily[day] ?? 0) + ride.tss(ftpAtRide);
  }
  return daily;
}

Watts _ftpEffectiveAt(
  DateTime date,
  List<FtpHistoryEntry> ftpHistory,
  Watts fallback,
) {
  if (ftpHistory.isEmpty) return fallback;

  FtpHistoryEntry? best;
  for (final entry in ftpHistory) {
    if (entry.effectiveDate.isAfter(date)) continue;
    if (best == null || entry.effectiveDate.isAfter(best.effectiveDate)) {
      best = entry;
    }
  }
  // No entry predates this ride — fall back to the earliest known FTP
  // rather than today's, since that's the closest historical estimate.
  return (best ?? ftpHistory.first).ftp;
}
