import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';

final _log = Logger('BlePermissionHandler');

/// Handles platform-specific BLE permission requests.
///
/// - **Android**: Bluetooth, BluetoothScan, BluetoothConnect, Location.
/// - **iOS**: Bluetooth (via Info.plist, prompted automatically).
/// - **Desktop** (macOS/Linux/Windows): no runtime permissions needed.
class BlePermissionHandler {
  /// Requests all required BLE permissions for the current platform.
  ///
  /// Returns `true` if all permissions are granted and Bluetooth is on.
  Future<bool> requestPermissions() async {
    _log.info('Requesting BLE permissions for ${Platform.operatingSystem}');

    if (Platform.isAndroid) {
      return _requestAndroidPermissions();
    } else if (Platform.isIOS) {
      return _requestIosPermissions();
    } else {
      // Desktop platforms — no runtime permissions needed.
      _log.info('Desktop platform — no BLE permissions required');
      return _ensureBluetoothOn();
    }
  }

  // ---------------------------------------------------------------------------
  // Android
  // ---------------------------------------------------------------------------

  Future<bool> _requestAndroidPermissions() async {
    final permissions = <Permission>[
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];

    final statuses = await permissions.request();

    for (final entry in statuses.entries) {
      _log.fine('${entry.key}: ${entry.value}');
      if (!entry.value.isGranted) {
        _log.warning('Permission denied: ${entry.key}');
        return false;
      }
    }

    return _ensureBluetoothOn();
  }

  // ---------------------------------------------------------------------------
  // iOS
  // ---------------------------------------------------------------------------

  Future<bool> _requestIosPermissions() async {
    // iOS prompts for Bluetooth via CBCentralManager automatically when the
    // app first tries to scan.  We just request the permission_handler entry
    // to give the user a heads-up.
    final status = await Permission.bluetooth.request();
    _log.fine('iOS bluetooth permission: $status');

    if (!status.isGranted) {
      _log.warning('Bluetooth permission denied on iOS');
      return false;
    }

    return _ensureBluetoothOn();
  }

  // ---------------------------------------------------------------------------
  // Adapter state
  // ---------------------------------------------------------------------------

  /// How long to wait for the adapter to report a settled state before
  /// giving up. Only relevant right after launch.
  static const adapterReadyTimeout = Duration(seconds: 5);

  Future<bool> _ensureBluetoothOn() async {
    var state = FlutterBluePlus.adapterStateNow;

    // CoreBluetooth reports `unknown` for a few hundred ms after launch
    // while the central manager powers up. Taking the stream's *first*
    // value there would reject a perfectly healthy radio — which is what
    // made connects issued at app start (auto-reconnect) fail while the
    // same connect from the Devices screen, seconds later, succeeded.
    if (state == BluetoothAdapterState.unknown) {
      _log.info('Bluetooth adapter still powering up — waiting…');
      state = await FlutterBluePlus.adapterState
          .firstWhere((s) => s != BluetoothAdapterState.unknown)
          .timeout(
            adapterReadyTimeout,
            onTimeout: () => BluetoothAdapterState.unknown,
          );
    }

    if (state != BluetoothAdapterState.on) {
      _log.warning('Bluetooth adapter is $state — not ON');
      return false;
    }
    _log.info('Bluetooth adapter is ON');
    return true;
  }
}
