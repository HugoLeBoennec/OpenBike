import 'package:go_router/go_router.dart';
import 'screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/ride',
  routes: [
    GoRoute(path: '/ride', builder: (_, __) => const RideScreen()),
    GoRoute(path: '/workouts', builder: (_, __) => const WorkoutBuilderScreen()),
    GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/devices', builder: (_, __) => const DeviceScanScreen()),
  ],
);
