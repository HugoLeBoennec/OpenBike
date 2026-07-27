import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/application/services/recording_engine.dart';
import '../../infrastructure/desktop/desktop_window_service.dart';
import '../state/providers.dart';
import 'ride_pause_actions.dart';

/// Starts recording, or toggles pause/resume if already active.
class StartPauseResumeIntent extends Intent {
  const StartPauseResumeIntent();
}

/// Marks a lap on the active recording.
class MarkLapIntent extends Intent {
  const MarkLapIntent();
}

/// Opens the end-ride confirmation (mirrors the header bar's stop button).
class StopRideIntent extends Intent {
  const StopRideIntent();
}

/// Toggles the native window's fullscreen state (desktop only).
class ToggleFullscreenIntent extends Intent {
  const ToggleFullscreenIntent();
}

/// Binds desktop keyboard shortcuts for the ride screen to the same actions
/// the on-screen controls use: Space (start/pause/resume), L (lap), Esc
/// (end & save while a ride is running, or leave the screen when idle), F
/// (fullscreen toggle).
class RideKeyboardShortcuts extends ConsumerWidget {
  const RideKeyboardShortcuts({super.key, required this.child});

  final Widget child;

  static const Map<ShortcutActivator, Intent> shortcutMap = {
    SingleActivator(LogicalKeyboardKey.space): StartPauseResumeIntent(),
    SingleActivator(LogicalKeyboardKey.keyL): MarkLapIntent(),
    SingleActivator(LogicalKeyboardKey.escape): StopRideIntent(),
    SingleActivator(LogicalKeyboardKey.keyF): ToggleFullscreenIntent(),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shortcuts(
      shortcuts: shortcutMap,
      child: Actions(
        actions: <Type, Action<Intent>>{
          StartPauseResumeIntent: CallbackAction<StartPauseResumeIntent>(
            onInvoke: (_) => _startPauseResume(ref),
          ),
          MarkLapIntent: CallbackAction<MarkLapIntent>(
            onInvoke: (_) => markLap(context, ref),
          ),
          StopRideIntent: CallbackAction<StopRideIntent>(
            // While a ride is running, Esc ends & saves it (matching the
            // stop button). When idle there's nothing to stop, so Esc just
            // leaves the screen instead of trying to stop an idle engine.
            onInvoke: (_) {
              if (ref.read(recordingEngineProvider).state ==
                  RecordingState.idle) {
                leaveRide(context, ref);
              } else {
                confirmStopRide(context, ref);
              }
              return null;
            },
          ),
          ToggleFullscreenIntent: CallbackAction<ToggleFullscreenIntent>(
            onInvoke: (_) => _toggleFullscreen(),
          ),
        },
        child: FocusScope(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }

  void _startPauseResume(WidgetRef ref) {
    // Reads the engine's synchronous state directly rather than the
    // stream-derived [recordingStateProvider], which can be transiently
    // unset for a freshly-created provider container.
    switch (ref.read(recordingEngineProvider).state) {
      case RecordingState.recording:
        pauseRide(ref);
      case RecordingState.paused:
        resumeRide(ref);
      case RecordingState.idle:
        ref.read(recordingEngineProvider).start();
    }
  }

  Future<void> _toggleFullscreen() async {
    if (!isDesktopPlatform) return;
    final isFullScreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullScreen);
  }
}
