import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/infrastructure/ble/ble_permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  group('BlePermissionHandler.androidPermissionsFor', () {
    // BLUETOOTH and ACCESS_FINE_LOCATION are declared with
    // maxSdkVersion="30", so requesting them on Android 12+ always comes
    // back denied — they must not be required there.
    test('asks only for Nearby devices on Android 12 and newer', () {
      for (final sdkInt in [31, 33, 36]) {
        expect(
          BlePermissionHandler.androidPermissionsFor(sdkInt),
          [Permission.bluetoothScan, Permission.bluetoothConnect],
          reason: 'API $sdkInt',
        );
      }
    });

    test('asks for location on Android 11 and older', () {
      for (final sdkInt in [24, 29, 30]) {
        expect(
          BlePermissionHandler.androidPermissionsFor(sdkInt),
          [Permission.locationWhenInUse],
          reason: 'API $sdkInt',
        );
      }
    });
  });
}
