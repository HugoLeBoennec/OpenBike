import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../infrastructure/files/gpx_parser.dart';
import '../models/ride_extra.dart';
import '../state/providers.dart';
import '../widgets/ride_summary_widgets.dart';

/// Home dashboard — device status, ride/workout/simulate actions, recent rides.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // One-shot: attempts to reconnect every saved role pairing.
    ref.watch(autoReconnectPairedRolesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('OpenBike'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white54),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Device status
          _DeviceStatusSection(),
          const SizedBox(height: 24),

          // Action cards
          _ActionCard(
            icon: Icons.pedal_bike,
            title: 'Free Ride',
            subtitle: 'Start riding without a workout',
            color: Colors.deepOrange,
            onTap: () => context.go('/ride'),
          ),
          const SizedBox(height: 8),
          _ActionCard(
            icon: Icons.fitness_center,
            title: 'Workout',
            subtitle: 'Choose a structured workout',
            color: Colors.blue,
            onTap: () => context.go('/workouts'),
          ),
          const SizedBox(height: 8),
          _ActionCard(
            icon: Icons.terrain,
            title: 'Simulate Route',
            subtitle: 'Load a .gpx file to simulate',
            color: Colors.green,
            onTap: () => _pickRoute(context),
          ),
          const SizedBox(height: 24),

          // Recent activities
          _RecentActivitiesSection(),
        ],
      ),
    );
  }

  Future<void> _pickRoute(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gpx'],
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) return;

    final gpxContent = await File(path).readAsString();
    final route = GpxRouteParser().parse(gpxContent);
    if (context.mounted) {
      context.go('/ride', extra: RideExtra(route: route));
    }
  }
}

// ---------------------------------------------------------------------------
// Device status
// ---------------------------------------------------------------------------

class _DeviceStatusSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(trainerDeviceProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/scan'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.bluetooth,
              color: device != null ? Colors.green : Colors.white38,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Devices',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                  Text(
                    device != null ? device.name : 'No device connected',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              device != null ? Icons.circle : Icons.circle_outlined,
              color: device != null ? Colors.green : Colors.red.withValues(alpha: 0.5),
              size: 10,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action cards
// ---------------------------------------------------------------------------

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: color,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style:
                            const TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color.withValues(alpha: 0.5), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent activities
// ---------------------------------------------------------------------------

class _RecentActivitiesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(rideHistoryProvider);
    final ftp = ref.watch(ftpProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Activities',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
            GestureDetector(
              onTap: () => context.go('/history'),
              child: const Text('See all',
                  style: TextStyle(
                      color: Colors.deepOrange, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ridesAsync.when(
          loading: () => const Center(
              child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(color: Colors.white30),
          )),
          error: (e, _) => Text('Error: $e',
              style: const TextStyle(color: Colors.red)),
          data: (rides) {
            if (rides.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No rides yet.',
                      style: TextStyle(color: Colors.white38, fontSize: 13)),
                ),
              );
            }
            final recent = rides.take(3).toList();
            return Column(
              children: [
                for (final ride in recent)
                  _RecentRideTile(ride: ride, ftp: ftp),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RecentRideTile extends StatelessWidget {
  const _RecentRideTile({required this.ride, required this.ftp});
  final Ride ride;
  final Watts ftp;

  @override
  Widget build(BuildContext context) {
    final avgW = ride.averagePower.value.round();
    final np = ride.normalizedPower.value.round();
    final tss = ride.tss(ftp).round();
    final dur = formatDuration(ride.activeDuration);
    final date = formatDate(ride.startTime);

    final ifactor = ride.intensityFactor(ftp);
    final borderColor = _intensityColor(ifactor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/history/${ride.id}'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(color: borderColor, width: 4),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(date,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('$dur  •  $avgW W  •  NP $np',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text('$tss',
                        style: TextStyle(
                            color: borderColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const Text('TSS',
                        style:
                            TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _intensityColor(double ifactor) {
    if (ifactor < 0.55) return Colors.grey;
    if (ifactor < 0.75) return Colors.green;
    if (ifactor < 0.90) return Colors.yellow;
    if (ifactor < 1.05) return Colors.orange;
    return Colors.red;
  }
}
