import 'plugin_interfaces.dart';

/// Public-repo default: no private plugins are available.
///
/// This file is the seam described in `docs/release/private-plugins.md`.
/// Release builds that pull in the private `openbike_private_plugins`
/// package replace this file with one that imports
/// `package:openbike_private_plugins/register.dart` and forwards to its
/// real export plugin constructors (see docs/release/private-plugins.md for naming conventions).
/// The public app must compile and run fully without that package present,
/// so this stub — not a conditional import — is what ships here.
List<ExportPlugin> extraExportPlugins() => const [];

List<DevicePlugin> extraDevicePlugins() => const [];
