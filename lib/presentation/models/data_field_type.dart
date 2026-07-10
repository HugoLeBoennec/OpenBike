import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';

// ---------------------------------------------------------------------------
// Data field types available on the ride screen
// ---------------------------------------------------------------------------

enum DataFieldType {
  power,
  avgPower,
  normalizedPower,
  threeSecAvgPower,
  cadence,
  heartRate,
  speed,
  distance,
  elapsedTime,
  calories,
  tss,
  intensityFactor,
  grade,
  elevation,
}

// ---------------------------------------------------------------------------
// Display metadata + value resolvers
// ---------------------------------------------------------------------------

extension DataFieldTypeX on DataFieldType {
  String get label {
    switch (this) {
      case DataFieldType.power:
        return 'POWER';
      case DataFieldType.avgPower:
        return 'AVG POWER';
      case DataFieldType.normalizedPower:
        return 'NP';
      case DataFieldType.threeSecAvgPower:
        return '3s POWER';
      case DataFieldType.cadence:
        return 'CADENCE';
      case DataFieldType.heartRate:
        return 'HEART RATE';
      case DataFieldType.speed:
        return 'SPEED';
      case DataFieldType.distance:
        return 'DISTANCE';
      case DataFieldType.elapsedTime:
        return 'TIME';
      case DataFieldType.calories:
        return 'CALORIES';
      case DataFieldType.tss:
        return 'TSS';
      case DataFieldType.intensityFactor:
        return 'IF';
      case DataFieldType.grade:
        return 'GRADE';
      case DataFieldType.elevation:
        return 'ELEVATION';
    }
  }

  String get unit {
    switch (this) {
      case DataFieldType.power:
      case DataFieldType.avgPower:
      case DataFieldType.normalizedPower:
      case DataFieldType.threeSecAvgPower:
        return 'w';
      case DataFieldType.cadence:
        return 'rpm';
      case DataFieldType.heartRate:
        return 'bpm';
      case DataFieldType.speed:
        return 'km/h';
      case DataFieldType.distance:
        return 'km';
      case DataFieldType.elapsedTime:
        return '';
      case DataFieldType.calories:
        return 'kcal';
      case DataFieldType.tss:
        return '';
      case DataFieldType.intensityFactor:
        return '';
      case DataFieldType.grade:
        return '%';
      case DataFieldType.elevation:
        return 'm';
    }
  }

  /// Unit-system-aware suffix — same as [unit] except for speed/distance/
  /// elevation, which switch between metric and imperial via
  /// [unitFormatterProvider].
  String unitFor(WidgetRef ref) {
    switch (this) {
      case DataFieldType.speed:
        return ref.watch(unitFormatterProvider).speedUnit;
      case DataFieldType.distance:
        return ref.watch(unitFormatterProvider).distanceUnit;
      case DataFieldType.elevation:
        return ref.watch(unitFormatterProvider).elevationUnit;
      default:
        return unit;
    }
  }

  bool get isPowerField =>
      this == DataFieldType.power ||
      this == DataFieldType.avgPower ||
      this == DataFieldType.normalizedPower ||
      this == DataFieldType.threeSecAvgPower;

  /// Resolves the current display value from Riverpod providers.
  String resolveValue(WidgetRef ref) {
    switch (this) {
      case DataFieldType.power:
        return ref.watch(livePowerProvider).value.round().toString();
      case DataFieldType.avgPower:
        final ride = ref.watch(currentRideProvider);
        return ride?.averagePower.value.round().toString() ?? '--';
      case DataFieldType.normalizedPower:
        final ride = ref.watch(currentRideProvider);
        return ride?.normalizedPower.value.round().toString() ?? '--';
      case DataFieldType.threeSecAvgPower:
        return ref.watch(threeSecondAvgPowerProvider).value.round().toString();
      case DataFieldType.cadence:
        return ref.watch(liveCadenceProvider).rpm.round().toString();
      case DataFieldType.heartRate:
        return ref.watch(liveHeartRateProvider).bpm.toString();
      case DataFieldType.speed:
        final formatter = ref.watch(unitFormatterProvider);
        return formatter
            .speedValue(ref.watch(liveSpeedProvider))
            .toStringAsFixed(1);
      case DataFieldType.distance:
        final ride = ref.watch(currentRideProvider);
        final formatter = ref.watch(unitFormatterProvider);
        return ride != null
            ? formatter.distanceValue(ride.totalDistance).toStringAsFixed(2)
            : '0.00';
      case DataFieldType.elapsedTime:
        final elapsed = ref.watch(rideElapsedProvider);
        return elapsed.when(
          data: (d) => _formatDuration(d),
          loading: () => '00:00:00',
          error: (_, __) => '--:--:--',
        );
      case DataFieldType.calories:
        // Simplified estimate: avg power × hours × 3.6
        final ride = ref.watch(currentRideProvider);
        if (ride == null) return '0';
        final hours = ride.activeDuration.inSeconds / 3600.0;
        return (ride.averagePower.value * hours * 3.6).round().toString();
      case DataFieldType.tss:
        final ride = ref.watch(currentRideProvider);
        final ftp = ref.watch(ftpProvider);
        return ride?.tss(ftp).toStringAsFixed(0) ?? '0';
      case DataFieldType.intensityFactor:
        final ride = ref.watch(currentRideProvider);
        final ftp = ref.watch(ftpProvider);
        return ride?.intensityFactor(ftp).toStringAsFixed(2) ?? '0.00';
      case DataFieldType.grade:
        final sim = ref.watch(simulationProgressProvider);
        return sim.when(
          data: (p) => p.grade.percent.toStringAsFixed(1),
          loading: () => '0.0',
          error: (_, __) => '--',
        );
      case DataFieldType.elevation:
        final sim = ref.watch(simulationProgressProvider);
        final formatter = ref.watch(unitFormatterProvider);
        return sim.when(
          data: (p) => formatter
              .elevationValue(p.currentPoint.smoothedElevation)
              .round()
              .toString(),
          loading: () => '0',
          error: (_, __) => '--',
        );
    }
  }

  /// Returns the zone color for this field's current value, or null if not
  /// a power field or no zone matched.
  Color? resolveZoneColor(WidgetRef ref) {
    if (!isPowerField) return null;
    final zone = ref.watch(currentPowerZoneProvider);
    return zone?.color;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _formatDuration(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}
