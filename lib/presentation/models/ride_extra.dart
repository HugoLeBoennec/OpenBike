import '../../core/domain/entities/entities.dart';

/// Extras passed to [RideScreen] via GoRouter's `extra` parameter.
class RideExtra {
  const RideExtra({this.workout, this.route, this.scheduledWorkoutId});

  final Workout? workout;
  final Route? route;

  /// Set when this ride was started from a training-calendar entry ("Start
  /// now") — [RideScreen] links the finished ride back to this entry.
  final String? scheduledWorkoutId;
}
