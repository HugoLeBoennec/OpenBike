import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/ports/storage_port.dart';
import '../../core/domain/ports/trainer_port.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../core/events/app_event.dart';
import '../../core/events/event_bus.dart';
import '../../core/application/services/connection_monitor.dart';
import '../../core/application/services/device_pairing_service.dart';
import '../../core/application/services/services.dart';
import '../../infrastructure/ant/ant_usb_transport.dart';
import '../../infrastructure/ble/ble_transport.dart';
import '../../infrastructure/ble/sensors/sensor_fusion.dart';
import '../../infrastructure/preferences/app_preferences.dart';
import '../../infrastructure/simulator/simulator.dart';
import '../../infrastructure/persistence/persistence.dart';
import '../../plugins/plugin_interfaces.dart';
import '../../plugins/plugin_registry.dart';
import '../models/ride_screen_config.dart';

// ---------------------------------------------------------------------------
// Core singletons
// ---------------------------------------------------------------------------

final eventBusProvider = Provider<EventBus>((ref) {
  final bus = EventBus();
  ref.onDispose(bus.dispose);
  return bus;
});

final pluginRegistryProvider = Provider<PluginRegistry>((ref) {
  final registry = PluginRegistry();
  ref.onDispose(registry.disposeAll);
  return registry;
});

// ---------------------------------------------------------------------------
// Preferences
// ---------------------------------------------------------------------------

/// Override in main() with `AppPreferences(await SharedPreferences.getInstance())`.
final appPreferencesProvider = Provider<AppPreferences>((ref) {
  throw UnimplementedError(
    'appPreferencesProvider must be overridden in main()',
  );
});

final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  return ref.watch(appPreferencesProvider).hasCompletedOnboarding;
});

final unitSystemProvider = StateProvider<String>((ref) {
  return ref.read(appPreferencesProvider).unitSystem;
});

final themeModeProvider = StateProvider<String>((ref) {
  return ref.read(appPreferencesProvider).themeMode;
});

// ---------------------------------------------------------------------------
// Database & storage
// ---------------------------------------------------------------------------

/// Override this provider with the platform-specific [AppDatabase] instance
/// (e.g. using NativeDatabase in the app's main()).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden with a platform-specific database',
  );
});

final storageProvider = Provider<StoragePort>((ref) {
  return DriftStorage(ref.watch(appDatabaseProvider));
});

// ---------------------------------------------------------------------------
// Recording engine
// ---------------------------------------------------------------------------

