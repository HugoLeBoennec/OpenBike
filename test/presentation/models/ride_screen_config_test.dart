import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/presentation/models/data_field_type.dart';
import 'package:open_bike/presentation/models/ride_screen_config.dart';

void main() {
  // ===========================================================================
  // Default presets
  // ===========================================================================

  group('RideScreenConfig — default presets', () {
    test('defaultPortrait has 2 pages, 2 columns', () {
      const config = RideScreenConfig.defaultPortrait;
      expect(config.pages.length, 2);
      expect(config.columns, 2);
      expect(config.rows, 2);
      expect(config.showChart, isTrue);
      expect(config.showPowerGauge, isFalse);
    });

    test('defaultPortrait pages have 4 fields each', () {
      const config = RideScreenConfig.defaultPortrait;
      expect(config.pages[0].length, 4);
      expect(config.pages[1].length, 4);
    });

    test('defaultLandscape has 1 page, 3 columns, gauge visible', () {
      const config = RideScreenConfig.defaultLandscape;
      expect(config.pages.length, 1);
      expect(config.columns, 3);
      expect(config.rows, 2);
      expect(config.showPowerGauge, isTrue);
    });

    test('defaultDesktop has 1 page, 3 columns, 4 rows, gauge visible', () {
      const config = RideScreenConfig.defaultDesktop;
      expect(config.pages.length, 1);
      expect(config.columns, 3);
      expect(config.rows, 4);
      expect(config.showPowerGauge, isTrue);
      expect(config.pages[0].length, 12);
    });
  });

  // ===========================================================================
  // RideScreenConfigNotifier
  // ===========================================================================

  group('RideScreenConfigNotifier', () {
    test('starts with defaultPortrait', () {
      final notifier = RideScreenConfigNotifier();
      expect(notifier.state.columns, 2);
      expect(notifier.state.pages.length, 2);
    });

    test('setFieldAt replaces a specific field', () {
      final notifier = RideScreenConfigNotifier();
      notifier.setFieldAt(0, 0, DataFieldType.distance);
      expect(notifier.state.pages[0][0], DataFieldType.distance);
    });

    test('setFieldAt ignores out-of-bounds page', () {
      final notifier = RideScreenConfigNotifier();
      final before = notifier.state;
      notifier.setFieldAt(99, 0, DataFieldType.distance);
      // Pages content should remain the same
      expect(notifier.state.pages[0][0], before.pages[0][0]);
    });

    test('setFieldAt ignores out-of-bounds field', () {
      final notifier = RideScreenConfigNotifier();
      final before = notifier.state;
      notifier.setFieldAt(0, 99, DataFieldType.distance);
      expect(notifier.state.pages[0], before.pages[0]);
    });

    test('adaptToLayout switches to landscape config', () {
      final notifier = RideScreenConfigNotifier();
      notifier.adaptToLayout(isLandscape: true, isDesktop: false);
      expect(notifier.state.columns, 3);
      expect(notifier.state.showPowerGauge, isTrue);
    });

    test('adaptToLayout switches to desktop config', () {
      final notifier = RideScreenConfigNotifier();
      notifier.adaptToLayout(isLandscape: true, isDesktop: true);
      expect(notifier.state.rows, 4);
      expect(notifier.state.pages[0].length, 12);
    });

    test('adaptToLayout twice with the same arguments notifies once', () {
      final notifier = RideScreenConfigNotifier();
      var notifications = 0;
      notifier.addListener((_) => notifications++, fireImmediately: false);

      notifier.adaptToLayout(isLandscape: true, isDesktop: false);
      notifier.adaptToLayout(isLandscape: true, isDesktop: false);

      expect(notifications, 1);
    });

    test('adaptToLayout is ignored after user customization', () {
      final notifier = RideScreenConfigNotifier();
      notifier.setFieldAt(0, 0, DataFieldType.elevation);
      notifier.adaptToLayout(isLandscape: true, isDesktop: false);
      // Should still have 2 columns since user customized
      expect(notifier.state.columns, 2);
      expect(notifier.state.pages[0][0], DataFieldType.elevation);
    });
  });
}
