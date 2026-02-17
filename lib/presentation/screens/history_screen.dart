import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/entities/ride.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../state/providers.dart';

/// Ride history list screen.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(rideHistoryProvider);
    final ftp = ref.watch(ftpProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(rideHistoryProvider),
        child: ridesAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white30)),
          error: (e, _) => Center(
              child:
                  Text('Error: $e', style: const TextStyle(color: Colors.red))),
          data: (rides) {
            if (rides.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.directions_bike,
                            size: 48, color: Colors.white24),
                        SizedBox(height: 16),
                        Text(
                          'No rides yet.',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: rides.length,
              itemBuilder: (context, index) {
                final ride = rides[index];
                return _RideTile(
                  ride: ride,
                  ftp: ftp,
                  onTap: () => context.push('/history/${ride.id}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ride tile
// ---------------------------------------------------------------------------

class _RideTile extends StatelessWidget {
  const _RideTile({
    required this.ride,
    required this.ftp,
    required this.onTap,
  });

  final Ride ride;
  final Watts ftp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avgW = ride.averagePower.value.round();
    final np = ride.normalizedPower.value.round();
    final tss = ride.tss(ftp).round();
    final dur = _formatDuration(ride.activeDuration);
    final date = _formatDate(ride.startTime);
    final dist = ride.totalDistance.km;

    // Intensity-based left border color
    final ifactor = ride.intensityFactor(ftp);
    final borderColor = _intensityColor(ifactor);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          date,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              _MiniStat(value: dur, label: ''),
              const SizedBox(width: 12),
              if (dist > 0) ...[
                _MiniStat(
                    value: dist.toStringAsFixed(1), label: 'km'),
                const SizedBox(width: 12),
              ],
              _MiniStat(value: '$avgW', label: 'W'),
              const SizedBox(width: 12),
              _MiniStat(value: '$np', label: 'NP'),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$tss',
              style: TextStyle(
                color: borderColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text('TSS',
                style: TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
        onTap: onTap,
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
// Mini stat label
// ---------------------------------------------------------------------------

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.isEmpty ? value : '$value $label',
      style: const TextStyle(color: Colors.white54, fontSize: 12),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  return '$m:${s.toString().padLeft(2, '0')}';
}

String _formatDate(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}
