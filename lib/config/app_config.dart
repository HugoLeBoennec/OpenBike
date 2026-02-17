/// Compile-time app configuration.
class AppConfig {
  static const bool devMode = bool.fromEnvironment('DEV_MODE');
  static const String appVersion = '0.1.0';
  static const int buildNumber = 1;
  static const String environment = devMode ? 'development' : 'production';
}
