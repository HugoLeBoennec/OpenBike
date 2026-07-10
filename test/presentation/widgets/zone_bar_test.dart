import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/domain/entities/user_profile.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/zone_bar.dart';

Widget _wrap({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(home: Scaffold(body: ZoneBar())),
  );
}

void main() {
  testWidgets('exposes the active zone as a Semantics value', (tester) async {
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
      // 200 W at FTP 250 -> 80% -> Tempo zone (76-90%).
      livePowerProvider.overrideWith((ref) => const Watts(200)),
    ]));
    await tester.pump();

    final finder = find.bySemanticsLabel('Power zone');
    expect(finder, findsOneWidget);
    final semantics = tester.getSemantics(finder);
    expect(semantics.value, contains('Tempo'));
    expect(tester.takeException(), isNull);

    handle.dispose();
  });

  testWidgets('defaults to Active Recovery at zero power', (tester) async {
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
    ]));
    await tester.pump();

    final finder = find.bySemanticsLabel('Power zone');
    expect(finder, findsOneWidget);
    final semantics = tester.getSemantics(finder);
    expect(semantics.value, contains('Active Recovery'));

    handle.dispose();
  });
}
