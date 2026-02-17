import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/infrastructure/ant/ant_fec_control.dart';

void main() {
  group('AntFecControl — basicResistance (page 48)', () {
    test('0% resistance', () {
      final payload = AntFecControl.basicResistance(0);
      expect(payload.length, 8);
      expect(payload[0], 48); // page number
      expect(payload[7], 0); // 0 * 2 = 0
    });

    test('50% resistance', () {
      final payload = AntFecControl.basicResistance(50);
      expect(payload[0], 48);
      expect(payload[7], 100); // 50 * 2
    });

    test('100% resistance', () {
      final payload = AntFecControl.basicResistance(100);
      expect(payload[7], 200); // 100 * 2
    });

    test('clamps above 100%', () {
      final payload = AntFecControl.basicResistance(150);
      expect(payload[7], 200); // clamped to 200
    });

    test('clamps below 0%', () {
      final payload = AntFecControl.basicResistance(-10);
      expect(payload[7], 0);
    });

    test('reserved bytes are 0xFF', () {
      final payload = AntFecControl.basicResistance(50);
      for (int i = 1; i <= 6; i++) {
        expect(payload[i], 0xFF, reason: 'byte $i should be 0xFF');
      }
    });
  });

  group('AntFecControl — targetPower (page 49)', () {
    test('200W target', () {
      final payload = AntFecControl.targetPower(200);
      expect(payload.length, 8);
      expect(payload[0], 49); // page number
      // 200 * 4 = 800 = 0x0320
      expect(payload[6], 0x20); // low byte
      expect(payload[7], 0x03); // high byte
    });

    test('0W target', () {
      final payload = AntFecControl.targetPower(0);
      expect(payload[6], 0);
      expect(payload[7], 0);
    });

    test('4000W target', () {
      final payload = AntFecControl.targetPower(4000);
      // 4000 * 4 = 16000 = 0x3E80
      expect(payload[6], 0x80);
      expect(payload[7], 0x3E);
    });

    test('clamps above 4000W', () {
      final payload = AntFecControl.targetPower(5000);
      // clamped to 16000 = 0x3E80
      expect(payload[6], 0x80);
      expect(payload[7], 0x3E);
    });

    test('reserved bytes are 0xFF', () {
      final payload = AntFecControl.targetPower(200);
      for (int i = 1; i <= 5; i++) {
        expect(payload[i], 0xFF, reason: 'byte $i should be 0xFF');
      }
    });
  });

  group('AntFecControl — windResistance (page 50)', () {
    test('zero wind, typical crr and cda', () {
      final payload = AntFecControl.windResistance(0, 0.004, 0.5);
      expect(payload.length, 8);
      expect(payload[0], 50); // page number
      expect(payload[5], 127); // 0 + 127
      expect(payload[6], 80); // 0.004 / 0.00005 = 80
      expect(payload[7], 50); // 0.5 / 0.01 = 50
    });

    test('headwind -20 km/h', () {
      final payload = AntFecControl.windResistance(-20, 0.005, 0.4);
      expect(payload[5], 107); // -20 + 127
    });

    test('tailwind +30 km/h', () {
      final payload = AntFecControl.windResistance(30, 0.005, 0.4);
      expect(payload[5], 157); // 30 + 127
    });

    test('reserved bytes are 0xFF', () {
      final payload = AntFecControl.windResistance(0, 0.004, 0.5);
      for (int i = 1; i <= 4; i++) {
        expect(payload[i], 0xFF, reason: 'byte $i should be 0xFF');
      }
    });
  });

  group('AntFecControl — trackResistance (page 51)', () {
    test('0% grade, typical crr', () {
      final payload = AntFecControl.trackResistance(0, 0.004);
      expect(payload.length, 8);
      expect(payload[0], 51); // page number
      // (0 + 200) / 0.01 = 20000 = 0x4E20
      expect(payload[5], 0x20); // low byte
      expect(payload[6], 0x4E); // high byte
      expect(payload[7], 80); // 0.004 / 0.00005 = 80
    });

    test('+5% grade', () {
      final payload = AntFecControl.trackResistance(5, 0.004);
      // (5 + 200) / 0.01 = 20500 = 0x5014
      expect(payload[5], 0x14);
      expect(payload[6], 0x50);
    });

    test('-5% grade', () {
      final payload = AntFecControl.trackResistance(-5, 0.004);
      // (-5 + 200) / 0.01 = 19500 = 0x4C2C
      expect(payload[5], 0x2C);
      expect(payload[6], 0x4C);
    });

    test('reserved bytes are 0xFF', () {
      final payload = AntFecControl.trackResistance(0, 0.004);
      for (int i = 1; i <= 4; i++) {
        expect(payload[i], 0xFF, reason: 'byte $i should be 0xFF');
      }
    });
  });
}
