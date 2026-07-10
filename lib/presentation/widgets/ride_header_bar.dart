import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/application/services/recording_engine.dart';
import '../../core/domain/entities/entities.dart';
import '../state/providers.dart';
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
      data: _formatDuration,
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
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Timer
          Expanded(
            child: Text(
              timerText,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: Colors.white,
                letterSpacing: 2,
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
              onPressed: () {
                final engine = ref.read(recordingEngineProvider);
                final lap = engine.markLap();
                final avgPower = engine.avgPowerForLap(lap);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Lap ${engine.lapCount} — '
                      '${_formatDuration(lap.duration)} — '
                      'avg ${avgPower.value.round()} W',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF333333),
                  ),
                );
              },
            ),

            // Stop
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.redAccent, size: 28),
              onPressed: () => _confirmStop(context, ref),
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
          ],
        ],
      ),
    );
  }

  Future<void> _confirmStop(BuildContext context, WidgetRef ref) async {
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

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
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
    final status = ref.watch(roleConnectionStatusProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final role in _roles) _dot(role, paired, status),
      ],
    );
  }

  Widget _dot(
    SensorRole role,
    PairedDevices paired,
    Map<SensorRole, bool> status,
  ) {
    final isPaired = paired.forRole(role) != null;
    final isConnected = status[role] ?? true;

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
        message: roleLabel(role),
        child: Icon(Icons.circle, size: 9, color: color),
      ),
    );
  }
}
