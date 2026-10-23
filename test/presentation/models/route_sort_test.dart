import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/domain/entities/saved_route.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/presentation/models/route_sort.dart';

SavedRoute _route(
  String name, {
  double km = 10,
  double ascent = 100,
  DateTime? createdAt,
  DateTime? lastRiddenAt,
  int rideCount = 0,
}) =>
    SavedRoute(
      id: name,
      name: name,
      fingerprint: '',
      distance: Distance(km * 1000),
      ascent: ascent,
      createdAt: createdAt ?? DateTime(2026, 10, 1),
      lastRiddenAt: lastRiddenAt,
      rideCount: rideCount,
    );

void main() {
  group('sortAndFilterRoutes', () {
    final ridden = _route('ridden',
        km: 30,
        ascent: 50,
        createdAt: DateTime(2026, 8, 1),
        lastRiddenAt: DateTime(2026, 10, 10),
        rideCount: 2);
    final fresh = _route('Fresh', km: 5, ascent: 900,
        createdAt: DateTime(2026, 10, 20));
    final stale = _route('stale', km: 20, ascent: 400,
        createdAt: DateTime(2026, 9, 1));
    final routes = [stale, ridden, fresh];

    List<String> names(RouteSort sort, {String query = ''}) =>
        sortAndFilterRoutes(routes, sort, query: query)
            .map((r) => r.name)
            .toList();

    test('recent: whichever of ridden or added is later', () {
      expect(names(RouteSort.recent), ['Fresh', 'ridden', 'stale']);
    });

    test('the other orders', () {
      expect(names(RouteSort.added), ['Fresh', 'stale', 'ridden']);
      expect(names(RouteSort.name), ['Fresh', 'ridden', 'stale']);
      expect(names(RouteSort.distance), ['Fresh', 'stale', 'ridden']);
      expect(names(RouteSort.climbing), ['ridden', 'stale', 'Fresh']);
    });

    test('query matches part of the name, ignoring case', () {
      expect(names(RouteSort.name, query: ' FRE '), ['Fresh']);
      expect(names(RouteSort.name, query: 'nothing'), isEmpty);
    });

    test('an unknown stored sort falls back to recent', () {
      expect(RouteSort.fromName('distance'), RouteSort.distance);
      expect(RouteSort.fromName('bogus'), RouteSort.recent);
      expect(RouteSort.fromName(null), RouteSort.recent);
    });
  });

  group('labels', () {
    final now = DateTime(2026, 10, 23, 9);

    test('usage', () {
      expect(routeUsageLabel(_route('a'), now), 'Not ridden yet');
      expect(
        routeUsageLabel(
          _route('a', rideCount: 3, lastRiddenAt: DateTime(2026, 10, 19, 22)),
          now,
        ),
        '3× · 4 days ago',
      );
    });

    test('days ago counts calendar days', () {
      expect(daysAgoLabel(DateTime(2026, 10, 23, 1), now), 'today');
      expect(daysAgoLabel(DateTime(2026, 10, 22, 23), now), 'yesterday');
      // Across the end of daylight-saving time (a 25-hour day in Europe).
      expect(
        daysAgoLabel(DateTime(2026, 10, 24), DateTime(2026, 10, 26)),
        '2 days ago',
      );
    });
  });
}
