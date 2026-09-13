import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/domain/entities/user_profile.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/screens/settings_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/theme/app_theme.dart';

Widget _wrap(DriftStorage storage, AppPreferences appPrefs, ThemeData theme) {
  return ProviderScope(
    overrides: [
      storageProvider.overrideWithValue(storage),
      appPreferencesProvider.overrideWithValue(appPrefs),
    ],
    child: MaterialApp(theme: theme, home: const SettingsScreen()),
  );
}

/// Pumps Settings on a viewport tall enough to build every section. The
/// default 800x600 surface only reaches partway down the list, so assertions
/// on the lower sections would break whenever a tile is added above them.
Future<void> _pumpSettings(
  WidgetTester tester,
  DriftStorage storage,
  AppPreferences appPrefs,
  ThemeData theme,
) async {
  tester.view.physicalSize = const Size(1000, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_wrap(storage, appPrefs, theme));
  await tester.pumpAndSettle();
}

void main() {
  group('SettingsScreen widget — both themes', () {
    late AppDatabase db;
    late DriftStorage storage;
    late AppPreferences appPrefs;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      storage = DriftStorage(db);
      SharedPreferences.setMockInitialValues({});
      appPrefs = AppPreferences(await SharedPreferences.getInstance());
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('renders in dark theme', (tester) async {
      await _pumpSettings(tester, storage, appPrefs, AppTheme.dark);

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('FTP'), findsOneWidget);
      expect(find.text('Units'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in light theme', (tester) async {
      await _pumpSettings(tester, storage, appPrefs, AppTheme.light);

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('FTP'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping Theme cycles Dark -> Light -> System -> Dark',
        (tester) async {
      await _pumpSettings(tester, storage, appPrefs, AppTheme.dark);

      expect(find.text('Dark'), findsOneWidget);
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      expect(find.text('Light'), findsOneWidget);

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      expect(find.text('System'), findsOneWidget);

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('FTP retest reminder defaults to six weeks and persists a pick',
        (tester) async {
      await _pumpSettings(tester, storage, appPrefs, AppTheme.dark);

      expect(find.text('FTP retest reminder'), findsOneWidget);
      expect(find.text('Every 6 weeks'), findsOneWidget);

      await tester.tap(find.text('FTP retest reminder'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('retestInterval-28')));
      await tester.pumpAndSettle();

      expect(find.text('Every 4 weeks'), findsOneWidget);
      expect(appPrefs.ftpRetestIntervalDays, 28);
    });

    testWidgets('crash reporting toggle defaults off and flips on tap',
        (tester) async {
      await _pumpSettings(tester, storage, appPrefs, AppTheme.dark);

      // The About section is below the fold — scroll it into view.
      await tester.scrollUntilVisible(find.text('Crash reporting'), 200);
      await tester.pumpAndSettle();

      final tile = find.ancestor(
        of: find.text('Crash reporting'),
        matching: find.byType(ListTile),
      );
      expect(tile, findsOneWidget);
      expect(find.descendant(of: tile, matching: find.text('Off')),
          findsOneWidget);
      expect(appPrefs.crashReportingEnabled, isFalse);

      await tester.tap(find.text('Crash reporting'));
      await tester.pumpAndSettle();

      expect(find.descendant(of: tile, matching: find.text('On')),
          findsOneWidget);
      expect(appPrefs.crashReportingEnabled, isTrue);
    });

    testWidgets('open-source licenses tile opens the license page',
        (tester) async {
      await _pumpSettings(tester, storage, appPrefs, AppTheme.dark);

      await tester.scrollUntilVisible(find.text('Open-source licenses'), 200);
      await tester.pumpAndSettle();

      expect(find.text('Open-source licenses'), findsOneWidget);
      await tester.tap(find.text('Open-source licenses'));
      await tester.pumpAndSettle();

      expect(find.text('OpenBike'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('UserProfile — copyWith for settings edits', () {
    const profile = UserProfile(
      ftp: Watts(250),
      weight: 72.5,
      height: 180,
      restingHr: HeartRate(55),
      maxHr: HeartRate(195),
      name: 'Test User',
    );

    test('copyWith ftp', () {
      final updated = profile.copyWith(ftp: const Watts(280));
      expect(updated.ftp.value, 280);
      expect(updated.weight, 72.5);
      expect(updated.name, 'Test User');
    });

    test('copyWith weight', () {
      final updated = profile.copyWith(weight: 68.0);
      expect(updated.weight, 68.0);
      expect(updated.ftp.value, 250);
    });

    test('copyWith height', () {
      final updated = profile.copyWith(height: 175);
      expect(updated.height, 175);
    });

    test('copyWith restingHr', () {
      final updated = profile.copyWith(restingHr: const HeartRate(50));
      expect(updated.restingHr.bpm, 50);
      expect(updated.maxHr.bpm, 195);
    });

    test('copyWith maxHr', () {
      final updated = profile.copyWith(maxHr: const HeartRate(200));
      expect(updated.maxHr.bpm, 200);
      expect(updated.restingHr.bpm, 55);
    });

    test('all fields preserved on single field update', () {
      final updated = profile.copyWith(name: 'New Name');
      expect(updated.ftp.value, 250);
      expect(updated.weight, 72.5);
      expect(updated.height, 180);
      expect(updated.restingHr.bpm, 55);
      expect(updated.maxHr.bpm, 195);
      expect(updated.name, 'New Name');
    });
  });
}

