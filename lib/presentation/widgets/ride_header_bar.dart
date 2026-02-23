import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/application/services/recording_engine.dart';
import '../../core/domain/entities/trainer_device.dart';
import '../state/providers.dart';

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
                final engine = ref.read(recordingEngineProvider);
                if (isPaused) {
                  engine.resume();
                } else {
                  engine.pause();
                }
              },
            ),

            // Lap
            IconButton(
              icon: const Icon(Icons.flag, color: Colors.amber, size: 28),
              onPressed: () {
                final engine = ref.read(recordingEngineProvider);
                final lap = engine.markLap();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Lap ${engine.lapCount} — '
                      '${_formatDuration(lap.duration)}',
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
          const SizedBox(width: 4),
          const _ModeBadge(),
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

// ─── Mode badge ────────────────────────────────────────────────────────────

class _ModeBadge extends ConsumerWidget {
  const _ModeBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(trainerModeProvider);
    final (label, color) = switch (mode) {
      ControlMode.erg => ('ERG', Colors.deepOrange),
      ControlMode.simulation => ('SIM', Colors.lightBlue),
      ControlMode.resistance => ('RES', Colors.white54),
    };
    return GestureDetector(
      onLongPress: () => _showModeSwitcher(context, ref, mode),
      child: Container(
        width: 40,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _showModeSwitcher(
      BuildContext context, WidgetRef ref, ControlMode current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _ModeSwitcherSheet(current: current, ref: ref),
    );
  }
}

class _ModeSwitcherSheet extends StatelessWidget {
  const _ModeSwitcherSheet({required this.current, required this.ref});

  final ControlMode current;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text(
            'TRAINER MODE',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _modeItem(context, ControlMode.erg, 'ERG',
              Icons.bolt, Colors.deepOrange),
          _modeItem(context, ControlMode.simulation, 'Simulation',
              Icons.terrain, Colors.lightBlue),
          _modeItem(context, ControlMode.resistance, 'Resistance',
              Icons.tune, Colors.white54),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _modeItem(BuildContext context, ControlMode mode, String label,
      IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: current == mode
          ? const Icon(Icons.check, color: Colors.deepOrange, size: 18)
          : null,
      onTap: () {
        ref
            .read(trainerModeControllerProvider.notifier)
            .switchMode(mode);
        Navigator.of(context).pop();
      },
    );
  }
}
