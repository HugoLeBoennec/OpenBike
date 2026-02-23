import 'package:shared_preferences/shared_preferences.dart';

/// Typed wrapper around [SharedPreferences] for app-wide settings.
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  // -------------------------------------------------------------------------
  // Keys
  // -------------------------------------------------------------------------

  static const _kOnboardingCompleted = 'onboarding_completed';
  static const _kSavedDeviceIds = 'saved_device_ids';
  static const _kUnitSystem = 'unit_system';
  static const _kThemeMode = 'theme_mode';
  static const _kTrainerDifficulty = 'trainer_difficulty';

  // -------------------------------------------------------------------------
  // Onboarding
  // -------------------------------------------------------------------------

  bool get hasCompletedOnboarding =>
      _prefs.getBool(_kOnboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool value) =>
      _prefs.setBool(_kOnboardingCompleted, value);

  // -------------------------------------------------------------------------
  // Saved device IDs (for auto-reconnect)
  // -------------------------------------------------------------------------

  List<String> get savedDeviceIds =>
      _prefs.getStringList(_kSavedDeviceIds) ?? [];

  Future<void> setSavedDeviceIds(List<String> ids) =>
      _prefs.setStringList(_kSavedDeviceIds, ids);

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
  // Trainer difficulty — gradient scaling for SIM mode (0.0–1.0, default 0.5)
  // -------------------------------------------------------------------------

  double get trainerDifficulty =>
      (_prefs.getDouble(_kTrainerDifficulty) ?? 0.5).clamp(0.0, 1.0);

  Future<void> setTrainerDifficulty(double value) =>
      _prefs.setDouble(_kTrainerDifficulty, value.clamp(0.0, 1.0));
}
