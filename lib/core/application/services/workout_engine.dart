import 'dart:async';

import 'package:logging/logging.dart';

import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_step.dart';
import '../../domain/ports/trainer_port.dart';
import '../../domain/value_objects/value_objects.dart';
import '../../events/app_event.dart';
import '../../events/event_bus.dart';

final _log = Logger('WorkoutEngine');

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum WorkoutEngineState { idle, running, paused, completed }

// ---------------------------------------------------------------------------
// Progress snapshot (emitted at 1 Hz)
// ---------------------------------------------------------------------------

class WorkoutProgress {
  const WorkoutProgress({
    required this.currentStepIndex,
    required this.currentStep,
    required this.elapsedInStep,
    required this.stepDuration,
    required this.totalSteps,
    required this.targetPower,
    required this.totalElapsed,
    required this.totalDuration,
    this.intervalRepeat,
    this.intervalPhase,
    this.textEvent,
  });

  final int currentStepIndex;
  final WorkoutStep currentStep;

  /// Elapsed time within the current step (or interval phase).
  final Duration elapsedInStep;

  /// Total duration of the current step (or phase).
  final Duration stepDuration;

  final int totalSteps;

  /// Current target power in watts.
  final Watts targetPower;

  /// Total elapsed time since workout started (excluding pauses).
  final Duration totalElapsed;

  /// Total workout duration.
  final Duration totalDuration;

  /// Current interval repeat (1-based), null when not in an interval step.
  final int? intervalRepeat;

  /// `true` = "on" phase, `false` = "off" phase. Null when not interval.
  final bool? intervalPhase;

  /// Active text event to display, if any.
  final TextEvent? textEvent;

  double get stepProgress {
    final ms = stepDuration.inMilliseconds;
    if (ms == 0) return 1;
    return elapsedInStep.inMilliseconds / ms;
  }

  double get overallProgress {
    final ms = totalDuration.inMilliseconds;
    if (ms == 0) return 1;
    return totalElapsed.inMilliseconds / ms;
  }

  Duration get remainingInStep => stepDuration - elapsedInStep;

  Duration get remainingTotal => totalDuration - totalElapsed;
}

// ---------------------------------------------------------------------------
// Engine
// ---------------------------------------------------------------------------

/// Drives a structured workout: iterates steps at 1 Hz, sends target power
/// to the trainer, handles ramp interpolation, interval repeats with on/off
/// phases, pause/resume, skip, and fires [WorkoutEvent]s on the [EventBus].
class WorkoutEngine {
  WorkoutEngine({
    required TrainerPort trainerPort,
    required EventBus eventBus,
  })  : _trainerPort = trainerPort,
        _eventBus = eventBus;

  final TrainerPort _trainerPort;
  final EventBus _eventBus;

  // ---------------------------------------------------------------------------
  // Public state
  // ---------------------------------------------------------------------------

  WorkoutEngineState _state = WorkoutEngineState.idle;
  WorkoutEngineState get state => _state;

  final _stateController = StreamController<WorkoutEngineState>.broadcast();
  Stream<WorkoutEngineState> get stateStream => _stateController.stream;

  final _progressController = StreamController<WorkoutProgress>.broadcast();
  Stream<WorkoutProgress> get progressStream => _progressController.stream;

  Workout? _currentWorkout;
  Workout? get currentWorkout => _currentWorkout;
  Watts _ftp = Watts.zero;

  int _currentStepIndex = 0;
  int get currentStepIndex => _currentStepIndex;

  Watts _targetPower = Watts.zero;
  Watts get targetPower => _targetPower;

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Timer? _ticker;

  /// Seconds elapsed within the current step/phase (reset per step/phase).
  int _elapsedInPhase = 0;

  /// Duration of the current phase in seconds.
  int _phaseDuration = 0;

  /// Total seconds elapsed since workout start (excluding pauses).
  int _totalElapsed = 0;

  /// For interval steps: which repeat we're on (0-based).
  int _intervalRepeatIndex = 0;

  /// For interval steps: true = "on" phase, false = "off" phase.
  bool _intervalIsOnPhase = true;

