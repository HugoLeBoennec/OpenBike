import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../infrastructure/files/gpx_parser.dart';
import '../models/ride_extra.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/ride_summary_widgets.dart';
import '../widgets/workout_mini_profile.dart';

/// Home dashboard — device status, ride/workout/simulate actions, recent rides.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // One-shot: attempts to reconnect every saved role pairing.
    ref.watch(autoReconnectPairedRolesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenBike'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: context.tokens.textTertiary),
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

          // Today's scheduled workout
          const _TodayCard(),
          const SizedBox(height: 24),

          // Fitness sparkline (CTL/TSB)
          const _FitnessSparkline(),
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
            onTap: () => _pickRoute(context, ref),
          ),
          const SizedBox(height: 24),

          // Recent activities
          _RecentActivitiesSection(),
        ],
      ),
    );
  }

  Future<void> _pickRoute(BuildContext context, WidgetRef ref) async {
    if (ref.read(activeTrainerPortProvider) == null) {
      final connect = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Connect a trainer'),
          content: const Text(
            'Route simulation drives your trainer\'s resistance to match '
            'the terrain — pair a trainer first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Connect Device'),
            ),
          ],
        ),
      );
      if (connect == true && context.mounted) context.push('/scan');
      return;
    }

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
    final tokens = context.tokens;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/scan'),
      child: Semantics(
        label: device != null
            ? 'Devices, connected to ${device.name}'
            : 'Devices, no device connected',
        button: true,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tokens.surfaceTier2,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.bluetooth,
                color: device != null ? Colors.green : tokens.textDisabled,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Devices',
                        style: TextStyle(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w600)),
                    Text(
                      device != null ? device.name : 'No device connected',
                      style:
                          TextStyle(color: tokens.textTertiary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                device != null ? Icons.circle : Icons.circle_outlined,
                color: device != null
                    ? Colors.green
                    : Colors.red.withValues(alpha: 0.5),
                size: 10,
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: tokens.textDisabled),
            ],
          ),
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
                        style: TextStyle(
                            color: context.tokens.textTertiary,
                            fontSize: 13)),
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
            Text('Recent Activities',
                style: TextStyle(
                    color: context.tokens.textTertiary,
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
            child: CircularProgressIndicator(),
          )),
          error: (e, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Couldn\'t load recent activities: $e',
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
              TextButton(
                onPressed: () => ref.invalidate(rideHistoryProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
          data: (rides) {
            if (rides.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No rides yet.',
                      style: TextStyle(
                          color: context.tokens.textDisabled, fontSize: 13)),
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

class _RecentRideTile extends ConsumerWidget {
  const _RecentRideTile({required this.ride, required this.ftp});
  final Ride ride;
  final Watts ftp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(unitFormatterProvider);
    final avgW = ride.averagePower.value.round();
    final np = ride.normalizedPower.value.round();
    final tss = ride.tss(ftp).round();
    final dur = formatDuration(ride.activeDuration);
    final date = formatDate(ride.startTime);
    final dist = ride.totalDistance.meters > 0
        ? '${formatter.distance(ride.totalDistance)}  •  '
        : '';

    final ifactor = ride.intensityFactor(ftp);
    final borderColor = _intensityColor(ifactor);

    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: tokens.surfaceTier2,
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
                          style: TextStyle(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('$dur  •  $dist$avgW W  •  NP $np',
                          style: TextStyle(
                              color: tokens.textTertiary, fontSize: 12)),
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
                    Text('TSS',
                        style:
                            TextStyle(color: tokens.textDisabled, fontSize: 10)),
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

// ---------------------------------------------------------------------------
// Today's scheduled workout
// ---------------------------------------------------------------------------

class _TodayCard extends ConsumerWidget {
  const _TodayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todaysScheduledWorkoutsProvider);
    final workouts = ref.watch(workoutListProvider);

    return todayAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (scheduled) {
        if (scheduled.isEmpty) return const SizedBox.shrink();

        Workout? workoutFor(String id) {
          for (final w in workouts) {
            if (w.id == id) return w;
          }
          return null;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TODAY',
                style: TextStyle(
                    color: context.tokens.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
            const SizedBox(height: 8),
            for (final s in scheduled)
              _TodayTile(
                scheduled: s,
                workout: workoutFor(s.workoutId),
              ),
          ],
        );
      },
    );
  }
}

class _TodayTile extends StatelessWidget {
  const _TodayTile({required this.scheduled, required this.workout});
  final ScheduledWorkout scheduled;
  final Workout? workout;

  @override
  Widget build(BuildContext context) {
    final isDone = scheduled.completedRideId != null;
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/calendar'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (workout != null)
                  SizedBox(
                    width: 40,
                    height: 28,
                    child: WorkoutMiniProfile(steps: workout!.steps),
                  )
                else
                  Icon(Icons.fitness_center, color: tokens.textDisabled),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    workout?.name ?? 'Scheduled workout',
                    style: TextStyle(
                        color: tokens.textPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
                if (isDone)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20)
                else
                  Icon(Icons.chevron_right, color: tokens.textDisabled),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fitness sparkline (CTL / TSB)
// ---------------------------------------------------------------------------

class _FitnessSparkline extends ConsumerWidget {
  const _FitnessSparkline();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fitnessAsync = ref.watch(fitnessHistoryProvider);

    return fitnessAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (points) {
        if (points.isEmpty) return const SizedBox.shrink();

        final recent = points.length > 42
            ? points.sublist(points.length - 42)
            : points;
        final latest = points.last;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go('/trends'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.tokens.surfaceTier2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _FitnessNumber(
                          label: 'CTL', value: latest.ctl, color: Colors.blueAccent),
                      const SizedBox(width: 16),
                      _FitnessNumber(
                          label: 'TSB', value: latest.tsb, color: Colors.purpleAccent),
                    ],
                  ),
                ),
                SizedBox(
                  width: 90,
                  height: 32,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (var i = 0; i < recent.length; i++)
                              FlSpot(i.toDouble(), recent[i].ctl),
                          ],
                          isCurved: true,
                          color: Colors.blueAccent,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                    duration: Duration.zero,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FitnessNumber extends StatelessWidget {
  const _FitnessNumber({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value.round().toString(),
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(color: context.tokens.textTertiary, fontSize: 10)),
      ],
    );
  }
}
