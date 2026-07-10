import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/application/services/bundled_workouts.dart';
import 'core/application/services/personal_records_backfill.dart';
import 'core/application/services/physics_engine.dart';
import 'core/events/event_bus.dart';
import 'infrastructure/ant/ant_device_plugin.dart';
import 'infrastructure/ant/ant_usb_transport.dart';
import 'infrastructure/ant/libusb_backend.dart';
import 'infrastructure/ble/ble_transport.dart';
import 'infrastructure/ble/ftms/ftms_device_plugin.dart';
import 'infrastructure/ble/sensors/sensor_device_plugin.dart';
import 'infrastructure/desktop/desktop_window_service.dart';
import 'infrastructure/files/erg_parser.dart';
import 'infrastructure/files/zwo_parser.dart';
import 'infrastructure/persistence/app_database.dart';
import 'infrastructure/persistence/drift_storage.dart';
import 'infrastructure/preferences/app_preferences.dart';
import 'infrastructure/simulator/simulator.dart';
import 'plugins/exports/garmin_export_plugin.dart';
import 'plugins/exports/strava_export_plugin.dart';
import 'plugins/plugin_registry.dart';
import 'plugins/private_plugins.dart';
import 'presentation/router.dart';
import 'presentation/state/providers.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/widgets/strava_deep_link_listener.dart';

final _log = Logger('main');

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
  _registerPlugins(registry, eventBus, bleTransport);

  // ---- Restore export plugin sessions (e.g. Strava OAuth tokens) ----
  for (final plugin in registry.getExportPlugins()) {
    if (plugin is StravaExportPlugin) {
      await plugin.restoreSession();
    }
  }

  // ---- Preferences ----
  final prefs = await SharedPreferences.getInstance();
  final appPrefs = AppPreferences(prefs);

  // ---- Desktop window (macOS/Windows/Linux only — no-op elsewhere) ----
  await initializeDesktopWindow(appPrefs);

  // ---- Load persisted user profile ----
  final storage = DriftStorage(db);
  final savedProfile = await storage.getProfile();

  // ---- Seed the starter workout library (idempotent) and load workouts ----
  await BundledWorkouts.seedIfNeeded(storage);
  final savedWorkouts = await storage.getWorkouts();

  // ---- One-time backfill of personal records for rides predating P5 ----
  if (!appPrefs.hasBackfilledPersonalRecords) {
    await backfillPersonalRecords(storage);
    await appPrefs.setHasBackfilledPersonalRecords(true);
  }

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        eventBusProvider.overrideWithValue(eventBus),
        pluginRegistryProvider.overrideWithValue(registry),
        bleTransportProvider.overrideWithValue(bleTransport),
        appPreferencesProvider.overrideWithValue(appPrefs),
        // Seed saved device IDs from preferences.
        savedDeviceIdsProvider.overrideWith((ref) => appPrefs.savedDeviceIds),
        // Seed per-role paired device assignments from preferences.
        pairedDevicesProvider.overrideWith((ref) => appPrefs.pairedDevices),
        // Seed profile from DB so zones/FTP are available immediately.
        if (savedProfile != null)
          userProfileProvider.overrideWith((ref) => savedProfile),
        // Seed the workout library from DB (bundled + any user-created).
        workoutListProvider.overrideWith((ref) => savedWorkouts),
      ],
      child: OpenBikeApp(
        router: createAppRouter(
          hasCompletedOnboarding: appPrefs.hasCompletedOnboarding,
        ),
      ),
    ),
  );
}

void _registerPlugins(
    PluginRegistry registry, EventBus eventBus, BleTransport bleTransport) {
  // ---- Device plugins ----

  // BLE FTMS — always available (shares BleTransport with bleTransportProvider).
  // Registered first: PluginRegistry.getPluginForDevice() picks the first
  // canHandle() match, so FTMS trainers must be claimed here before the
  // sensor plugin below gets a chance to see them.
  registry.registerDevice(FtmsDevicePlugin(
    transport: bleTransport,
    eventBus: eventBus,
  ));

  // BLE standalone sensors (HR straps, power meters, speed/cadence) — always
  // available. Only handles non-FTMS protocols (see SensorDevicePlugin.canHandle).
  registry.registerDevice(SensorDevicePlugin(
    transport: bleTransport,
    eventBus: eventBus,
  ));

  // ANT+ FE-C — desktop only (requires a USB dongle + the bundled libusb
  // binary; see docs/release/antplus-usb.md). Failing to load libusb (e.g.
  // the binary isn't bundled for this build) must not crash startup, so
  // registration is attempted and skipped on error rather than gated on a
  // platform check that can't detect a missing/bad binary.
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    try {
      final usbBackend = LibusbBackend();
      registry.registerDevice(AntDevicePlugin(
        transport: AntUsbTransport(backend: usbBackend),
        eventBus: eventBus,
      ));
    } catch (e) {
      _log.warning('ANT+ USB backend unavailable, skipping registration: $e');
    }
  }

  // Simulator — dev mode only (--dart-define=DEV_MODE=true).
  const devMode = bool.fromEnvironment('DEV_MODE');
  if (devMode) {
    registry.registerDevice(SimulatorDevicePlugin(
      eventBus: eventBus,
      physics: CyclingPhysicsEngine(),
    ));
  }

  // ---- Export plugins ----

  // Garmin Connect — local FIT file export (always available).
  registry.registerExport(GarminConnectExportPlugin());

  // Strava — OAuth2 upload (requires client credentials via env).
  const stravaClientId = String.fromEnvironment('STRAVA_CLIENT_ID');
  const stravaClientSecret = String.fromEnvironment('STRAVA_CLIENT_SECRET');
  if (stravaClientId.isNotEmpty && stravaClientSecret.isNotEmpty) {
    registry.registerExport(StravaExportPlugin(
      config: StravaConfig(
        clientId: stravaClientId,
        clientSecret: stravaClientSecret,
      ),
    ));
  }

  // ---- Workout format plugins ----

  registry.registerFormat(ZwoParser());
  registry.registerFormat(ErgMrcParser());

  // ---- Private-package plugins (open-core seam) ----
  // No-op unless a release build has swapped in the real registration file.
  // See docs/release/private-plugins.md.
  registerPrivatePlugins(registry);
}

class OpenBikeApp extends ConsumerWidget {
  const OpenBikeApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = _parseThemeMode(ref.watch(themeModeProvider));
    return StravaDeepLinkListener(
      child: MaterialApp.router(
        title: 'OpenBike',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }
}
