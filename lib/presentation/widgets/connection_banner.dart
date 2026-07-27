import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/entities/paired_devices.dart';
import '../state/providers.dart';
import 'sensor_role_labels.dart';

/// Warns about paired roles that aren't delivering data, auto-dismissing as
/// each one connects. Driven by [roleConnectionProvider].
///
/// Distinguishes the two ways a role goes quiet, because only one of them
/// recovers on its own: a mid-ride dropout is retried automatically by
/// `BleTransport`, while a device that never connected this session (e.g.
/// it was asleep at app start) needs the user to reconnect it from the
/// Devices screen.
class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paired = ref.watch(pairedDevicesProvider);
    final connection = ref.watch(roleConnectionProvider);

    List<SensorRole> rolesIn(RoleConnection status) => [
          for (final role in paired.byRole.keys)
            if (connection[role] == status) role,
        ];

    final lost = rolesIn(RoleConnection.lost);
    final notConnected = rolesIn(RoleConnection.notConnected);
    if (lost.isEmpty && notConnected.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Colors.red.shade900,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lost.isNotEmpty)
            _BannerLine(
              text: '${lost.map(roleLabel).join(', ')} connection lost — '
                  'reconnecting…',
            ),
          if (notConnected.isNotEmpty)
            _BannerLine(
              text: '${notConnected.map(roleLabel).join(', ')} not connected — '
                  'reconnect from Devices',
            ),
        ],
      ),
    );
  }
}

class _BannerLine extends StatelessWidget {
  const _BannerLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          const Icon(Icons.bluetooth_disabled, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
