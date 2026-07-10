import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/domain/entities/route_point.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/gpx_profile_widget.dart';

final _points = List.generate(10, (i) {
  final dist = i * 100.0;
  return RoutePoint(
    position: const GeoPoint(lat: 45.0, lon: 6.0),
    distanceFromStart: dist,
    smoothedElevation: 500 + i * 5,
    grade: const Grade(4.2),
  );
});

Widget _wrap({int? currentPointIndex, required AppPreferences appPrefs}) {
  return ProviderScope(
    overrides: [appPreferencesProvider.overrideWithValue(appPrefs)],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          height: 150,
          child: GpxProfileWidget(
            points: _points,
            currentPointIndex: currentPointIndex,
          ),
        ),
      ),
    ),
  );
}

Future<AppPreferences> _fakePrefs() async {
  SharedPreferences.setMockInitialValues({});
  return AppPreferences(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('exposes grade and elevation as a Semantics value at the '
      'current position', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      _wrap(currentPointIndex: 3, appPrefs: await _fakePrefs()),
    );
    await tester.pump();

    final finder = find.bySemanticsLabel('Route elevation profile');
    expect(finder, findsOneWidget);
    final semantics = tester.getSemantics(finder);
    expect(semantics.value, contains('4.2 percent grade'));
    expect(semantics.value, contains('515 meters elevation'));
    expect(tester.takeException(), isNull);

    handle.dispose();
  });

  testWidgets('falls back to a generic value with no position marker',
      (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_wrap(appPrefs: await _fakePrefs()));
    await tester.pump();

    final finder = find.bySemanticsLabel('Route elevation profile');
    expect(finder, findsOneWidget);
    final semantics = tester.getSemantics(finder);
    expect(semantics.value, 'Elevation profile');

    handle.dispose();
  });
}
