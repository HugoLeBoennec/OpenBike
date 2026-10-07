import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/domain/entities/ride.dart';
import 'package:open_bike/core/domain/entities/sensor_reading.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/presentation/format/unit_formatter.dart';
import 'package:open_bike/presentation/models/data_field_type.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/data_field_cell.dart';

Widget _wrap({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      home: Scaffold(body: DataFieldCell(fieldType: DataFieldType.power)),
    ),
  );
}

void main() {
  testWidgets('exposes label, value, and unit as a single Semantics label',
      (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_wrap(overrides: [
      livePowerProvider.overrideWith((ref) => const Watts(215)),
    ]));
    await tester.pump();

    final finder = find.bySemanticsLabel('POWER: 215 w');
    expect(finder, findsOneWidget);
    expect(tester.takeException(), isNull);

    handle.dispose();
  });

  testWidgets('renders without overflow at 1.3x text scale', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: _wrap(),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('live ride fields update as the ride progresses', (tester) async {
    final rides = StreamController<Ride?>();
    addTearDown(rides.close);

    Ride rideWith(double meters, double watts) => Ride(
          id: 'r1',
          startTime: DateTime.now(),
          status: RideStatus.active,
          readings: [
            SensorReading(
              timestamp: DateTime.now(),
              power: Watts(watts),
              distance: Distance(meters),
            ),
          ],
        );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentRideProvider.overrideWith((ref) => rides.stream),
        unitFormatterProvider
            .overrideWithValue(UnitFormatter(UnitSystem.metric)),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: Column(children: [
            DataFieldCell(fieldType: DataFieldType.distance),
            DataFieldCell(fieldType: DataFieldType.avgPower),
          ]),
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('0.00'), findsOneWidget);
    expect(find.text('--'), findsOneWidget);

    rides.add(rideWith(1500, 200));
    await tester.pump();
    await tester.pump();
    expect(find.text('1.50'), findsOneWidget);
    expect(find.text('200'), findsOneWidget);

    rides.add(rideWith(2500, 220));
    await tester.pump();
    await tester.pump();
    expect(find.text('2.50'), findsOneWidget);
    expect(find.text('220'), findsOneWidget);
  });
}
