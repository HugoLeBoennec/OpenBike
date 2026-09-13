import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/application/services/ftp_test_planner.dart';
import 'package:open_bike/core/domain/entities/ftp_history_entry.dart';
import 'package:open_bike/core/domain/entities/user_profile.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/presentation/screens/ftp_test_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';

const _profile = UserProfile(
  name: 'A',
  ftp: Watts(250),
  maxHr: HeartRate(180),
  restingHr: HeartRate(60),
  weight: 70,
  height: 1.75,
);

FtpHistoryEntry _test(DateTime date, double ftp) => FtpHistoryEntry(
      effectiveDate: date,
      ftp: Watts(ftp),
      source: FtpSource.rampTest,
    );

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required List<FtpHistoryEntry> history,
}) async {
  final container = ProviderContainer(overrides: [
    userProfileProvider.overrideWith((ref) => _profile),
    ftpHistoryProvider.overrideWith((ref) async => history),
    // Default six weeks — overridden directly so the test doesn't need a
    // SharedPreferences-backed AppPreferences.
    ftpRetestIntervalProvider
        .overrideWith((ref) => FtpTestPlanner.defaultIntervalDays),
  ]);
  addTearDown(container.dispose);

  // The screen is a tall scrolling page; the default 800x600 test surface
  // leaves the protocol picker and chart unbuilt, so give it room to render
  // the whole thing rather than scrolling in every test.
  tester.view.physicalSize = const Size(1000, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: FtpTestScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('prompts a first-time rider and recommends the ramp test',
      (tester) async {
    await _pump(tester, history: const []);

    expect(find.text('Not tested yet'), findsOneWidget);
    expect(find.textContaining('sets the target for every workout'),
        findsOneWidget);

    // The ramp is both badged and pre-selected, so a beginner can start
    // without having to weigh two protocols they don't yet understand.
    expect(find.text('RECOMMENDED FOR YOU'), findsOneWidget);
    expect(find.text('Start Ramp Test'), findsOneWidget);

    // Nothing to chart yet — the empty state explains what will appear.
    expect(find.textContaining('will be charted here'), findsOneWidget);
  });

  testWidgets('shows the current FTP from the profile', (tester) async {
    await _pump(tester, history: const []);

    expect(find.text('250'), findsOneWidget);
    expect(find.text('CURRENT FTP'), findsOneWidget);
  });

  testWidgets('reports a due retest with how long it has been',
      (tester) async {
    final lastTest = DateTime.now().subtract(const Duration(days: 63));
    await _pump(tester, history: [_test(lastTest, 240)]);

    expect(find.text('Time to retest'), findsOneWidget);
    expect(find.textContaining('9 weeks ago'), findsOneWidget);
  });

  testWidgets('reports an up-to-date rider without nagging', (tester) async {
    final lastTest = DateTime.now().subtract(const Duration(days: 5));
    await _pump(tester, history: [_test(lastTest, 240)]);

    expect(find.text('Up to date'), findsOneWidget);
    expect(find.text('Time to retest'), findsNothing);
  });

  testWidgets('recommends the 20-minute test after two ramp tests',
      (tester) async {
    final now = DateTime.now();
    await _pump(tester, history: [
      _test(now.subtract(const Duration(days: 120)), 230),
      _test(now.subtract(const Duration(days: 60)), 245),
    ]);

    expect(find.text('Start 20-Minute Test'), findsOneWidget);
  });

  testWidgets('lets the rider override the recommended protocol',
      (tester) async {
    await _pump(tester, history: const []);
    expect(find.text('Start Ramp Test'), findsOneWidget);

    await tester.tap(find.byKey(const Key('protocol-twentyMinute')));
    await tester.pumpAndSettle();

    expect(find.text('Start 20-Minute Test'), findsOneWidget);
    // The recommendation badge stays on the ramp — overriding a suggestion
    // must not rewrite what was suggested.
    expect(find.text('RECOMMENDED FOR YOU'), findsOneWidget);
  });

  testWidgets('summarises progress between the last two tests',
      (tester) async {
    final now = DateTime.now();
    await _pump(tester, history: [
      _test(now.subtract(const Duration(days: 120)), 200),
      _test(now.subtract(const Duration(days: 60)), 220),
    ]);

    expect(find.textContaining('+20 W since your previous test'),
        findsOneWidget);
    expect(find.textContaining('+10.0%'), findsOneWidget);
  });

  testWidgets('charts only measured tests, not hand-typed FTP values',
      (tester) async {
    final now = DateTime.now();
    await _pump(tester, history: [
      _test(now.subtract(const Duration(days: 120)), 200),
      FtpHistoryEntry(
        effectiveDate: now.subtract(const Duration(days: 90)),
        ftp: const Watts(215),
        source: FtpSource.manual,
      ),
      _test(now.subtract(const Duration(days: 60)), 220),
    ]);

    // Two ramp rows in the history list, and no row for the manual edit.
    expect(find.text('Ramp test'), findsNWidgets(2));
    expect(find.text('Entered manually'), findsNothing);

    // Progress is measured test-to-test: 200 → 220, ignoring the 215 edit.
    expect(find.textContaining('+20 W since your previous test'),
        findsOneWidget);
  });
}
