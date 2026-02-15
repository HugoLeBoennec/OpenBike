import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/domain/entities/entities.dart';
import '../../core/domain/ports/storage_port.dart';
import '../../core/domain/ports/trainer_port.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../core/events/event_bus.dart';
import '../../core/application/services/services.dart';
import '../../infrastructure/persistence/persistence.dart';
import '../../plugins/plugin_interfaces.dart';
import '../../plugins/plugin_registry.dart';

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
// Ride state
// ---------------------------------------------------------------------------

final currentRideProvider = Provider<Ride?>((ref) {
  return ref.watch(recordingEngineProvider).currentRide;
});

// ---------------------------------------------------------------------------
// Trainer state
// ---------------------------------------------------------------------------

final trainerDeviceProvider = StateProvider<TrainerDevice?>((ref) => null);

final trainerListProvider = StateProvider<List<TrainerDevice>>((ref) => []);

// ---------------------------------------------------------------------------
// Live sensor data
// ---------------------------------------------------------------------------

final livePowerProvider = StateProvider<Watts>((ref) => Watts.zero);

final liveCadenceProvider = StateProvider<Cadence>((ref) => Cadence.zero);

final liveHeartRateProvider = StateProvider<HeartRate>((ref) => HeartRate.zero);

final liveSpeedProvider = StateProvider<Speed>((ref) => Speed.zero);

final sensorReadingsProvider = StateProvider<List<SensorReading>>((ref) => []);

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

// ---------------------------------------------------------------------------
// Physics & route simulation
// ---------------------------------------------------------------------------

final physicsEngineProvider = Provider<CyclingPhysicsEngine>((ref) {
  return CyclingPhysicsEngine();
});

/// Override [trainerPortProvider] with the actual BLE trainer adapter.
final trainerPortProvider = Provider<TrainerPort>((ref) {
  throw UnimplementedError(
    'trainerPortProvider must be overridden with a platform-specific adapter',
  );
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
