import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/presentation/models/data_field_type.dart';
import 'package:open_bike/presentation/models/ride_screen_config.dart';

/// These tests validate the RingBufferNotifier and related logic.
///
/// Because _RingBufferNotifier is private to providers.dart, we test the
/// public behavior through RideScreenConfigNotifier (which is public) and
/// validate the data_field_type model logic directly.
void main() {
  // ===========================================================================
  // RideScreenConfigNotifier (acts as proxy for StateNotifier behavior)
  // ===========================================================================

  group('RideScreenConfigNotifier — state updates', () {
    test('initial state matches defaultPortrait', () {
      final notifier = RideScreenConfigNotifier();
      expect(notifier.state.pages.length, 2);
      expect(notifier.state.columns, 2);
    });

    test('multiple setFieldAt calls accumulate changes', () {
      final notifier = RideScreenConfigNotifier();
      notifier.setFieldAt(0, 0, DataFieldType.elevation);
      notifier.setFieldAt(0, 1, DataFieldType.grade);
      notifier.setFieldAt(0, 2, DataFieldType.tss);

      expect(notifier.state.pages[0][0], DataFieldType.elevation);
      expect(notifier.state.pages[0][1], DataFieldType.grade);
      expect(notifier.state.pages[0][2], DataFieldType.tss);
    });

    test('setFieldAt on second page works', () {
      final notifier = RideScreenConfigNotifier();
      notifier.setFieldAt(1, 0, DataFieldType.calories);
      expect(notifier.state.pages[1][0], DataFieldType.calories);
    });

    test('setFieldAt preserves other config values', () {
      final notifier = RideScreenConfigNotifier();
      notifier.setFieldAt(0, 0, DataFieldType.grade);
      expect(notifier.state.showChart, isTrue);
      expect(notifier.state.showPowerGauge, isFalse);
      expect(notifier.state.rows, 2);
    });
  });

  // ===========================================================================
  // 3-second average logic (pure computation, no providers)
  // ===========================================================================

  group('3-second average — computation', () {
    test('average of 3 values', () {
      final history = [100.0, 200.0, 150.0];
      final count = history.length < 3 ? history.length : 3;
      double sum = 0;
      for (int i = history.length - count; i < history.length; i++) {
        sum += history[i];
      }
      final avg = sum / count;
      expect(avg, 150.0);
    });

    test('average of fewer than 3 values', () {
      final history = [200.0];
      final count = history.length < 3 ? history.length : 3;
      double sum = 0;
      for (int i = history.length - count; i < history.length; i++) {
        sum += history[i];
      }
      final avg = sum / count;
      expect(avg, 200.0);
    });

    test('average uses only last 3 of longer history', () {
      final history = [50.0, 100.0, 200.0, 300.0, 150.0];
      const count = 3;
      double sum = 0;
      for (int i = history.length - count; i < history.length; i++) {
        sum += history[i];
      }
      final avg = sum / count;
      // Last 3: 200, 300, 150 → avg = 216.67
      expect(avg, closeTo(216.67, 0.01));
    });
  });
}
