import 'dart:typed_data';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/value_objects/value_objects.dart';

/// Encodes a [Ride] into the Garmin FIT binary format.
///
/// Implements a minimal but conformant FIT file for indoor cycling activities:
/// file_id → event(start) → record × N → lap → session → activity → event(stop).
///
/// All numeric values are little-endian. Timestamps use Garmin epoch
/// (seconds since 1989-12-31T00:00:00Z). CRC-16 appended at end of file.
class FitEncoder {
  // ---------------------------------------------------------------------------
  // Garmin epoch
  // ---------------------------------------------------------------------------

  static final DateTime _garminEpoch = DateTime.utc(1989, 12, 31, 0, 0, 0);

  // ---------------------------------------------------------------------------
  // CRC-16 nibble table (FIT SDK)
  // ---------------------------------------------------------------------------

  static const List<int> _crcTable = [
    0x0000, 0xCC01, 0xD801, 0x1400, 0xF001, 0x3C00, 0x2800, 0xE401,
    0xA001, 0x6C00, 0x7800, 0xB401, 0x5000, 0x9C01, 0x8801, 0x4400,
  ];

  // ---------------------------------------------------------------------------
  // Global message numbers
  // ---------------------------------------------------------------------------

  static const int _mesgFileId = 0;
  static const int _mesgSession = 18;
  static const int _mesgLap = 19;
  static const int _mesgRecord = 20;
  static const int _mesgEvent = 21;
  static const int _mesgActivity = 34;

  // ---------------------------------------------------------------------------
  // FIT base types
  // ---------------------------------------------------------------------------

  static const int _typeEnum = 0x00;
  static const int _typeUint8 = 0x02;
  // ignore: unused_field
  static const int _typeSint16 = 0x83;
  static const int _typeUint16 = 0x84;
  static const int _typeUint32 = 0x86;
  static const int _typeUint32z = 0x8C;

  // ---------------------------------------------------------------------------
  // Invalid sentinel values
  // ---------------------------------------------------------------------------

