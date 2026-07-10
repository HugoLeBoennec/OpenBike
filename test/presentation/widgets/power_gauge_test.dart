import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/domain/entities/user_profile.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/power_gauge.dart';

Widget _wrap({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      home: Scaffold(body: SizedBox(width: 200, height: 200, child: PowerGauge())),
    ),
  );
}

void main() {
  testWidgets('exposes current power as a Semantics value', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_wrap(overrides: [
      userProfileProvider.overrideWith((ref) => const UserProfile(
            ftp: Watts(250),
            weight: 75,
            height: 178,
            restingHr: HeartRate(60),
            maxHr: HeartRate(190),
            name: '',
          )),
      livePowerProvider.overrideWith((ref) => const Watts(180)),
    ]));
    await tester.pump();

    final finder = find.bySemanticsLabel('Power gauge');
    expect(finder, findsOneWidget);
    final semantics = tester.getSemantics(finder);
    expect(semantics.value, '180 watts');
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
}
