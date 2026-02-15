import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('FTP'),
            subtitle: Text(profile != null ? '${profile.ftp.value.round()} W' : 'Not set'),
            onTap: () {
              // TODO: Edit FTP
            },
          ),
          ListTile(
            title: const Text('Weight'),
            subtitle: Text(profile?.weight != null ? '${profile!.weight} kg' : 'Not set'),
            onTap: () {
              // TODO: Edit weight
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Connected Services'),
            subtitle: const Text('Strava, Garmin Connect, TrainingPeaks'),
            onTap: () {
              // TODO: Manage OAuth connections
            },
          ),
        ],
      ),
    );
  }
}
