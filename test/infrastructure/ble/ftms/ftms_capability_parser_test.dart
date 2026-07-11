import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/infrastructure/ble/ftms/ftms_control_client.dart';

void main() {
  // -------------------------------------------------------------------------
  // FtmsFeatures — parsing 0x2ACC
  // -------------------------------------------------------------------------

  group('FtmsFeatures', () {
    // KICKR Core v2 realistic example
    // Machine features: 0x00004086
    //   bit 1 → cadence, bit 2 → total distance, bit 7 → resistance level,
    //   bit 14 → power measurement
    // Target features:  0x0000200C
    //   bit 2 → target resistance, bit 3 → target power,
    //   bit 13 → indoor bike simulation
    final kickrCoreBytes = [
      0x86, 0x40, 0x00, 0x00, // machine features LE
      0x0C, 0x20, 0x00, 0x00, // target features LE
    ];

    FtmsFeatures parseKickr() {
      final bd = ByteData.sublistView(Uint8List.fromList(kickrCoreBytes));
      return FtmsFeatures(
        machineFeatures: bd.getUint32(0, Endian.little),
        targetFeatures: bd.getUint32(4, Endian.little),
      );
    }

    test('KICKR Core v2 — machine feature bits', () {
      final f = parseKickr();
      expect(f.supportsCadence, isTrue); // bit 1
      expect(f.supportsTotalDistance, isTrue); // bit 2
      expect(f.supportsResistanceLevel, isTrue); // bit 7
      expect(f.supportsPower, isTrue); // bit 14
      expect(f.supportsHeartRate, isFalse); // bit 15 not set
    });

    test('KICKR Core v2 — target setting feature bits', () {
      final f = parseKickr();
      expect(f.supportsTargetResistance, isTrue); // bit 2
      expect(f.supportsTargetPower, isTrue); // bit 3
      expect(f.supportsSimulationParams, isTrue); // bit 13
      expect(f.supportsSpinDown, isFalse); // bit 14 not set
    });

    test('all-zero payload → no capabilities reported', () {
      final f = FtmsFeatures(machineFeatures: 0, targetFeatures: 0);
      expect(f.supportsTargetPower, isFalse);
      expect(f.supportsTargetResistance, isFalse);
      expect(f.supportsSimulationParams, isFalse);
      expect(f.supportsSpinDown, isFalse);
      expect(f.supportsCadence, isFalse);
      expect(f.supportsPower, isFalse);
    });

    test('all-bits-set payload → all capabilities reported', () {
      final f = FtmsFeatures(
        machineFeatures: 0xFFFFFFFF,
        targetFeatures: 0xFFFFFFFF,
      );
      expect(f.supportsTargetPower, isTrue);
      expect(f.supportsTargetResistance, isTrue);
      expect(f.supportsSimulationParams, isTrue);
      expect(f.supportsSpinDown, isTrue);
    });

    test('trainer with only ERG support', () {
      // Only bit 3 in target features (target power), nothing else.
      final f = FtmsFeatures(machineFeatures: 0, targetFeatures: 0x00000008);
      expect(f.supportsTargetPower, isTrue);
      expect(f.supportsTargetResistance, isFalse);
      expect(f.supportsSimulationParams, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // PowerRange — parsing 0x2AD8
  // -------------------------------------------------------------------------

  group('PowerRange', () {
    test('default range clamps correctly', () {
      const r = PowerRange.defaultRange;
      expect(r.clamp(-100), 0);
      expect(r.clamp(0), 0);
      expect(r.clamp(250), 250);
      expect(r.clamp(4000), 4000);
      expect(r.clamp(9999), 4000);
    });

    test('fromBytes: min=0W max=2000W increment=1W', () {
      // SINT16 LE: 0x0000=0, 0x07D0=2000, UINT16 LE: 0x0001=1
      final raw = [0x00, 0x00, 0xD0, 0x07, 0x01, 0x00];
      final r = PowerRange.fromBytes(raw);
      expect(r.minWatts, 0);
      expect(r.maxWatts, 2000);
      expect(r.incrementWatts, 1);
    });

    test('fromBytes: min=50W max=1500W increment=5W', () {
      final bd = ByteData(6);
      bd.setInt16(0, 50, Endian.little);
      bd.setInt16(2, 1500, Endian.little);
      bd.setUint16(4, 5, Endian.little);
      final r = PowerRange.fromBytes(bd.buffer.asUint8List());
      expect(r.minWatts, 50);
      expect(r.maxWatts, 1500);
      expect(r.incrementWatts, 5);
      expect(r.clamp(10), 50); // below min → clamped to min
      expect(r.clamp(2000), 1500); // above max → clamped to max
    });

    test('fromBytes: short payload → default range', () {
      final r = PowerRange.fromBytes([0x00, 0x00]); // only 2 bytes
      expect(r.minWatts, PowerRange.defaultRange.minWatts);
      expect(r.maxWatts, PowerRange.defaultRange.maxWatts);
    });
  });

  // -------------------------------------------------------------------------
  // ResistanceLevelRange — parsing 0x2AD6
  // -------------------------------------------------------------------------

  group('ResistanceLevelRange', () {
    test('default range clamps correctly', () {
      const r = ResistanceLevelRange.defaultRange;
      expect(r.clamp(-1), 0.0);
      expect(r.clamp(10), 10.0);
      expect(r.clamp(30), 25.5); // exceeds max
    });

    test('fromBytes: min=0.0 max=10.0 increment=0.5', () {
      // SINT16 × 0.1: 0 = 0×0.1, 100 = 10.0, UINT16: 5 = 0.5
      final bd = ByteData(6);
      bd.setInt16(0, 0, Endian.little);
      bd.setInt16(2, 100, Endian.little);
      bd.setUint16(4, 5, Endian.little);
      final r = ResistanceLevelRange.fromBytes(bd.buffer.asUint8List());
      expect(r.min, closeTo(0.0, 0.001));
      expect(r.max, closeTo(10.0, 0.001));
      expect(r.increment, closeTo(0.5, 0.001));
    });

    test('fromBytes: short payload → default range', () {
      final r = ResistanceLevelRange.fromBytes([]);
      expect(r.max, ResistanceLevelRange.defaultRange.max);
    });
  });

  // -------------------------------------------------------------------------
  // Gradient scaling (Zwift-style)
  // -------------------------------------------------------------------------

  group('Gradient scaling', () {
    double applyDifficulty(double gradePercent, double difficulty) {
      var scaled = gradePercent * difficulty;
      if (scaled < 0) scaled *= 0.5;
      return scaled;
    }

    test('10% grade at 0.5 difficulty → 5.0%', () {
      expect(applyDifficulty(10.0, 0.5), closeTo(5.0, 0.001));
    });

    test('10% grade at 1.0 difficulty → 10.0% (full)', () {
      expect(applyDifficulty(10.0, 1.0), closeTo(10.0, 0.001));
    });

    test('10% grade at 0.0 difficulty → 0.0% (flat)', () {
      expect(applyDifficulty(10.0, 0.0), closeTo(0.0, 0.001));
    });

    test('-10% grade at 0.5 difficulty → -2.5% (half downhill)', () {
      // negative × 0.5 difficulty = -5.0, then × 0.5 downhill factor = -2.5
      expect(applyDifficulty(-10.0, 0.5), closeTo(-2.5, 0.001));
    });

    test('-10% grade at 1.0 difficulty → -5.0% (full downhill still halved)',
        () {
      expect(applyDifficulty(-10.0, 1.0), closeTo(-5.0, 0.001));
    });

    test('0% grade always stays 0% regardless of difficulty', () {
      for (final d in [0.0, 0.5, 1.0]) {
        expect(applyDifficulty(0.0, d), 0.0);
      }
    });
  });
}
