import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/erg_easing_banner.dart';

void main() {
  Future<void> pumpBanner(WidgetTester tester, {required bool easing}) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        ergEasingProvider.overrideWith((ref) => Stream.value(easing)),
      ],
      child: const MaterialApp(home: Scaffold(body: ErgEasingBanner())),
    ));
    await tester.pump();
  }

  testWidgets('explains the eased target while cadence is low',
      (tester) async {
    await pumpBanner(tester, easing: true);
    expect(find.textContaining('Cadence too low'), findsOneWidget);
  });

  testWidgets('stays hidden otherwise', (tester) async {
    await pumpBanner(tester, easing: false);
    expect(find.textContaining('Cadence too low'), findsNothing);
  });
}
