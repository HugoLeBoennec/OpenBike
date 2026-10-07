import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/application/services/auto_pause_detector.dart';
import '../../core/application/services/bundled_workouts.dart';
import '../../core/application/services/ftp_test_planner.dart';
import '../../core/application/services/recording_engine.dart';
import '../../core/application/services/route_simulator.dart';
import '../../core/application/services/workout_engine.dart';
import '../../core/events/app_event.dart';
import '../models/data_field_type.dart';
import '../models/ride_extra.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_banner.dart';
import '../widgets/data_field_grid.dart';
import '../widgets/live_chart.dart';
import '../widgets/manual_trainer_controls.dart';
import '../widgets/power_gauge.dart';
import '../widgets/ride_header_bar.dart';
import '../widgets/ride_keyboard_shortcuts.dart';
import '../widgets/ride_pause_actions.dart';
import '../widgets/route_profile_pane.dart';
import '../widgets/workout_hud_widget.dart';
import '../widgets/zone_bar.dart';

/// Main ride screen — Garmin Edge style dark UI with responsive layouts.
///
/// - **Portrait** (<600px): Header → ZoneBar → PageView(grids) → dots → Chart
/// - **Landscape** (≥600px): Row → Left(header+zone+grid) → Right(chart+gauge)
/// - **Desktop** (≥1200px): same as landscape but with larger grid (3×4)
/// - **Portrait tablet** (≥600px wide and taller than wide): stacked — header,
///   zone bar, a height-filling 3-column grid, then the chart/HUD beside the gauge
class RideScreen extends ConsumerStatefulWidget {
  const RideScreen({super.key, this.extra});

  final RideExtra? extra;

