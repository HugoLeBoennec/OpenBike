import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/application/services/bundled_workouts.dart';
import 'package:open_bike/presentation/screens/workout_detail_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/theme/app_theme.dart';

void main() {
  // Warm-up ramp 40→85 %, 5 × (3 min @ 120 % + 3 min @ 50 %), cool-down
  // ramp 65→40 % — every kind of step whose power isn't powerTargetPercent.
  final vo2 =
      BundledWorkouts.all.singleWhere((w) => w.id == 'bundled-vo2max-5x3');

  Future<void> pump(WidgetTester tester) async {
    // Tall enough that the lazy step list builds the cool-down row too.
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ProviderScope(
      overrides: [workoutListProvider.overrideWith((ref) => [vo2])],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const WorkoutDetailScreen(workoutIndex: 0),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('charts every ramp and interval repeat over time',
      (tester) async {
    await pump(tester);

    final chart = tester.widget<LineChart>(find.byType(LineChart));
    // Warm-up + 5 on/off pairs + cool-down.
    expect(chart.data.lineBarsData, hasLength(12));
    expect(chart.data.maxX, vo2.totalDuration.inSeconds / 60);

    final warmup = chart.data.lineBarsData.first.spots;
    expect([warmup.first.y, warmup.last.y], [40, 85]);
  });

  testWidgets('lists each step with the targets it actually rides',
      (tester) async {
    await pump(tester);

    expect(find.text('10:00 • 40% → 85% FTP'), findsOneWidget);
    expect(find.text('30:00 • 5 × 3:00 @ 120% / 3:00 @ 50% FTP'),
        findsOneWidget);
    expect(find.text('5:00 • 65% → 40% FTP'), findsOneWidget);
  });
}
