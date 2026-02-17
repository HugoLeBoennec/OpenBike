import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../widgets/ride_summary_widgets.dart';

/// Post-ride detail screen — metrics, power chart, zone distribution, export.
class RideDetailScreen extends ConsumerWidget {
  const RideDetailScreen({super.key, required this.rideId});

  final String rideId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideAsync = ref.watch(rideDetailProvider(rideId));
    final ftp = ref.watch(ftpProvider);
    final zones = ref.watch(powerZonesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Ride Detail'),
        backgroundColor: Colors.black,
      ),
      body: rideAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white30)),
        error: (e, _) => Center(
            child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
        data: (ride) {
          if (ride == null) {
            return const Center(
              child: Text('Ride not found.',
                  style: TextStyle(color: Colors.white54)),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              HeaderCard(ride: ride),
              const SizedBox(height: 16),
              MetricsGrid(ride: ride, ftp: ftp),
              const SizedBox(height: 24),
              if (ride.readings.isNotEmpty) ...[
                const SectionLabel('POWER'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: RidePowerChart(ride: ride, zones: zones, ftp: ftp),
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
            ],
          );
        },
      ),
    );
  }
}
