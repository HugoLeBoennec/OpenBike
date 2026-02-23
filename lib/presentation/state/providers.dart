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
import '../../core/application/services/services.dart';
import '../../infrastructure/ant/ant_usb_transport.dart';
import '../../infrastructure/ble/ble_transport.dart';
import '../../infrastructure/ble/ftms/ftms_device_plugin.dart';
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

/// Watch this in [RideScreen] to bridge [SensorEvent] from the [EventBus]
/// into the live UI providers ([livePowerProvider], [liveCadenceProvider], etc.).
///
/// Without this, the ride screen data fields stay at zero because nothing
/// pushes trainer data into the Riverpod state layer.
final _bridgeLog = Logger('LiveSensorBridge');

final liveSensorBridgeProvider = Provider<void>((ref) {
  final eventBus = ref.watch(eventBusProvider);
  _bridgeLog.info('[BLE-DEBUG] LiveSensorBridge listening for SensorEvents');
  final sub = eventBus.on<SensorEvent>().listen((event) {
    final r = event.reading;
    _bridgeLog.fine('[BLE-DEBUG] SensorEvent received — '
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

/// Mutable source of truth for Strava authentication state.
///
/// Updated by [main.dart] after [restoreSession] completes and after the
/// OAuth deep link callback is handled. The UI reads [stravaAuthProvider]
/// which is derived from this.
final stravaAuthStateProvider = StateProvider<bool>((ref) => false);

/// Strava authentication state — `true` if the Strava plugin is authenticated.
///
/// Backed by [stravaAuthStateProvider] so it rebuilds whenever the auth state
/// changes (e.g. after deep link callback or disconnect).
final stravaAuthProvider = Provider<bool>((ref) {
  return ref.watch(stravaAuthStateProvider);
});

/// Strava athlete display name, or `null` if not authenticated.
final stravaAthleteNameProvider = Provider<String?>((ref) {
  ref.watch(stravaAuthStateProvider); // rebuild when auth changes
  final plugins = ref.watch(exportPluginsProvider);
  return plugins['strava-export']?.athleteName;
});

/// Action provider to export a [Ride] to a given target (e.g. 'strava-export').
///
/// Usage: `ref.read(exportRideProvider)('ride-id', 'strava-export');`
final exportRideProvider = Provider<Future<void> Function(String rideId, String target)>((ref) {
  final queueService = ref.watch(exportQueueServiceProvider);
  return queueService.enqueue;
});

// ---------------------------------------------------------------------------
// Trainer difficulty (gradient scaling for SIM mode)
// ---------------------------------------------------------------------------

/// Gradient difficulty scalar (0.0–1.0).
///
/// Seeded from [AppPreferences] at startup. When changed, the new value is
/// propagated to any connected [FtmsTrainerAdapter] and must also be persisted
/// via [AppPreferences.setTrainerDifficulty].
final trainerDifficultyProvider = StateProvider<double>((ref) {
  return ref.read(appPreferencesProvider).trainerDifficulty;
});

// ---------------------------------------------------------------------------
// Trainer mode orchestration
// ---------------------------------------------------------------------------

/// Single source of truth for the current trainer control mode.
///
/// Listens to [WorkoutEvent] / [SimulationEvent] on the [EventBus] and
/// switches modes automatically. Exposed to the UI via [trainerModeProvider].
final trainerModeControllerProvider =
    StateNotifierProvider<TrainerModeController, TrainerModeState>((ref) {
  final eventBus = ref.watch(eventBusProvider);

  final controller = TrainerModeController(
    eventBus: eventBus,
    // Supply difficulty as a live callback so it always reflects the slider.
    getDefaultResistance: () => ref.read(trainerDifficultyProvider) * 10.0,
  );

  // Sync the trainer port whenever it changes.
  controller.setTrainerPort(ref.read(activeTrainerPortProvider));
  ref.listen(activeTrainerPortProvider, (_, port) {
    controller.setTrainerPort(port);
    // Propagate current difficulty immediately to any new FTMS adapter.
    if (port is FtmsTrainerAdapter) {
      port.difficulty = ref.read(trainerDifficultyProvider);
    }
  });

  // Propagate difficulty changes to the currently connected FTMS adapter.
  ref.listen(trainerDifficultyProvider, (_, difficulty) {
    final port = ref.read(activeTrainerPortProvider);
    if (port is FtmsTrainerAdapter) port.difficulty = difficulty;
  });

  ref.onDispose(controller.dispose);
  return controller;
});

/// The current [ControlMode] — convenient shorthand for widgets.
final trainerModeProvider = Provider<ControlMode>((ref) {
  return ref.watch(trainerModeControllerProvider).mode;
});

// ---------------------------------------------------------------------------
// Trainer status (physicalStop / safetyStop events)
// ---------------------------------------------------------------------------

/// Reflects stop events fired by the trainer hardware.
enum TrainerStatus { normal, stoppedByUser, safetyLimit }

final trainerStatusProvider =
    StateNotifierProvider<_TrainerStatusNotifier, TrainerStatus>((ref) {
  return _TrainerStatusNotifier(ref.watch(eventBusProvider));
});

class _TrainerStatusNotifier extends StateNotifier<TrainerStatus> {
  _TrainerStatusNotifier(EventBus eventBus) : super(TrainerStatus.normal) {
    _sub = eventBus.on<TrainerEvent>().listen(_onTrainerEvent);
  }

  StreamSubscription<TrainerEvent>? _sub;

  void _onTrainerEvent(TrainerEvent event) {
    event.maybeWhen(
      physicalStop: (_) => state = TrainerStatus.stoppedByUser,
      safetyStop: (_) => state = TrainerStatus.safetyLimit,
      connected: (_) => state = TrainerStatus.normal,
      orElse: () {},
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Resistance level — display helper (0–100 %)
// ---------------------------------------------------------------------------

/// Current resistance level as a display percentage (0–100).
///
/// Maps [TrainerModeState.resistanceLevel] (0–10 internal range) to
/// a 0–100 value suitable for showing in the UI.
final resistanceLevelProvider = Provider<double>((ref) {
  final level = ref.watch(trainerModeControllerProvider).resistanceLevel;
  return (level / 10.0 * 100).clamp(0.0, 100.0);
});

// ---------------------------------------------------------------------------
// Cadence target (set by WorkoutEngine in future; null = no target shown)
// ---------------------------------------------------------------------------

/// A min/max cadence target range displayed in ERG mode.
class CadenceRange {
  const CadenceRange({required this.min, required this.max});
  final int min;
  final int max;
}

final cadenceTargetProvider = StateProvider<CadenceRange?>((ref) => null);

// ---------------------------------------------------------------------------
// ERG target watts — UI-writable, sent to trainer via switchMode
// ---------------------------------------------------------------------------

class _ErgWattsNotifier extends StateNotifier<int> {
  _ErgWattsNotifier() : super(150);

  static const _min = 0;
  static const _max = 2000;

  void adjust(int delta) => state = (state + delta).clamp(_min, _max);
}

final ergTargetWattsProvider =
    StateNotifierProvider<_ErgWattsNotifier, int>((ref) => _ErgWattsNotifier());
