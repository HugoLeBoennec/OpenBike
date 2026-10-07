import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/entities/ride.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/personal_records_panel.dart';

/// Ride history list screen.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(rideHistoryProvider);
    final ftp = ref.watch(ftpProvider);
    final recordsAsync = ref.watch(personalRecordsProvider);

    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: Icon(Icons.show_chart, color: tokens.textTertiary),
            tooltip: 'Trends',
            onPressed: () => context.go('/trends'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(rideHistoryProvider);
          ref.invalidate(personalRecordsProvider);
        },
        child: ridesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Couldn\'t load history: $e',
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(rideHistoryProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (rides) {
            if (rides.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.directions_bike,
                            size: 48, color: tokens.textDisabled),
                        const SizedBox(height: 16),
                        Text(
                          'No rides yet.',
                          style:
                              TextStyle(color: tokens.textTertiary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: rides.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: recordsAsync.maybeWhen(
                      data: (records) => PersonalRecordsPanel(records: records),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  );
                }
                final ride = rides[index - 1];
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

class _RideTile extends ConsumerWidget {
  const _RideTile({
    required this.ride,
    required this.ftp,
    required this.onTap,
  });

  final Ride ride;
  final Watts ftp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(unitFormatterProvider);
    final avgW = ride.averagePower.value.round();
    final np = ride.normalizedPower.value.round();
    final tss = ride.tss(ftp).round();
    final dur = _formatDuration(ride.activeDuration);
    final date = _formatDate(ride.startTime);
    final dist = formatter.distanceValue(ride.totalDistance);

    // Intensity-based left border color
    final ifactor = ride.intensityFactor(ftp);
    final borderColor = _intensityColor(ifactor);

    final tokens = context.tokens;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: tokens.surfaceTier2,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
      ),
      // Transparent Material so ListTile's ink draws above this
      // container's background instead of being hidden by it.
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            date,
            style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                _MiniStat(value: dur, label: ''),
                const SizedBox(width: 12),
                if (dist > 0) ...[
                  _MiniStat(
                      value: dist.toStringAsFixed(1),
                      label: formatter.distanceUnit),
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
              Text('TSS',
                  style: TextStyle(color: tokens.textDisabled, fontSize: 10)),
            ],
          ),
          onTap: onTap,
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
      style: TextStyle(color: context.tokens.textTertiary, fontSize: 12),
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
