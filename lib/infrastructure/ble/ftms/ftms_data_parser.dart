import 'dart:typed_data';

import 'package:logging/logging.dart';

import '../../../core/domain/entities/sensor_reading.dart';
import '../../../core/domain/value_objects/value_objects.dart';

final _log = Logger('FtmsDataParser');

/// Parsed result of an FTMS Indoor Bike Data characteristic notification.
///
/// All fields are optional because the FTMS spec uses a flags bitmask to
/// indicate which fields are present in any given notification.
class FtmsIndoorBikeData {
  const FtmsIndoorBikeData({
    this.instantaneousSpeed,
    this.averageSpeed,
    this.instantaneousCadence,
    this.averageCadence,
    this.totalDistance,
    this.resistanceLevel,
    this.instantaneousPower,
    this.averagePower,
    this.totalEnergy,
    this.energyPerHour,
    this.energyPerMinute,
    this.heartRate,
    this.metabolicEquivalent,
    this.elapsedTime,
    this.remainingTime,
  });

  /// km/h (resolution 0.01)
  final double? instantaneousSpeed;

  /// km/h (resolution 0.01)
  final double? averageSpeed;

  /// RPM (resolution 0.5)
  final double? instantaneousCadence;

  /// RPM (resolution 0.5)
  final double? averageCadence;

  /// Meters
  final int? totalDistance;

  /// Unitless (resolution 0.1)
  final double? resistanceLevel;

  /// Watts (resolution 1, signed)
  final int? instantaneousPower;

  /// Watts (resolution 1, signed)
  final int? averagePower;

  /// kcal
  final int? totalEnergy;

  /// kcal/hour
  final int? energyPerHour;

  /// kcal/minute (resolution 0.1)
  final double? energyPerMinute;

  /// BPM
  final int? heartRate;

  /// (resolution 0.1)
  final double? metabolicEquivalent;

  /// Seconds
  final int? elapsedTime;

  /// Seconds
  final int? remainingTime;
}

/// Stateless parser for the FTMS Indoor Bike Data characteristic (0x2AD2).
///
/// The characteristic layout is defined by the Bluetooth SIG FTMS spec:
/// - Bytes 0–1: 16-bit flags bitmask (little-endian)
/// - Remaining bytes: field data in the order dictated by the flag bits
///
/// Flag bits and their meaning:
/// ```
/// Bit 0:  More Data                (0 = Instantaneous Speed present)
/// Bit 1:  Average Speed present
/// Bit 2:  Instantaneous Cadence present
/// Bit 3:  Average Cadence present
/// Bit 4:  Total Distance present
/// Bit 5:  Resistance Level present
/// Bit 6:  Instantaneous Power present
/// Bit 7:  Average Power present
/// Bit 8:  Expended Energy present
/// Bit 9:  Heart Rate present
/// Bit 10: Metabolic Equivalent present
/// Bit 11: Elapsed Time present
/// Bit 12: Remaining Time present
/// ```
class FtmsDataParser {
  const FtmsDataParser();

