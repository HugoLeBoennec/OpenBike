import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/trainer_device.dart';
import '../../domain/entities/workout_step.dart';
import '../../domain/ports/trainer_port.dart';
import '../../domain/value_objects/value_objects.dart';
import '../../events/app_event.dart';
import '../../events/event_bus.dart';

final _log = Logger('TrainerModeController');

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// Snapshot of the current trainer mode and its associated targets.
class TrainerModeState {
  const TrainerModeState({
    required this.mode,
    this.resistanceLevel = 3.0,
  });

  /// Active control mode.
  final ControlMode mode;

  /// Resistance level in effect when [mode] is [ControlMode.resistance].
  final double resistanceLevel;

  TrainerModeState copyWith({ControlMode? mode, double? resistanceLevel}) =>
      TrainerModeState(
        mode: mode ?? this.mode,
        resistanceLevel: resistanceLevel ?? this.resistanceLevel,
      );
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

/// Orchestrates trainer mode switching based on workout / route state.
///
/// Listens to [WorkoutEvent] and [SimulationEvent] on the [EventBus] and
/// calls the appropriate [TrainerPort] method when the mode changes.
///
/// Switching rules (priority order):
/// - Structured workout + step has a power target  → ERG
/// - Structured workout + freeRide step            → Resistance (level 3)
/// - GPX route active, no structured workout       → SIM
/// - No workout, no route                          → Resistance (adjustable)
///
/// The [getDefaultResistance] callback lets callers (e.g. providers) supply
/// the current user preference without creating an infrastructure dependency
/// inside this domain service.
class TrainerModeController extends StateNotifier<TrainerModeState> {
  TrainerModeController({
    required EventBus eventBus,
    double Function()? getDefaultResistance,
  })  : _getDefaultResistance = getDefaultResistance ?? (() => 3.0),
        super(const TrainerModeState(mode: ControlMode.resistance)) {
    _workoutSub = eventBus.on<WorkoutEvent>().listen(_onWorkoutEvent);
    _simSub = eventBus.on<SimulationEvent>().listen(_onSimulationEvent);
  }

  final double Function() _getDefaultResistance;

  TrainerPort? _trainerPort;
  StreamSubscription<WorkoutEvent>? _workoutSub;
  StreamSubscription<SimulationEvent>? _simSub;

  bool _hasActiveWorkout = false;
  bool _hasActiveRoute = false;

  // ---------------------------------------------------------------------------
  // Port injection
  // ---------------------------------------------------------------------------

  /// Called by the provider layer when the active [TrainerPort] changes.
  void setTrainerPort(TrainerPort? port) {
    _trainerPort = port;
  }

  // ---------------------------------------------------------------------------
  // EventBus listeners
  // ---------------------------------------------------------------------------

  void _onWorkoutEvent(WorkoutEvent event) {
    event.when(
      started: (_) => _hasActiveWorkout = true,
      stepChanged: (step, _) => _applyModeForStep(step),
      completed: () {
        _hasActiveWorkout = false;
        _applyDefaultMode();
      },
      paused: () {},
      resumed: () {},
    );
  }

  void _onSimulationEvent(SimulationEvent event) {
    event.when(
      started: (_) {
        _hasActiveRoute = true;
        if (!_hasActiveWorkout) switchMode(ControlMode.simulation);
      },
      positionChanged: (_, __) {},
      paused: () {},
      resumed: () {},
      completed: () {
        _hasActiveRoute = false;
        _applyDefaultMode();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Mode selection helpers
  // ---------------------------------------------------------------------------

  void _applyModeForStep(WorkoutStep step) {
    switch (step.type) {
      case StepType.freeRide:
        switchMode(ControlMode.resistance, resistance: 3.0);
      default:
        // All other step types (warmup, cooldown, steadyState, interval,
        // ramp) drive the trainer in ERG mode.
        switchMode(ControlMode.erg);
    }
  }

  void _applyDefaultMode() {
    if (_hasActiveRoute && !_hasActiveWorkout) {
      switchMode(ControlMode.simulation);
    } else {
      switchMode(
        ControlMode.resistance,
        resistance: _getDefaultResistance(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Switches the trainer to [mode], optionally sending an initial target.
  ///
  /// - [power]: initial ERG target (only used when mode == erg).
  /// - [grade]: initial simulation grade (only used when mode == simulation).
  ///   Grade scaling (difficulty) is applied by [FtmsTrainerAdapter], not here.
  /// - [resistance]: resistance level (only used when mode == resistance).
  Future<void> switchMode(
    ControlMode mode, {
    Watts? power,
    Grade? grade,
    double? resistance,
  }) async {
    _log.info('switchMode → $mode');

    final effectiveResistance =
        resistance ?? (mode == ControlMode.resistance ? _getDefaultResistance() : state.resistanceLevel);

    state = TrainerModeState(
      mode: mode,
      resistanceLevel: mode == ControlMode.resistance
          ? effectiveResistance
          : state.resistanceLevel,
    );

    final port = _trainerPort;
    if (port == null) {
      _log.fine('switchMode: no trainer connected — mode stored only');
      return;
    }

    try {
      switch (mode) {
        case ControlMode.erg:
          // WorkoutEngine handles per-tick ERG targets; only send here if an
          // explicit initial power was provided (e.g. from the UI).
          if (power != null) await port.setTargetPower(power);

        case ControlMode.simulation:
          // RouteSimulator sends per-tick simulation params.
          // Only send an initial value when an explicit grade is given.
          if (grade != null) {
            await port.setSimulationParams(0, grade, 0.004, 0.51);
          }

        case ControlMode.resistance:
          await port.setResistance(effectiveResistance);
      }
    } catch (e) {
      _log.warning('switchMode($mode) BLE command failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _workoutSub?.cancel();
    _simSub?.cancel();
    super.dispose();
  }
}
