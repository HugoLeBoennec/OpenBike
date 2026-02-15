import 'dart:typed_data';

import 'package:logging/logging.dart';

import '../../../core/domain/entities/sensor_reading.dart';
import '../../../core/domain/value_objects/value_objects.dart';

final _log = Logger('CscReader');

/// Default wheel circumference for a 700×25c tire, in meters.
const double defaultWheelCircumference = 2.105;

/// Parsed CSC Measurement data.
class CscMeasurement {
  const CscMeasurement({
    this.wheelRevolutions,
    this.lastWheelEventTime,
    this.crankRevolutions,
    this.lastCrankEventTime,
  });

  /// Cumulative wheel revolutions (UINT32).
  final int? wheelRevolutions;

  /// Last wheel event time in 1/1024 s (UINT16).
  final int? lastWheelEventTime;

  /// Cumulative crank revolutions (UINT16).
  final int? crankRevolutions;

  /// Last crank event time in 1/1024 s (UINT16).
  final int? lastCrankEventTime;
}

/// Parses the CSC (Cycling Speed and Cadence) Measurement characteristic
/// (0x2A5B) and computes speed and cadence from successive notifications.
///
/// Characteristic layout:
/// - Byte 0: Flags
///   - Bit 0: Wheel Revolution Data present
///   - Bit 1: Crank Revolution Data present
/// - If wheel data:
///   - UINT32: Cumulative Wheel Revolutions
///   - UINT16: Last Wheel Event Time (1/1024 s)
/// - If crank data:
///   - UINT16: Cumulative Crank Revolutions
///   - UINT16: Last Crank Event Time (1/1024 s)
class CscReader {
  CscReader({double wheelCircumference = defaultWheelCircumference})
      : _wheelCircumference = wheelCircumference;

  final double _wheelCircumference;

  // State for speed calculation.
  int? _prevWheelRevolutions;
  int? _prevWheelEventTime;

  // State for cadence calculation.
  int? _prevCrankRevolutions;
  int? _prevCrankEventTime;

  /// Parses raw bytes from a CSC Measurement notification.
  CscMeasurement? parse(List<int> raw) {
    if (raw.isEmpty) {
      _log.warning('CSC Measurement empty');
      return null;
    }

    final flags = raw[0];
    var offset = 1;

    // ------------------------------------------------------------------
    // Bit 0: Wheel Revolution Data
    // ------------------------------------------------------------------
    int? wheelRevolutions;
    int? lastWheelEventTime;
    if (flags & 0x01 != 0) {
      if (offset + 6 > raw.length) return _truncated();
      final bytes = ByteData.sublistView(Uint8List.fromList(raw));
      wheelRevolutions = bytes.getUint32(offset, Endian.little);
      lastWheelEventTime = bytes.getUint16(offset + 4, Endian.little);
      offset += 6;
    }

    // ------------------------------------------------------------------
    // Bit 1: Crank Revolution Data
    // ------------------------------------------------------------------
    int? crankRevolutions;
    int? lastCrankEventTime;
    if (flags & 0x02 != 0) {
      if (offset + 4 > raw.length) return _truncated();
      final bytes = ByteData.sublistView(Uint8List.fromList(raw));
      crankRevolutions = bytes.getUint16(offset, Endian.little);
      lastCrankEventTime = bytes.getUint16(offset + 2, Endian.little);
      offset += 4;
    }

    return CscMeasurement(
      wheelRevolutions: wheelRevolutions,
      lastWheelEventTime: lastWheelEventTime,
      crankRevolutions: crankRevolutions,
      lastCrankEventTime: lastCrankEventTime,
    );
  }

  /// Computes speed in km/h from wheel revolution data.
  ///
  /// Returns `null` on the first call or if no wheel data is present.
  /// Handles UINT32 rollover for revolutions and UINT16 for time.
  double? computeSpeed(CscMeasurement data) {
    if (data.wheelRevolutions == null || data.lastWheelEventTime == null) {
      return null;
    }

    final revs = data.wheelRevolutions!;
    final time = data.lastWheelEventTime!;

    if (_prevWheelRevolutions == null || _prevWheelEventTime == null) {
      _prevWheelRevolutions = revs;
      _prevWheelEventTime = time;
      return null;
    }

    // Handle UINT32 rollover.
    var deltaRevs = revs - _prevWheelRevolutions!;
    if (deltaRevs < 0) deltaRevs += 4294967296; // 2^32

    // Handle UINT16 rollover (time in 1/1024 s).
    var deltaTime = time - _prevWheelEventTime!;
    if (deltaTime < 0) deltaTime += 65536;

    _prevWheelRevolutions = revs;
    _prevWheelEventTime = time;

    if (deltaTime == 0 || deltaRevs == 0) return null;

    // distance = deltaRevs × circumference (meters)
    // time = deltaTime / 1024 (seconds)
    // speed = distance / time (m/s) → convert to km/h
    final distanceMeters = deltaRevs * _wheelCircumference;
    final timeSeconds = deltaTime / 1024.0;
    final speedMps = distanceMeters / timeSeconds;
    final speedKmh = speedMps * 3.6;

    // Sanity check.
    if (speedKmh > 150) {
      _log.fine('Speed too high ($speedKmh km/h), ignoring');
      return null;
    }

    return speedKmh;
  }

  /// Computes cadence in RPM from crank revolution data.
  ///
  /// Returns `null` on the first call or if no crank data is present.
  /// Handles UINT16 rollover for both revolutions and time.
  double? computeCadence(CscMeasurement data) {
    if (data.crankRevolutions == null || data.lastCrankEventTime == null) {
      return null;
    }

    final revs = data.crankRevolutions!;
    final time = data.lastCrankEventTime!;

    if (_prevCrankRevolutions == null || _prevCrankEventTime == null) {
      _prevCrankRevolutions = revs;
      _prevCrankEventTime = time;
      return null;
    }

    // Handle UINT16 rollover.
    var deltaRevs = revs - _prevCrankRevolutions!;
    if (deltaRevs < 0) deltaRevs += 65536;

    var deltaTime = time - _prevCrankEventTime!;
    if (deltaTime < 0) deltaTime += 65536;

    _prevCrankRevolutions = revs;
    _prevCrankEventTime = time;

    if (deltaTime == 0 || deltaRevs == 0) return null;

    // cadence = (deltaRevs / (deltaTime / 1024)) × 60
    final cadence = (deltaRevs / (deltaTime / 1024.0)) * 60.0;

    if (cadence > 250) {
      _log.fine('Cadence too high ($cadence RPM), ignoring');
      return null;
    }

    return cadence;
  }

  /// Converts computed speed/cadence into a domain [SensorReading].
  SensorReading toSensorReading({double? speedKmh, double? cadence}) {
    return SensorReading(
      timestamp: DateTime.now(),
      speed: speedKmh != null ? Speed(speedKmh) : null,
      cadence: cadence != null ? Cadence(cadence) : null,
    );
  }

  /// Resets internal state (call when reconnecting).
  void reset() {
    _prevWheelRevolutions = null;
    _prevWheelEventTime = null;
    _prevCrankRevolutions = null;
    _prevCrankEventTime = null;
  }

  CscMeasurement? _truncated() {
    _log.warning('CSC Measurement truncated');
    return null;
  }
}
