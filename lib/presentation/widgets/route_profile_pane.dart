import 'package:flutter/material.dart' hide Route;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/application/services/route_simulator.dart';
import '../../core/domain/entities/route.dart';
import '../../core/domain/entities/route_point.dart';
import '../state/providers.dart';
import 'gpx_profile_widget.dart';
import 'route_mini_map.dart';

/// Elevation profile + upcoming-gradient strip for a GPX route simulation,
/// shown in place of the live power chart while a route ride is active.
class RouteProfilePane extends ConsumerWidget {
  const RouteProfilePane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeSimulatorProvider).currentRoute;
    if (route == null) {
      return Container(
        color: const Color(0xFF0A0A0A),
        child: const Center(
          child: Text('No route loaded', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final progressAsync = ref.watch(simulationProgressProvider);

    return progressAsync.when(
      data: (progress) => _RouteProfileContent(route: route, progress: progress),
      loading: () => _RouteProfileContent(route: route, progress: null),
      error: (_, __) => _RouteProfileContent(route: route, progress: null),
    );
  }
}

class _RouteProfileContent extends ConsumerWidget {
  const _RouteProfileContent({required this.route, required this.progress});

  final Route route;
  final SimulationProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = progress?.grade.percent ?? route.points.first.grade.percent;
    final distRemaining = progress != null
        ? progress!.distanceRemaining.km
        : route.totalDistance.km;
    final showMiniMap = ref.watch(showMiniMapProvider);

    return Container(
      color: const Color(0xFF0A0A0A),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${grade.toStringAsFixed(1)}% grade',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              Row(
                children: [
                  Text(
                    '${distRemaining.toStringAsFixed(1)} km left',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      showMiniMap ? Icons.terrain : Icons.map_outlined,
                      color: Colors.white54,
                      size: 18,
                    ),
                    tooltip: showMiniMap ? 'Show elevation profile' : 'Show map',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => ref
                        .read(showMiniMapProvider.notifier)
                        .state = !showMiniMap,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: showMiniMap
                ? RouteMiniMap(
                    route: route,
                    currentPointIndex: progress?.pointIndex,
                  )
                : GpxProfileWidget(
                    points: route.points,
                    currentPointIndex: progress?.pointIndex,
                  ),
          ),
          const SizedBox(height: 6),
          _UpcomingGradientStrip(
            points: route.points,
            distanceCovered: progress?.distanceCovered.meters ?? 0,
            totalDistance: route.totalDistance.meters,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Upcoming-gradient strip — colored segments for the next ~1 km
// ---------------------------------------------------------------------------

class _UpcomingGradientStrip extends StatelessWidget {
  const _UpcomingGradientStrip({
    required this.points,
    required this.distanceCovered,
    required this.totalDistance,
  });

  final List<RoutePoint> points;
  final double distanceCovered;
  final double totalDistance;

  static const _lookaheadMeters = 1000.0;
  static const _segments = 24;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return const SizedBox.shrink();

    final segStep = _lookaheadMeters / _segments;

    return SizedBox(
      height: 10,
      child: Row(
        children: List.generate(_segments, (i) {
          final d = (distanceCovered + i * segStep).clamp(0.0, totalDistance);
          final grade = _gradeAt(points, d);
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              color: _gradeColor(grade),
            ),
          );
        }),
      ),
    );
  }

  /// Nearest-point grade lookup via binary search — a coarse approximation
  /// suitable for this preview strip (full interpolation lives in
  /// [RouteSimulator._gradeAtDistance]).
  double _gradeAt(List<RoutePoint> points, double distance) {
    var lo = 0;
    var hi = points.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (points[mid].distanceFromStart < distance) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return points[lo].grade.percent;
  }

  /// Same 7-step spectrum as [PowerZone.coggan7] for visual consistency
  /// between the power zone bar and the upcoming-gradient strip.
  Color _gradeColor(double percent) {
    if (percent < 0) return const Color(0xFF9E9E9E); // descent
    if (percent < 3) return const Color(0xFF2196F3);
    if (percent < 6) return const Color(0xFF4CAF50);
    if (percent < 9) return const Color(0xFFFFEB3B);
    if (percent < 12) return const Color(0xFFFF9800);
    if (percent < 15) return const Color(0xFFF44336);
    return const Color(0xFF9C27B0);
  }
}
