import 'package:flutter/material.dart';

import '../../core/domain/entities/entities.dart';

/// Human-readable label for a [SensorRole], shared by the device-management
/// screen and in-ride connection UI so they don't drift.
String roleLabel(SensorRole role) {
  switch (role) {
    case SensorRole.trainer:
      return 'Trainer';
    case SensorRole.heartRate:
      return 'Heart Rate';
    case SensorRole.power:
      return 'Power Meter';
    case SensorRole.cadenceSpeed:
      return 'Cadence / Speed';
  }
}

/// Icon representing a [SensorRole].
IconData roleIcon(SensorRole role) {
  switch (role) {
    case SensorRole.trainer:
      return Icons.pedal_bike;
    case SensorRole.heartRate:
      return Icons.favorite;
    case SensorRole.power:
      return Icons.bolt;
    case SensorRole.cadenceSpeed:
      return Icons.rotate_right;
  }
}
