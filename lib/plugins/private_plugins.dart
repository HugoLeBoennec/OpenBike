import 'plugin_interfaces.dart';
import 'plugin_registry.dart';
import 'private_registration.dart' as private;

/// Registers any private-package plugins (see
/// `docs/release/private-plugins.md`) into [registry].
///
/// Resolves [extraExportPlugins]/[extraDevicePlugins] against the checked-in
/// `private_registration.dart` stub by default, which returns empty lists —
/// so this is a no-op in the public repo. A release build swaps that stub
/// for one backed by `package:openbike_private_plugins`; callers can also
/// pass hooks directly (e.g. in tests, to simulate a private package being
/// present without touching the stub file).
void registerPrivatePlugins(
  PluginRegistry registry, {
  List<ExportPlugin> Function()? extraExportPlugins,
  List<DevicePlugin> Function()? extraDevicePlugins,
}) {
  final exportHook = extraExportPlugins ?? private.extraExportPlugins;
  final deviceHook = extraDevicePlugins ?? private.extraDevicePlugins;

  for (final plugin in exportHook()) {
    registry.registerExport(plugin);
  }
  for (final plugin in deviceHook()) {
    registry.registerDevice(plugin);
  }
}
