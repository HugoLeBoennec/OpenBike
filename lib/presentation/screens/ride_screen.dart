import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../widgets/power_gauge.dart';
import '../widgets/zone_bar.dart';
import '../widgets/data_field_grid.dart';

class RideScreen extends ConsumerWidget {
  const RideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ride = ref.watch(currentRideProvider);
    final power = ref.watch(livePowerProvider);
    final cadence = ref.watch(liveCadenceProvider);
    final heartRate = ref.watch(liveHeartRateProvider);
    final speed = ref.watch(liveSpeedProvider);
    final zones = ref.watch(powerZonesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ride')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: PowerGauge(power: power),
          ),
          if (zones.isNotEmpty) ZoneBar(power: power, zones: zones),
          Expanded(
            flex: 3,
            child: DataFieldGrid(
              power: power,
              cadence: cadence,
              heartRate: heartRate,
              speed: speed,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Start / stop ride
        },
        child: Icon(ride == null ? Icons.play_arrow : Icons.stop),
      ),
    );
  }
}
