import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';

class DeviceScanScreen extends ConsumerWidget {
  const DeviceScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainers = ref.watch(trainerListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Devices')),
      body: trainers.isEmpty
          ? const Center(child: Text('Tap scan to search for nearby trainers.'))
          : ListView.builder(
              itemCount: trainers.length,
              itemBuilder: (context, index) {
                final trainer = trainers[index];
                return ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(trainer.name),
                  subtitle: Text(trainer.connectionState.name),
                  onTap: () {
                    // TODO: Connect to trainer
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Start BLE scan
        },
        child: const Icon(Icons.bluetooth_searching),
      ),
    );
  }
}
