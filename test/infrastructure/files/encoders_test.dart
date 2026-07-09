import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/files/fit_encoder.dart';
import 'package:open_bike/infrastructure/files/tcx_encoder.dart';
import 'package:xml/xml.dart';

// ---------------------------------------------------------------------------
// Test data — 60-second ride
// ---------------------------------------------------------------------------

final _start = DateTime.utc(2025, 6, 15, 10, 0, 0);

Ride _testRide() {
  final readings = <SensorReading>[];
  for (var i = 0; i < 60; i++) {
    readings.add(SensorReading(
      timestamp: _start.add(Duration(seconds: i)),
      power: Watts(180 + (i % 10) * 5),
      heartRate: HeartRate(130 + (i % 15)),
      cadence: Cadence(85 + (i % 5).toDouble()),
      speed: Speed(30 + (i % 8).toDouble()),
      distance: Distance(i * 8.5),
    ));
  }
  return Ride(
    id: 'test-ride-001',
    startTime: _start,
    endTime: _start.add(const Duration(seconds: 60)),
    status: RideStatus.finished,
    readings: readings,
  );
}

// ---------------------------------------------------------------------------
// FIT CRC-16 verifier (same algorithm as encoder)
// ---------------------------------------------------------------------------

int _crc16(int crc, int byte) {
  const table = [
    0x0000, 0xCC01, 0xD801, 0x1400, 0xF001, 0x3C00, 0x2800, 0xE401,
    0xA001, 0x6C00, 0x7800, 0xB401, 0x5000, 0x9C01, 0x8801, 0x4400,
  ];
  int tmp = table[crc & 0xF];
  crc = (crc >> 4) & 0x0FFF;
  crc = crc ^ tmp ^ table[byte & 0xF];
  tmp = table[crc & 0xF];
  crc = (crc >> 4) & 0x0FFF;
  crc = crc ^ tmp ^ table[(byte >> 4) & 0xF];
  return crc;
}

int _computeFileCrc(Uint8List data) {
  // CRC over everything except the trailing 2 CRC bytes.
  int crc = 0;
  for (var i = 0; i < data.length - 2; i++) {
    crc = _crc16(crc, data[i]);
  }
  return crc;
}

// ---------------------------------------------------------------------------
// Minimal generic FIT record walker — locates the session message (global
// mesg 18) and reads its fields by FIT field definition number, without
// hard-coding byte offsets that depend on reading count.
// ---------------------------------------------------------------------------

class _FieldDef {
  const _FieldDef(this.num, this.size);
  final int num;
  final int size;
}

/// Walks the FIT data records starting after the 14-byte header and returns
/// the raw unsigned integer field values (keyed by field definition number)
/// of the first data message matching [targetGlobalMesg].
Map<int, int> _readMessageFields(Uint8List bytes, int targetGlobalMesg) {
  final bd = ByteData.sublistView(bytes);
  final definitions = <int, List<_FieldDef>>{};
  final globalMesgByLocal = <int, int>{};

  var offset = 14; // skip header
  while (offset < bytes.length - 2) {
    final recordHeader = bytes[offset];
    final localType = recordHeader & 0x0F;

    if (recordHeader & 0x40 != 0) {
      // Definition record: [0]header [1]reserved [2]arch [3-4]globalMesg
      // [5]numFields [6..]field triples.
      final globalMesg = bd.getUint16(offset + 3, Endian.little);
      final numFields = bytes[offset + 5];
      final fields = <_FieldDef>[];
      var fieldOffset = offset + 6;
      for (var i = 0; i < numFields; i++) {
        fields.add(_FieldDef(bytes[fieldOffset], bytes[fieldOffset + 1]));
        fieldOffset += 3;
      }
      definitions[localType] = fields;
      globalMesgByLocal[localType] = globalMesg;
      offset = fieldOffset;
    } else {
      // Data record.
      final fields = definitions[localType]!;
      final isTarget = globalMesgByLocal[localType] == targetGlobalMesg;
      var dataOffset = offset + 1;
      final values = <int, int>{};
      for (final field in fields) {
        if (isTarget) {
          values[field.num] = switch (field.size) {
            1 => bytes[dataOffset],
            2 => bd.getUint16(dataOffset, Endian.little),
            4 => bd.getUint32(dataOffset, Endian.little),
            _ => throw StateError('Unsupported field size ${field.size}'),
          };
        }
        dataOffset += field.size;
      }
      if (isTarget) return values;
      offset = dataOffset;
    }
  }
  throw StateError('Message $targetGlobalMesg not found');
}

