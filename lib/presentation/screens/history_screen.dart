import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(rideHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ridesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rides) {
          if (rides.isEmpty) {
            return const Center(child: Text('No rides recorded yet.'));
          }
          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              return ListTile(
                leading: const Icon(Icons.directions_bike),
                title: Text(
                  ride.startTime.toIso8601String().substring(0, 10),
                ),
                subtitle: Text(
                  '${ride.activeDuration.inMinutes} min — '
                  '${ride.averagePower.value.round()} W avg',
                ),
                onTap: () {
                  // TODO: Open ride detail
                },
              );
            },
          );
        },
      ),
    );
  }
}
