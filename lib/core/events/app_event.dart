import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/entities/entities.dart';
import '../domain/value_objects/value_objects.dart';

part 'app_event.freezed.dart';

// ---------------------------------------------------------------------------
// Sensor
// ---------------------------------------------------------------------------

@freezed
class SensorEvent with _$SensorEvent {
  const factory SensorEvent({
    required SensorReading reading,
    required String deviceId,
  }) = _SensorEvent;
}

// ---------------------------------------------------------------------------
// Trainer
// ---------------------------------------------------------------------------

@freezed
class TrainerEvent with _$TrainerEvent {
  const factory TrainerEvent.connected(TrainerDevice device) = TrainerConnected;
  const factory TrainerEvent.disconnected(String deviceId) =
      TrainerDisconnected;
  const factory TrainerEvent.controlAcquired(String deviceId) =
      TrainerControlAcquired;
  const factory TrainerEvent.modeChanged(String deviceId, ControlMode mode) =
      TrainerModeChanged;

  /// Trainer stopped/paused via its physical button (0x2ADA status 0x02).
  const factory TrainerEvent.physicalStop(String deviceId) = TrainerPhysicalStop;

  /// Trainer stopped by safety key / limit (0x2ADA status 0x04).
  const factory TrainerEvent.safetyStop(String deviceId) = TrainerSafetyStop;
}

// ---------------------------------------------------------------------------
// Workout
// ---------------------------------------------------------------------------

@freezed
class WorkoutEvent with _$WorkoutEvent {
  const factory WorkoutEvent.started(Workout workout) = WorkoutStarted;
  const factory WorkoutEvent.stepChanged(WorkoutStep step, int index) =
      WorkoutStepChanged;
  const factory WorkoutEvent.completed() = WorkoutCompleted;
  const factory WorkoutEvent.paused() = WorkoutPaused;
  const factory WorkoutEvent.resumed() = WorkoutResumed;

  /// Fired by [WorkoutEngine.reset] — clears all workout state and returns
  /// the engine to idle.  Listeners should treat this as a full session end.
  const factory WorkoutEvent.reset() = WorkoutReset;
}

// ---------------------------------------------------------------------------
// Ride
// ---------------------------------------------------------------------------

@freezed
class RideEvent with _$RideEvent {
  const factory RideEvent.started(String rideId) = RideStarted;
  const factory RideEvent.paused(String rideId) = RidePaused;
  const factory RideEvent.resumed(String rideId) = RideResumed;
  const factory RideEvent.lapMarked(String rideId, Lap lap) = RideLapMarked;
  const factory RideEvent.stopped(Ride ride) = RideStopped;
}

// ---------------------------------------------------------------------------
// Simulation
// ---------------------------------------------------------------------------

@freezed
class SimulationEvent with _$SimulationEvent {
  const factory SimulationEvent.started(Route route) = SimulationStarted;
  const factory SimulationEvent.positionChanged(
      RoutePoint point, Speed speed) = SimulationPositionChanged;
  const factory SimulationEvent.paused() = SimulationPaused;
  const factory SimulationEvent.resumed() = SimulationResumed;
  const factory SimulationEvent.completed() = SimulationCompleted;
}

// ---------------------------------------------------------------------------
// Export
// ---------------------------------------------------------------------------

@freezed
class ExportEvent with _$ExportEvent {
  const factory ExportEvent.queued(String rideId, String target) =
      ExportQueued;
  const factory ExportEvent.uploading(String rideId, String target) =
      ExportUploading;
  const factory ExportEvent.success(String rideId, String target) =
      ExportSuccess;
  const factory ExportEvent.failed(String rideId, String target, String error) =
      ExportFailed;
}
