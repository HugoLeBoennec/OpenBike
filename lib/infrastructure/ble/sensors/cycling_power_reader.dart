import 'dart:typed_data';

import 'package:logging/logging.dart';

import '../../../core/domain/entities/sensor_reading.dart';
import '../../../core/domain/value_objects/value_objects.dart';

final _log = Logger('CyclingPowerReader');

/// Parsed Cycling Power Measurement data.
class CyclingPowerMeasurement {
  const CyclingPowerMeasurement({
    required this.instantaneousPower,
    this.pedalPowerBalance,
    this.accumulatedTorque,
    this.wheelRevolutions,
    this.lastWheelEventTime,
    this.crankRevolutions,
    this.lastCrankEventTime,
  });

  /// Instantaneous power in watts (SINT16, always present).
  final int instantaneousPower;

  /// Pedal power balance in % (resolution 0.5).
  final double? pedalPowerBalance;

  /// Accumulated torque in Nm (resolution 1/32).
  final double? accumulatedTorque;

  /// Cumulative wheel revolutions (UINT32).
  final int? wheelRevolutions;

  /// Last wheel event time in 1/2048 s (UINT16).
  final int? lastWheelEventTime;

  /// Cumulative crank revolutions (UINT16).
  final int? crankRevolutions;

  /// Last crank event time in 1/1024 s (UINT16).
  final int? lastCrankEventTime;
}

/// Parses the Cycling Power Measurement characteristic (0x2A63) and
/// computes cadence from successive crank revolution data.
///
/// Characteristic layout:
/// - Bytes 0–1: Flags (UINT16, little-endian)
///   - Bit 0:  Pedal Power Balance present
///   - Bit 1:  Pedal Power Balance reference (0=unknown, 1=left)
///   - Bit 2:  Accumulated Torque present
///   - Bit 3:  Accumulated Torque source (0=wheel, 1=crank)
///   - Bit 4:  Wheel Revolution Data present
///   - Bit 5:  Crank Revolution Data present
///   - Bits 6–15: other fields (extreme force/torque/angles/etc.)
/// - Bytes 2–3: Instantaneous Power (SINT16, always present)
/// - Remaining: optional fields in flag order
class CyclingPowerReader {
  CyclingPowerReader();

  // State for cadence calculation from crank data.
  int? _prevCrankRevolutions;
  int? _prevCrankEventTime;

  /// Parses raw bytes from a CPS Measurement notification.
  CyclingPowerMeasurement? parse(List<int> raw) {
    if (raw.length < 4) {
      _log.warning('CPS Measurement too short (${raw.length} bytes)');
      return null;
    }

    final bytes = ByteData.sublistView(Uint8List.fromList(raw));
    final flags = bytes.getUint16(0, Endian.little);
    var offset = 2;

    // ------------------------------------------------------------------
    // Instantaneous Power — SINT16, always present
    // ------------------------------------------------------------------
    final instantaneousPower = bytes.getInt16(offset, Endian.little);
    offset += 2;

    // ------------------------------------------------------------------
    // Bit 0: Pedal Power Balance — UINT8, resolution 0.5%
    // ------------------------------------------------------------------
    double? pedalPowerBalance;
    if (flags & 0x0001 != 0) {
      if (offset + 1 > raw.length) return _truncated();
      pedalPowerBalance = raw[offset] / 2.0;
      offset += 1;
    }

    // ------------------------------------------------------------------
    // Bit 2: Accumulated Torque — UINT16, resolution 1/32 Nm
    // ------------------------------------------------------------------
    double? accumulatedTorque;
    if (flags & 0x0004 != 0) {
      if (offset + 2 > raw.length) return _truncated();
      accumulatedTorque = bytes.getUint16(offset, Endian.little) / 32.0;
      offset += 2;
    }

    // ------------------------------------------------------------------
    // Bit 4: Wheel Revolution Data — UINT32 revolutions + UINT16 time
    // ------------------------------------------------------------------
    int? wheelRevolutions;
    int? lastWheelEventTime;
    if (flags & 0x0010 != 0) {
      if (offset + 6 > raw.length) return _truncated();
      wheelRevolutions = bytes.getUint32(offset, Endian.little);
      lastWheelEventTime = bytes.getUint16(offset + 4, Endian.little);
      offset += 6;
    }

    // ------------------------------------------------------------------
    // Bit 5: Crank Revolution Data — UINT16 revolutions + UINT16 time
    // ------------------------------------------------------------------
    int? crankRevolutions;
    int? lastCrankEventTime;
    if (flags & 0x0020 != 0) {
      if (offset + 4 > raw.length) return _truncated();
      crankRevolutions = bytes.getUint16(offset, Endian.little);
      lastCrankEventTime = bytes.getUint16(offset + 2, Endian.little);
      offset += 4;
    }

    // Skip remaining optional fields (extreme force/torque/angles) —
    // not commonly used by indoor cycling power meters.

    return CyclingPowerMeasurement(
      instantaneousPower: instantaneousPower,
      pedalPowerBalance: pedalPowerBalance,
      accumulatedTorque: accumulatedTorque,
      wheelRevolutions: wheelRevolutions,
      lastWheelEventTime: lastWheelEventTime,
      crankRevolutions: crankRevolutions,
      lastCrankEventTime: lastCrankEventTime,
    );
  }

  /// Computes cadence in RPM from crank revolution data.
  ///
  /// Uses the delta between the current and previous notification.
  /// Returns `null` on the first call or if no crank data is present.
  ///
  /// Handles UINT16 rollover for both revolutions and time.
  double? computeCadence(CyclingPowerMeasurement data) {
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

    // Handle UINT16 rollover (max 65535).
    var deltaRevs = revs - _prevCrankRevolutions!;
    if (deltaRevs < 0) deltaRevs += 65536;

    // Time is in 1/1024 s units. Handle UINT16 rollover.
    var deltaTime = time - _prevCrankEventTime!;
    if (deltaTime < 0) deltaTime += 65536;

    _prevCrankRevolutions = revs;
    _prevCrankEventTime = time;

    if (deltaTime == 0 || deltaRevs == 0) return null;

    // cadence = (deltaRevs / (deltaTime / 1024)) × 60
    final cadence = (deltaRevs / (deltaTime / 1024.0)) * 60.0;

    // Sanity check: reject unreasonable cadence.
    if (cadence > 250) {
      _log.fine('Cadence too high ($cadence RPM), ignoring');
      return null;
    }

    return cadence;
  }

  /// Converts a parsed measurement + computed cadence into a [SensorReading].
  SensorReading toSensorReading(
    CyclingPowerMeasurement data, {
    double? cadence,
  }) {
    return SensorReading(
      timestamp: DateTime.now(),
      power: Watts(data.instantaneousPower.toDouble()),
      cadence: cadence != null ? Cadence(cadence) : null,
    );
  }

  /// Resets internal state (call when reconnecting to a device).
  void reset() {
    _prevCrankRevolutions = null;
    _prevCrankEventTime = null;
  }

  CyclingPowerMeasurement? _truncated() {
    _log.warning('CPS Measurement truncated');
    return null;
  }
}
