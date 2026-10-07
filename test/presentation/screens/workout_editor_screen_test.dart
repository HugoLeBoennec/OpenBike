import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:open_bike/core/domain/entities/workout_step.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/presentation/screens/workout_editor_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';

void main() {
  testWidgets(
      'building a 2x(5min@105%/1min@50%) interval workout via the UI '
      'saves correct steps and a TSS estimate matching the hand-computed value',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final storage = DriftStorage(db);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const Scaffold(body: SizedBox())),
        GoRoute(
          path: '/workouts/new',
          builder: (_, __) => const WorkoutEditorScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [storageProvider.overrideWithValue(storage)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    router.push('/workouts/new');
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('workoutNameField')), '2x5 Intervals');

    // --- Add the interval step ---
    await tester.tap(find.byKey(const Key('addStepButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('stepTypeDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Interval').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('stepDurationField')), '300');
    await tester.enterText(find.byKey(const Key('stepPowerField')), '105');
    await tester.enterText(find.byKey(const Key('stepRepeatField')), '2');
    await tester.enterText(find.byKey(const Key('stepOffDurationField')), '60');
    await tester.enterText(find.byKey(const Key('stepOffPowerField')), '50');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('stepSaveButton')));
    await tester.pumpAndSettle();

    // Totals reflect the single interval step: 2 x (5min + 1min) = 12 min.
    expect(find.text('12 min'), findsOneWidget);

    // One drag handle per step (no extra default handle on desktop).
    expect(find.byIcon(Icons.drag_handle), findsOneWidget);

    // --- Hand-computed TSS (duration-weighted 4th-power average of the
    // on/off segments across both repeats, independent of the estimator
    // implementation under test) ---
    const onDur = 300.0, offDur = 60.0, onPow = 105.0, offPow = 50.0;
    final totalDur = 2 * (onDur + offDur);
    final weightedPow4 = 2 * (onDur * pow(onPow, 4) + offDur * pow(offPow, 4));
    final np = pow(weightedPow4 / totalDur, 0.25).toDouble();
    final ifactor = np / 100.0;
    final expectedTss = (totalDur * np * ifactor) / (100.0 * 3600) * 100;

    final tssFinder = find.byKey(const Key('workoutTssValue'));
    final tssText = tester.widgetList<Text>(
      find.descendant(of: tssFinder, matching: find.byType(Text)),
    );
    final displayedTss = double.parse(tssText.first.data!);
    expect(displayedTss, closeTo(expectedTss, 1));

    // --- Save and verify persisted workout ---
    await tester.tap(find.byKey(const Key('workoutSaveButton')));
    await tester.pumpAndSettle();

    final saved = (await storage.getWorkouts()).single;
    expect(saved.name, '2x5 Intervals');
    expect(saved.steps, hasLength(1));

    final step = saved.steps.single;
    expect(step.type, StepType.interval);
    expect(step.durationSeconds, 300);
    expect(step.offDurationSeconds, 60);
    expect(step.repeat, 2);
    expect(step.powerTargetPercent, 105);
    expect(step.powerLowPercent, 50);
    expect(step.totalDurationSeconds, 720); // 2 x (300 + 60)

    // Back on the underlying route after save.
    expect(find.byType(WorkoutEditorScreen), findsNothing);
  });
}
