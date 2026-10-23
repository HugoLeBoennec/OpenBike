import 'package:freezed_annotation/freezed_annotation.dart';

import '../value_objects/value_objects.dart';

part 'saved_route.freezed.dart';

/// A route kept in the rider's library, without its GPX text — the list
/// shows many of these, and each file can run to megabytes, so the text is
/// loaded on its own when the route is ridden (`StoragePort.getRouteGpx`).
///
/// [rideCount] and [lastRiddenAt] come from the rides linked to this route,
/// not from this row, so deleting a ride keeps them right.
@freezed
class SavedRoute with _$SavedRoute {
  const SavedRoute._();

  const factory SavedRoute({
    required String id,
    required String name,

    /// [importSource] for a file the rider picked; otherwise the id of the
    /// route source that provided it, with [externalRef] its id there.
    @Default(SavedRoute.importSource) String source,
    String? externalRef,

    /// Encoded [RouteShape] — what duplicate detection compares.
    required String fingerprint,
    required Distance distance,

    /// Metres climbed, from the smoothed elevations.
    required double ascent,

    /// Elevation samples spread evenly along the route, for thumbnails.
    @Default([]) List<double> profile,
    required DateTime createdAt,
    @Default(0) int rideCount,
    DateTime? lastRiddenAt,
  }) = _SavedRoute;

  static const importSource = 'import';

  /// Whether the rider can rename or delete it — routes from a source are
  /// that source's to change.
  bool get isEditable => source == importSource;
}
