import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import 'sensor_role_labels.dart';

/// Shows "X connection lost — reconnecting…" for every paired role whose
/// device has disconnected mid-ride, auto-dismissing as each role
/// reconnects. Driven by [disconnectedPairedRolesProvider].
class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disconnectedRoles = ref.watch(disconnectedPairedRolesProvider);
    if (disconnectedRoles.isEmpty) return const SizedBox.shrink();

    final label = disconnectedRoles.map(roleLabel).join(', ');

    return Container(
      width: double.infinity,
      color: Colors.red.shade900,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.bluetooth_disabled, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label connection lost — reconnecting…',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