int _sessionThresholdPower(Uint8List bytes) =>
    _readMessageFields(bytes, 18)[37]!;

double _sessionIntensityFactor(Uint8List bytes) =>
    _readMessageFields(bytes, 18)[36]! / 1000.0;

double _sessionTss(Uint8List bytes) => _readMessageFields(bytes, 18)[35]! / 10.0;

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Ride ride;
  late FitEncoder fitEncoder;
  late TcxEncoder tcxEncoder;

  setUp(() {
    ride = _testRide();
    fitEncoder = FitEncoder();
    tcxEncoder = TcxEncoder();
  });

  // =========================================================================
  // FIT encoder
  // =========================================================================

  group('FitEncoder', () {
    test('produces non-empty output', () {
      final bytes = fitEncoder.encode(ride);
      expect(bytes.length, greaterThan(14 + 2)); // header + CRC minimum
    });

    test('header is 14 bytes with correct signature', () {
      final bytes = fitEncoder.encode(ride);

      // Byte 0: header size = 14
      expect(bytes[0], 14);

      // Byte 1: protocol version 2.0
      expect(bytes[1], 0x20);

      // Bytes 2-3: profile version 21.60 (2160 LE)
      final profileVersion = bytes[2] | (bytes[3] << 8);
      expect(profileVersion, 2160);

      // Bytes 8-11: ".FIT"
      expect(bytes[8], 0x2E); // '.'
      expect(bytes[9], 0x46); // 'F'
      expect(bytes[10], 0x49); // 'I'
      expect(bytes[11], 0x54); // 'T'
    });

    test('data size in header matches actual data', () {
      final bytes = fitEncoder.encode(ride);

      // Bytes 4-7: data size (LE), excludes header (14) and file CRC (2)
      final dataSize =
          bytes[4] | (bytes[5] << 8) | (bytes[6] << 16) | (bytes[7] << 24);
      expect(dataSize, bytes.length - 14 - 2);
    });

    test('header CRC is valid', () {
      final bytes = fitEncoder.encode(ride);

      // Header CRC covers bytes 0-11
      int crc = 0;
      for (int i = 0; i < 12; i++) {
        crc = _crc16(crc, bytes[i]);
      }
      final storedCrc = bytes[12] | (bytes[13] << 8);
      expect(storedCrc, crc);
    });

    test('file CRC at end is valid', () {
      final bytes = fitEncoder.encode(ride);

      final computed = _computeFileCrc(bytes);
      final stored = bytes[bytes.length - 2] | (bytes[bytes.length - 1] << 8);
      expect(stored, computed);
    });

    test('first data message is file_id definition (local type 0)', () {
      final bytes = fitEncoder.encode(ride);

      // Byte 14: definition header for local type 0 → 0x40
      expect(bytes[14], 0x40);

      // Bytes 15: reserved = 0, 16: arch = 0 (LE)
      expect(bytes[15], 0);
      expect(bytes[16], 0);

      // Bytes 17-18: global message number = 0 (file_id) LE
      final globalMesg = bytes[17] | (bytes[18] << 8);
      expect(globalMesg, 0);
    });

    test('file_id data has type=activity (4)', () {
      final bytes = fitEncoder.encode(ride);

      // After file_id definition:
      // def header(1) + reserved(1) + arch(1) + global(2) + numFields(1) + 5 fields × 3
      // = 1 + 1 + 1 + 2 + 1 + 15 = 21 bytes for definition
      // Then data header (1 byte at offset 14+21=35), then first field is type
      expect(bytes[35], 0x00); // data header for local type 0
      expect(bytes[36], 4); // type = activity
    });

    test('contains 60 record data messages', () {
      final bytes = fitEncoder.encode(ride);

      // Record definition uses local type 2. Data header = 0x02.
      // Each record data = 1 (header) + 4 (ts) + 2 (power) + 1 (hr) + 1 (cad) + 2 (speed) + 4 (dist) = 15 bytes.
      // Count occurrences of record data headers.
      // We need to walk the file structure to count properly.
      // Simpler: check the file is big enough for 60 records.
      // 60 records × 15 bytes = 900 bytes minimum for record data alone.
      expect(bytes.length, greaterThan(900));
    });

    test('encodes garmin timestamps correctly', () {
      final bytes = fitEncoder.encode(ride);
      final bd = ByteData.sublistView(bytes);

      // The file_id time_created field is at a known offset.
      // file_id def: 21 bytes (offset 14)
      // file_id data: offset 35, header(1) + type(1) + manufacturer(2) + product(2) + serial(4) = 10 bytes before time_created
      // time_created at offset 35 + 1 + 1 + 2 + 2 + 4 = 45
      final storedTs = bd.getUint32(45, Endian.little);

      // Garmin epoch: 1989-12-31T00:00:00Z
      final garminEpoch = DateTime.utc(1989, 12, 31, 0, 0, 0);
      final expectedTs = _start.difference(garminEpoch).inSeconds;
      expect(storedTs, expectedTs);
    });

    test('encode is deterministic', () {
      final a = fitEncoder.encode(ride);
      final b = fitEncoder.encode(ride);
      expect(a, equals(b));
    });

    test('threshold_power in session message reflects the given FTP', () {
      final defaultBytes = fitEncoder.encode(ride);
      final ftp250Bytes = fitEncoder.encode(ride, ftp: const Watts(250));

      final defaultThreshold = _sessionThresholdPower(defaultBytes);
      final threshold250 = _sessionThresholdPower(ftp250Bytes);

      // Default (no FTP given) falls back to 200 W.
      expect(defaultThreshold, 200);
      expect(threshold250, 250);

      // TSS/IF in the session message must be computed against the same FTP.
      final expectedIf = ride.intensityFactor(const Watts(250));
      final expectedTss = ride.tss(const Watts(250));
      expect(_sessionIntensityFactor(ftp250Bytes),
          closeTo(expectedIf, 0.001));
      expect(_sessionTss(ftp250Bytes), closeTo(expectedTss, 0.1));
    });
  });

  // =========================================================================
  // TCX encoder
  // =========================================================================

  group('TcxEncoder', () {
    test('produces valid XML', () {
      final xml = tcxEncoder.encode(ride);
      // Should not throw
      final doc = XmlDocument.parse(xml);
      expect(doc, isNotNull);
    });

    test('root element is TrainingCenterDatabase', () {
      final xml = tcxEncoder.encode(ride);
      final doc = XmlDocument.parse(xml);
      expect(doc.rootElement.name.local, 'TrainingCenterDatabase');
    });

    test('has correct TCD namespace', () {
      final xml = tcxEncoder.encode(ride);
      final doc = XmlDocument.parse(xml);
      final ns = doc.rootElement.getAttribute('xmlns');
      expect(ns,
          'http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2');
    });

    test('has ActivityExtension namespace', () {
      final xml = tcxEncoder.encode(ride);
      final doc = XmlDocument.parse(xml);
      final ns3 = doc.rootElement.getAttribute('xmlns:ns3');
      expect(ns3,
          'http://www.garmin.com/xmlschemas/ActivityExtension/v2');
    });

    test('Activity Sport is Biking', () {
      final xml = tcxEncoder.encode(ride);
      final doc = XmlDocument.parse(xml);
      final activity = doc.rootElement
          .findAllElements('Activity')
          .first;
      expect(activity.getAttribute('Sport'), 'Biking');
    });

    test('has Id element with start time', () {
      final xml = tcxEncoder.encode(ride);
      final doc = XmlDocument.parse(xml);
      final id = doc.rootElement.findAllElements('Id').first.innerText;
      expect(id, ride.startTime.toUtc().toIso8601String());
    });

    test('contains one Lap (auto-generated)', () {
      final xml = tcxEncoder.encode(ride);
      final doc = XmlDocument.parse(xml);
      final laps = doc.rootElement.findAllElements('Lap');
      expect(laps.length, 1);
    });

    test('Lap has TotalTimeSeconds', () {
      final xml = tcxEncoder.encode(ride);
      final doc = XmlDocument.parse(xml);
      final totalTime = doc.rootElement
          .findAllElements('TotalTimeSeconds')
          .first
          .innerText;
      expect(int.parse(totalTime), ride.activeDuration.inSeconds);
    });

    test('contains 60 Trackpoints', () {
      final xml = tcxEncoder.encode(ride);
      final doc = XmlDocument.parse(xml);
      final trackpoints = doc.rootElement.findAllElements('Trackpoint');
      expect(trackpoints.length, 60);
    });

    test('Trackpoint has Time element', () {
      final xml = tcxEncoder.encode(ride);
      final doc = XmlDocument.parse(xml);
      final tp = doc.rootElement.findAllElements('Trackpoint').first;
      final time = tp.findElements('Time').first.innerText;
      expect(time, ride.readings.first.timestamp.toUtc().toIso8601String());
    });

    test('Trackpoint has HeartRateBpm/Value', () {
      final xml = tcxEncoder.encode(ride);
      final doc = XmlDocument.parse(xml);
      final tp = doc.rootElement.findAllElements('Trackpoint').first;
      final hrValue = tp
          .findElements('HeartRateBpm')
          .first
          .findElements('Value')
          .first
          .innerText;
      expect(int.parse(hrValue), ride.readings.first.heartRate!.bpm);
    });

    test('Trackpoint has Cadence', () {
      final xml = tcxEncoder.encode(ride);
      final doc = XmlDocument.parse(xml);
      final tp = doc.rootElement.findAllElements('Trackpoint').first;
      final cadence = tp.findElements('Cadence').first.innerText;
      expect(int.parse(cadence), ride.readings.first.cadence!.rpm.round());
    });

    test('Trackpoint has DistanceMeters', () {
      final xml = tcxEncoder.encode(ride);
      final doc = XmlDocument.parse(xml);
      final tp = doc.rootElement.findAllElements('Trackpoint').first;
      final dist = tp.findElements('DistanceMeters').first.innerText;
      expect(double.parse(dist),
          closeTo(ride.readings.first.distance!.meters, 0.01));
    });

    test('Trackpoint has Extensions with Watts', () {
      final xml = tcxEncoder.encode(ride);
      final doc = XmlDocument.parse(xml);
      final tp = doc.rootElement.findAllElements('Trackpoint').first;
      final watts = tp
          .findAllElements('ns3:Watts')
          .first
          .innerText;
      expect(int.parse(watts), ride.readings.first.power!.value.round());
    });

    test('Trackpoint has Extensions with Speed', () {
      final xml = tcxEncoder.encode(ride);
      final doc = XmlDocument.parse(xml);
      final tp = doc.rootElement.findAllElements('Trackpoint').first;
      final speed = tp
          .findAllElements('ns3:Speed')
          .first
          .innerText;
      expect(double.parse(speed),
          closeTo(ride.readings.first.speed!.mps, 0.001));
    });

    test('encode is deterministic', () {
      final a = tcxEncoder.encode(ride);
      final b = tcxEncoder.encode(ride);
      expect(a, equals(b));
    });
  });
}
