import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/entities/workout.dart';
import '../models/ride_extra.dart';
import '../state/providers.dart';

/// Returns `true` when a trainer is connected. Otherwise explains why one is
/// needed with [reason], offers to open the device scan, and returns `false`
/// so the caller doesn't start the ride.
Future<bool> ensureTrainerConnected(
  BuildContext context,
  WidgetRef ref, {
  required String reason,
}) async {
  if (ref.read(activeTrainerPortProvider) != null) return true;

  final connect = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Connect a trainer'),
      content: Text(reason),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Connect Device'),
        ),
      ],
    ),
  );
  if (connect == true && context.mounted) context.push('/scan');
  return false;
}

/// Opens the ride screen on [workout] — shared by the workout library, the
/// training calendar and the FTP test so they all require a trainer: the
/// workout engine drives its ERG targets and can't run without one.
Future<void> startWorkoutRide(
  BuildContext context,
  WidgetRef ref,
  Workout workout, {
  String? scheduledWorkoutId,
}) async {
  final connected = await ensureTrainerConnected(
    context,
    ref,
    reason: 'Workouts drive your trainer to each step\'s target power — '
        'pair a trainer first.',
  );
  if (!connected || !context.mounted) return;
  context.go(
    '/ride',
    extra: RideExtra(workout: workout, scheduledWorkoutId: scheduledWorkoutId),
  );
}
