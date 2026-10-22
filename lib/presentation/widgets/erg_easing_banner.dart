import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';

/// Says why the trainer gives less than the ERG target while the
/// `ErgCadenceGuard` eases it for a collapsed cadence, and how to get the
/// target back. Hidden the rest of the time.
class ErgEasingBanner extends ConsumerWidget {
  const ErgEasingBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final easing = ref.watch(ergEasingProvider).valueOrNull ?? false;
    if (!easing) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Colors.orange.shade900,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        children: [
          Icon(Icons.speed, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cadence too low — resistance eased. Spin up to get back to '
              'the target.',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
