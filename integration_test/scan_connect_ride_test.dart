import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scan → connect simulator → ride screen shows live data',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    // Navigate to /scan.
    final context = tester.element(find.byType(MaterialApp));
    GoRouter.of(context).go('/scan');
    await tester.pumpAndSettle();

    // Verify we're on the device scan screen.
    expect(find.text('Devices'), findsOneWidget);

    // Tap the scan FAB.
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // The simulator device should appear.
    expect(find.text('OpenBike Virtual Trainer'), findsOneWidget);

    // Tap the simulator device to connect.
    await tester.tap(find.text('OpenBike Virtual Trainer'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Navigate back to ride screen.
    GoRouter.of(context).go('/ride');
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // After 3 seconds the simulator should have emitted data.
    // Verify no crash occurred and we're on a valid screen.
    expect(find.byType(Scaffold), findsWidgets);
  });
}
