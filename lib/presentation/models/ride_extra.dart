import '../../core/domain/entities/entities.dart';

/// Extras passed to [RideScreen] via GoRouter's `extra` parameter.
class RideExtra {
  const RideExtra({this.workout, this.route});

  final Workout? workout;
  final Route? route;
}
