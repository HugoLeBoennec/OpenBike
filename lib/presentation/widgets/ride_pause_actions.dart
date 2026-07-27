import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/application/services/recording_engine.dart';
import '../../core/application/services/workout_engine.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';

/// Pauses recording and, if a workout is active, the [WorkoutEngine] too —
/// shared by [RideHeaderBar]'s pause button and the auto-pause prompt so
/// both paths keep ERG targets and the recorded timeline in sync.
void pauseRide(WidgetRef ref) {
  ref.read(recordingEngineProvider).pause();
  if (ref.read(currentWorkoutProvider) != null) {
    final engine = ref.read(workoutEngineProvider);
    if (engine.state == WorkoutEngineState.running) engine.pause();
  }
}

/// Resumes recording and, if a workout is active, the [WorkoutEngine] too.
void resumeRide(WidgetRef ref) {
  ref.read(recordingEngineProvider).resume();
  if (ref.read(currentWorkoutProvider) != null) {
    final engine = ref.read(workoutEngineProvider);
    if (engine.state == WorkoutEngineState.paused) engine.resume();
  }
}

/// Marks a lap on the active recording and shows a summary snackbar —
/// shared by [RideHeaderBar]'s lap button and the ride screen's `L`
/// keyboard shortcut so both paths behave identically.
void markLap(BuildContext context, WidgetRef ref) {
  final engine = ref.read(recordingEngineProvider);
  final lap = engine.markLap();
  final avgPower = engine.avgPowerForLap(lap);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Lap ${engine.lapCount} — '
        '${formatRideDuration(lap.duration)} — '
        'avg ${avgPower.value.round()} W',
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: context.tokens.surfaceTier2,
    ),
  );
}

/// Prompts to end the ride, then stops recording and saves — shared by
/// [RideHeaderBar]'s stop button and the ride screen's `Esc` keyboard
/// shortcut.
Future<void> confirmStopRide(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('End ride?'),
      content: const Text('Stop recording and save?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('End Ride',
              style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  final engine = ref.read(recordingEngineProvider);
  final ftp = ref.read(ftpProvider);
  final ride = await engine.stop(ftp: ftp);

  WakelockPlus.disable();
  ref.invalidate(rideHistoryProvider);
  ref.invalidate(personalRecordsProvider);
  ref.invalidate(scheduledWorkoutsProvider);

  if (context.mounted) {
    context.go('/ride/summary/${ride.id}');
  }
}

/// Leaves the ride screen without saving. A ride in progress is discarded
/// (after a confirm), since the red stop button is the way to *save*; when
/// idle there's nothing to lose, so it exits straight away. Shared by the
/// header's close button, the `Esc` shortcut while idle, and the ride
/// screen's back-gesture handler.
Future<void> leaveRide(BuildContext context, WidgetRef ref) async {
  final inProgress =
      ref.read(recordingEngineProvider).state != RecordingState.idle;
  if (inProgress) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave ride?'),
        content: const Text('Your current ride data will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Leave',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
  }

  // No need to disable the wakelock here — leaving disposes RideScreen,
  // whose dispose() already does it.
  if (!context.mounted) return;
  // The ride screen is reached via `context.go`, so there's usually nothing
  // to pop back to — fall back to the home route in that case.
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/');
  }
}

/// Formats a duration as `HH:MM:SS` — shared by lap snackbars and the ride
/// header's elapsed timer.
String formatRideDuration(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}
