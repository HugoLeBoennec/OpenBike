import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/ports/storage_port.dart';
import '../../core/domain/ports/trainer_port.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../core/events/app_event.dart';
import '../../core/events/event_bus.dart';
import '../../core/application/services/background_recording_service.dart';
import '../../core/application/services/connection_monitor.dart';
import '../../core/application/services/device_pairing_service.dart';
import '../../core/application/services/services.dart';
import '../../infrastructure/ant/ant_usb_transport.dart';
import '../../infrastructure/ble/ble_transport.dart';
import '../../infrastructure/ble/ftms/ftms_control_client.dart'
    show PowerRange, ResistanceLevelRange;
import '../../infrastructure/ble/ftms/ftms_device_plugin.dart'
    show FtmsTrainerAdapter;
import '../../infrastructure/ble/sensors/sensor_fusion.dart';
import '../../infrastructure/foreground/foreground_service_controller.dart';
import '../../infrastructure/preferences/app_preferences.dart';
import '../../infrastructure/simulator/simulator.dart';
import '../../infrastructure/persistence/persistence.dart';
import '../../plugins/plugin_interfaces.dart';
import '../../plugins/plugin_registry.dart';
import '../format/unit_formatter.dart';
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
// App metadata
// ---------------------------------------------------------------------------

/// Version and build number read from the platform bundle, so the About
/// screen always reflects `pubspec.yaml`'s `version:` (and the store build
/// number derived from it) rather than a hand-synced string literal.
final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

