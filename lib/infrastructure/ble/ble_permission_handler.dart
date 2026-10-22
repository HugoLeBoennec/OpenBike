import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';

final _log = Logger('BlePermissionHandler');

/// Whether BLE can be used right now and, when it can't, why — the UI needs
/// the reason to tell the user what to do about it (allow access in
/// Settings vs. turn Bluetooth on) instead of silently finding nothing.
enum BleAvailability {
  ready,

  /// The user denied Bluetooth access (or it is restricted). The OS won't
  /// prompt again; access has to be granted from the app's Settings page.
  permissionDenied,

  /// Access is granted but the radio is off (or never finished powering up).
  bluetoothOff,

  /// This device has no usable Bluetooth LE adapter.
  unsupported,
}

/// Handles platform-specific BLE permission requests.
///
/// - **Android 12+**: BluetoothScan, BluetoothConnect ("Nearby devices").
/// - **Android 11 and older**: Location.
/// - **iOS**: Bluetooth (via Info.plist, prompted automatically).
/// - **Desktop** (macOS/Linux/Windows): no runtime permissions needed.
class BlePermissionHandler {
  /// Requests all required BLE permissions for the current platform, then
  /// checks the adapter.
  ///
  /// Returns [BleAvailability.ready] if all permissions are granted and
  /// Bluetooth is on, otherwise the first reason it isn't.
  Future<BleAvailability> requestAccess() async {
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

  /// Android 12 (API 31) replaced Bluetooth's location permission with the
  /// "Nearby devices" ones.
  static const _android12 = 31;

  static const _platformChannel =
      MethodChannel('run.records.openbike/platform');

  /// Runtime permissions BLE needs on Android API level [sdkInt].
  ///
  /// Only permissions the manifest declares for that level may be listed:
  /// BLUETOOTH and ACCESS_FINE_LOCATION are capped at API 30 there, and on
  /// Android 12+ permission_handler reports such a permission denied without
  /// ever prompting — which would refuse Bluetooth no matter what the user
  /// allowed.
  @visibleForTesting
  static List<Permission> androidPermissionsFor(int sdkInt) =>
      sdkInt >= _android12
          ? [Permission.bluetoothScan, Permission.bluetoothConnect]
          : [Permission.locationWhenInUse];

  /// The device's Android API level, from MainActivity. It never changes
  /// while the app runs, so it is asked for once.
  static final Future<int> _androidSdkInt = _queryAndroidSdkInt();

  static Future<int> _queryAndroidSdkInt() async {
    try {
      final sdkInt =
          await _platformChannel.invokeMethod<int>('androidSdkInt');
      if (sdkInt != null) return sdkInt;
    } on Exception catch (e) {
      _log.warning('Could not read the Android API level: $e');
    }
    // Fall back to the permissions every current device uses.
    return _android12;
  }

  Future<BleAvailability> _requestAndroidPermissions() async {
    final sdkInt = await _androidSdkInt;
    _log.fine('Android API level $sdkInt');

    final statuses = await androidPermissionsFor(sdkInt).request();

    for (final entry in statuses.entries) {
      _log.fine('${entry.key}: ${entry.value}');
      if (!entry.value.isGranted) {
        _log.warning('Permission denied: ${entry.key}');
        return BleAvailability.permissionDenied;
      }
    }

    return _ensureBluetoothOn();
  }

  // ---------------------------------------------------------------------------
  // iOS
  // ---------------------------------------------------------------------------

  Future<BleAvailability> _requestIosPermissions() async {
    // iOS prompts for Bluetooth via CBCentralManager automatically when the
    // app first tries to scan.  We just request the permission_handler entry
    // to give the user a heads-up.
    final status = await Permission.bluetooth.request();
    _log.fine('iOS bluetooth permission: $status');

    if (!status.isGranted) {
      // `permanentlyDenied` (the user said no earlier) and `restricted`
      // (Screen Time / MDM) both come back without any prompt — the only
      // way forward is the app's page in Settings.
      _log.warning('Bluetooth permission not granted on iOS: $status');
      return BleAvailability.permissionDenied;
    }

    return _ensureBluetoothOn();
  }

  // ---------------------------------------------------------------------------
  // Adapter state
  // ---------------------------------------------------------------------------

  /// How long to wait for the adapter to report a settled state before
  /// giving up. Only relevant right after launch.
  static const adapterReadyTimeout = Duration(seconds: 5);

  Future<BleAvailability> _ensureBluetoothOn() async {
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

    switch (state) {
      case BluetoothAdapterState.on:
        _log.info('Bluetooth adapter is ON');
        return BleAvailability.ready;
      case BluetoothAdapterState.unauthorized:
        _log.warning('Bluetooth adapter reports unauthorized');
        return BleAvailability.permissionDenied;
      case BluetoothAdapterState.unavailable:
        _log.warning('Bluetooth LE is not supported on this device');
        return BleAvailability.unsupported;
      default:
        _log.warning('Bluetooth adapter is $state — not ON');
        return BleAvailability.bluetoothOff;
    }
  }

  /// Opens this app's page in the system Settings, where a denied
  /// Bluetooth permission can be switched back on.
  Future<bool> openSettings() => openAppSettings();
}
