import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/application/services/background_recording_service.dart';
import 'package:open_bike/core/application/services/trainer_mode_controller.dart';
import 'package:open_bike/core/domain/ports/storage_port.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/screens/ride_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/data_field_cell.dart';
import 'package:open_bike/presentation/widgets/power_gauge.dart';

class _MockStorage extends Mock implements StoragePort {}

class _MockBackgroundService extends Mock implements BackgroundRecordingService {}

Future<void> _pumpRideScreen(WidgetTester tester, Size size) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = AppPreferences(await SharedPreferences.getInstance());

  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      appPreferencesProvider.overrideWithValue(prefs),
      storageProvider.overrideWithValue(_MockStorage()),
      roleConnectionProvider.overrideWithValue(const {}),
      // The real provider disposes its controller twice at teardown (its own
      // onDispose plus StateNotifierProvider's), which asserts in tests.
      trainerModeControllerProvider
          .overrideWith((ref) => TrainerModeController(eventBus: EventBus())),
      // Per-second tickers would leave periodic timers pending.
      rideElapsedProvider.overrideWith((ref) => Stream.value(Duration.zero)),
      currentRideProvider.overrideWith((ref) => Stream.value(null)),
      // Side-effect providers that talk to hardware or plugins.
      liveSensorBridgeProvider.overrideWith((ref) {}),
      powerHistoryUpdaterProvider.overrideWith((ref) {}),
      hrHistoryUpdaterProvider.overrideWith((ref) {}),
      scheduledWorkoutLinkerProvider.overrideWith((ref) {}),
      autoUploadProvider.overrideWith((ref) {}),
      backgroundRecordingServiceProvider
          .overrideWithValue(_MockBackgroundService()),
    ],
    child: const MaterialApp(home: RideScreen()),
  ));
  // Let the post-build config adaptation (microtask) rebuild the layout.
  await tester.pump();
  await tester.pump();
}

void main() {
  const tablets = {
    '7" tablet portrait': Size(617, 1097),
    '10" tablet portrait': Size(823, 1463),
    'iPad 13" portrait': Size(1032, 1376),
  };

  tablets.forEach((name, size) {
    testWidgets('$name: six data fields and the gauge fill the screen',
        (tester) async {
      await _pumpRideScreen(tester, size);

      expect(tester.takeException(), isNull);
      expect(find.byType(DataFieldCell), findsNWidgets(6));
      expect(find.byType(PowerGauge), findsOneWidget);

      // The grid starts near the top and the gauge sits in the lower half:
      // the screen isn't mostly blank.
      final lastCell = tester.getBottomRight(find.byType(DataFieldCell).last);
      expect(lastCell.dy, greaterThan(size.height * 0.35));
      expect(tester.getCenter(find.byType(PowerGauge)).dy,
          greaterThan(size.height * 0.6));
    });
  });

  testWidgets('landscape tablet keeps the side-by-side layout', (tester) async {
    await _pumpRideScreen(tester, const Size(1366, 1024));

    expect(tester.takeException(), isNull);
    expect(find.byType(DataFieldCell), findsNWidgets(12));
    // Gauge sits in the right-hand pane, not under the grid.
    expect(tester.getCenter(find.byType(PowerGauge)).dx, greaterThan(1366 * 0.6));
  });

  testWidgets('desktop-size portrait window uses the stacked layout',
      (tester) async {
    await _pumpRideScreen(tester, const Size(1300, 1600));

    expect(tester.takeException(), isNull);
    expect(find.byType(DataFieldCell), findsNWidgets(12));
    expect(tester.getCenter(find.byType(PowerGauge)).dy, greaterThan(1600 * 0.6));
  });
}