/// Display form of [packageInfoProvider] — `1.0.0 (1)`. Empty while the
/// platform channel call is still in flight, and on the error path: a
/// version string is decoration on the About screen, never worth an error
/// state in the UI.
final appVersionProvider = Provider<String>((ref) {
  return ref.watch(packageInfoProvider).maybeWhen(
        data: (info) => '${info.version} (${info.buildNumber})',
        orElse: () => '',
      );
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

/// Metric/imperial number formatter derived from [unitSystemProvider] —
/// the single place widgets should go for distance/speed/weight/height
/// display strings instead of converting inline.
final unitFormatterProvider = Provider<UnitFormatter>((ref) {
  final system = ref.watch(unitSystemProvider);
  return UnitFormatter(unitSystemFromString(system));
});

final themeModeProvider = StateProvider<String>((ref) {
  return ref.read(appPreferencesProvider).themeMode;
});

final autoPauseEnabledProvider = StateProvider<bool>((ref) {
  return ref.read(appPreferencesProvider).autoPauseEnabled;
});

/// Opt-in crash reporting toggle (see docs/release/analytics.md). Callers
/// that flip it also call `CrashReportingService.apply`, which starts or
/// closes Sentry immediately without an app restart.
final crashReportingEnabledProvider = StateProvider<bool>((ref) {
  return ref.read(appPreferencesProvider).crashReportingEnabled;
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
// Background recording (Android foreground service)
// ---------------------------------------------------------------------------

/// Android uses a real foreground service; every other platform gets a
/// no-op (iOS relies on the `bluetooth-central` background mode instead).
final foregroundServiceControllerProvider =
    Provider<ForegroundServiceController>((ref) {
  if (Platform.isAndroid) return FlutterForegroundTaskController();
  return const NoopForegroundServiceController();
});

/// Starts/stops the foreground service with [RecordingEngine]'s lifecycle.
/// Watch this once from [RideScreen] so it's alive before recording starts.
final backgroundRecordingServiceProvider =
    Provider<BackgroundRecordingService>((ref) {
  final service = BackgroundRecordingService(
    recordingEngine: ref.watch(recordingEngineProvider),
    controller: ref.watch(foregroundServiceControllerProvider),
  );
  ref.onDispose(service.dispose);
  return service;
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

/// The ride in progress with its samples so far, refreshed once per second.
/// The engine instance never changes, so a plain `Provider` here would be
/// read once and never update — which left avg power, NP, distance, TSS, IF
/// and calories stuck at their empty values for the whole ride.
final currentRideProvider = StreamProvider<Ride?>((ref) async* {
  final engine = ref.watch(recordingEngineProvider);
  yield engine.liveRide;
  yield* Stream.periodic(const Duration(seconds: 1), (_) => engine.liveRide);
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

/// Live connection state of a [SensorRole]'s paired device.
///
/// [lost] and [notConnected] both mean "no data is flowing", but they need
/// different UI: a mid-session dropout is retried automatically by
/// `BleTransport`, whereas a device that never connected is not — the user
/// has to trigger a reconnect themselves.
enum RoleConnection {
  /// A live connection is open.
  connected,

  /// Was connected during this session and dropped — auto-retry is running.
  lost,

  /// No connection: never established this session, or an attempt failed.
  notConnected,
}

/// Tracks connection state per [SensorRole], from [TrainerEvent]s on the
/// [EventBus] correlated against [PairedDevices], plus explicit
/// [markConnected]/[markFailed] calls from the connect paths.
///
/// A role with no entry means "nothing observed yet" — callers must treat
/// that as *unknown*, not *connected*, and fall back to the pairing
/// service's live ports (see [roleConnectionProvider]). Being paired is a
/// saved preference that survives restarts; it says nothing about whether
/// the device is reachable right now.
class RoleConnectionNotifier
    extends StateNotifier<Map<SensorRole, RoleConnection>> {
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
      connected: (e) => _setStatus(e.device.id, RoleConnection.connected),
      // A drop for a device we'd seen connected — BleTransport retries it.
      disconnected: (e) => _setStatus(e.deviceId, RoleConnection.lost),
      controlAcquired: (_) {},
      modeChanged: (_) {},
    );
  }

  /// Records that [role] connected successfully.
  void markConnected(SensorRole role) {
    state = {...state, role: RoleConnection.connected};
  }

  /// Records that a connect attempt for [role] failed. Called by the
  /// auto-reconnect and manual-connect paths so a failure is visible in the
  /// UI rather than silently absent.
  void markFailed(SensorRole role) {
    state = {...state, role: RoleConnection.notConnected};
  }

  /// Drops [role]'s entry — used when a role is forgotten, so a later
  /// re-pair starts from "unknown" rather than a stale verdict.
  void clearRole(SensorRole role) {
    state = {...state}..remove(role);
  }

  void _setStatus(String deviceId, RoleConnection status) {
    final role = _getPairedDevices().roleForDevice(deviceId);
    if (role == null) return;
    state = {...state, role: status};
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final roleConnectionStatusProvider = StateNotifierProvider<
    RoleConnectionNotifier, Map<SensorRole, RoleConnection>>((ref) {
  return RoleConnectionNotifier(
    eventBus: ref.watch(eventBusProvider),
    getPairedDevices: () => ref.read(pairedDevicesProvider),
  );
});

/// Resolved connection state for every role — the single source of truth
/// behind each connection indicator in the UI.
///
/// Observed state wins; where nothing has been observed we fall back to
/// whether [DevicePairingService] actually holds an open port, so a role
/// can never render as connected merely because a pairing was saved.
final roleConnectionProvider =
    Provider<Map<SensorRole, RoleConnection>>((ref) {
  final observed = ref.watch(roleConnectionStatusProvider);
  final service = ref.watch(devicePairingServiceProvider);
  return {
    for (final role in SensorRole.values)
      role: observed[role] ??
          (service.portForRole(role) != null
              ? RoleConnection.connected
              : RoleConnection.notConnected),
  };
});

/// Roles that are paired but have no live connection — drives the in-ride
/// connection banner. Covers both a mid-ride dropout and a device that
/// never came back after a restart.
final disconnectedPairedRolesProvider = Provider<List<SensorRole>>((ref) {
  final paired = ref.watch(pairedDevicesProvider);
  final connection = ref.watch(roleConnectionProvider);
  return [
    for (final role in paired.byRole.keys)
      if (connection[role] != RoleConnection.connected) role,
  ];
});

final _autoReconnectLog = Logger('AutoReconnectPairedRoles');

/// Watch this once near app start (e.g. from `HomeScreen`) to attempt
/// reconnecting every saved role pairing.
///
/// A [Provider] body only runs once per [ProviderScope] lifetime — reading
/// [pairedDevicesProvider] with `ref.read` (a snapshot, not a subscription)
/// means this fires exactly once rather than on every future role change.
///
/// Roles are reconnected **concurrently**: a device that isn't powered on
/// burns the full BLE connect timeout (15s), and connecting them in
/// sequence made one absent device delay every other device behind it by
/// that much — a trainer left off would stall a worn HR strap for 15s.
final autoReconnectPairedRolesProvider = Provider<void>((ref) {
  if (ref.watch(devModeProvider)) return; // simulator builds skip real BLE

  final paired = ref.read(pairedDevicesProvider);
  final service = ref.read(devicePairingServiceProvider);

  Future.microtask(() async {
    await Future.wait([
      for (final entry in paired.byRole.entries)
        _reconnectRole(ref, service, entry.key, entry.value),
    ]);
  });
});

/// Reconnects one saved role, best-effort. Never throws — a failure is
/// recorded and logged so it can't take down the other roles' attempts.
Future<void> _reconnectRole(
  Ref ref,
  DevicePairingService service,
  SensorRole role,
  PairedDevice saved,
) async {
  if (service.portForRole(role) != null) return;

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
    ref.read(roleConnectionStatusProvider.notifier).markConnected(role);
    _autoReconnectLog.info('Auto-reconnected $role → ${saved.name}');
  } catch (e) {
    // Record the failure rather than only logging it — otherwise the role
    // keeps rendering as connected and the user gets a paired device that
    // silently produces no data.
    ref.read(roleConnectionStatusProvider.notifier).markFailed(role);
    _autoReconnectLog.warning(
        'Auto-reconnect failed for $role (${saved.name}): $e');
  }
}

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
    final ride = engine.liveRide;
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

/// Drives a structured workout against the connected trainer. Mirrors the
/// [routeSimulatorProvider] pattern: created lazily, requires a connected
/// trainer, started explicitly from [RideScreen].
final workoutEngineProvider = Provider<WorkoutEngine>((ref) {
  final engine = WorkoutEngine(
    trainerPort: ref.watch(trainerPortProvider),
    eventBus: ref.watch(eventBusProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
});

final workoutEngineStateProvider = StreamProvider<WorkoutEngineState>((ref) {
  return ref.watch(workoutEngineProvider).stateStream;
});

final workoutProgressProvider = StreamProvider<WorkoutProgress>((ref) {
  return ref.watch(workoutEngineProvider).progressStream;
});

/// Which bundled FTP test protocol (if any) is driving the ride currently
/// starting. Set by [RideScreen] when the started workout's id matches one
/// of [BundledWorkouts.rampTestId] / [BundledWorkouts.twentyMinTestId];
/// consumed once by `FtpTestPrompt` on the ride-summary screen, which
/// clears it back to null after showing the update-profile prompt.
final activeFtpTestProvider = StateProvider<FtpTestProtocol?>((ref) => null);

/// Every dated FTP value on record, oldest first — the raw material for the
/// FTP test screen's progression chart and retest reminder.
final ftpHistoryProvider = FutureProvider<List<FtpHistoryEntry>>((ref) async {
  return ref.watch(storageProvider).getFtpHistory();
});

/// Days between FTP tests before the app nudges for another (see Settings).
final ftpRetestIntervalProvider = StateProvider<int>((ref) {
  return ref.read(appPreferencesProvider).ftpRetestIntervalDays;
});

/// When the rider last tested, whether another test is due, and which
/// protocol to steer them toward. Null while the history is still loading.
final ftpTestPlanProvider = Provider<FtpTestPlan?>((ref) {
  final history = ref.watch(ftpHistoryProvider).valueOrNull;
  if (history == null) return null;
  return FtpTestPlanner.plan(
    ftpHistory: history,
    now: DateTime.now(),
    intervalDays: ref.watch(ftpRetestIntervalProvider),
  );
});

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
// Training calendar (scheduled workouts)
// ---------------------------------------------------------------------------

final scheduledWorkoutsProvider =
    FutureProvider<List<ScheduledWorkout>>((ref) async {
  final storage = ref.watch(storageProvider);
  return storage.getScheduledWorkouts();
});

/// Scheduled workouts falling on today's date, for the home screen's "Today"
/// card.
final todaysScheduledWorkoutsProvider =
    Provider<AsyncValue<List<ScheduledWorkout>>>((ref) {
  final all = ref.watch(scheduledWorkoutsProvider);
  return all.whenData((list) {
    final now = DateTime.now();
    return list
        .where((s) =>
            s.date.year == now.year &&
            s.date.month == now.month &&
            s.date.day == now.day)
        .toList();
  });
});

/// Set by [RideScreen] when started from a scheduled calendar entry (via
/// [RideExtra.scheduledWorkoutId]) so [scheduledWorkoutLinkerProvider] can
/// link the finished ride back to it once recording stops.
final activeScheduledWorkoutIdProvider = StateProvider<String?>((ref) => null);

/// Watch this once from [RideScreen] to auto-link a finished ride back to
/// the scheduled workout it was started from.
final scheduledWorkoutLinkerProvider = Provider<void>((ref) {
  final storage = ref.watch(storageProvider);
  final eventBus = ref.watch(eventBusProvider);
  final sub = eventBus.on<RideEvent>().listen((event) {
    if (event is! RideStopped) return;
    final scheduledId = ref.read(activeScheduledWorkoutIdProvider);
    if (scheduledId == null) return;
    ref.read(activeScheduledWorkoutIdProvider.notifier).state = null;
    storage.linkCompletedRide(scheduledId, event.ride.id).then((_) {
      ref.invalidate(scheduledWorkoutsProvider);
    });
  });
  ref.onDispose(sub.cancel);
});

// ---------------------------------------------------------------------------
// Personal records
// ---------------------------------------------------------------------------

final personalRecordsProvider =
    FutureProvider<List<PersonalRecord>>((ref) async {
  final storage = ref.watch(storageProvider);
  return storage.getPersonalRecords();
});

/// Best (highest-watts) record per duration bucket, scoped to all-time or
/// the last 90 days.
Map<int, PersonalRecord> bestPerDuration(
  List<PersonalRecord> records, {
  bool last90DaysOnly = false,
}) {
  final cutoff = DateTime.now().subtract(const Duration(days: 90));
  final best = <int, PersonalRecord>{};
  for (final r in records) {
    if (last90DaysOnly && r.achievedAt.isBefore(cutoff)) continue;
    final current = best[r.durationSeconds];
    if (current == null || r.watts.value > current.watts.value) {
      best[r.durationSeconds] = r;
    }
  }
  return best;
}

/// Duration buckets (of [personalRecordDurations]) where [rideId] holds the
/// all-time best — drives the "New PR!" badge on the ride summary screen.
final newPersonalRecordsForRideProvider =
    Provider.family<List<int>, String>((ref, rideId) {
  final records = ref.watch(personalRecordsProvider).valueOrNull ?? [];
  final best = bestPerDuration(records);
  return [
    for (final entry in best.entries)
      if (entry.value.rideId == rideId) entry.key,
  ]..sort();
});

// ---------------------------------------------------------------------------
// Performance Management Chart (CTL / ATL / TSB)
// ---------------------------------------------------------------------------

final fitnessHistoryProvider =
    FutureProvider<List<FitnessDataPoint>>((ref) async {
  final storage = ref.watch(storageProvider);
  final rides = await storage.getRides();
  final ftpHistory = await storage.getFtpHistory();
  final currentFtp = ref.watch(ftpProvider);
  final daily = dailyTssFromRides(
    rides,
    ftpHistory: ftpHistory,
    currentFtp: currentFtp,
  );
  return FitnessCalculator().calculate(daily);
});

/// Today's fitness point (or null if there's no ride history yet) — drives
/// the home screen's compact CTL/TSB sparkline.
final currentFitnessProvider = Provider<FitnessDataPoint?>((ref) {
  final points = ref.watch(fitnessHistoryProvider).valueOrNull;
  if (points == null || points.isEmpty) return null;
  return points.last;
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

/// Toggles the OSM mini-map in [RouteProfilePane]. Off by default — it's a
/// stretch feature (P3 task 3) layered on top of the elevation profile.
final showMiniMapProvider = StateProvider<bool>((ref) => false);

// ---------------------------------------------------------------------------
// Manual trainer control (P11: on-the-fly ERG/resistance/SIM difficulty)
// ---------------------------------------------------------------------------

/// Last manually-set ERG target power, watts. Seeded from [AppPreferences]
/// and persisted by [ManualTrainerControls] on every change.
final ergTargetWattsProvider = StateProvider<double>((ref) {
  return ref.read(appPreferencesProvider).lastErgWatts;
});

/// Last manually-set resistance level. Seeded from [AppPreferences].
final resistanceLevelProvider = StateProvider<double>((ref) {
  return ref.read(appPreferencesProvider).lastResistanceLevel;
});

/// Gradient difficulty scalar (0.0–1.0) applied to SIM mode grade.
///
/// Seeded from [AppPreferences]. Propagated to the connected
/// [FtmsTrainerAdapter] below and persisted via
/// [AppPreferences.setTrainerDifficulty].
final trainerDifficultyProvider = StateProvider<double>((ref) {
  return ref.read(appPreferencesProvider).trainerDifficulty;
});

/// Supported power range read from the connected FTMS trainer's
/// capabilities (0x2AD8) — used to clamp/step [ManualTrainerControls]'s ERG
/// stepper. Falls back to [PowerRange.defaultRange] for non-FTMS trainers
/// (simulator, ANT+) or when nothing is connected.
final ergPowerRangeProvider = Provider<PowerRange>((ref) {
  final port = ref.watch(activeTrainerPortProvider);
  if (port is FtmsTrainerAdapter) return port.controlClient.powerRange;
  return PowerRange.defaultRange;
});

/// Supported resistance level range read from the connected FTMS trainer's
/// capabilities (0x2AD6). Falls back to [ResistanceLevelRange.defaultRange].
final resistanceRangeProvider = Provider<ResistanceLevelRange>((ref) {
  final port = ref.watch(activeTrainerPortProvider);
  if (port is FtmsTrainerAdapter) return port.controlClient.resistanceRange;
  return ResistanceLevelRange.defaultRange;
});

/// Single source of truth for the current trainer control mode. Listens to
/// [WorkoutEvent] / [SimulationEvent] on the [EventBus] and switches modes
/// automatically; exposed to the UI via [trainerModeProvider]. Also the
/// single writer of mode-transition commands to [TrainerPort] — see
/// [TrainerModeController]'s doc comment for the ownership split with
/// [WorkoutEngine] / [RouteSimulator]'s existing per-tick writes.
final trainerModeControllerProvider =
    StateNotifierProvider<TrainerModeController, TrainerModeState>((ref) {
  final controller = TrainerModeController(
    eventBus: ref.watch(eventBusProvider),
    getDefaultResistance: () => ref.read(resistanceLevelProvider),
  );

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

/// Action provider to export a [Ride] to a given target (e.g. 'strava-export').
///
/// Usage: `ref.read(exportRideProvider)('ride-id', 'strava-export');`
final exportRideProvider = Provider<Future<void> Function(String rideId, String target)>((ref) {
  final queueService = ref.watch(exportQueueServiceProvider);
  return queueService.enqueue;
});

/// Watch this once from [RideScreen] to auto-enqueue exports for every
/// service the user has enabled auto-upload for (Settings → Connections),
/// as soon as a ride finishes recording.
final autoUploadProvider = Provider<void>((ref) {
  final eventBus = ref.watch(eventBusProvider);
  final sub = eventBus.on<RideEvent>().listen((event) {
    if (event is! RideStopped) return;
    final targets = ref.read(appPreferencesProvider).autoUploadTargets;
    if (targets.isEmpty) return;

    final plugins = ref.read(exportPluginsProvider);
    final queueService = ref.read(exportQueueServiceProvider);
    for (final target in targets) {
      final plugin = plugins[target];
      if (plugin != null && plugin.isAuthenticated) {
        queueService.enqueue(event.ride.id, target);
      }
    }
  });
  ref.onDispose(sub.cancel);
});
