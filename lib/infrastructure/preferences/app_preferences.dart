import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/domain/entities/paired_devices.dart';
import '../../core/domain/entities/trainer_device.dart';

/// Typed wrapper around [SharedPreferences] for app-wide settings.
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  // -------------------------------------------------------------------------
  // Keys
  // -------------------------------------------------------------------------

  static const _kOnboardingCompleted = 'onboarding_completed';
  static const _kSavedDeviceIds = 'saved_device_ids';
  static const _kPairedDevices = 'paired_devices_v1';
  static const _kUnitSystem = 'unit_system';
  static const _kThemeMode = 'theme_mode';
  static const _kAutoPauseEnabled = 'auto_pause_enabled';
  static const _kHasBackfilledPersonalRecords = 'has_backfilled_personal_records';

  // -------------------------------------------------------------------------
  // Onboarding
  // -------------------------------------------------------------------------

  bool get hasCompletedOnboarding =>
      _prefs.getBool(_kOnboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool value) =>
      _prefs.setBool(_kOnboardingCompleted, value);

  // -------------------------------------------------------------------------
  // Saved device IDs (legacy flat list — superseded by [pairedDevices])
  // -------------------------------------------------------------------------

  /// All device ids the user has ever paired (across every role) — used for
  /// reconnect-eligibility checks that don't need to know the role.
  List<String> get savedDeviceIds {
    final legacy = _prefs.getStringList(_kSavedDeviceIds) ?? [];
    final fromRoles = pairedDevices.byRole.values.map((d) => d.deviceId);
    return {...legacy, ...fromRoles}.toList();
  }

  Future<void> setSavedDeviceIds(List<String> ids) =>
      _prefs.setStringList(_kSavedDeviceIds, ids);

  // -------------------------------------------------------------------------
  // Per-role paired devices
  // -------------------------------------------------------------------------

  /// Role → paired device assignments.
  ///
  /// Falls back to migrating the legacy flat [savedDeviceIds] list the first
  /// time this is read: the first saved id (if any) becomes the `trainer`
  /// role pairing, since single-trainer auto-reconnect was the only paired
  /// device flow that existed before per-role pairing. The migration is not
  /// persisted automatically — it is recomputed until the caller explicitly
  /// assigns/saves a [PairedDevices] via [setPairedDevices].
  PairedDevices get pairedDevices {
    final raw = _prefs.getString(_kPairedDevices);
    if (raw == null) return _migrateLegacyPairedDevices();

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return PairedDevices.decode(decoded);
    } catch (_) {
      return _migrateLegacyPairedDevices();
    }
  }

  Future<void> setPairedDevices(PairedDevices devices) =>
      _prefs.setString(_kPairedDevices, jsonEncode(devices.encode()));

  PairedDevices _migrateLegacyPairedDevices() {
    final legacy = _prefs.getStringList(_kSavedDeviceIds) ?? [];
    if (legacy.isEmpty) return const PairedDevices();
    return PairedDevices(byRole: {
      SensorRole.trainer: PairedDevice(
        deviceId: legacy.first,
        name: 'Saved device',
        protocol: DeviceProtocol.bleFtms,
      ),
    });
  }

  // -------------------------------------------------------------------------
  // Unit system (metric / imperial)
  // -------------------------------------------------------------------------

  String get unitSystem => _prefs.getString(_kUnitSystem) ?? 'metric';

  Future<void> setUnitSystem(String value) =>
      _prefs.setString(_kUnitSystem, value);

  // -------------------------------------------------------------------------
  // Theme mode (dark / system)
  // -------------------------------------------------------------------------

  String get themeMode => _prefs.getString(_kThemeMode) ?? 'dark';

  Future<void> setThemeMode(String value) =>
      _prefs.setString(_kThemeMode, value);

  // -------------------------------------------------------------------------
  // Auto-pause (default off)
  // -------------------------------------------------------------------------

  bool get autoPauseEnabled => _prefs.getBool(_kAutoPauseEnabled) ?? false;

  Future<void> setAutoPauseEnabled(bool value) =>
      _prefs.setBool(_kAutoPauseEnabled, value);

  // -------------------------------------------------------------------------
  // Personal records backfill (one-time job, see [backfillPersonalRecords])
  // -------------------------------------------------------------------------

  bool get hasBackfilledPersonalRecords =>
      _prefs.getBool(_kHasBackfilledPersonalRecords) ?? false;

  Future<void> setHasBackfilledPersonalRecords(bool value) =>
      _prefs.setBool(_kHasBackfilledPersonalRecords, value);
}
