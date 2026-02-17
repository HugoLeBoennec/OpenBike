import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/domain/entities/user_profile.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';

void main() {
  group('UserProfile — copyWith for settings edits', () {
    const profile = UserProfile(
      ftp: Watts(250),
      weight: 72.5,
      height: 180,
      restingHr: HeartRate(55),
      maxHr: HeartRate(195),
      name: 'Test User',
    );

    test('copyWith ftp', () {
      final updated = profile.copyWith(ftp: const Watts(280));
      expect(updated.ftp.value, 280);
      expect(updated.weight, 72.5);
      expect(updated.name, 'Test User');
    });

    test('copyWith weight', () {
      final updated = profile.copyWith(weight: 68.0);
      expect(updated.weight, 68.0);
      expect(updated.ftp.value, 250);
    });

    test('copyWith height', () {
      final updated = profile.copyWith(height: 175);
      expect(updated.height, 175);
    });

    test('copyWith restingHr', () {
      final updated = profile.copyWith(restingHr: const HeartRate(50));
      expect(updated.restingHr.bpm, 50);
      expect(updated.maxHr.bpm, 195);
    });

    test('copyWith maxHr', () {
      final updated = profile.copyWith(maxHr: const HeartRate(200));
      expect(updated.maxHr.bpm, 200);
      expect(updated.restingHr.bpm, 55);
    });

    test('all fields preserved on single field update', () {
      final updated = profile.copyWith(name: 'New Name');
      expect(updated.ftp.value, 250);
      expect(updated.weight, 72.5);
      expect(updated.height, 180);
      expect(updated.restingHr.bpm, 55);
      expect(updated.maxHr.bpm, 195);
      expect(updated.name, 'New Name');
    });
  });
}
