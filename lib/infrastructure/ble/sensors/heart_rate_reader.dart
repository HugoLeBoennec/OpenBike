import 'package:logging/logging.dart';

import '../../../core/domain/entities/sensor_reading.dart';
import '../../../core/domain/value_objects/value_objects.dart';

final _log = Logger('HeartRateReader');

/// Parsed Heart Rate Measurement data.
class HeartRateMeasurement {
  const HeartRateMeasurement({
    required this.heartRate,
    required this.sensorContact,
    this.energyExpended,
    this.rrIntervals = const [],
  });

  /// Heart rate in BPM.
  final int heartRate;

  /// Whether the sensor is in contact with the body.
  /// `null` if contact detection is not supported.
  final bool? sensorContact;

  /// Cumulative energy expended in kJ, if present.
  final int? energyExpended;

  /// RR-intervals in milliseconds (resolution: 1/1024 s ≈ 0.977 ms).
  final List<int> rrIntervals;
}

/// Parses the Heart Rate Measurement characteristic (0x2A37).
///
/// Characteristic layout:
/// - Byte 0: Flags
///   - Bit 0: HR format (0 = UINT8, 1 = UINT16)
///   - Bits 1–2: Sensor Contact Status
///     - 0b00 or 0b01: not supported
///     - 0b10: supported, no contact
///     - 0b11: supported, contact detected
///   - Bit 3: Energy Expended present
///   - Bit 4: RR-Interval present
/// - Byte 1 (or 1–2): Heart Rate value
/// - Optional: Energy Expended (UINT16)
/// - Optional: one or more RR-Interval values (UINT16, 1/1024 s)
class HeartRateReader {
  const HeartRateReader();

  /// Parses raw bytes from a HR Measurement notification.
  ///
  /// Returns `null` if the payload is too short.
  HeartRateMeasurement? parse(List<int> raw) {
    if (raw.isEmpty) {
      _log.warning('HR Measurement empty');
      return null;
    }

    final flags = raw[0];
    var offset = 1;

    // ------------------------------------------------------------------
    // Heart Rate value
    // ------------------------------------------------------------------
    final hrIs16Bit = flags & 0x01 != 0;
    int heartRate;

    if (hrIs16Bit) {
      if (offset + 2 > raw.length) return _truncated();
      heartRate = raw[offset] | (raw[offset + 1] << 8);
      offset += 2;
    } else {
      if (offset + 1 > raw.length) return _truncated();
      heartRate = raw[offset];
      offset += 1;
    }

    // ------------------------------------------------------------------
    // Sensor Contact Status (bits 1–2)
    // ------------------------------------------------------------------
    final contactBits = (flags >> 1) & 0x03;
    bool? sensorContact;
    if (contactBits >= 2) {
      sensorContact = contactBits == 3;
    }

    // ------------------------------------------------------------------
    // Energy Expended (bit 3)
    // ------------------------------------------------------------------
    int? energyExpended;
    if (flags & 0x08 != 0) {
      if (offset + 2 > raw.length) return _truncated();
      energyExpended = raw[offset] | (raw[offset + 1] << 8);
      offset += 2;
    }

    // ------------------------------------------------------------------
    // RR-Intervals (bit 4) — may contain multiple values
    // ------------------------------------------------------------------
    final rrIntervals = <int>[];
    if (flags & 0x10 != 0) {
      while (offset + 2 <= raw.length) {
        final rawRr = raw[offset] | (raw[offset + 1] << 8);
        // Convert from 1/1024 s to milliseconds: rawRr * 1000 / 1024
        final rrMs = (rawRr * 1000) ~/ 1024;
        rrIntervals.add(rrMs);
        offset += 2;
      }
    }

    return HeartRateMeasurement(
      heartRate: heartRate,
      sensorContact: sensorContact,
      energyExpended: energyExpended,
      rrIntervals: rrIntervals,
    );
  }

  /// Converts a parsed [HeartRateMeasurement] into a domain [SensorReading].
  SensorReading toSensorReading(HeartRateMeasurement data) {
    return SensorReading(
      timestamp: DateTime.now(),
      heartRate: HeartRate(data.heartRate),
    );
  }

  HeartRateMeasurement? _truncated() {
    _log.warning('HR Measurement truncated');
    return null;
  }
}
