import '../../core/domain/entities/saved_route.dart';

/// Orders the route library can be shown in.
enum RouteSort {
  /// Last ridden, or added for a route never ridden — whichever is later,
  /// so a route just imported shows at the top.
  recent('Recently used'),
  added('Recently added'),
  name('Name'),
  distance('Distance'),
  climbing('Climbing');

  const RouteSort(this.label);

  final String label;

  static RouteSort fromName(String? name) => RouteSort.values.firstWhere(
        (s) => s.name == name,
        orElse: () => RouteSort.recent,
      );
}

/// [routes] whose name contains [query] (ignoring case), in [sort] order.
List<SavedRoute> sortAndFilterRoutes(
  List<SavedRoute> routes,
  RouteSort sort, {
  String query = '',
}) {
  final needle = query.trim().toLowerCase();
  final result = [
    for (final r in routes)
      if (needle.isEmpty || r.name.toLowerCase().contains(needle)) r,
  ];
  int Function(SavedRoute, SavedRoute) compare = switch (sort) {
    RouteSort.recent => (a, b) => _lastUsed(b).compareTo(_lastUsed(a)),
    RouteSort.added => (a, b) => b.createdAt.compareTo(a.createdAt),
    RouteSort.name => (a, b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    RouteSort.distance => (a, b) =>
        a.distance.meters.compareTo(b.distance.meters),
    RouteSort.climbing => (a, b) => a.ascent.compareTo(b.ascent),
  };
  result.sort(compare);
  return result;
}

DateTime _lastUsed(SavedRoute r) {
  final ridden = r.lastRiddenAt;
  return ridden != null && ridden.isAfter(r.createdAt) ? ridden : r.createdAt;
}

/// "3× · 4 days ago", "1× · today", or "Not ridden yet".
String routeUsageLabel(SavedRoute route, DateTime now) {
  final last = route.lastRiddenAt;
  if (route.rideCount == 0 || last == null) return 'Not ridden yet';
  return '${route.rideCount}× · ${daysAgoLabel(last, now)}';
}

/// "today", "yesterday", "4 days ago", by calendar day in local time.
String daysAgoLabel(DateTime when, DateTime now) {
  // Calendar dates as UTC: local midnights can be 23 or 25 hours apart
  // across a daylight-saving change.
  final day = DateTime.utc(when.year, when.month, when.day);
  final today = DateTime.utc(now.year, now.month, now.day);
  final days = today.difference(day).inDays;
  if (days <= 0) return 'today';
  if (days == 1) return 'yesterday';
  return '$days days ago';
}
