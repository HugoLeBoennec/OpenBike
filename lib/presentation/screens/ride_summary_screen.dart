import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/entities/power_zone.dart';
import '../../core/domain/entities/ride.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../state/providers.dart';
import '../widgets/ftp_test_prompt.dart';
import '../widgets/ride_summary_widgets.dart';

/// Post-ride summary screen shown after stopping a ride.
///
/// Uses [PopScope] to prevent back-navigation — the user must tap "Done".
class RideSummaryScreen extends ConsumerWidget {
  const RideSummaryScreen({super.key, required this.rideId});

  final String rideId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideAsync = ref.watch(rideDetailProvider(rideId));
    final ftp = ref.watch(ftpProvider);
    final zones = ref.watch(powerZonesProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Ride Summary'),
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            _buildBody(rideAsync, ftp, zones, context, ref),
            FtpTestPrompt(rideId: rideId),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    AsyncValue<Ride?> rideAsync,
    Watts ftp,
    List<PowerZone> zones,
    BuildContext context,
    WidgetRef ref,
  ) {
    return rideAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white30)),
          error: (e, _) => Center(
              child:
                  Text('Error: $e', style: const TextStyle(color: Colors.red))),
          data: (ride) {
            if (ride == null) {
              return const Center(
                child: Text('Ride not found.',
                    style: TextStyle(color: Colors.white54)),
              );
            }
            final newPrDurations = ref.watch(newPersonalRecordsForRideProvider(ride.id));
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                HeaderCard(ride: ride),
                const SizedBox(height: 16),
                if (newPrDurations.isNotEmpty) ...[
                  NewPersonalRecordsBanner(durations: newPrDurations),
                  const SizedBox(height: 16),
                ],
                MetricsGrid(ride: ride, ftp: ftp),
                const SizedBox(height: 24),
                if (ride.readings.isNotEmpty) ...[
                  const SectionLabel('POWER'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child:
                        RidePowerChart(ride: ride, zones: zones, ftp: ftp),
                  ),
                  const SizedBox(height: 24),
                ],
                if (ride.readings.isNotEmpty && zones.isNotEmpty) ...[
                  const SectionLabel('ZONE DISTRIBUTION'),
                  const SizedBox(height: 8),
                  ZoneDistributionChart(ride: ride, zones: zones, ftp: ftp),
                  const SizedBox(height: 24),
                ],
                if (ride.laps.isNotEmpty) ...[
                  const SectionLabel('LAPS'),
                  const SizedBox(height: 8),
                  LapsTable(ride: ride),
                  const SizedBox(height: 24),
                ],
                const SectionLabel('EXPORT'),
                const SizedBox(height: 8),
                ExportSection(rideId: ride.id),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () => _confirmDelete(context, ref),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => context.go('/'),
                        child: const Text('Done',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete ride?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final storage = ref.read(storageProvider);
      await storage.deleteRide(rideId);
      ref.invalidate(rideHistoryProvider);
      if (context.mounted) context.go('/');
    }
  }
}
