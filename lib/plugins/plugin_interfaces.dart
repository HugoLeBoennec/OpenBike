import 'package:flutter/widgets.dart';
import '../core/domain/entities/entities.dart';
import '../core/domain/ports/export_port.dart';
import '../core/domain/ports/trainer_port.dart';
import 'plugin_manifest.dart';

// ---------------------------------------------------------------------------
// DevicePlugin
// ---------------------------------------------------------------------------

abstract class DevicePlugin {
  PluginManifest get manifest;

  /// Scans for compatible devices within the given [timeout].
  Future<List<TrainerDevice>> scan(Duration timeout);

  /// Opens a connection and returns a [TrainerPort] for the device.
  Future<TrainerPort> connect(TrainerDevice device);

  /// Returns `true` if this plugin knows how to drive [device].
  bool canHandle(TrainerDevice device);
}

// ---------------------------------------------------------------------------
// ExportPlugin
// ---------------------------------------------------------------------------

abstract class ExportPlugin {
  PluginManifest get manifest;

  /// Whether the user has authorized this plugin.
  bool get isAuthenticated;

  /// Authenticated user's display name, if available (e.g. Strava athlete name).
  String? get athleteName => null;

  /// Starts the OAuth / authentication flow.
  Future<void> authenticate();

  /// Logs out and clears stored credentials.
  Future<void> disconnect();

  /// Exports [ride] and returns a platform-specific identifier
  /// (e.g. Strava activity ID, local file path).
  Future<String> export(Ride ride, {ExportFormat format});
}

// ---------------------------------------------------------------------------
// WorkoutFormatPlugin
// ---------------------------------------------------------------------------

abstract class WorkoutFormatPlugin {
  PluginManifest get manifest;

  /// File extensions this plugin can read/write (e.g. `['.zwo', '.erg']`).
  List<String> get supportedExtensions;

  Future<Workout> parse(String content);

  Future<String> serialize(Workout workout);
}

// ---------------------------------------------------------------------------
// WidgetPlugin
// ---------------------------------------------------------------------------

abstract class WidgetPlugin {
  PluginManifest get manifest;

  /// Builds a live widget that reacts to the [sensorStream].
  Widget build(BuildContext context, Stream<SensorReading> sensorStream);
}