  @override
  ConsumerState<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends ConsumerState<RideScreen> {
  StreamSubscription<SimulationEvent>? _simCompletionSub;
  Timer? _autoPauseTimer;
  final _autoPauseDetector = AutoPauseDetector();
  bool _autoPauseDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();

    // If a workout was passed, set it as the current workout and start the
    // ERG-driving engine against the connected trainer.
    if (widget.extra?.workout != null) {
      Future.microtask(() {
        final workout = widget.extra!.workout!;
        ref.read(currentWorkoutProvider.notifier).state = workout;
        ref.read(activeFtpTestProvider.notifier).state = switch (workout.id) {
          BundledWorkouts.rampTestId => FtpTestProtocol.ramp,
          BundledWorkouts.twentyMinTestId => FtpTestProtocol.twentyMinute,
          _ => null,
        };
        final ftp = ref.read(ftpProvider);
        final engine = ref.read(workoutEngineProvider);
        // A previous ride may have left the engine running or completed.
        if (engine.state != WorkoutEngineState.idle) engine.stop();
        engine.start(workout, ftp);
      });
    } else {
      Future.microtask(() {
        ref.read(activeFtpTestProvider.notifier).state = null;
      });
    }

    if (widget.extra?.scheduledWorkoutId != null) {
      Future.microtask(() {
        ref.read(activeScheduledWorkoutIdProvider.notifier).state =
            widget.extra!.scheduledWorkoutId;
      });
    }

    // If a route was passed, start the route simulator and watch for
    // completion so we can prompt to stop & save.
    if (widget.extra?.route != null) {
      Future.microtask(() {
        final simulator = ref.read(routeSimulatorProvider);
        // A previous ride may have left the simulator running or completed.
        if (simulator.state != SimulationState.idle) simulator.stop();
        simulator.start(widget.extra!.route!);
      });
      _simCompletionSub =
          ref.read(eventBusProvider).on<SimulationEvent>().listen((event) {
        if (event is SimulationCompleted) _onRouteCompleted();
      });
    }

    _autoPauseTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _checkAutoPause());
  }

  @override
  void dispose() {
    _simCompletionSub?.cancel();
    _autoPauseTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  // ─── Auto-pause ────────────────────────────────────────────────────

  void _checkAutoPause() {
    if (!ref.read(autoPauseEnabledProvider)) return;
    if (_autoPauseDialogShowing) return;

    final recState = ref.read(recordingStateProvider).valueOrNull;
    if (recState != RecordingState.recording) return;

    final speedKmh = ref.read(liveSpeedProvider).kmh;
    final trigger = _autoPauseDetector.onSpeedSample(speedKmh, DateTime.now());
    if (trigger) _showAutoPausePrompt();
  }

  Future<void> _showAutoPausePrompt() async {
    _autoPauseDialogShowing = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Still riding?'),
        content: const Text(
          'Speed has been near zero for a while. Pause recording?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Pause'),
          ),
        ],
      ),
    );
    _autoPauseDialogShowing = false;
    if (confirmed == true && mounted) {
      pauseRide(ref);
    }
  }

  // ─── Route completion ──────────────────────────────────────────────

  void _onRouteCompleted() {
    if (!mounted) return;
    final recState = ref.read(recordingStateProvider).valueOrNull;
    final isRecording = recState == RecordingState.recording ||
        recState == RecordingState.paused;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Route completed!'),
        content: Text(
          isRecording
              ? 'You reached the end of the route. Stop and save your ride?'
              : 'You reached the end of the route.',
        ),
        actions: [
          if (isRecording) ...[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Keep riding'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _stopAndSave();
              },
              child: const Text('Stop & Save',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ] else
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
        ],
      ),
    );
  }

  Future<void> _stopAndSave() async {
    final engine = ref.read(recordingEngineProvider);
    final ftp = ref.read(ftpProvider);
    final ride = await engine.stop(ftp: ftp);
    endRideSession(ref);

    WakelockPlus.disable();
    ref.invalidate(rideHistoryProvider);
    ref.invalidate(personalRecordsProvider);
    ref.invalidate(scheduledWorkoutsProvider);

    if (mounted) {
      context.go('/ride/summary/${ride.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bridge EventBus sensor events into live UI providers
    ref.watch(liveSensorBridgeProvider);
    // Activate history updaters so ring buffers receive live data
    ref.watch(powerHistoryUpdaterProvider);
    ref.watch(hrHistoryUpdaterProvider);
    // Starts/stops the Android foreground service with recording state.
    ref.watch(backgroundRecordingServiceProvider);
    // Links a finished ride back to the calendar entry it was started from.
    ref.watch(scheduledWorkoutLinkerProvider);
    // Auto-enqueues exports for any service with auto-upload enabled.
    ref.watch(autoUploadProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) leaveRide(context, ref);
      },
      child: RideKeyboardShortcuts(
        child: Scaffold(
          backgroundColor: context.tokens.rideSurface,
          body: SafeArea(
            child: Column(
              children: [
                const ConnectionBanner(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _adaptConfigToWidth(constraints.maxWidth);
                      if (constraints.maxWidth >= 600 &&
                          constraints.maxHeight > constraints.maxWidth) {
                        return _buildTabletPortraitLayout(
                            context, ref, constraints);
                      } else if (constraints.maxWidth >= 1200) {
                        return _buildDesktopLayout(context, ref, constraints);
                      } else if (constraints.maxWidth >= 600) {
                        return _buildLandscapeLayout(
                            context, ref, constraints);
                      } else {
                        return _buildPortraitLayout(
                            context, ref, constraints);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Picks the data-field preset that matches the layout class chosen by
  /// the [LayoutBuilder]. Deferred because providers can't change mid-build.
  void _adaptConfigToWidth(double width) {
    Future.microtask(() {
      if (!mounted) return;
      ref.read(rideScreenConfigProvider.notifier).adaptToLayout(
            isLandscape: width >= 600,
            isDesktop: width >= 1200,
          );
    });
  }

  // ─── Bottom pane — workout HUD / route profile / live chart ───────

  /// Picks the bottom pane by mode: a workout HUD when a structured workout
  /// is driving the ride, the GPX elevation profile for a route simulation,
  /// or the default live power/HR chart otherwise.
  Widget _buildBottomPane(BuildContext context, WidgetRef ref) {
    final hasWorkout = ref.watch(currentWorkoutProvider) != null;
    if (hasWorkout) return const WorkoutHudWidget();
    if (widget.extra?.route != null) return const RouteProfilePane();
    return const LiveChart();
  }

  // ─── Portrait ──────────────────────────────────────────────────────

  Widget _buildPortraitLayout(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    final config = ref.watch(rideScreenConfigProvider);
    final pages = config.pages;

    return Column(
      children: [
        const RideHeaderBar(),
        const ZoneBar(),
        const ManualTrainerControls(),
        Expanded(
          flex: 3,
          child: _PagedDataGrid(
            pages: pages,
            columns: config.columns,
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildBottomPane(context, ref),
        ),
      ],
    );
  }

  // ─── Portrait tablet ───────────────────────────────────────────────

  /// Tall, wide screens (7"/10" tablets, iPad in portrait): the side-by-side
  /// layouts would leave most of the height empty, so stack everything and
  /// let the grid and the bottom section share the height.
  Widget _buildTabletPortraitLayout(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    final config = ref.watch(rideScreenConfigProvider);
    final fields =
        config.pages.isNotEmpty ? config.pages.first : <DataFieldType>[];

    return Column(
      children: [
        const RideHeaderBar(),
        const ZoneBar(),
        const ManualTrainerControls(),
        Expanded(
          flex: 4,
          child: DataFieldGrid(
            fields: fields,
            columns: 3,
            pageIndex: 0,
            fillHeight: true,
          ),
        ),
        Expanded(
          flex: 5,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildBottomPane(context, ref),
              ),
              if (config.showPowerGauge)
                const Expanded(
                  flex: 2,
                  child: PowerGauge(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Landscape ─────────────────────────────────────────────────────

  Widget _buildLandscapeLayout(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    final config = ref.watch(rideScreenConfigProvider);
    final fields =
        config.pages.isNotEmpty ? config.pages.first : <DataFieldType>[];

    return Row(
      children: [
        // Left: header + zone + grid
        Expanded(
          flex: 3,
          child: Column(
            children: [
              const RideHeaderBar(),
              const ZoneBar(),
              const ManualTrainerControls(),
              Expanded(
                child: DataFieldGrid(
                  fields: fields,
                  columns: 3,
                  pageIndex: 0,
                ),
              ),
            ],
          ),
        ),
        // Right: chart/HUD/profile + gauge
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: _buildBottomPane(context, ref),
              ),
              if (config.showPowerGauge)
                const Expanded(
                  flex: 2,
                  child: PowerGauge(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Desktop ───────────────────────────────────────────────────────

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    final config = ref.watch(rideScreenConfigProvider);
    final fields =
        config.pages.isNotEmpty ? config.pages.first : <DataFieldType>[];

    return Row(
      children: [
        // Left: header + zone + large grid
        Expanded(
          flex: 3,
          child: Column(
            children: [
              const RideHeaderBar(),
              const ZoneBar(),
              const ManualTrainerControls(),
              Expanded(
                child: DataFieldGrid(
                  fields: fields,
                  columns: 3,
                  pageIndex: 0,
                ),
              ),
            ],
          ),
        ),
        // Right: chart/HUD/profile + gauge
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: _buildBottomPane(context, ref),
              ),
              if (config.showPowerGauge)
                const Expanded(
                  flex: 2,
                  child: PowerGauge(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Paged Data Grid (portrait only) ───────────────────────────────────

class _PagedDataGrid extends StatefulWidget {
  final List<List<DataFieldType>> pages;
  final int columns;

  const _PagedDataGrid({
    required this.pages,
    required this.columns,
  });

  @override
  State<_PagedDataGrid> createState() => _PagedDataGridState();
}

class _PagedDataGridState extends State<_PagedDataGrid> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            itemCount: widget.pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return DataFieldGrid(
                fields: widget.pages[index],
                columns: widget.columns,
                pageIndex: index,
              );
            },
          ),
        ),
        if (widget.pages.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _PageDots(
              count: widget.pages.length,
              current: _currentPage,
            ),
          ),
      ],
    );
  }
}

// ─── Page indicator dots ───────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  final int count;
  final int current;

  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == current
                ? context.tokens.rideOnSurface
                : context.tokens.rideOnSurface.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}