final recordingEngineProvider = Provider<RecordingEngine>((ref) {
  final engine = RecordingEngine(
    eventBus: ref.watch(eventBusProvider),
    storage: ref.watch(storageProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
});

final recordingStateProvider = StreamProvider<RecordingState>((ref) {
  return ref.watch(recordingEngineProvider).stateStream;
});

// ---------------------------------------------------------------------------
// Connection monitor
// ---------------------------------------------------------------------------

final connectionMonitorProvider = Provider<ConnectionMonitor>((ref) {
  final monitor = ConnectionMonitor(
    eventBus: ref.watch(eventBusProvider),
    bleTransport: ref.watch(bleTransportProvider),
    getSavedDeviceIds: () => ref.read(savedDeviceIdsProvider),
    isRecording: () => ref.read(recordingEngineProvider).state == RecordingState.recording,
  );
  monitor.start();
  ref.onDispose(monitor.dispose);
  return monitor;
});

// ---------------------------------------------------------------------------
// Ride state
// ---------------------------------------------------------------------------

final currentRideProvider = Provider<Ride?>((ref) {
  return ref.watch(recordingEngineProvider).currentRide;
});

// ---------------------------------------------------------------------------
// BLE transport & scanning
// ---------------------------------------------------------------------------

/// Override this provider with a real [BleTransport] instance in main().
final bleTransportProvider = Provider<BleTransport>((ref) {
  final transport = BleTransport();
  ref.onDispose(transport.dispose);
  return transport;
});

final bleScanStateProvider = StreamProvider<BleTransportState>((ref) {
  return ref.watch(bleTransportProvider).stateStream;
});

final bleScanResultsProvider = StreamProvider<List<BleScannedDevice>>((ref) {
  return ref.watch(bleTransportProvider).scanResults;
});

/// Device IDs previously connected — used for auto-reconnect hints.
final savedDeviceIdsProvider = StateProvider<List<String>>((ref) => []);

// ---------------------------------------------------------------------------
// Multi-sensor pairing (roles) & fusion
// ---------------------------------------------------------------------------

/// Merges every paired sensor's readings into one fused stream, with a
/// dedicated role's device winning over the trainer's own embedded sensor
/// for the same field. See [DevicePairingService].
final sensorFusionProvider = Provider<SensorFusion>((ref) {
  final fusion = SensorFusion(eventBus: ref.watch(eventBusProvider));
  ref.onDispose(fusion.dispose);
  return fusion;
});

/// Connects a device to a [SensorRole] and wires it into [sensorFusionProvider].
final devicePairingServiceProvider = Provider<DevicePairingService>((ref) {
  final service = DevicePairingService(
    registry: ref.watch(pluginRegistryProvider),
    sensorFusion: ref.watch(sensorFusionProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Current role → paired device assignments.
///
/// Seed with `pairedDevicesProvider.overrideWith((ref) => appPrefs.pairedDevices)`
/// in main(); the device-management screen updates this (and persists via
/// [AppPreferences.setPairedDevices]) whenever the user assigns or forgets a role.
final pairedDevicesProvider = StateProvider<PairedDevices>((ref) {
  return const PairedDevices();
});

// ---------------------------------------------------------------------------
// Per-role connection status (in-ride banner + sensor status dots)
// ---------------------------------------------------------------------------

/// Tracks connected/disconnected per [SensorRole], derived from
/// [TrainerEvent]s on the [EventBus] correlated against [PairedDevices].
///
/// A role with no entry in the map means "no disconnect has been observed
/// yet" rather than "explicitly disconnected" — the `connected` event for a
/// role fires at pairing time, which may be before this notifier existed
/// (e.g. paired from the device screen before the ride screen ever mounted).
class RoleConnectionNotifier extends StateNotifier<Map<SensorRole, bool>> {
  RoleConnectionNotifier({
    required EventBus eventBus,
    required PairedDevices Function() getPairedDevices,
  })  : _getPairedDevices = getPairedDevices,
        super(const {}) {
    _sub = eventBus.on<TrainerEvent>().listen(_onEvent);
  }

  final PairedDevices Function() _getPairedDevices;
  late final StreamSubscription<TrainerEvent> _sub;

  void _onEvent(TrainerEvent event) {
    event.map(
      connected: (e) => _setStatus(e.device.id, true),
      disconnected: (e) => _setStatus(e.deviceId, false),
      controlAcquired: (_) {},
      modeChanged: (_) {},
    );
  }

  void _setStatus(String deviceId, bool connected) {
    final role = _getPairedDevices().roleForDevice(deviceId);
    if (role == null) return;
    state = {...state, role: connected};
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final roleConnectionStatusProvider =
    StateNotifierProvider<RoleConnectionNotifier, Map<SensorRole, bool>>((ref) {
  return RoleConnectionNotifier(
    eventBus: ref.watch(eventBusProvider),
    getPairedDevices: () => ref.read(pairedDevicesProvider),
  );
});

/// Roles that are paired but whose device reported a disconnect that hasn't
/// been followed by a reconnect yet — drives the in-ride connection banner.
final disconnectedPairedRolesProvider = Provider<List<SensorRole>>((ref) {
  final paired = ref.watch(pairedDevicesProvider);
  final status = ref.watch(roleConnectionStatusProvider);
  return [
    for (final role in paired.byRole.keys)
      if (status[role] == false) role,
  ];
});

final _autoReconnectLog = Logger('AutoReconnectPairedRoles');

/// Watch this once near app start (e.g. from `HomeScreen`) to attempt
/// reconnecting every saved role pairing.
///
/// A [Provider] body only runs once per [ProviderScope] lifetime — reading
/// [pairedDevicesProvider] with `ref.read` (a snapshot, not a subscription)
/// means this fires exactly once rather than on every future role change.
/// Each role's reconnect is independent and best-effort: a failure is
/// logged and skipped so one missing device doesn't block the others.
final autoReconnectPairedRolesProvider = Provider<void>((ref) {
  if (ref.watch(devModeProvider)) return; // simulator builds skip real BLE

  final paired = ref.read(pairedDevicesProvider);
  final service = ref.read(devicePairingServiceProvider);

  Future.microtask(() async {
    for (final entry in paired.byRole.entries) {
      final role = entry.key;
      final saved = entry.value;
      if (service.portForRole(role) != null) continue;

      final device = TrainerDevice(
        id: saved.deviceId,
        name: saved.name,
        protocol: saved.protocol,
      );
      try {
        final port = await service.assign(role, device);
        if (role == SensorRole.trainer) {
          ref.read(trainerDeviceProvider.notifier).state = device;
          ref.read(activeTrainerPortProvider.notifier).state = port;
        }
        _autoReconnectLog.info('Auto-reconnected $role → ${saved.name}');
      } catch (e) {
        _autoReconnectLog.warning(
            'Auto-reconnect failed for $role (${saved.name}): $e');
      }
    }
  });
});

// ---------------------------------------------------------------------------
// Dev mode + simulator
// ---------------------------------------------------------------------------

/// Whether the app was compiled with `--dart-define=DEV_MODE=true`.
final devModeProvider = Provider<bool>((ref) {
  return const bool.fromEnvironment('DEV_MODE');
});

/// The simulator plugin, if registered. Null in production.
final simulatorPluginProvider = Provider<SimulatorDevicePlugin?>((ref) {
  final registry = ref.watch(pluginRegistryProvider);
  for (final p in registry.getDevicePlugins()) {
    if (p is SimulatorDevicePlugin) return p;
  }
  return null;
});

// ---------------------------------------------------------------------------
// ANT+ USB transport (desktop only)
// ---------------------------------------------------------------------------

/// Override this provider with a [UsbBackend]-backed [AntUsbTransport] in
/// main() on desktop platforms.
final antUsbTransportProvider = Provider<AntUsbTransport>((ref) {
  throw UnimplementedError(
    'antUsbTransportProvider must be overridden with a UsbBackend implementation',
  );
});

// ---------------------------------------------------------------------------
// Trainer state
// ---------------------------------------------------------------------------

final trainerDeviceProvider = StateProvider<TrainerDevice?>((ref) => null);

final trainerListProvider = StateProvider<List<TrainerDevice>>((ref) => []);

/// The currently connected [TrainerPort] from a real BLE or simulator plugin.
/// Set by DeviceScanScreen on successful connection.
final activeTrainerPortProvider = StateProvider<TrainerPort?>((ref) => null);

// ---------------------------------------------------------------------------
// Live sensor data
// ---------------------------------------------------------------------------

final livePowerProvider = StateProvider<Watts>((ref) => Watts.zero);

final liveCadenceProvider = StateProvider<Cadence>((ref) => Cadence.zero);

final liveHeartRateProvider = StateProvider<HeartRate>((ref) => HeartRate.zero);

final liveSpeedProvider = StateProvider<Speed>((ref) => Speed.zero);

final sensorReadingsProvider = StateProvider<List<SensorReading>>((ref) => []);

// ---------------------------------------------------------------------------
// Live sensor bridge (EventBus → UI providers)
// ---------------------------------------------------------------------------

/// Watch this in [RideScreen] to bridge fused sensor readings from
/// [sensorFusionProvider] into the live UI providers ([livePowerProvider],
/// [liveCadenceProvider], etc.).
///
/// Without this, the ride screen data fields stay at zero because nothing
/// pushes trainer data into the Riverpod state layer.
///
/// Reads come from [SensorFusion] rather than raw sensor events so that
/// multiple simultaneously-paired devices (trainer + dedicated HR strap,
/// say) merge into one reading instead of each device's event clobbering
/// the fields the other device just set.
final _bridgeLog = Logger('LiveSensorBridge');

final liveSensorBridgeProvider = Provider<void>((ref) {
  final fusion = ref.watch(sensorFusionProvider);
  _bridgeLog.info('[BLE-DEBUG] LiveSensorBridge listening for fused readings');
  final sub = fusion.stream.listen((r) {
    _bridgeLog.fine('[BLE-DEBUG] Fused reading — '
        'power=${r.power}, cadence=${r.cadence}, '
        'speed=${r.speed}, hr=${r.heartRate}');
    Future.microtask(() {
      ref.read(livePowerProvider.notifier).state = r.power ?? Watts.zero;
      ref.read(liveCadenceProvider.notifier).state = r.cadence ?? Cadence.zero;
      ref.read(liveHeartRateProvider.notifier).state = r.heartRate ?? HeartRate.zero;
      ref.read(liveSpeedProvider.notifier).state = r.speed ?? Speed.zero;
    });
  });
  ref.onDispose(sub.cancel);
});

// ---------------------------------------------------------------------------
// Derived live data
// ---------------------------------------------------------------------------

/// FTP convenience — falls back to 200 W when no profile is set.
final ftpProvider = Provider<Watts>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.ftp ?? const Watts(200);
});

/// Which Coggan zone the current power falls into.
final currentPowerZoneProvider = Provider<PowerZone?>((ref) {
  final power = ref.watch(livePowerProvider);
  final ftp = ref.watch(ftpProvider);
  final zones = ref.watch(powerZonesProvider);
  if (ftp.value == 0 || zones.isEmpty) return null;
  final pct = (power.value / ftp.value) * 100;
  for (final zone in zones) {
    if (zone.contains(pct)) return zone;
  }
  return zones.last;
});

/// 3-second rolling average of power — standard cycling smoothing.
final threeSecondAvgPowerProvider = Provider<Watts>((ref) {
  final history = ref.watch(powerHistoryProvider);
  if (history.isEmpty) return Watts.zero;
  final count = history.length < 3 ? history.length : 3;
  double sum = 0;
  for (int i = history.length - count; i < history.length; i++) {
    sum += history[i];
  }
  return Watts(sum / count);
});

/// Elapsed active ride time, ticking once per second.
final rideElapsedProvider = StreamProvider<Duration>((ref) {
  final engine = ref.watch(recordingEngineProvider);
  return Stream.periodic(const Duration(seconds: 1), (_) {
    final ride = engine.currentRide;
    if (ride == null) return Duration.zero;
    return ride.activeDuration;
  });
});

// ---------------------------------------------------------------------------
// Power & HR history ring buffers
// ---------------------------------------------------------------------------

/// Ring buffer holding the last 3600 power samples (1 hour at 1 Hz).
final powerHistoryProvider =
    StateNotifierProvider<_RingBufferNotifier, List<double>>((ref) {
  return _RingBufferNotifier();
});

/// Ring buffer holding the last 3600 HR samples (1 hour at 1 Hz).
final hrHistoryProvider =
    StateNotifierProvider<_RingBufferNotifier, List<double>>((ref) {
  return _RingBufferNotifier();
});

class _RingBufferNotifier extends StateNotifier<List<double>> {
  _RingBufferNotifier() : super([]);

  static const _maxSize = 3600;
  DateTime? _lastAdded;

  /// Adds a value, throttled to ~1 Hz (ignores calls within 900 ms).
  void add(double value) {
    final now = DateTime.now();
    if (_lastAdded != null &&
        now.difference(_lastAdded!).inMilliseconds < 900) {
      return;
    }
    _lastAdded = now;
    if (state.length >= _maxSize) {
      state = [...state.sublist(1), value];
    } else {
      state = [...state, value];
    }
  }

  void clear() => state = [];
}

/// Watch this in RideScreen to push live power into the ring buffer.
///
/// Mutations are scheduled via [Future.microtask] to avoid modifying providers
/// during initialization (a Riverpod restriction).
final powerHistoryUpdaterProvider = Provider<void>((ref) {
  final power = ref.watch(livePowerProvider);
  final recState = ref.watch(recordingStateProvider);
  recState.whenData((s) {
    if (s == RecordingState.recording) {
      Future.microtask(() => ref.read(powerHistoryProvider.notifier).add(power.value));
    }
  });
});

/// Watch this in RideScreen to push live HR into the ring buffer.
final hrHistoryUpdaterProvider = Provider<void>((ref) {
  final hr = ref.watch(liveHeartRateProvider);
  final recState = ref.watch(recordingStateProvider);
  recState.whenData((s) {
    if (s == RecordingState.recording) {
      Future.microtask(() => ref.read(hrHistoryProvider.notifier).add(hr.bpm.toDouble()));
    }
  });
});

// ---------------------------------------------------------------------------
// Ride screen configuration
// ---------------------------------------------------------------------------

final rideScreenConfigProvider =
    StateNotifierProvider<RideScreenConfigNotifier, RideScreenConfig>((ref) {
  return RideScreenConfigNotifier();
});

// ---------------------------------------------------------------------------
// Workout state
// ---------------------------------------------------------------------------

final currentWorkoutProvider = StateProvider<Workout?>((ref) => null);

final workoutListProvider = StateProvider<List<Workout>>((ref) => []);

// ---------------------------------------------------------------------------
// User profile & zones
// ---------------------------------------------------------------------------

final userProfileProvider = StateProvider<UserProfile?>((ref) => null);

final powerZonesProvider = Provider<List<PowerZone>>((ref) {
  final profile = ref.watch(userProfileProvider);
  if (profile == null) return [];
  return ZoneCalculator().calculateZones(profile.ftp);
});

// ---------------------------------------------------------------------------
// History (from database)
// ---------------------------------------------------------------------------

final rideHistoryProvider = FutureProvider<List<Ride>>((ref) async {
  final storage = ref.watch(storageProvider);
  return storage.getRides();
});

/// Loads a full ride with sensor readings and laps for the detail screen.
final rideDetailProvider = FutureProvider.family<Ride?, String>((ref, id) async {
  final storage = ref.watch(storageProvider);
  final ride = await storage.getRide(id);
  if (ride == null) return null;
  final readings = await storage.getSensorReadings(id);
  final laps = await storage.getLaps(id);
  return ride.copyWith(readings: readings, laps: laps);
});

// ---------------------------------------------------------------------------
// Physics & route simulation
// ---------------------------------------------------------------------------

final physicsEngineProvider = Provider<CyclingPhysicsEngine>((ref) {
  return CyclingPhysicsEngine();
});

/// Provides the active [TrainerPort] from [activeTrainerPortProvider].
/// Throws if no trainer is connected — only access when a device is connected.
final trainerPortProvider = Provider<TrainerPort>((ref) {
  final port = ref.watch(activeTrainerPortProvider);
  if (port == null) {
    throw StateError('No trainer connected — connect a device first');
  }
  return port;
});

final routeSimulatorProvider = Provider<RouteSimulator>((ref) {
  final sim = RouteSimulator(
    trainerPort: ref.watch(trainerPortProvider),
    eventBus: ref.watch(eventBusProvider),
    physics: ref.watch(physicsEngineProvider),
  );
  ref.onDispose(sim.dispose);
  return sim;
});

final simulationStateProvider = StreamProvider<SimulationState>((ref) {
  return ref.watch(routeSimulatorProvider).stateStream;
});

final simulationProgressProvider = StreamProvider<SimulationProgress>((ref) {
  return ref.watch(routeSimulatorProvider).progressStream;
});

// ---------------------------------------------------------------------------
// Export
// ---------------------------------------------------------------------------

/// Map of target name → [ExportPlugin]. Override in main() after registering
/// plugins in the [PluginRegistry].
final exportPluginsProvider = Provider<Map<String, ExportPlugin>>((ref) {
  final registry = ref.watch(pluginRegistryProvider);
  return {
    for (final plugin in registry.getExportPlugins())
      plugin.manifest.id: plugin,
  };
});

final exportQueueServiceProvider = Provider<ExportQueueService>((ref) {
  final service = ExportQueueService(
    db: ref.watch(appDatabaseProvider),
    storage: ref.watch(storageProvider),
    plugins: ref.watch(exportPluginsProvider),
  );
  ref.onDispose(service.dispose);
  service.start();
  return service;
});

final exportQueueProvider = StreamProvider<List<ExportQueueItem>>((ref) {
  return ref.watch(exportQueueServiceProvider).queueStream;
});

/// Strava authentication state — `true` if the Strava plugin is authenticated.
final stravaAuthProvider = Provider<bool>((ref) {
  final plugins = ref.watch(exportPluginsProvider);
  final strava = plugins['strava-export'];
  return strava?.isAuthenticated ?? false;
});

/// Action provider to export a [Ride] to a given target (e.g. 'strava-export').
///
/// Usage: `ref.read(exportRideProvider)('ride-id', 'strava-export');`
final exportRideProvider = Provider<Future<void> Function(String rideId, String target)>((ref) {
  final queueService = ref.watch(exportQueueServiceProvider);
  return queueService.enqueue;
});
