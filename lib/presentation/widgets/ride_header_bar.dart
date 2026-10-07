import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/application/services/recording_engine.dart';
import '../../core/domain/entities/entities.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import 'ride_pause_actions.dart';
import 'sensor_role_labels.dart';

/// Header bar showing the ride timer and control buttons (pause, lap, stop).
class RideHeaderBar extends ConsumerWidget {
  const RideHeaderBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsed = ref.watch(rideElapsedProvider);
    final recState = ref.watch(recordingStateProvider);

    final timerText = elapsed.when(
      data: formatRideDuration,
      loading: () => '00:00:00',
      error: (_, __) => '--:--:--',
    );

    final isRecording = recState.when(
      data: (s) => s == RecordingState.recording,
      loading: () => false,
      error: (_, __) => false,
    );

    final isPaused = recState.when(
      data: (s) => s == RecordingState.paused,
      loading: () => false,
      error: (_, __) => false,
    );

    final isActive = isRecording || isPaused;

    return Container(
      height: 56,
      color: context.tokens.rideSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Timer
          Expanded(
            // Never wrap onto a second line: scale the timer down when the
            // space beside the buttons is too narrow (small tablets, where
            // this header only gets part of the width).
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                timerText,
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          const _SensorStatusDots(),
          const SizedBox(width: 12),

          // Control buttons
          if (isActive) ...[
            // Pause / Resume
            IconButton(
              icon: Icon(
                isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                if (isPaused) {
                  resumeRide(ref);
                } else {
                  pauseRide(ref);
                }
              },
            ),

            // Lap
            IconButton(
              icon: const Icon(Icons.flag, color: Colors.amber, size: 28),
              onPressed: () => markLap(context, ref),
            ),

            // Stop — also the way to leave once a ride is running (with a
            // save/discard confirm), so the close button below is hidden
            // while active to keep this row from wrapping to two lines on
            // narrow screens.
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.redAccent, size: 28),
              onPressed: () => confirmStopRide(context, ref),
            ),
          ] else ...[
            // Start
            IconButton(
              icon: const Icon(Icons.play_arrow,
                  color: Colors.greenAccent, size: 32),
              onPressed: () {
                ref.read(recordingEngineProvider).start();
              },
            ),

            // Close — only shown before the ride starts, since the stop
            // button takes over as the way to leave once it's running.
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.close,
                  color: context.tokens.textTertiary, size: 26),
              tooltip: 'Leave ride',
              onPressed: () => leaveRide(context, ref),
            ),
          ],
        ],
      ),
    );
  }

}

/// Small status dots for the trainer/HR/power roles: grey when nothing is
/// paired to that role, green when connected, red when the paired device
/// has disconnected.
class _SensorStatusDots extends ConsumerWidget {
  const _SensorStatusDots();

  static const _roles = [
    SensorRole.trainer,
    SensorRole.heartRate,
    SensorRole.power,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paired = ref.watch(pairedDevicesProvider);
    final connection = ref.watch(roleConnectionProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final role in _roles) _dot(role, paired, connection),
      ],
    );
  }

  Widget _dot(
    SensorRole role,
    PairedDevices paired,
    Map<SensorRole, RoleConnection> connection,
  ) {
    final isPaired = paired.forRole(role) != null;
    // Paired is a saved preference, not a live connection — only an actual
    // open port turns the dot green.
    final isConnected = connection[role] == RoleConnection.connected;

    final Color color;
    if (!isPaired) {
      color = Colors.white12;
    } else if (isConnected) {
      color = Colors.greenAccent;
    } else {
      color = Colors.redAccent;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Tooltip(
        message: isPaired && !isConnected
            ? '${roleLabel(role)} — not connected'
            : roleLabel(role),
        child: Icon(Icons.circle, size: 9, color: color),
      ),
    );
  }
}