  static const int _invalidUint8 = 0xFF;
  static const int _invalidUint16 = 0xFFFF;
  static const int _invalidUint32 = 0xFFFFFFFF;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Encodes [ride] into a conformant FIT binary file.
  ///
  /// [ftp] is used to compute threshold_power / TSS / IF in the session
  /// message; falls back to 200 W when not provided.
  Uint8List encode(Ride ride, {Watts? ftp}) {
    final data = BytesBuilder();

    final startTs = _garminTs(ride.startTime);
    final endTime = ride.endTime ?? ride.startTime.add(ride.duration);
    final endTs = _garminTs(endTime);
    final serial = ride.id.hashCode & 0xFFFFFFFF;

    // 1. file_id (local type 0)
    _defineFileId(data);
    _writeFileId(data, startTs, serial);

    // 2. event start (local type 1)
    _defineEvent(data);
    _writeEvent(data, startTs, _eventTypeStart);

    // 3. records (local type 2)
    _defineRecord(data);
    for (final reading in ride.readings) {
      _writeRecord(data, reading);
    }

    // 4. lap (local type 3)
    _defineLap(data);
    _writeLap(data, ride, startTs, endTs);

    // 5. session (local type 4)
    _defineSession(data);
    _writeSession(data, ride, startTs, endTs, ftp: ftp);

    // 6. activity (local type 5)
    _defineActivity(data);
    _writeActivity(data, ride, endTs);

    // 7. event stop (reuse local type 1 — same definition)
    _writeEvent(data, endTs, _eventTypeStopAll);

    // Assemble: header + data + CRC
    final dataBytes = data.toBytes();
    final file = BytesBuilder();
    _writeHeader(file, dataBytes.length);
    file.add(dataBytes);

    // CRC over entire file (header + data)
    final allBytes = file.toBytes();
    int crc = 0;
    for (final b in allBytes) {
      crc = _crc16(crc, b);
    }

    final result = BytesBuilder();
    result.add(allBytes);
    result.addByte(crc & 0xFF);
    result.addByte((crc >> 8) & 0xFF);

    return result.toBytes();
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  void _writeHeader(BytesBuilder b, int dataSize) {
    final hdr = ByteData(14);
    hdr.setUint8(0, 14); // header size
    hdr.setUint8(1, 0x20); // protocol version 2.0
    hdr.setUint16(2, 2160, Endian.little); // profile version 21.60
    hdr.setUint32(4, dataSize, Endian.little);
    hdr.setUint8(8, 0x2E); // '.'
    hdr.setUint8(9, 0x46); // 'F'
    hdr.setUint8(10, 0x49); // 'I'
    hdr.setUint8(11, 0x54); // 'T'
    // Header CRC (first 12 bytes)
    int crc = 0;
    for (int i = 0; i < 12; i++) {
      crc = _crc16(crc, hdr.getUint8(i));
    }
    hdr.setUint16(12, crc, Endian.little);
    b.add(hdr.buffer.asUint8List());
  }

  // ---------------------------------------------------------------------------
  // file_id (local 0, global 0)
  // ---------------------------------------------------------------------------

  void _defineFileId(BytesBuilder b) {
    _writeDef(b, 0, _mesgFileId, [
      [0, 1, _typeEnum], // type
      [1, 2, _typeUint16], // manufacturer
      [2, 2, _typeUint16], // product
      [3, 4, _typeUint32z], // serial_number
      [4, 4, _typeUint32], // time_created
    ]);
  }

  void _writeFileId(BytesBuilder b, int ts, int serial) {
    _dataHdr(b, 0);
    _u8(b, 4); // type = activity
    _u16(b, 255); // manufacturer = development
    _u16(b, 0); // product
    _u32(b, serial);
    _u32(b, ts);
  }

  // ---------------------------------------------------------------------------
  // event (local 1, global 21)
  // ---------------------------------------------------------------------------

  static const int _eventTypeStart = 0;
  static const int _eventTypeStopAll = 9;

  void _defineEvent(BytesBuilder b) {
    _writeDef(b, 1, _mesgEvent, [
      [253, 4, _typeUint32], // timestamp
      [0, 1, _typeEnum], // event
      [1, 1, _typeEnum], // event_type
    ]);
  }

  void _writeEvent(BytesBuilder b, int ts, int eventType) {
    _dataHdr(b, 1);
    _u32(b, ts);
    _u8(b, 0); // event = timer
    _u8(b, eventType);
  }

  // ---------------------------------------------------------------------------
  // record (local 2, global 20)
  // ---------------------------------------------------------------------------

  void _defineRecord(BytesBuilder b) {
    _writeDef(b, 2, _mesgRecord, [
      [253, 4, _typeUint32], // timestamp
      [7, 2, _typeUint16], // power
      [3, 1, _typeUint8], // heart_rate
      [4, 1, _typeUint8], // cadence
      [6, 2, _typeUint16], // speed (m/s × 1000)
      [5, 4, _typeUint32], // distance (m × 100)
    ]);
  }

  void _writeRecord(BytesBuilder b, SensorReading r) {
    _dataHdr(b, 2);
    _u32(b, _garminTs(r.timestamp));

    _u16(b, r.power != null ? r.power!.value.round() : _invalidUint16);
    _u8(b, r.heartRate != null ? r.heartRate!.bpm : _invalidUint8);
    _u8(b, r.cadence != null ? r.cadence!.rpm.round() : _invalidUint8);
    _u16(b, r.speed != null
        ? (r.speed!.mps * 1000).round()
        : _invalidUint16);
    _u32(b, r.distance != null
        ? (r.distance!.meters * 100).round()
        : _invalidUint32);
  }

  // ---------------------------------------------------------------------------
  // lap (local 3, global 19)
  // ---------------------------------------------------------------------------

  void _defineLap(BytesBuilder b) {
    _writeDef(b, 3, _mesgLap, [
      [253, 4, _typeUint32], // timestamp
      [2, 4, _typeUint32], // start_time
      [7, 4, _typeUint32], // total_elapsed_time (s × 1000)
      [8, 4, _typeUint32], // total_timer_time (s × 1000)
      [19, 2, _typeUint16], // avg_power
      [20, 2, _typeUint16], // max_power
      [15, 1, _typeUint8], // avg_heart_rate
      [17, 1, _typeUint8], // avg_cadence
      [9, 4, _typeUint32], // total_distance (m × 100)
    ]);
  }

  void _writeLap(BytesBuilder b, Ride ride, int startTs, int endTs) {
    _dataHdr(b, 3);
    _u32(b, endTs);
    _u32(b, startTs);
    _u32(b, ride.duration.inMilliseconds.clamp(0, 0xFFFFFFFF));
    _u32(b, ride.activeDuration.inMilliseconds.clamp(0, 0xFFFFFFFF));
    _u16(b, ride.averagePower.value.round());
    _u16(b, ride.maxPower.value.round());
    _u8(b, ride.averageHr.bpm);
    _u8(b, ride.averageCadence.rpm.round());
    _u32(b, (ride.totalDistance.meters * 100).round());
  }

  // ---------------------------------------------------------------------------
  // session (local 4, global 18)
  // ---------------------------------------------------------------------------

  void _defineSession(BytesBuilder b) {
    _writeDef(b, 4, _mesgSession, [
      [253, 4, _typeUint32], // timestamp
      [2, 4, _typeUint32], // start_time
      [7, 4, _typeUint32], // total_elapsed_time (s × 1000)
      [8, 4, _typeUint32], // total_timer_time (s × 1000)
      [5, 1, _typeEnum], // sport
      [6, 1, _typeEnum], // sub_sport
      [20, 2, _typeUint16], // avg_power
      [21, 2, _typeUint16], // max_power
      [16, 1, _typeUint8], // avg_heart_rate
      [18, 1, _typeUint8], // avg_cadence
      [9, 4, _typeUint32], // total_distance (m × 100)
      [34, 2, _typeUint16], // normalized_power
      [35, 2, _typeUint16], // training_stress_score (× 10)
      [36, 2, _typeUint16], // intensity_factor (× 1000)
      [37, 2, _typeUint16], // threshold_power
    ]);
  }

  void _writeSession(
    BytesBuilder b,
    Ride ride,
    int startTs,
    int endTs, {
    Watts? ftp,
  }) {
    final thresholdPower = ftp ?? const Watts(200);

    _dataHdr(b, 4);
    _u32(b, endTs);
    _u32(b, startTs);
    _u32(b, ride.duration.inMilliseconds.clamp(0, 0xFFFFFFFF));
    _u32(b, ride.activeDuration.inMilliseconds.clamp(0, 0xFFFFFFFF));
    _u8(b, 2); // sport = cycling
    _u8(b, 6); // sub_sport = indoor_cycling
    _u16(b, ride.averagePower.value.round());
    _u16(b, ride.maxPower.value.round());
    _u8(b, ride.averageHr.bpm);
    _u8(b, ride.averageCadence.rpm.round());
    _u32(b, (ride.totalDistance.meters * 100).round());
    _u16(b, ride.normalizedPower.value.round());
    _u16(b, (ride.tss(thresholdPower) * 10).round());
    _u16(b, (ride.intensityFactor(thresholdPower) * 1000).round());
    _u16(b, thresholdPower.value.round());
  }

  // ---------------------------------------------------------------------------
  // activity (local 5, global 34)
  // ---------------------------------------------------------------------------

  void _defineActivity(BytesBuilder b) {
    _writeDef(b, 5, _mesgActivity, [
      [253, 4, _typeUint32], // timestamp
      [0, 4, _typeUint32], // total_timer_time (s × 1000)
      [1, 2, _typeUint16], // num_sessions
      [2, 1, _typeEnum], // type
    ]);
  }

  void _writeActivity(BytesBuilder b, Ride ride, int endTs) {
    _dataHdr(b, 5);
    _u32(b, endTs);
    _u32(b, ride.activeDuration.inMilliseconds.clamp(0, 0xFFFFFFFF));
    _u16(b, 1); // num_sessions
    _u8(b, 0); // type = manual
  }

  // ---------------------------------------------------------------------------
  // Low-level helpers
  // ---------------------------------------------------------------------------

  int _garminTs(DateTime dt) =>
      dt.toUtc().difference(_garminEpoch).inSeconds;

  int _crc16(int crc, int byte) {
    int tmp = _crcTable[crc & 0xF];
    crc = (crc >> 4) & 0x0FFF;
    crc = crc ^ tmp ^ _crcTable[byte & 0xF];
    tmp = _crcTable[crc & 0xF];
    crc = (crc >> 4) & 0x0FFF;
    crc = crc ^ tmp ^ _crcTable[(byte >> 4) & 0xF];
    return crc;
  }

  void _writeDef(
    BytesBuilder b,
    int localType,
    int globalMesgNum,
    List<List<int>> fields,
  ) {
    b.addByte(0x40 | (localType & 0x0F)); // definition record header
    b.addByte(0); // reserved
    b.addByte(0); // architecture: little-endian
    _u16(b, globalMesgNum);
    b.addByte(fields.length);
    for (final f in fields) {
      b.addByte(f[0]); // field def num
      b.addByte(f[1]); // size in bytes
      b.addByte(f[2]); // base type
    }
  }

  void _dataHdr(BytesBuilder b, int localType) {
    b.addByte(localType & 0x0F);
  }

  void _u8(BytesBuilder b, int v) => b.addByte(v & 0xFF);

  void _u16(BytesBuilder b, int v) {
    b.addByte(v & 0xFF);
    b.addByte((v >> 8) & 0xFF);
  }

  void _u32(BytesBuilder b, int v) {
    b.addByte(v & 0xFF);
    b.addByte((v >> 8) & 0xFF);
    b.addByte((v >> 16) & 0xFF);
    b.addByte((v >> 24) & 0xFF);
  }
}
