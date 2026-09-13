import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/screens/home_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/theme/app_theme.dart';

Widget _wrap(DriftStorage storage, AppPreferences appPrefs, ThemeData theme) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(
          path: '/settings',
          builder: (_, __) => const Scaffold(body: Text('settings screen'))),
      GoRoute(
          path: '/ride',
          builder: (_, __) => const Scaffold(body: Text('ride screen'))),
    ],
  );
  return ProviderScope(
    overrides: [
      storageProvider.overrideWithValue(storage),
      appPreferencesProvider.overrideWithValue(appPrefs),
    ],
    child: MaterialApp.router(theme: theme, routerConfig: router),
  );
}

/// Pumps Home on a viewport tall enough to build the whole dashboard. The
/// default 800x600 surface cuts off the recent-activities section below the
/// action cards, so assertions on it would depend on how many cards the
/// dashboard happens to have.
Future<void> _pumpHome(
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

  testWidgets('renders in dark theme with no rides yet', (tester) async {
    await _pumpHome(tester, storage, appPrefs, AppTheme.dark);

    expect(find.text('OpenBike'), findsOneWidget);
    expect(find.text('Free Ride'), findsOneWidget);
    expect(find.text('No rides yet.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in light theme with no rides yet', (tester) async {
    await _pumpHome(tester, storage, appPrefs, AppTheme.light);

    expect(find.text('OpenBike'), findsOneWidget);
    expect(find.text('Free Ride'), findsOneWidget);
    expect(find.text('No rides yet.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('surfaces the FTP test as a first step for an untested rider',
      (tester) async {
    await _pumpHome(tester, storage, appPrefs, AppTheme.dark);

    expect(find.text('FTP Test'), findsOneWidget);
    // No FTP history at all — the card nudges rather than reporting a date.
    expect(find.text('START HERE'), findsOneWidget);
    expect(
      find.text('Set your training zones from a real measurement'),
      findsOneWidget,
    );
  });

  testWidgets('tapping settings icon navigates to settings', (tester) async {
    await tester.pumpWidget(_wrap(storage, appPrefs, AppTheme.dark));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('settings screen'), findsOneWidget);
  });
}
