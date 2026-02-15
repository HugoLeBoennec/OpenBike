import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/value_objects.dart';
import 'lap.dart';
import 'sensor_reading.dart';

part 'ride.freezed.dart';

enum RideStatus { idle, active, paused, finished }

@freezed
class Ride with _$Ride {
  const Ride._();

  const factory Ride({
    required String id,
    required DateTime startTime,
    DateTime? endTime,
    @Default(RideStatus.idle) RideStatus status,
    @Default([]) List<SensorReading> readings,
    @Default([]) List<Lap> laps,
    @Default(Duration.zero) Duration pauseDuration,
  }) = _Ride;

  // ---------------------------------------------------------------------------
  // Duration
  // ---------------------------------------------------------------------------

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Duration excluding pauses — the actual active recording time.
  Duration get activeDuration => duration - pauseDuration;

  // ---------------------------------------------------------------------------
  // Power metrics
  // ---------------------------------------------------------------------------

  List<double> get _powerValues =>
      readings.where((r) => r.power != null).map((r) => r.power!.value).toList();

  Watts get averagePower {
    final p = _powerValues;
    if (p.isEmpty) return Watts.zero;
    return Watts(p.reduce((a, b) => a + b) / p.length);
  }

  Watts get maxPower {
    final p = _powerValues;
    if (p.isEmpty) return Watts.zero;
    return Watts(p.reduce(max));
  }

  /// Normalized Power — 30-second rolling average raised to the 4th power,
  /// averaged, then 4th root.
  Watts get normalizedPower {
    final p = _powerValues;
    if (p.length < 30) return averagePower;

    final rollingAvgs = <double>[];
    double windowSum = 0;
    for (var i = 0; i < p.length; i++) {
      windowSum += p[i];
      if (i >= 30) windowSum -= p[i - 30];
      if (i >= 29) rollingAvgs.add(windowSum / 30);
    }

    final mean4 =
        rollingAvgs.map((v) => v * v * v * v).reduce((a, b) => a + b) /
            rollingAvgs.length;
    return Watts(pow(mean4, 0.25).toDouble());
  }

  // ---------------------------------------------------------------------------
  // Cadence / HR
  // ---------------------------------------------------------------------------

  Cadence get averageCadence {
    final vals = readings
        .where((r) => r.cadence != null)
        .map((r) => r.cadence!.rpm)
        .toList();
    if (vals.isEmpty) return Cadence.zero;
    return Cadence(vals.reduce((a, b) => a + b) / vals.length);
  }

  HeartRate get averageHr {
    final vals = readings
        .where((r) => r.heartRate != null)
        .map((r) => r.heartRate!.bpm)
        .toList();
    if (vals.isEmpty) return HeartRate.zero;
    return HeartRate((vals.reduce((a, b) => a + b) / vals.length).round());
  }

  HeartRate get maxHr {
    final vals = readings
        .where((r) => r.heartRate != null)
        .map((r) => r.heartRate!.bpm)
        .toList();
    if (vals.isEmpty) return HeartRate.zero;
    return HeartRate(vals.reduce(max));
  }

  // ---------------------------------------------------------------------------
  // Distance
  // ---------------------------------------------------------------------------

  Distance get totalDistance {
    final distances = readings.where((r) => r.distance != null).toList();
    if (distances.isEmpty) return Distance.zero;
    return distances.last.distance!;
  }

  // ---------------------------------------------------------------------------
  // TSS / IF
  // ---------------------------------------------------------------------------

  /// Intensity Factor = NP / FTP.
  double intensityFactor(Watts ftp) {
    if (ftp.value == 0) return 0;
    return normalizedPower.value / ftp.value;
  }

  /// Training Stress Score.
  ///
  /// Uses [activeDuration] (excluding pauses) for the time component.
  double tss(Watts ftp) {
    if (ftp.value == 0) return 0;
    final ifactor = intensityFactor(ftp);
    return (activeDuration.inSeconds * normalizedPower.value * ifactor) /
        (ftp.value * 3600) *
        100;
  }
}
