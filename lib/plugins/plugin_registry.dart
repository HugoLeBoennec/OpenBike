import '../core/domain/entities/trainer_device.dart';
import 'plugin_interfaces.dart';
import 'plugin_manifest.dart';

/// Central registry for all OpenBike plugins.
///
/// Plugins are registered by type and can be looked up individually or as a
/// group.  The registry owns the lifecycle of every registered plugin — call
/// [disposeAll] when the app shuts down.
class PluginRegistry {
  final List<DevicePlugin> _devices = [];
  final List<ExportPlugin> _exports = [];
  final List<WorkoutFormatPlugin> _formats = [];
  final List<WidgetPlugin> _widgets = [];

  // -------------------------------------------------------------------------
  // Registration
  // -------------------------------------------------------------------------

  void registerDevice(DevicePlugin plugin) => _devices.add(plugin);
  void registerExport(ExportPlugin plugin) => _exports.add(plugin);
  void registerFormat(WorkoutFormatPlugin plugin) => _formats.add(plugin);
  void registerWidget(WidgetPlugin plugin) => _widgets.add(plugin);

  // -------------------------------------------------------------------------
  // Typed getters
  // -------------------------------------------------------------------------

  List<DevicePlugin> getDevicePlugins() => List.unmodifiable(_devices);
  List<ExportPlugin> getExportPlugins() => List.unmodifiable(_exports);
  List<WorkoutFormatPlugin> getFormatPlugins() => List.unmodifiable(_formats);
  List<WidgetPlugin> getWidgetPlugins() => List.unmodifiable(_widgets);

  /// All registered manifests regardless of type.
  List<PluginManifest> get allManifests => [
        ..._devices.map((p) => p.manifest),
        ..._exports.map((p) => p.manifest),
        ..._formats.map((p) => p.manifest),
        ..._widgets.map((p) => p.manifest),
      ];

  // -------------------------------------------------------------------------
  // Device look-up
  // -------------------------------------------------------------------------

  /// Returns the first [DevicePlugin] whose [canHandle] returns `true` for
  /// [device], or `null` if none matches.
  DevicePlugin? getPluginForDevice(TrainerDevice device) {
    for (final plugin in _devices) {
      if (plugin.canHandle(device)) return plugin;
    }
    return null;
  }

  // -------------------------------------------------------------------------
  // Format look-up
  // -------------------------------------------------------------------------

  /// Returns a [WorkoutFormatPlugin] that supports the given file [extension]
  /// (e.g. `'.zwo'`), or `null`.
  WorkoutFormatPlugin? getFormatForExtension(String extension) {
    final ext = extension.toLowerCase();
    for (final plugin in _formats) {
      if (plugin.supportedExtensions.any((e) => e.toLowerCase() == ext)) {
        return plugin;
      }
    }
    return null;
  }

  // -------------------------------------------------------------------------
  // Un-registration
  // -------------------------------------------------------------------------

  void unregister(String pluginId) {
    _devices.removeWhere((p) => p.manifest.id == pluginId);
    _exports.removeWhere((p) => p.manifest.id == pluginId);
    _formats.removeWhere((p) => p.manifest.id == pluginId);
    _widgets.removeWhere((p) => p.manifest.id == pluginId);
  }

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  /// Clears all registered plugins.
  void disposeAll() {
    _devices.clear();
    _exports.clear();
    _formats.clear();
    _widgets.clear();
  }
}
