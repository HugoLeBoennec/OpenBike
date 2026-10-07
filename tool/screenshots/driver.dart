// App Store screenshot driver — a separate Flutter entrypoint, NOT part of
// the shipped app (nothing under lib/ imports it). Run it through
// tool/screenshots/take_screenshots.sh, which builds it from a scratch copy of
// the repo with `-t tool/screenshots/driver.dart --dart-define=DEV_MODE=true`.
//
// Seeds an in-memory database and in-memory preferences with generic data
// (nothing is read from or written to a real app container), connects the
// DEV_MODE simulator trainer, then walks through each screen. On iOS it prints
// `OPENBIKE_SHOT <name>` and holds the screen while the host captures it with
// `xcrun simctl io <udid> screenshot`; on macOS it renders the window content
// itself at 2x (so the capture doesn't depend on a Retina display) and prints
// `OPENBIKE_SAVED <name> <path>`.
//
// `--dart-define=SHOTS=static,ftp,route,workout` limits the run to those
// passes (default: all).

// print() is the host protocol here, and setMockInitialValues is what keeps
// preferences in memory instead of touching a real container.
// ignore_for_file: avoid_print, invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'package:open_bike/core/application/services/bundled_workouts.dart';
import 'package:open_bike/core/application/services/services.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/ble/ble_transport.dart';
import 'package:open_bike/infrastructure/desktop/desktop_window_service.dart';
import 'package:open_bike/infrastructure/files/gpx_parser.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/infrastructure/simulator/simulator.dart';
import 'package:open_bike/main.dart' show OpenBikeApp;
import 'package:open_bike/plugins/plugin_interfaces.dart';
import 'package:open_bike/plugins/plugin_manifest.dart';
import 'package:open_bike/plugins/plugin_registry.dart';
import 'package:open_bike/presentation/models/ride_extra.dart';
import 'package:open_bike/presentation/router.dart';
import 'package:open_bike/presentation/state/providers.dart';

final _boundaryKey = GlobalKey();

const _customWorkoutId = 'custom-threshold-ladder';

/// Workout ride is captured this far in (warm-up is 600 s, so ~1:40 into the
/// first sweet-spot block).
const _workoutShotAtSeconds = 700;

/// Route ride is captured once this far along — on the 1.2 % drag before the
/// first climb, which is visible ahead. Steeper sections ask the simulator for
/// implausible watts: its virtual speed stays near 30 km/h whatever the grade.
const _routeShotAtMeters = 1450.0;

const _trainer = TrainerDevice(
  id: 'simulator-0',
  name: 'Smart Trainer',
  manufacturer: 'OpenBike',
  protocol: DeviceProtocol.simulator,
  isControllable: true,
  supportedModes: [
    ControlMode.erg,
    ControlMode.simulation,
    ControlMode.resistance,
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences.setMockInitialValues({
    'onboarding_completed': true,
    'has_asked_crash_reporting_consent': true,
    'has_backfilled_personal_records': true,
    'theme_mode': 'dark',
    'unit_system': 'metric',
  });
  final appPrefs = AppPreferences(await SharedPreferences.getInstance());

  final db = AppDatabase(NativeDatabase.memory());
  final storage = DriftStorage(db);
  final eventBus = EventBus();
  final registry = PluginRegistry()
    ..registerDevice(_ShotSimulatorPlugin(eventBus));

  final seeded = await _seed(db, storage);
  final workouts = await storage.getWorkouts();

  if (Platform.isMacOS) {
    await initializeDesktopWindow(appPrefs);
    final titleBar = await windowManager.getTitleBarHeight();
    await windowManager.setSize(Size(1440, 900 + titleBar.toDouble()));
    await windowManager.center();
  }

  final router = createAppRouter(hasCompletedOnboarding: true);
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      eventBusProvider.overrideWithValue(eventBus),
      pluginRegistryProvider.overrideWithValue(registry),
      bleTransportProvider.overrideWithValue(BleTransport()),
      appPreferencesProvider.overrideWithValue(appPrefs),
      savedDeviceIdsProvider.overrideWith((ref) => appPrefs.savedDeviceIds),
      pairedDevicesProvider.overrideWith((ref) => appPrefs.pairedDevices),
      userProfileProvider.overrideWith((ref) => seeded.profile),
      workoutListProvider.overrideWith((ref) => workouts),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: RepaintBoundary(
        key: _boundaryKey,
        child: OpenBikeApp(router: router),
      ),
    ),
  );

  // A backgrounded or occluded macOS window gets no display refresh, hence no
  // frames: captures waiting on the next frame would hang, and Riverpod
  // (which flushes provider updates on frames) would stall the ride passes.
  // Drive frames from a timer instead of the display.
  if (Platform.isMacOS) {
    Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => SchedulerBinding.instance.scheduleWarmUpFrame(),
    );
  }

  unawaited(_script(container, router, seeded.route));
}

