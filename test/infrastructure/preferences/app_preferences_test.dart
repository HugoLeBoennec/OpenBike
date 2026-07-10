import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_bike/core/domain/entities/paired_devices.dart';
import 'package:open_bike/core/domain/entities/trainer_device.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppPreferences> makePrefs([Map<String, Object> initial = const {}]) async {
    SharedPreferences.setMockInitialValues(initial);
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences(prefs);
  }

  group('AppPreferences — pairedDevices', () {
    test('defaults to empty when nothing saved', () async {
      final appPrefs = await makePrefs();
      expect(appPrefs.pairedDevices.byRole, isEmpty);
    });

    test('round-trips a role assignment through setPairedDevices', () async {
      final appPrefs = await makePrefs();

      const device = PairedDevice(
        deviceId: 'AA:BB:CC',
        name: 'Wahoo TICKR',
        protocol: DeviceProtocol.bleHr,
      );
      final updated =
          appPrefs.pairedDevices.withRole(SensorRole.heartRate, device);
      await appPrefs.setPairedDevices(updated);

      // Simulate app restart: read from a fresh AppPreferences wrapping the
      // same (mocked) SharedPreferences backing store.
      final reloaded = AppPreferences(await SharedPreferences.getInstance());
      final result = reloaded.pairedDevices.forRole(SensorRole.heartRate);

      expect(result, device);
    });

    test('withoutRole clears a single role and persists the change', () async {
      final appPrefs = await makePrefs();

      const trainer = PairedDevice(
        deviceId: 'trainer-1',
        name: 'Kickr',
        protocol: DeviceProtocol.bleFtms,
      );
      const hrm = PairedDevice(
        deviceId: 'hrm-1',
        name: 'TICKR',
        protocol: DeviceProtocol.bleHr,
      );

      var devices = appPrefs.pairedDevices
          .withRole(SensorRole.trainer, trainer)
          .withRole(SensorRole.heartRate, hrm);
      await appPrefs.setPairedDevices(devices);

      devices = appPrefs.pairedDevices.withoutRole(SensorRole.heartRate);
      await appPrefs.setPairedDevices(devices);

      final reloaded = AppPreferences(await SharedPreferences.getInstance());
      expect(reloaded.pairedDevices.forRole(SensorRole.heartRate), isNull);
      expect(reloaded.pairedDevices.forRole(SensorRole.trainer), trainer);
    });

    test('migrates legacy flat saved_device_ids to a trainer-role pairing',
        () async {
      final appPrefs = await makePrefs({
        'saved_device_ids': ['legacy-trainer-id'],
      });

      final migrated = appPrefs.pairedDevices;

      expect(migrated.forRole(SensorRole.trainer)?.deviceId,
          'legacy-trainer-id');
    });

    test('legacy migration yields empty PairedDevices when nothing saved',
        () async {
      final appPrefs = await makePrefs({'saved_device_ids': <String>[]});
      expect(appPrefs.pairedDevices.byRole, isEmpty);
    });

    test('roleForDevice finds the role a device id is paired to', () async {
      final appPrefs = await makePrefs();
      const hrm = PairedDevice(
        deviceId: 'hrm-1',
        name: 'TICKR',
        protocol: DeviceProtocol.bleHr,
      );
      await appPrefs
          .setPairedDevices(appPrefs.pairedDevices.withRole(SensorRole.heartRate, hrm));

      expect(appPrefs.pairedDevices.roleForDevice('hrm-1'), SensorRole.heartRate);
      expect(appPrefs.pairedDevices.roleForDevice('unknown'), isNull);
    });
  });

  group('AppPreferences — savedDeviceIds', () {
    test('includes ids from both the legacy list and paired roles', () async {
      final appPrefs = await makePrefs({
        'saved_device_ids': ['legacy-id'],
      });

      const power = PairedDevice(
        deviceId: 'power-1',
        name: 'Stages',
        protocol: DeviceProtocol.blePower,
      );
      await appPrefs.setPairedDevices(
          appPrefs.pairedDevices.withRole(SensorRole.power, power));

      expect(appPrefs.savedDeviceIds, containsAll(['legacy-id', 'power-1']));
    });
  });

  group('AppPreferences — autoUploadTargets', () {
    test('defaults to empty (auto-upload off for everything)', () async {
      final appPrefs = await makePrefs();
      expect(appPrefs.autoUploadTargets, isEmpty);
      expect(appPrefs.isAutoUploadEnabled('strava-export'), isFalse);
    });

    test('enabling a target persists it', () async {
      final appPrefs = await makePrefs();
      await appPrefs.setAutoUploadEnabled('strava-export', true);

      expect(appPrefs.isAutoUploadEnabled('strava-export'), isTrue);
      expect(appPrefs.autoUploadTargets, {'strava-export'});
    });

    test('disabling a target removes it without touching others', () async {
      final appPrefs = await makePrefs();
      await appPrefs.setAutoUploadEnabled('strava-export', true);
      await appPrefs.setAutoUploadEnabled('garmin-connect-export', true);

      await appPrefs.setAutoUploadEnabled('strava-export', false);

      expect(appPrefs.autoUploadTargets, {'garmin-connect-export'});
    });
  });

  group('AppPreferences — crash reporting consent', () {
    test('defaults to off and not-yet-asked', () async {
      final appPrefs = await makePrefs();
      expect(appPrefs.crashReportingEnabled, isFalse);
      expect(appPrefs.hasAskedCrashReportingConsent, isFalse);
    });

    test('setCrashReportingEnabled persists across reload', () async {
      final appPrefs = await makePrefs();
      await appPrefs.setCrashReportingEnabled(true);

      final reloaded = AppPreferences(await SharedPreferences.getInstance());
      expect(reloaded.crashReportingEnabled, isTrue);
    });

    test('setHasAskedCrashReportingConsent persists across reload', () async {
      final appPrefs = await makePrefs();
      await appPrefs.setHasAskedCrashReportingConsent(true);

      final reloaded = AppPreferences(await SharedPreferences.getInstance());
      expect(reloaded.hasAskedCrashReportingConsent, isTrue);
      // Declining still records that the prompt was shown.
      expect(reloaded.crashReportingEnabled, isFalse);
    });
  });
}
