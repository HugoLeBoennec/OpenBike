import 'dart:async';

import 'package:flutter/material.dart' hide Route;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_bike/core/application/services/physics_engine.dart';
import 'package:open_bike/core/application/services/route_simulator.dart';
import 'package:open_bike/core/domain/entities/route.dart';
import 'package:open_bike/core/domain/entities/route_point.dart';
import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/route_profile_pane.dart';

class MockTrainerPort extends Mock implements TrainerPort {}

/// Exposes a fixed [currentRoute] without ever calling [RouteSimulator.start]
/// — avoids spinning up its real 1 Hz ticker just to satisfy
/// [RouteProfilePane]'s "is a route loaded" check in tests.
class _FakeRouteSimulator extends RouteSimulator {
  _FakeRouteSimulator(this._fakeRoute)
      : super(
          trainerPort: MockTrainerPort(),
          eventBus: EventBus(),
          physics: CyclingPhysicsEngine(),
        );

  final Route? _fakeRoute;

  @override
  Route? get currentRoute => _fakeRoute;
}

final _route = Route(
  id: 'r1',
  name: 'Test Route',
  points: List.generate(50, (i) {
    final dist = i * 100.0; // 0..4900 m
    return RoutePoint(
      position: const GeoPoint(lat: 45.0, lon: 6.0),
      distanceFromStart: dist,
      smoothedElevation: 500 + i * 2,
      grade: Grade(dist < 1000 ? 5.0 : -2.0),
    );
  }),
);

SimulationProgress _progressAt(int pointIndex) {
  final point = _route.points[pointIndex];
  return SimulationProgress(
    currentPoint: point,
    pointIndex: pointIndex,
    speed: const Speed(25),
    grade: point.grade,
    distanceCovered: Distance(point.distanceFromStart),
    distanceRemaining:
        Distance(_route.totalDistance.meters - point.distanceFromStart),
    elevationGain: 0,
    elapsed: Duration(seconds: pointIndex * 5),
  );
}

void main() {
  testWidgets('shows placeholder when no route is loaded', (tester) async {
    final sim = _FakeRouteSimulator(null);
    addTearDown(sim.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [routeSimulatorProvider.overrideWithValue(sim)],
        child: const MaterialApp(home: Scaffold(body: RouteProfilePane())),
      ),
    );
    await tester.pump();

    expect(find.text('No route loaded'), findsOneWidget);
  });

  testWidgets('position marker stats advance with SimulationProgress',
      (tester) async {
    final sim = _FakeRouteSimulator(_route);
    addTearDown(sim.dispose);

    final controller = StreamController<SimulationProgress>();
    addTearDown(controller.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routeSimulatorProvider.overrideWithValue(sim),
          simulationProgressProvider.overrideWith((ref) => controller.stream),
        ],
        child: const MaterialApp(home: Scaffold(body: RouteProfilePane())),
      ),
    );
    await tester.pump();

    controller.add(_progressAt(5));
    await tester.pump();
    expect(find.textContaining('5.0% grade'), findsOneWidget);

    controller.add(_progressAt(20));
    await tester.pump();
    expect(find.textContaining('-2.0% grade'), findsOneWidget);
    expect(find.textContaining('2.9 km left'), findsOneWidget);
  });
}