// ---------------------------------------------------------------------------
// Capture script
// ---------------------------------------------------------------------------

Future<void> _script(ProviderContainer c, GoRouter router, Route route) async {
  await Future<void>.delayed(const Duration(seconds: 4));
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  print(
    'OPENBIKE_VIEW ${view.physicalSize / view.devicePixelRatio} '
    '@${view.devicePixelRatio}x',
  );

  // `--dart-define=SHOTS=ftp,route` re-takes only those passes.
  const shots = String.fromEnvironment('SHOTS', defaultValue: 'all');
  bool want(String pass) => shots == 'all' || shots.split(',').contains(pass);

  if (want('static')) {
    router.go('/trends');
    await _shot('05-trends');

    router.go('/workouts');
    await _shot('03-workout-library');

    router.go('/workouts/edit/$_customWorkoutId');
    await _shot('04-workout-editor');
  }

  if (want('ftp')) {
    router.go('/ftp-test');
    await _shot('06-ftp-test');
    if (await _scrollTo('FTP OVER TIME')) await _shot('07-ftp-history');
  }

  if (want('route') || want('workout')) await _connectTrainer(c);

  // --- Route simulation ride (first, from a clean trainer-mode state) ---
  if (want('route')) {
    // In SIM mode the simulator holds roughly whatever speed it had before
    // (then random-walks), so a short ERG pre-roll sets a ~31 km/h start and
    // keeps the captured watts in a plausible endurance range.
    await c.read(activeTrainerPortProvider)!.setTargetPower(const Watts(200));
    await Future<void>.delayed(const Duration(seconds: 10));

    router.go('/ride', extra: RideExtra(route: route));
    await Future<void>.delayed(const Duration(seconds: 2));
    await c.read(recordingEngineProvider).start();
    await _waitFor<SimulationProgress>(
      c,
      simulationProgressProvider,
      (p) => p.distanceCovered.meters >= _routeShotAtMeters,
    );
    await _shot('02-route-simulation');

    c.read(routeSimulatorProvider).stop();
    await c.read(recordingEngineProvider).stop(ftp: c.read(ftpProvider));
    c.read(powerHistoryProvider.notifier).clear();
    c.read(hrHistoryProvider.notifier).clear();
    router.go('/');
    await Future<void>.delayed(const Duration(seconds: 3));
  }

  // --- Structured workout ride ---
  if (want('workout')) {
    router.go('/ride', extra: RideExtra(workout: _rideWorkout()));
    await Future<void>.delayed(const Duration(seconds: 2));
    await c.read(recordingEngineProvider).start();
    await _waitFor<WorkoutProgress>(
      c,
      workoutProgressProvider,
      (p) => p.totalElapsed.inSeconds >= _workoutShotAtSeconds,
    );
    await _shot('01-ride-workout');
  }

  print('OPENBIKE_DONE');
}

Future<void> _waitFor<T>(
  ProviderContainer c,
  ProviderListenable<AsyncValue<T>> provider,
  bool Function(T) done,
) async {
  final completer = Completer<void>();
  var lastLog = DateTime.now();
  final sub = c.listen<AsyncValue<T>>(provider, (_, next) {
    final value = next.valueOrNull;
    if (value == null || completer.isCompleted) return;
    if (DateTime.now().difference(lastLog).inSeconds >= 30) {
      lastLog = DateTime.now();
      print('OPENBIKE_WAIT $value');
    }
    if (done(value)) completer.complete();
  });
  await completer.future;
  sub.close();
}

