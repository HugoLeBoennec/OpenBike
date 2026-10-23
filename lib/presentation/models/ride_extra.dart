import '../../core/application/services/route_library.dart';
import '../../core/domain/entities/entities.dart';

/// Extras passed to [RideScreen] via GoRouter's `extra` parameter.
class RideExtra {
  const RideExtra({
    this.workout,
    this.route,
    this.savedRouteId,
    this.routeDraft,
    this.scheduledWorkoutId,
  });

  final Workout? workout;
  final Route? route;

  /// The library route [route] was loaded from — the finished ride is
  /// linked to it.
  final String? savedRouteId;

  /// The file [route] was read from when it wasn't saved, so the ride
  /// summary can still offer to save it.
  final RouteDraft? routeDraft;

  /// Set when this ride was started from a training-calendar entry ("Start
  /// now") — [RideScreen] links the finished ride back to this entry.
  final String? scheduledWorkoutId;
}
