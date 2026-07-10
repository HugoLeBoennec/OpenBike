import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/application/services/physics_engine.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/files/erg_parser.dart';
import 'package:open_bike/infrastructure/files/zwo_parser.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/infrastructure/simulator/simulator.dart';
import 'package:open_bike/plugins/exports/garmin_export_plugin.dart';
import 'package:open_bike/plugins/plugin_registry.dart';
import 'package:open_bike/presentation/models/ride_extra.dart';
import 'package:open_bike/presentation/screens/screens.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/app_shell.dart';

/// Creates a [ProviderScope] with an in-memory database, [EventBus],
/// [SimulatorDevicePlugin], format plugins, and Garmin export pre-registered.
Widget buildTestApp({
  GoRouter? router,
}) {
  final db = AppDatabase(NativeDatabase.memory());
  final eventBus = EventBus();
  final physics = CyclingPhysicsEngine();
  final registry = PluginRegistry();

  // Device plugins.
  final simPlugin = SimulatorDevicePlugin(
    eventBus: eventBus,
    physics: physics,
  );
  registry.registerDevice(simPlugin);

  // Export plugins.
  registry.registerExport(GarminConnectExportPlugin());

  // Format plugins.
  registry.registerFormat(ZwoParser());
  registry.registerFormat(ErgMrcParser());

  // In-memory preferences for tests.
  SharedPreferences.setMockInitialValues({});

  final testRouter = router ??
      GoRouter(
        initialLocation: '/',
        routes: [
          // Full-screen routes (outside shell)
          GoRoute(
              path: '/onboarding',
              builder: (_, __) => const OnboardingScreen()),
          GoRoute(
            path: '/ride',
            builder: (_, state) {
              final extra = state.extra;
              return RideScreen(
                extra: extra is RideExtra ? extra : null,
              );
            },
          ),
          GoRoute(
            path: '/ride/summary/:id',
            builder: (_, state) {
              final id = state.pathParameters['id'] ?? '';
              return RideSummaryScreen(rideId: id);
            },
          ),
          GoRoute(
              path: '/scan',
              builder: (_, __) => const DeviceScanScreen()),

          // Shell routes
          ShellRoute(
            builder: (_, __, child) => AppShell(child: child),
            routes: [
              GoRoute(
                  path: '/', builder: (_, __) => const HomeScreen()),
              GoRoute(
                  path: '/workouts',
                  builder: (_, __) => const WorkoutBuilderScreen()),
              GoRoute(
                path: '/workouts/new',
                builder: (_, __) => const WorkoutEditorScreen(),
              ),
              GoRoute(
                path: '/workouts/edit/:id',
                builder: (_, state) {
                  final id = state.pathParameters['id'];
                  return WorkoutEditorScreen(workoutId: id);
                },
              ),
              GoRoute(
                path: '/workouts/:id',
                builder: (_, state) {
                  final id =
                      int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  return WorkoutDetailScreen(workoutIndex: id);
                },
              ),
              GoRoute(
                  path: '/history',
                  builder: (_, __) => const HistoryScreen()),
              GoRoute(
                path: '/history/:id',
                builder: (_, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return RideDetailScreen(rideId: id);
                },
              ),
              GoRoute(
                  path: '/settings',
                  builder: (_, __) => const SettingsScreen()),
              GoRoute(
                  path: '/dev',
                  builder: (_, __) => const DevToolsScreen()),
            ],
          ),
        ],
      );

  return _TestAppWrapper(
    db: db,
    eventBus: eventBus,
    registry: registry,
    router: testRouter,
  );
}

/// Wrapper that initializes SharedPreferences before building.
class _TestAppWrapper extends StatelessWidget {
  const _TestAppWrapper({
    required this.db,
    required this.eventBus,
    required this.registry,
    required this.router,
  });

  final AppDatabase db;
  final EventBus eventBus;
  final PluginRegistry registry;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final appPrefs = AppPreferences(snapshot.data!);
        return ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            eventBusProvider.overrideWithValue(eventBus),
            pluginRegistryProvider.overrideWithValue(registry),
            appPreferencesProvider.overrideWithValue(appPrefs),
          ],
          child: MaterialApp.router(
            title: 'OpenBike Test',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.deepOrange,
              brightness: Brightness.dark,
            ),
            routerConfig: router,
          ),
        );
      },
    );
  }
}