  /// Parses raw Indoor Bike Data bytes into an [FtmsIndoorBikeData].
  ///
  /// Returns `null` if the payload is too short to contain the flags field.
  FtmsIndoorBikeData? parseIndoorBikeData(List<int> raw) {
    if (raw.length < 2) {
      _log.warning('Indoor Bike Data too short (${raw.length} bytes)');
      return null;
    }

    final bytes = ByteData.sublistView(Uint8List.fromList(raw));
    final flags = bytes.getUint16(0, Endian.little);
    var offset = 2;

    // ------------------------------------------------------------------
    // Bit 0: More Data — inverted logic!
    //   0 → Instantaneous Speed IS present
    //   1 → Instantaneous Speed is NOT present
    // ------------------------------------------------------------------
    double? instantaneousSpeed;
    if (flags & 0x0001 == 0) {
      if (offset + 2 > raw.length) return _truncated(offset);
      instantaneousSpeed =
          bytes.getUint16(offset, Endian.little) / 100.0; // 0.01 km/h
      offset += 2;
    }

    // ------------------------------------------------------------------
    // Bit 1: Average Speed
    // ------------------------------------------------------------------
    double? averageSpeed;
    if (flags & 0x0002 != 0) {
      if (offset + 2 > raw.length) return _truncated(offset);
      averageSpeed =
          bytes.getUint16(offset, Endian.little) / 100.0; // 0.01 km/h
      offset += 2;
    }

    // ------------------------------------------------------------------
    // Bit 2: Instantaneous Cadence
    // ------------------------------------------------------------------
    double? instantaneousCadence;
    if (flags & 0x0004 != 0) {
      if (offset + 2 > raw.length) return _truncated(offset);
      instantaneousCadence =
          bytes.getUint16(offset, Endian.little) / 2.0; // 0.5 RPM
      offset += 2;
    }

    // ------------------------------------------------------------------
    // Bit 3: Average Cadence
    // ------------------------------------------------------------------
    double? averageCadence;
    if (flags & 0x0008 != 0) {
      if (offset + 2 > raw.length) return _truncated(offset);
      averageCadence =
          bytes.getUint16(offset, Endian.little) / 2.0; // 0.5 RPM
      offset += 2;
    }

    // ------------------------------------------------------------------
    // Bit 4: Total Distance — 3 bytes (UINT24), meters
    // ------------------------------------------------------------------
    int? totalDistance;
    if (flags & 0x0010 != 0) {
      if (offset + 3 > raw.length) return _truncated(offset);
      totalDistance =
          raw[offset] | (raw[offset + 1] << 8) | (raw[offset + 2] << 16);
      offset += 3;
    }

    // ------------------------------------------------------------------
    // Bit 5: Resistance Level — SINT16, resolution 0.1
    // ------------------------------------------------------------------
    double? resistanceLevel;
    if (flags & 0x0020 != 0) {
      if (offset + 2 > raw.length) return _truncated(offset);
      resistanceLevel =
          bytes.getInt16(offset, Endian.little) / 10.0; // 0.1 unitless
      offset += 2;
    }

    // ------------------------------------------------------------------
    // Bit 6: Instantaneous Power — SINT16, 1 W
    // ------------------------------------------------------------------
    int? instantaneousPower;
    if (flags & 0x0040 != 0) {
      if (offset + 2 > raw.length) return _truncated(offset);
      instantaneousPower = bytes.getInt16(offset, Endian.little);
      offset += 2;
    }

    // ------------------------------------------------------------------
    // Bit 7: Average Power — SINT16, 1 W
    // ------------------------------------------------------------------
    int? averagePower;
    if (flags & 0x0080 != 0) {
      if (offset + 2 > raw.length) return _truncated(offset);
      averagePower = bytes.getInt16(offset, Endian.little);
      offset += 2;
    }

    // ------------------------------------------------------------------
    // Bit 8: Expended Energy — 3 fields:
    //   Total Energy (UINT16, kcal)
    //   Energy Per Hour (UINT16, kcal)
    //   Energy Per Minute (UINT8, kcal, resolution 0.1) — total 5 bytes
    // ------------------------------------------------------------------
    int? totalEnergy;
    int? energyPerHour;
    double? energyPerMinute;
    if (flags & 0x0100 != 0) {
      if (offset + 5 > raw.length) return _truncated(offset);
      totalEnergy = bytes.getUint16(offset, Endian.little);
      energyPerHour = bytes.getUint16(offset + 2, Endian.little);
      energyPerMinute = raw[offset + 4] / 10.0;
      offset += 5;
    }

    // ------------------------------------------------------------------
    // Bit 9: Heart Rate — UINT8, BPM
    // ------------------------------------------------------------------
    int? heartRate;
    if (flags & 0x0200 != 0) {
      if (offset + 1 > raw.length) return _truncated(offset);
      heartRate = raw[offset];
      offset += 1;
    }

    // ------------------------------------------------------------------
    // Bit 10: Metabolic Equivalent — UINT8, resolution 0.1
    // ------------------------------------------------------------------
    double? metabolicEquivalent;
    if (flags & 0x0400 != 0) {
      if (offset + 1 > raw.length) return _truncated(offset);
      metabolicEquivalent = raw[offset] / 10.0;
      offset += 1;
    }

    // ------------------------------------------------------------------
    // Bit 11: Elapsed Time — UINT16, seconds
    // ------------------------------------------------------------------
    int? elapsedTime;
    if (flags & 0x0800 != 0) {
      if (offset + 2 > raw.length) return _truncated(offset);
      elapsedTime = bytes.getUint16(offset, Endian.little);
      offset += 2;
    }

    // ------------------------------------------------------------------
    // Bit 12: Remaining Time — UINT16, seconds
    // ------------------------------------------------------------------
    int? remainingTime;
    if (flags & 0x1000 != 0) {
      if (offset + 2 > raw.length) return _truncated(offset);
      remainingTime = bytes.getUint16(offset, Endian.little);
      offset += 2;
    }

    return FtmsIndoorBikeData(
      instantaneousSpeed: instantaneousSpeed,
      averageSpeed: averageSpeed,
      instantaneousCadence: instantaneousCadence,
      averageCadence: averageCadence,
      totalDistance: totalDistance,
      resistanceLevel: resistanceLevel,
      instantaneousPower: instantaneousPower,
      averagePower: averagePower,
      totalEnergy: totalEnergy,
      energyPerHour: energyPerHour,
      energyPerMinute: energyPerMinute,
      heartRate: heartRate,
      metabolicEquivalent: metabolicEquivalent,
      elapsedTime: elapsedTime,
      remainingTime: remainingTime,
    );
  }

  /// Converts a raw [FtmsIndoorBikeData] into a domain [SensorReading].
  SensorReading toSensorReading(FtmsIndoorBikeData data) {
    return SensorReading(
      timestamp: DateTime.now(),
      power: data.instantaneousPower != null
          ? Watts(data.instantaneousPower!.toDouble())
          : null,
      cadence: data.instantaneousCadence != null
          ? Cadence(data.instantaneousCadence!)
          : null,
      speed: data.instantaneousSpeed != null
          ? Speed(data.instantaneousSpeed!)
          : null,
      heartRate:
          data.heartRate != null ? HeartRate(data.heartRate!) : null,
      distance: data.totalDistance != null
          ? Distance(data.totalDistance!.toDouble())
          : null,
    );
  }

  FtmsIndoorBikeData? _truncated(int offset) {
    _log.warning('Indoor Bike Data truncated at offset $offset');
    return null;
  }
}
