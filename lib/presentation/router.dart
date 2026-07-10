import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/ride_extra.dart';
import 'screens/screens.dart';
import 'widgets/app_shell.dart';

/// Creates the app router with [ShellRoute] for tab navigation.
///
/// Routes outside the shell (full-screen, no nav bar):
///   /onboarding, /ride, /ride/summary/:id, /scan
///
/// Routes inside the shell (with bottom nav / sidebar):
///   /, /calendar, /workouts, /workouts/:id, /history, /history/:id, /trends,
///   /settings, /dev
GoRouter createAppRouter({required bool hasCompletedOnboarding}) {
  return GoRouter(
    initialLocation: hasCompletedOnboarding ? '/' : '/onboarding',
    routes: [
      // ── Full-screen routes (outside shell) ──────────────────────────
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
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
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: DeviceScanScreen(),
        ),
      ),

      // ── Shell routes (with bottom nav / sidebar) ────────────────────
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/workouts',
            builder: (_, __) => const WorkoutBuilderScreen(),
          ),
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
            path: '/calendar',
            builder: (_, __) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (_, __) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/trends',
            builder: (_, __) => const TrendsScreen(),
          ),
          GoRoute(
            path: '/history/:id',
            builder: (_, state) {
              final id = state.pathParameters['id'] ?? '';
              return RideDetailScreen(rideId: id);
            },
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/dev',
            builder: (_, __) => const DevToolsScreen(),
          ),
        ],
      ),
    ],
  );
}
