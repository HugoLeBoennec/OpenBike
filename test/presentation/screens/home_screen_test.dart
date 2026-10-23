import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/screens/home_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/theme/app_theme.dart';

class MockTrainerPort extends Mock implements TrainerPort {}

Widget _wrap(
  DriftStorage storage,
  AppPreferences appPrefs,
  ThemeData theme, {
  List<Override> extraOverrides = const [],
}) {
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
      GoRoute(
          path: '/scan',
          builder: (_, __) => const Scaffold(body: Text('scan screen'))),
      GoRoute(
          path: '/routes',
          builder: (_, __) => const Scaffold(body: Text('routes screen'))),
    ],
  );
  return ProviderScope(
    overrides: [
      storageProvider.overrideWithValue(storage),
      appPreferencesProvider.overrideWithValue(appPrefs),
      ...extraOverrides,
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
  ThemeData theme, {
  List<Override> extraOverrides = const [],
}) async {
  tester.view.physicalSize = const Size(1000, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
      _wrap(storage, appPrefs, theme, extraOverrides: extraOverrides));
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

  testWidgets('Simulate Route opens the route library, trainer or not',
      (tester) async {
    await _pumpHome(tester, storage, appPrefs, AppTheme.dark);

    await tester.tap(find.text('Simulate Route'));
    await tester.pumpAndSettle();

    expect(find.text('routes screen'), findsOneWidget);
    expect(find.text('Connect a trainer'), findsNothing);
  });

  testWidgets('free ride without a trainer asks to connect one',
      (tester) async {
    await _pumpHome(tester, storage, appPrefs, AppTheme.dark);

    await tester.tap(find.text('Free Ride'));
    await tester.pumpAndSettle();

    expect(find.text('Connect a trainer'), findsOneWidget);
    expect(find.text('ride screen'), findsNothing);

    await tester.tap(find.text('Connect Device'));
    await tester.pumpAndSettle();

    expect(find.text('scan screen'), findsOneWidget);
  });

  testWidgets('free ride with a trainer goes straight to the ride',
      (tester) async {
    await _pumpHome(
      tester,
      storage,
      appPrefs,
      AppTheme.dark,
      extraOverrides: [
        activeTrainerPortProvider.overrideWith((ref) => MockTrainerPort()),
      ],
    );

    await tester.tap(find.text('Free Ride'));
    await tester.pumpAndSettle();

    expect(find.text('ride screen'), findsOneWidget);
  });
}
