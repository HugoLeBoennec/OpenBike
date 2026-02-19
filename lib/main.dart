import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/application/services/physics_engine.dart';
import 'core/events/event_bus.dart';
import 'infrastructure/ble/ble_transport.dart';
import 'infrastructure/ble/ftms/ftms_device_plugin.dart';
import 'infrastructure/files/erg_parser.dart';
import 'infrastructure/files/zwo_parser.dart';
import 'infrastructure/persistence/app_database.dart';
import 'infrastructure/persistence/drift_storage.dart';
import 'infrastructure/preferences/app_preferences.dart';
import 'infrastructure/simulator/simulator.dart';
import 'plugins/exports/garmin_export_plugin.dart';
import 'plugins/exports/strava_export_plugin.dart';
import 'plugins/exports/tcx_file_export_plugin.dart';
import 'plugins/plugin_registry.dart';
import 'presentation/router.dart';
import 'presentation/state/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---- Database ----
  final dbDir = await getApplicationDocumentsDirectory();
  final dbFile = File(p.join(dbDir.path, 'open_bike.db'));
  final db = AppDatabase(NativeDatabase(dbFile));

  // ---- Core singletons ----
  final eventBus = EventBus();
  final bleTransport = BleTransport();
  final registry = PluginRegistry();
  final stravaPlugin = _registerPlugins(registry, eventBus, bleTransport);

  // ---- Preferences ----
  final prefs = await SharedPreferences.getInstance();
  final appPrefs = AppPreferences(prefs);

  // ---- Load persisted user profile ----
  final storage = DriftStorage(db);
  final savedProfile = await storage.getProfile();

  // ---- Build ProviderContainer so we can update auth state from outside ----
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      eventBusProvider.overrideWithValue(eventBus),
      pluginRegistryProvider.overrideWithValue(registry),
      bleTransportProvider.overrideWithValue(bleTransport),
      appPreferencesProvider.overrideWithValue(appPrefs),
      // Seed saved device IDs from preferences.
      savedDeviceIdsProvider.overrideWith((ref) => appPrefs.savedDeviceIds),
      // Seed profile from DB so zones/FTP are available immediately.
      if (savedProfile != null)
        userProfileProvider.overrideWith((ref) => savedProfile),
    ],
  );

  // ---- Restore Strava session (reload tokens from secure storage) ----
  if (stravaPlugin != null) {
    await stravaPlugin.restoreSession();
    container.read(stravaAuthStateProvider.notifier).state =
        stravaPlugin.isAuthenticated;
  }

  // ---- Deep link listener (Strava OAuth callback) ----
  if (stravaPlugin != null) {
    AppLinks().uriLinkStream.listen((uri) {
      if (uri.scheme == 'openbike' && uri.host == 'strava') {
        stravaPlugin.handleCallback(uri).then((_) {
          container.read(stravaAuthStateProvider.notifier).state = true;
        }).catchError((Object e) {
          // Callback errors are logged; the user will see "Not connected" still.
          debugPrint('[Strava] OAuth callback error: $e');
        });
      }
    });
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: OpenBikeApp(
        router: createAppRouter(
          hasCompletedOnboarding: appPrefs.hasCompletedOnboarding,
        ),
      ),
    ),
  );
}

/// Registers all plugins and returns the [StravaExportPlugin] if configured.
StravaExportPlugin? _registerPlugins(
    PluginRegistry registry, EventBus eventBus, BleTransport bleTransport) {
  // ---- Device plugins ----

  // BLE FTMS — always available (shares BleTransport with bleTransportProvider).
  registry.registerDevice(FtmsDevicePlugin(
    transport: bleTransport,
    eventBus: eventBus,
  ));

  // ANT+ FE-C — desktop only (requires USB dongle).
  // To enable: provide a UsbBackend implementation (e.g. dart:ffi + libusb)
  // and uncomment the block below.
  //
  // if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
  //   final usbBackend = LibusbBackend(); // TODO: implement UsbBackend
  //   registry.registerDevice(AntDevicePlugin(
  //     transport: AntUsbTransport(backend: usbBackend),
  //     eventBus: eventBus,
  //   ));
  // }

  // Simulator — dev mode only (--dart-define=DEV_MODE=true).
  const devMode = bool.fromEnvironment('DEV_MODE');
  if (devMode) {
    registry.registerDevice(SimulatorDevicePlugin(
      eventBus: eventBus,
      physics: CyclingPhysicsEngine(),
    ));
  }

  // ---- Export plugins ----

  // FIT file — always available.
  registry.registerExport(GarminConnectExportPlugin());

  // TCX file — always available.
  registry.registerExport(TcxFileExportPlugin());

  // Strava — OAuth2 upload (requires client credentials via env).
  StravaExportPlugin? stravaPlugin;
  const stravaClientId = String.fromEnvironment('STRAVA_CLIENT_ID');
  const stravaClientSecret = String.fromEnvironment('STRAVA_CLIENT_SECRET');
  if (stravaClientId.isNotEmpty && stravaClientSecret.isNotEmpty) {
    stravaPlugin = StravaExportPlugin(
      config: StravaConfig(
        clientId: stravaClientId,
        clientSecret: stravaClientSecret,
      ),
    );
    registry.registerExport(stravaPlugin);
  }

  // ---- Workout format plugins ----

  registry.registerFormat(ZwoParser());
  registry.registerFormat(ErgMrcParser());

  return stravaPlugin;
}

class OpenBikeApp extends StatelessWidget {
  const OpenBikeApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OpenBike',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.dark,
      ),
      routerConfig: router,
    );
  }
}
