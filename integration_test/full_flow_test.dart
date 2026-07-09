import 'dart:typed_data';

import 'package:flutter/material.dart' hide Route;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'package:open_bike/core/application/services/recording_engine.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/app_event.dart';
import 'package:open_bike/infrastructure/files/fit_encoder.dart';
import 'package:open_bike/infrastructure/files/gpx_parser.dart';
import 'package:open_bike/infrastructure/files/zwo_parser.dart';
import 'package:open_bike/presentation/models/ride_extra.dart';
import 'package:open_bike/presentation/state/providers.dart';

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // =========================================================================
  // 1. Simulator → scan → connect → ride → lap → stop → verify storage
  // =========================================================================

  testWidgets('full ride flow: connect simulator → record → lap → stop → DB',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );

    // --- Connect the simulator ---
    final plugin = container.read(simulatorPluginProvider)!;
    final devices = await plugin.scan(const Duration(seconds: 1));
    final trainer = await plugin.connect(devices.first);

    // Wire trainer data into live providers.
    trainer.dataStream.listen((reading) {
      container.read(livePowerProvider.notifier).state =
          reading.power ?? Watts.zero;
      container.read(liveCadenceProvider.notifier).state =
          reading.cadence ?? Cadence.zero;
      container.read(liveHeartRateProvider.notifier).state =
          reading.heartRate ?? HeartRate.zero;
      container.read(liveSpeedProvider.notifier).state =
          reading.speed ?? Speed.zero;
    });

    // Pump to let first readings arrive.
    await tester.pump(const Duration(seconds: 2));
    await Future<void>.delayed(const Duration(seconds: 2));

    // Verify live data is non-zero.
    final power = container.read(livePowerProvider);
    expect(power.value, greaterThan(0), reason: 'Simulator should emit power');

    // --- Start recording ---
    final engine = container.read(recordingEngineProvider);
    final ride = await engine.start();
    expect(ride.id, isNotEmpty);
    expect(engine.state, RecordingState.recording);

    // Let data accumulate.
    await tester.pump(const Duration(seconds: 3));
    await Future<void>.delayed(const Duration(seconds: 3));

    // --- Mark a lap ---
    final lap = engine.markLap();
    expect(lap.startIndex, 0);
    expect(lap.duration, greaterThan(Duration.zero));

    // More data.
    await tester.pump(const Duration(seconds: 2));
    await Future<void>.delayed(const Duration(seconds: 2));

    // --- Stop recording ---
    final finishedRide = await engine.stop();
    expect(finishedRide.status, RideStatus.finished);
    expect(finishedRide.readings, isNotEmpty);
    expect(finishedRide.laps, hasLength(1));

    // --- Verify ride is in storage ---
    final storage = container.read(storageProvider);
    final savedRides = await storage.getRides();
    expect(savedRides, isNotEmpty);

    final savedRide = await storage.getRide(ride.id);
    expect(savedRide, isNotNull);
    expect(savedRide!.status, RideStatus.finished);

    final savedReadings = await storage.getSensorReadings(ride.id);
    expect(savedReadings, isNotEmpty,
        reason: 'Readings should be persisted in SQLite');

    final savedLaps = await storage.getLaps(ride.id);
    expect(savedLaps, hasLength(1), reason: 'One lap should be persisted');

    await trainer.disconnect();
  });

  // =========================================================================
  // 2. FIT export — encode ride and validate header
  // =========================================================================

  testWidgets('FIT export: encode ride produces valid FIT bytes',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );

    // Connect simulator and record a short ride.
    final plugin = container.read(simulatorPluginProvider)!;
    final devices = await plugin.scan(const Duration(seconds: 1));
    final trainer = await plugin.connect(devices.first);

    trainer.dataStream.listen((reading) {
      container.read(livePowerProvider.notifier).state =
          reading.power ?? Watts.zero;
    });

    final engine = container.read(recordingEngineProvider);
    await engine.start();

    await tester.pump(const Duration(seconds: 3));
    await Future<void>.delayed(const Duration(seconds: 3));

    final ride = await engine.stop();

    // Load full ride with readings.
    final storage = container.read(storageProvider);
    final readings = await storage.getSensorReadings(ride.id);
    final fullRide = ride.copyWith(readings: readings);

    // Encode to FIT.
    final encoder = FitEncoder();
    final Uint8List fitBytes = encoder.encode(fullRide);

    // Validate FIT header: starts with header size byte, then ".FIT" signature.
    expect(fitBytes.length, greaterThan(14), reason: 'FIT file should not be empty');
    // FIT header: bytes 8-11 should be ".FIT" (0x2E, 0x46, 0x49, 0x54).
    expect(fitBytes[8], 0x2E); // '.'
    expect(fitBytes[9], 0x46); // 'F'
    expect(fitBytes[10], 0x49); // 'I'
    expect(fitBytes[11], 0x54); // 'T'

    await trainer.disconnect();
  });

  // =========================================================================
  // 3. ZWO workout → set targets on simulator
  // =========================================================================

  testWidgets('ZWO workout: parse and apply targets to simulator',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );

    // Parse a ZWO workout.
    final zwoParser = ZwoParser();
    final workout = await zwoParser.parse('''
<workout_file>
  <name>Test Intervals</name>
  <workout>
    <SteadyState Duration="10" Power="0.50"/>
    <SteadyState Duration="10" Power="1.00"/>
  </workout>
</workout_file>
''');

    expect(workout.name, 'Test Intervals');
    expect(workout.steps, hasLength(2));
    expect(workout.steps[0].powerTargetPercent, closeTo(0.50, 0.01));
    expect(workout.steps[1].powerTargetPercent, closeTo(1.00, 0.01));

    // Connect simulator.
    final plugin = container.read(simulatorPluginProvider)!;
    final devices = await plugin.scan(const Duration(seconds: 1));
    final trainer = await plugin.connect(devices.first);

    // Apply first step target: 50% of 200W FTP = 100W.
    final ftp = container.read(ftpProvider);
    final step1Target =
        Watts(workout.steps[0].powerTargetPercent * ftp.value);
    await trainer.setTargetPower(step1Target);

    // Verify modeChanged event was fired.
    final events = <TrainerEvent>[];
    final eventBus = container.read(eventBusProvider);
    eventBus.on<TrainerEvent>().listen(events.add);

    // Apply second step.
    final step2Target =
        Watts(workout.steps[1].powerTargetPercent * ftp.value);
    await trainer.setTargetPower(step2Target);
    await Future<void>.delayed(Duration.zero);

    expect(events.whereType<TrainerModeChanged>(), isNotEmpty);

    // Wait for convergence.
    final readings = <SensorReading>[];
    final sub = trainer.dataStream.listen(readings.add);
    await tester.pump(const Duration(seconds: 8));
    await Future<void>.delayed(const Duration(seconds: 8));
    await sub.cancel();

    if (readings.isNotEmpty) {
      final lastPower = readings.last.power!.value;
      expect(lastPower, closeTo(200, 60),
          reason: 'Power should converge toward 200W (100% FTP)');
    }

    await trainer.disconnect();
  });

  // =========================================================================
  // 4. GPX route → simulation mode → grade changes on trainer
  // =========================================================================

  testWidgets('GPX simulation: parse route and apply grade to trainer',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );

    // Parse a simple GPX with elevation changes.
    final parser = GpxRouteParser();
    final route = parser.parse('''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test">
  <trk>
    <name>Test Climb</name>
    <trkseg>
      <trkpt lat="45.0" lon="6.0"><ele>500</ele></trkpt>
      <trkpt lat="45.001" lon="6.0"><ele>510</ele></trkpt>
      <trkpt lat="45.002" lon="6.0"><ele>530</ele></trkpt>
      <trkpt lat="45.003" lon="6.0"><ele>560</ele></trkpt>
      <trkpt lat="45.004" lon="6.0"><ele>600</ele></trkpt>
    </trkseg>
  </trk>
</gpx>
''', name: 'Test Climb');

    expect(route.points, isNotEmpty);
    expect(route.name, 'Test Climb');

    // The route should have positive grades (climbing).
    final hasPositiveGrade =
        route.points.any((p) => p.grade.percent > 0);
    expect(hasPositiveGrade, isTrue,
        reason: 'Route with increasing elevation should have positive grades');

    // Connect simulator.
    final plugin = container.read(simulatorPluginProvider)!;
    final devices = await plugin.scan(const Duration(seconds: 1));
    final trainer = await plugin.connect(devices.first);

    // Apply simulation params with grade from route.
    final firstGrade = route.points.first.grade;
    await trainer.setSimulationParams(0, firstGrade, 0.004, 0.32);

    // Verify we're in simulation mode.
    final modeEvents = <TrainerEvent>[];
    final eventBus = container.read(eventBusProvider);
    eventBus.on<TrainerEvent>().listen(modeEvents.add);

    // Change to a steeper grade point.
    final steepPoint = route.points.last;
    await trainer.setSimulationParams(
        0, steepPoint.grade, 0.004, 0.32);
    await Future<void>.delayed(Duration.zero);

    expect(
      modeEvents.whereType<TrainerModeChanged>().any(
            (e) => e.mode == ControlMode.simulation,
          ),
      isTrue,
    );

    await trainer.disconnect();
  });

  // =========================================================================
  // 5. EventBus integration — verify events flow across modules
  // =========================================================================

  testWidgets('EventBus: sensor, trainer, and ride events flow correctly',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );

    final eventBus = container.read(eventBusProvider);
    final allEvents = <Object>[];
    eventBus.stream.listen(allEvents.add);

    // Connect simulator — should fire TrainerEvent.connected + controlAcquired.
    final plugin = container.read(simulatorPluginProvider)!;
    final devices = await plugin.scan(const Duration(seconds: 1));
    final trainer = await plugin.connect(devices.first);

    await tester.pump(const Duration(seconds: 2));
    await Future<void>.delayed(const Duration(seconds: 2));

    // Should have trainer events + sensor events.
    expect(allEvents.whereType<TrainerEvent>().length, greaterThanOrEqualTo(2),
        reason: 'connected + controlAcquired');
    expect(allEvents.whereType<SensorEvent>(), isNotEmpty,
        reason: 'Simulator should emit SensorEvents');

    // Start recording — should fire RideEvent.started.
    final engine = container.read(recordingEngineProvider);
    await engine.start();
    await Future<void>.delayed(Duration.zero);

    expect(allEvents.whereType<RideEvent>(), isNotEmpty,
        reason: 'Recording start should fire RideEvent');

    await engine.stop();
    await trainer.disconnect();
  });

  // =========================================================================
  // 6. Plugin registry — verify all plugins are registered
  // =========================================================================

  testWidgets('PluginRegistry: all plugins registered correctly',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );

    final registry = container.read(pluginRegistryProvider);

    // Device plugins.
    final devicePlugins = registry.getDevicePlugins();
    expect(devicePlugins, hasLength(1)); // Simulator only in test
    expect(devicePlugins.first.manifest.id, 'openbike.simulator');

    // Export plugins.
    final exportPlugins = registry.getExportPlugins();
    expect(exportPlugins, hasLength(1)); // Garmin only in test
    expect(exportPlugins.first.manifest.id, 'garmin-connect-export');

    // Format plugins.
    final formatPlugins = registry.getFormatPlugins();
    expect(formatPlugins, hasLength(2)); // ZWO + ERG/MRC

    // Format lookup by extension.
    expect(registry.getFormatForExtension('.zwo'), isNotNull);
    expect(registry.getFormatForExtension('.erg'), isNotNull);
    expect(registry.getFormatForExtension('.mrc'), isNotNull);
    expect(registry.getFormatForExtension('.xyz'), isNull);
  });

  // =========================================================================
  // 7. Navigation — verify all routes work
  // =========================================================================

  testWidgets('Navigation: all main routes resolve without crash',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(MaterialApp));
    final goRouter = GoRouter.of(context);

    // Navigate through main routes.
    for (final path in ['/ride', '/scan', '/settings', '/dev',
        '/history', '/workouts']) {
      goRouter.go(path);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.byType(Scaffold), findsWidgets,
          reason: 'Route $path should render a Scaffold');
    }
  });

  // =========================================================================
  // 8. P3 — Workout HUD appears when a workout ride starts
  // =========================================================================

  testWidgets('Workout ride: HUD shows the active step once the engine ticks',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );

    // Connect the simulator as the active trainer — required by
    // workoutEngineProvider, which throws without a connected TrainerPort.
    final plugin = container.read(simulatorPluginProvider)!;
    final devices = await plugin.scan(const Duration(seconds: 1));
    final trainer = await plugin.connect(devices.first);
    container.read(activeTrainerPortProvider.notifier).state = trainer;

    final workout = Workout(
      id: 'hud-test',
      name: 'HUD Test',
      steps: const [
        WorkoutStep(
          type: StepType.steadyState,
          durationSeconds: 30,
          powerTargetPercent: 100,
        ),
      ],
    );

    final goRouter = GoRouter.of(tester.element(find.byType(MaterialApp)));
    goRouter.go('/ride', extra: RideExtra(workout: workout));
    await tester.pumpAndSettle();

    // The HUD only renders once WorkoutEngine emits its first progress tick.
    await tester.pump(const Duration(seconds: 1));
    await Future<void>.delayed(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('STEADY STATE'), findsOneWidget);

    await trainer.disconnect();
  });

  // =========================================================================
  // 9. P3 — Route completion prompts to stop & save
  // =========================================================================

  testWidgets('Route ride: completion dialog appears when the route ends',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );

    final plugin = container.read(simulatorPluginProvider)!;
    final devices = await plugin.scan(const Duration(seconds: 1));
    final trainer = await plugin.connect(devices.first);
    container.read(activeTrainerPortProvider.notifier).state = trainer;

    // A tiny flat route so the simulator completes it within a couple of
    // ticks regardless of how quickly virtual speed converges.
    final route = Route(
      id: 'short-route',
      name: 'Short',
      points: const [
        RoutePoint(
          position: GeoPoint(lat: 45.0, lon: 6.0),
          distanceFromStart: 0,
          smoothedElevation: 100,
          grade: Grade.flat,
        ),
        RoutePoint(
          position: GeoPoint(lat: 45.0001, lon: 6.0),
          distanceFromStart: 2,
          smoothedElevation: 100,
          grade: Grade.flat,
        ),
      ],
    );

    final goRouter = GoRouter.of(tester.element(find.byType(MaterialApp)));
    goRouter.go('/ride', extra: RideExtra(route: route));
    await tester.pumpAndSettle();

    // Let the simulator tick until it covers the (very short) route.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 1));
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    await tester.pump();

    expect(find.text('Route completed!'), findsOneWidget);

    await trainer.disconnect();
  });
}
