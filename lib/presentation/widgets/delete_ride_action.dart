import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';

/// Asks for confirmation, then deletes the ride and refreshes everything
/// that shows it — history, Home's CTL/TSB (through the ride history),
/// personal records, and the calendar plan it completed, which goes back to
/// not done. Returns whether it was deleted, for the caller to leave the
/// ride's screen. Shared by the ride summary and the History ride page.
Future<bool> confirmAndDeleteRide(
  BuildContext context,
  WidgetRef ref,
  String rideId,
) async {
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
          key: const Key('confirmDeleteRideButton'),
          onPressed: () => Navigator.of(ctx).pop(true),
          child:
              const Text('Delete', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;

  await ref.read(storageProvider).deleteRide(rideId);
  ref.invalidate(rideHistoryProvider);
  ref.invalidate(personalRecordsProvider);
  ref.invalidate(scheduledWorkoutsProvider);
  ref.invalidate(rideDetailProvider(rideId));
  return true;
}