  // ---------------------------------------------------------------------------
  // start
  // ---------------------------------------------------------------------------

  void start(Workout workout, Watts ftp) {
    if (_state == WorkoutEngineState.running ||
        _state == WorkoutEngineState.paused) {
      throw StateError('Cannot start: engine is $_state');
    }

    _currentWorkout = workout;
    _ftp = ftp;
    _currentStepIndex = 0;
    _totalElapsed = 0;

    _setState(WorkoutEngineState.running);
    _eventBus.fire(WorkoutEvent.started(workout));
    _log.info('Workout started: ${workout.name} (${workout.steps.length} steps, FTP=${ftp.value})');

    _beginStep(0);

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  // ---------------------------------------------------------------------------
  // pause / resume
  // ---------------------------------------------------------------------------

  void pause() {
    if (_state != WorkoutEngineState.running) {
      throw StateError('Cannot pause: engine is $_state');
    }
    _setState(WorkoutEngineState.paused);
    _eventBus.fire(const WorkoutEvent.paused());
    _log.info('Workout paused');
  }

  void resume() {
    if (_state != WorkoutEngineState.paused) {
      throw StateError('Cannot resume: engine is $_state');
    }
    _setState(WorkoutEngineState.running);
    _eventBus.fire(const WorkoutEvent.resumed());
    _log.info('Workout resumed');
  }

  // ---------------------------------------------------------------------------
  // skip (advance to next step)
  // ---------------------------------------------------------------------------

  void skip() {
    if (_state != WorkoutEngineState.running &&
        _state != WorkoutEngineState.paused) {
      throw StateError('Cannot skip: engine is $_state');
    }

    final nextIndex = _currentStepIndex + 1;
    if (nextIndex >= _currentWorkout!.steps.length) {
      _complete();
    } else {
      _beginStep(nextIndex);
    }
  }

  // ---------------------------------------------------------------------------
  // stop
  // ---------------------------------------------------------------------------

  void stop() {
    if (_state == WorkoutEngineState.idle) {
      throw StateError('Cannot stop: engine is idle');
    }

    _ticker?.cancel();
    _ticker = null;
    _setState(WorkoutEngineState.idle);
    _currentWorkout = null;
    _eventBus.fire(const WorkoutEvent.stopped());
    _log.info('Workout stopped by user');
  }

  // ---------------------------------------------------------------------------
  // dispose
  // ---------------------------------------------------------------------------

  void dispose() {
    _ticker?.cancel();
    _stateController.close();
    _progressController.close();
  }

  // ---------------------------------------------------------------------------
  // Step initialisation
  // ---------------------------------------------------------------------------

  void _beginStep(int index) {
    _currentStepIndex = index;
    final step = _currentWorkout!.steps[index];

    _eventBus.fire(WorkoutEvent.stepChanged(step, index));
    _log.fine('Step $index: ${step.type} ${step.durationSeconds}s');

    if (step.type == StepType.interval) {
      _intervalRepeatIndex = 0;
      _intervalIsOnPhase = true;
      _phaseDuration = step.durationSeconds; // "on" duration
    } else {
      _phaseDuration = step.durationSeconds;
    }

    _elapsedInPhase = 0;
    _updateTargetPower();
    _sendTargetToTrainer();
  }

  // ---------------------------------------------------------------------------
  // 1 Hz tick
  // ---------------------------------------------------------------------------

  void _onTick() {
    if (_state != WorkoutEngineState.running) return;

    _totalElapsed++;
    _elapsedInPhase++;

    // Check if current phase is done.
    if (_elapsedInPhase >= _phaseDuration) {
      if (!_advancePhase()) return; // workout completed
    }

    _updateTargetPower();
    _sendTargetToTrainer();
    _emitProgress();
  }

  /// Advances to the next phase/step. Returns `false` if the workout ended.
  bool _advancePhase() {
    final step = _currentWorkout!.steps[_currentStepIndex];

    if (step.type == StepType.interval) {
      if (_intervalIsOnPhase) {
        // Transition to "off" phase.
        _intervalIsOnPhase = false;
        _phaseDuration = step.offDurationSeconds ?? step.durationSeconds;
        _elapsedInPhase = 0;
        return true;
      } else {
        // End of "off" phase — next repeat or next step.
        _intervalRepeatIndex++;
        if (_intervalRepeatIndex < (step.repeat ?? 1)) {
          _intervalIsOnPhase = true;
          _phaseDuration = step.durationSeconds;
          _elapsedInPhase = 0;
          return true;
        }
        // All repeats done → fall through to next step.
      }
    }

    // Move to next step.
    final nextIndex = _currentStepIndex + 1;
    if (nextIndex >= _currentWorkout!.steps.length) {
      _complete();
      return false;
    }

    _beginStep(nextIndex);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Power computation
  // ---------------------------------------------------------------------------

  void _updateTargetPower() {
    final step = _currentWorkout!.steps[_currentStepIndex];
    final ftpValue = _ftp.value;

    switch (step.type) {
      case StepType.warmup:
      case StepType.cooldown:
      case StepType.ramp:
        // Linear interpolation from powerLowPercent → powerHighPercent.
        final low = (step.powerLowPercent ?? step.powerTargetPercent) / 100;
        final high = (step.powerHighPercent ?? step.powerTargetPercent) / 100;
        final t = _phaseDuration > 0
            ? _elapsedInPhase / _phaseDuration
            : 0.0;
        final lerped = low + (high - low) * t.clamp(0.0, 1.0);
        _targetPower = Watts((lerped * ftpValue).roundToDouble());
        break;

      case StepType.steadyState:
        _targetPower =
            Watts((step.powerTargetPercent / 100 * ftpValue).roundToDouble());
        break;

      case StepType.interval:
        if (_intervalIsOnPhase) {
          _targetPower = Watts(
              (step.powerTargetPercent / 100 * ftpValue).roundToDouble());
        } else {
          // Off phase uses powerLowPercent (off power).
          final offPct = step.powerLowPercent ?? step.powerTargetPercent;
          _targetPower =
              Watts((offPct / 100 * ftpValue).roundToDouble());
        }
        break;

      case StepType.freeRide:
        _targetPower = Watts.zero; // No ERG target.
        break;
    }
  }

  void _sendTargetToTrainer() {
    final step = _currentWorkout!.steps[_currentStepIndex];
    if (step.type == StepType.freeRide) return; // Don't send ERG for free ride.

    _trainerPort.setTargetPower(_targetPower).catchError((e) {
      _log.warning('Failed to set target power: $e');
    });
  }

  // ---------------------------------------------------------------------------
  // Progress emission
  // ---------------------------------------------------------------------------

  void _emitProgress() {
    final step = _currentWorkout!.steps[_currentStepIndex];

    // Find active text event for the current total elapsed time.
    TextEvent? activeText;
    for (final te in _currentWorkout!.textEvents) {
      if (_totalElapsed >= te.offsetSeconds &&
          _totalElapsed < te.offsetSeconds + te.durationSeconds) {
        activeText = te;
        break;
      }
    }

    final progress = WorkoutProgress(
      currentStepIndex: _currentStepIndex,
      currentStep: step,
      elapsedInStep: Duration(seconds: _elapsedInPhase),
      stepDuration: Duration(seconds: _phaseDuration),
      totalSteps: _currentWorkout!.steps.length,
      targetPower: _targetPower,
      totalElapsed: Duration(seconds: _totalElapsed),
      totalDuration: _currentWorkout!.totalDuration,
      intervalRepeat:
          step.type == StepType.interval ? _intervalRepeatIndex + 1 : null,
      intervalPhase:
          step.type == StepType.interval ? _intervalIsOnPhase : null,
      textEvent: activeText,
    );

    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }

  // ---------------------------------------------------------------------------
  // Completion
  // ---------------------------------------------------------------------------

  void _complete() {
    _ticker?.cancel();
    _ticker = null;
    _setState(WorkoutEngineState.completed);
    _eventBus.fire(const WorkoutEvent.completed());
    _log.info('Workout completed');
  }

  void _setState(WorkoutEngineState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }
}