Future<void> _shot(String name) async {
  // Let route transitions, chart animations and async providers settle.
  await Future<void>.delayed(const Duration(milliseconds: 2500));
  await WidgetsBinding.instance.endOfFrame;

  if (Platform.isMacOS) {
    final boundary =
        _boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory(
      p.join((await getTemporaryDirectory()).path, 'openbike-shots'),
    )..createSync(recursive: true);
    final file = File(p.join(dir.path, '$name.png'));
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    print('OPENBIKE_SAVED $name ${file.path}');
  } else {
    print('OPENBIKE_SHOT $name');
    await Future<void>.delayed(const Duration(seconds: 4));
  }
}

/// Scrolls the current page so the text [label] sits near the top. Returns
/// false when it was already on screen without scrolling (nothing new to
/// capture) or isn't found.
Future<bool> _scrollTo(String label) async {
  Element? find(bool Function(Element) match) {
    Element? hit;
    void visit(Element e) {
      if (hit != null) return;
      if (match(e)) {
        hit = e;
        return;
      }
      e.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
    return hit;
  }

  bool isLabel(Element e) =>
      e.widget is Text && (e.widget as Text).data == label;

  // The page is usually a lazy ListView: step down until the label is built.
  final scrollable = find(
    (e) =>
        e is StatefulElement &&
        e.state is ScrollableState &&
        (e.state as ScrollableState).position.axis == Axis.vertical &&
        (e.state as ScrollableState).position.maxScrollExtent > 0,
  );
  if (scrollable == null) return false;
  final position =
      ((scrollable as StatefulElement).state as ScrollableState).position;
  final before = position.pixels;

  var target = find(isLabel);
  while (target == null && position.pixels < position.maxScrollExtent) {
    position.jumpTo(
      min(
        position.pixels + position.viewportDimension * 0.5,
        position.maxScrollExtent,
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
    target = find(isLabel);
  }
  if (target == null) return false;
  await Scrollable.ensureVisible(target, alignment: 0.02);
  return (position.pixels - before).abs() > 200;
}

Future<void> _connectTrainer(ProviderContainer c) async {
  final port = await c
      .read(devicePairingServiceProvider)
      .assign(SensorRole.trainer, _trainer);
  c.read(trainerDeviceProvider.notifier).state = _trainer;
  c.read(activeTrainerPortProvider.notifier).state = port;
  c.read(pairedDevicesProvider.notifier).state = c
      .read(pairedDevicesProvider)
      .withRole(
        SensorRole.trainer,
        PairedDevice(
          deviceId: _trainer.id,
          name: _trainer.name,
          protocol: _trainer.protocol,
        ),
      );
  c
      .read(roleConnectionStatusProvider.notifier)
      .markConnected(SensorRole.trainer);
}

/// The DEV_MODE [FakeTrainer], with its heart-rate model calibrated so a
/// rider at ~250 W FTP shows plausible heart rates (the stock plugin assumes
/// a 200 W FTP, which pins HR at the 200 bpm clamp on threshold efforts).
class _ShotSimulatorPlugin implements DevicePlugin {
  _ShotSimulatorPlugin(this._eventBus);

  final EventBus _eventBus;

  @override
  PluginManifest get manifest => const PluginManifest(
    id: 'openbike.simulator',
    name: 'Virtual Trainer',
    version: '0.1.0',
    type: PluginType.device,
    author: 'OpenBike',
    description: 'Simulated trainer for screenshots.',
    capabilities: ['erg', 'simulation', 'resistance'],
  );

  @override
  bool canHandle(TrainerDevice device) =>
      device.protocol == DeviceProtocol.simulator;

  @override
  Future<List<TrainerDevice>> scan(Duration timeout) async => const [_trainer];

  @override
  Future<TrainerPort> connect(TrainerDevice device) async {
    final trainer = FakeTrainer(
      eventBus: _eventBus,
      physics: CyclingPhysicsEngine(),
      deviceId: device.id,
      ftp: 300,
    );
    await trainer.initialize();
    return trainer;
  }
}

// ---------------------------------------------------------------------------
// Seed data — generic, synthetic, no real people
// ---------------------------------------------------------------------------

class _Seeded {
  _Seeded(this.profile, this.route);
  final UserProfile profile;
  final Route route;
}

Future<_Seeded> _seed(AppDatabase db, DriftStorage storage) async {
  final today = _today();

  // FTP progression: an initial typed-in guess, two ramp tests, then two
  // 20-minute tests. The last test is 38 days old, so with the default
  // 42-day interval the retest reminder reads "due soon".
  final ftpHistory = [
    (170, 222.0, FtpSource.manual),
    (150, 228.0, FtpSource.rampTest),
    (108, 236.0, FtpSource.rampTest),
    (66, 244.0, FtpSource.twentyMinuteTest),
    (38, 251.0, FtpSource.twentyMinuteTest),
  ];
  for (final (daysAgo, ftp, source) in ftpHistory) {
    final date = today
        .subtract(Duration(days: daysAgo))
        .add(const Duration(hours: 18, minutes: 50));
    await db
        .into(db.ftpHistory)
        .insert(
          FtpHistoryCompanion.insert(
            effectiveDate: date.millisecondsSinceEpoch,
            ftp: ftp,
            source: Value(source.name),
          ),
        );
  }

  const profile = UserProfile(
    ftp: Watts(251),
    weight: 72,
    height: 1.78,
    restingHr: HeartRate(52),
    maxHr: HeartRate(188),
    name: 'Rider',
  );
  await storage.saveProfile(profile);

  await BundledWorkouts.seedIfNeeded(storage);
  await storage.saveWorkout(_customWorkout());

  await _seedRides(storage, await storage.getFtpHistory());
  await backfillPersonalRecords(storage);

  return _Seeded(
    profile,
    GpxRouteParser().parse(_routeGpx(), name: 'Rolling Hills Loop'),
  );
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

Workout _customWorkout() {
  return WorkoutBuilder(
        'Threshold Ladder',
        description:
            '3, 5 and 7 minutes around FTP, then four short '
            'over-threshold surges.',
      )
      .warmup(duration: 600, fromPercent: 50, toPercent: 65)
      .steady(duration: 180, percent: 95, cadence: 92)
      .steady(duration: 120, percent: 55)
      .steady(duration: 300, percent: 98, cadence: 92)
      .steady(duration: 180, percent: 55)
      .steady(duration: 420, percent: 100, cadence: 90)
      .steady(duration: 240, percent: 55)
      .intervals(
        repeat: 4,
        onDuration: 30,
        offDuration: 90,
        onPercent: 130,
        offPercent: 50,
        cadence: 105,
      )
      .cooldown(duration: 360, fromPercent: 55, toPercent: 40)
      .build()
      .copyWith(id: _customWorkoutId);
}

Workout _rideWorkout() {
  return WorkoutBuilder(
        'Sweet Spot 3x12',
        description:
            'Three 12-minute sweet-spot blocks, 5 minutes easy between.',
      )
      .warmup(duration: 600, fromPercent: 50, toPercent: 68)
      .intervals(
        repeat: 3,
        onDuration: 720,
        offDuration: 300,
        onPercent: 90,
        offPercent: 55,
        cadence: 90,
      )
      .cooldown(duration: 300, fromPercent: 55, toPercent: 40)
      .build();
}

enum _Kind { vo2, anaerobic, sweetSpot, threshold, endurance, long, recovery }

extension on _Kind {
  int get minutes => switch (this) {
    _Kind.vo2 => 70,
    _Kind.anaerobic => 65,
    _Kind.sweetSpot => 75,
    _Kind.threshold => 80,
    _Kind.endurance => 75,
    _Kind.long => 150,
    _Kind.recovery => 35,
  };

  double get intensity => switch (this) {
    _Kind.vo2 => 0.85,
    _Kind.anaerobic => 0.82,
    _Kind.sweetSpot => 0.84,
    _Kind.threshold => 0.87,
    _Kind.endurance => 0.69,
    _Kind.long => 0.72,
    _Kind.recovery => 0.55,
  };

  double get variability => switch (this) {
    _Kind.vo2 || _Kind.anaerobic => 1.09,
    _Kind.sweetSpot || _Kind.threshold => 1.04,
    _Kind.long => 1.05,
    _Kind.endurance || _Kind.recovery => 1.02,
  };
}

_Kind? _kindFor(DateTime day, int week, Random rng) {
  switch (day.weekday) {
    case DateTime.tuesday:
      return week.isEven ? _Kind.vo2 : _Kind.anaerobic;
    case DateTime.wednesday:
      return _Kind.endurance;
    case DateTime.thursday:
      return week.isEven ? _Kind.sweetSpot : _Kind.threshold;
    case DateTime.friday:
      return rng.nextDouble() < 0.4 ? _Kind.recovery : null;
    case DateTime.saturday:
      return _Kind.long;
    case DateTime.sunday:
      return _Kind.endurance;
    default:
      return null;
  }
}

Watts _ftpAt(DateTime date, List<FtpHistoryEntry> history) {
  FtpHistoryEntry? best;
  for (final e in history) {
    if (e.effectiveDate.isAfter(date)) continue;
    if (best == null || e.effectiveDate.isAfter(best.effectiveDate)) best = e;
  }
  return (best ?? history.first).ftp;
}

Future<void> _seedRides(
  DriftStorage storage,
  List<FtpHistoryEntry> ftpHistory,
) async {
  final rng = Random(7);
  final today = _today();
  const totalDays = 182;
  const detailedDays = 16; // rides this recent get full 1 Hz readings

  for (var daysAgo = totalDays; daysAgo >= 1; daysAgo--) {
    final day = today.subtract(Duration(days: daysAgo));
    final week = (totalDays - daysAgo) ~/ 7;
    final kind = _kindFor(day, week, rng);
    if (kind == null) continue;
    if (rng.nextDouble() < 0.07) continue; // the odd missed session

    final recoveryWeek = week % 4 == 3;
    final build = 0.72 + 0.28 * min(1.0, week / 18);
    final minutes =
        kind.minutes *
        (kind == _Kind.recovery ? 1.0 : build) *
        (recoveryWeek ? 0.6 : 1.0) *
        (0.92 + rng.nextDouble() * 0.16);
    final seconds = (minutes * 60).round();
    final ftp = _ftpAt(day, ftpHistory);
    final weekend = day.weekday >= DateTime.saturday;
    final start = day.add(
      Duration(hours: weekend ? 8 : 18, minutes: rng.nextInt(45)),
    );
    final id = 'seed-${start.millisecondsSinceEpoch}';

    if (daysAgo <= detailedDays) {
      final readings = _synthReadings(kind, start, seconds, ftp.value, rng);
      final ride = Ride(
        id: id,
        startTime: start,
        endTime: start.add(Duration(seconds: seconds)),
        status: RideStatus.finished,
        readings: readings,
      );
      await storage.saveRide(ride, ftp: ftp);
      await storage.saveSensorReadings(id, readings);
      continue;
    }

    final intensity =
        kind.intensity *
        (recoveryWeek ? 0.93 : 1.0) *
        (0.97 + rng.nextDouble() * 0.05);
    final np = ftp.value * intensity;
    final avg = np / kind.variability;
    final speedKmh = 5.2 * pow(avg, 1 / 3).toDouble();
    final ride = Ride(
      id: id,
      startTime: start,
      endTime: start.add(Duration(seconds: seconds)),
      status: RideStatus.finished,
      cachedAvgPower: Watts(avg),
      cachedNormalizedPower: Watts(np),
      cachedMaxPower: Watts(ftp.value * (2.2 + rng.nextDouble() * 1.2)),
      cachedAvgCadence: Cadence(86 + rng.nextDouble() * 6),
      cachedAvgHr: HeartRate((70 + 100 * intensity).round()),
      cachedMaxHr: HeartRate(
        (95 + 95 * intensity).round().clamp(120, 186).toInt(),
      ),
      cachedTotalDistance: Distance(speedKmh / 3.6 * seconds),
    );
    await storage.saveRide(ride, ftp: ftp);
  }
}

/// Second-by-second power for a session of [kind], as a fraction of FTP.
List<double> _profile(_Kind kind, int seconds, Random rng) {
  final out = <double>[];
  void add(int dur, double Function(int t) f) {
    for (var t = 0; t < dur && out.length < seconds; t++) {
      out.add(f(t));
    }
  }

  void warmup() {
    add(600, (t) => 0.5 + 0.25 * t / 600);
    // Two seated sprints at the end of the warm-up on hard days.
    if (kind != _Kind.endurance && kind != _Kind.recovery) {
      add(8, (_) => 3.3 + rng.nextDouble() * 0.4);
      add(120, (_) => 0.5);
      add(8, (_) => 3.4 + rng.nextDouble() * 0.4);
      add(120, (_) => 0.5);
    }
  }

  switch (kind) {
    case _Kind.vo2:
      warmup();
      for (var i = 0; i < 5; i++) {
        add(270, (_) => 1.18);
        add(240, (_) => 0.52);
      }
    case _Kind.anaerobic:
      warmup();
      for (var i = 0; i < 6; i++) {
        add(60, (_) => 1.62);
        add(180, (_) => 0.5);
      }
      add(900, (_) => 0.75);
    case _Kind.sweetSpot:
      warmup();
      for (var i = 0; i < 3; i++) {
        add(720, (_) => 0.9);
        add(300, (_) => 0.55);
      }
    case _Kind.threshold:
      warmup();
      for (var i = 0; i < 2; i++) {
        add(1200, (_) => 0.99);
        add(300, (_) => 0.55);
      }
    case _Kind.endurance:
    case _Kind.long:
      warmup();
      add(seconds, (t) {
        final surge = (t % 900) < 30 && t > 0 ? 0.55 : 0.0;
        return 0.68 + 0.05 * sin(t / 240) + surge;
      });
    case _Kind.recovery:
      add(seconds, (t) => 0.52 + 0.03 * sin(t / 120));
  }
  // Easy spin for whatever remains (cool-down).
  add(seconds, (t) => max(0.4, 0.6 - t / 3000));
  return out;
}

List<SensorReading> _synthReadings(
  _Kind kind,
  DateTime start,
  int seconds,
  double ftp,
  Random rng,
) {
  final fractions = _profile(kind, seconds, rng);
  final readings = <SensorReading>[];
  var hr = 70.0;
  var distance = 0.0;
  for (var i = 0; i < fractions.length; i++) {
    final power = max(0.0, fractions[i] * ftp + _gauss(rng, 7));
    final ratio = power / ftp;
    final cadence = ratio > 2
        ? 108 + rng.nextDouble() * 8
        : (84 + 8 * ratio + _gauss(rng, 2)).clamp(70.0, 105.0).toDouble();
    final targetHr = 58 + 118 * min(ratio, 1.25);
    hr += (targetHr - hr) * (1 - exp(-1 / 35));
    final kmh = power <= 0 ? 0.0 : 5.2 * pow(power, 1 / 3).toDouble();
    distance += kmh / 3.6;
    readings.add(
      SensorReading(
        timestamp: start.add(Duration(seconds: i)),
        power: Watts(power),
        cadence: Cadence(cadence),
        heartRate: HeartRate(hr.round().clamp(50, 186).toInt()),
        speed: Speed(kmh),
        distance: Distance(distance),
      ),
    );
  }
  return readings;
}

double _gauss(Random rng, double sigma) {
  final u1 = rng.nextDouble();
  final u2 = rng.nextDouble();
  return sigma * sqrt(-2 * log(u1 + 1e-10)) * cos(2 * pi * u2);
}

/// A made-up ~17 km loop: rolling start, a 2.6 % lead-in to a 4–5 % climb,
/// a descent, a second steeper climb and a long run back down.
String _routeGpx() {
  const segments = [
    (600.0, 0.5),
    (500.0, -0.8),
    (700.0, 1.2),
    (300.0, 0.0),
    (1300.0, 2.6),
    (2400.0, 4.6),
    (400.0, 1.0),
    (2000.0, -4.0),
    (1500.0, 0.5),
    (900.0, 2.0),
    (1600.0, 5.5),
    (600.0, 2.0),
    (2400.0, -3.5),
    (1800.0, -0.4),
  ];
  const step = 25.0;
  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln(
      '<gpx version="1.1" creator="OpenBike" '
      'xmlns="http://www.topografix.com/GPX/1/1">',
    )
    ..writeln('<trk><name>Rolling Hills Loop</name><trkseg>');

  var lat = 45.1000;
  var lon = 5.9000;
  var elevation = 210.0;
  var distance = 0.0;
  var heading = 0.6;
  for (final (length, grade) in segments) {
    for (var d = 0.0; d < length; d += step) {
      final wobble = 1.2 * sin(distance / 170) * (grade.abs() < 1.5 ? 1 : 0.3);
      buffer.writeln(
        '<trkpt lat="${lat.toStringAsFixed(6)}" '
        'lon="${lon.toStringAsFixed(6)}">'
        '<ele>${(elevation + wobble).toStringAsFixed(1)}</ele></trkpt>',
      );
      elevation += step * grade / 100;
      distance += step;
      heading += 0.012 * sin(distance / 900);
      lat += step * cos(heading) / 111320;
      lon += step * sin(heading) / (111320 * cos(lat * pi / 180));
    }
  }
  buffer.writeln('</trkseg></trk></gpx>');
  return buffer.toString();
}
