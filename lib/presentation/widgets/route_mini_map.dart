import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../core/domain/entities/route.dart';
import '../theme/app_theme.dart';

/// OSM mini-map showing the GPX track and the rider's current position.
///
/// Stretch feature (P3 task 3) — kept behind a toggle in [RouteProfilePane]
/// and hides itself when there's no connectivity, since OSM tiles require a
/// live network and there's no offline tile cache.
class RouteMiniMap extends StatelessWidget {
  const RouteMiniMap({
    super.key,
    required this.route,
    this.currentPointIndex,
  });

  final Route route;
  final int? currentPointIndex;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data;
        final isOffline =
            results != null && results.every((r) => r == ConnectivityResult.none);
        if (isOffline) {
          return Center(
            child: Text(
              'Map unavailable offline',
              style: TextStyle(
                  color: context.tokens.rideOnSurfaceMuted, fontSize: 12),
            ),
          );
        }
        return _buildMap(context);
      },
    );
  }

  Widget _buildMap(BuildContext context) {
    if (route.points.isEmpty) return const SizedBox.shrink();

    final points = route.points
        .map((p) => latlong.LatLng(p.position.lat, p.position.lon))
        .toList();

    final markerIndex =
        currentPointIndex?.clamp(0, route.points.length - 1) ?? 0;
    final markerPoint = points[markerIndex];

    return FlutterMap(
      options: MapOptions(
        initialCenter: markerPoint,
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          // Must stay in sync with the app id in android/app/build.gradle.kts
          // and the Xcode bundle id: OSM's tile usage policy requires a valid
          // identifying User-Agent and blocks traffic that doesn't have one.
          // https://operations.osmfoundation.org/policies/tiles/
          userAgentPackageName: 'run.records.openbike',
        ),
        PolylineLayer(
          polylines: [
            Polyline(points: points, color: Colors.orange, strokeWidth: 3),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: markerPoint,
              width: 16,
              height: 16,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
