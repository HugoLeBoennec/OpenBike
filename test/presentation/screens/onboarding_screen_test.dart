import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/application/services/device_pairing_service.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/ble/ble_permission_handler.dart';
import 'package:open_bike/infrastructure/ble/ble_transport.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/screens/home_screen.dart';
import 'package:open_bike/presentation/screens/onboarding_screen.dart';
import 'package:open_bike/presentation/state/providers.dart';

class _MockPermissionHandler extends Mock implements BlePermissionHandler {}

class _MockPairingService extends Mock implements DevicePairingService {}

const _trainer = TrainerDevice(
  id: 'AA:BB:CC:DD:EE:FF',
  name: 'KICKR CORE',
  protocol: DeviceProtocol.bleFtms,
);

Widget _wrap(
  DriftStorage storage,
  AppPreferences appPrefs, {
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(
          path: '/settings',
          builder: (_, __) => const Scaffold(body: Text('settings screen'))),
    ],
  );
  return ProviderScope(
    overrides: [
      storageProvider.overrideWithValue(storage),
      appPreferencesProvider.overrideWithValue(appPrefs),
      ...overrides,
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

/// Welcome → Profile → Units & Body → Sensor scan.
Future<void> _goToScanPage(WidgetTester tester) async {
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  expect(find.text('Connect Your Trainer'), findsOneWidget);
}

void main() {
  setUpAll(() {
    registerFallbackValue(SensorRole.trainer);
    registerFallbackValue(_trainer);
  });

  late AppDatabase db;
  late DriftStorage storage;
  late AppPreferences appPrefs;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    storage = DriftStorage(db);
    SharedPreferences.setMockInitialValues({});
    appPrefs = AppPreferences(await SharedPreferences.getInstance());

    // A ride already on record, so Home's recent-activity tile has a
    // distance to display once onboarding finishes.
    await storage.saveRide(
      Ride(
        id: 'ride-1',
        startTime: DateTime.utc(2026, 1, 1, 8),
        endTime: DateTime.utc(2026, 1, 1, 9),
        status: RideStatus.finished,
        readings: [
          SensorReading(
            timestamp: DateTime.utc(2026, 1, 1, 8),
            power: const Watts(200),
            distance: const Distance(16093), // 10 miles
          ),
        ],
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets(
      'completing onboarding with imperial units shows mi on Home',
      (tester) async {
    // This test lands on Home and asserts on the recent-ride distance, which
    // sits below the action cards — the default 800x600 surface never builds
    // it. Give the viewport room rather than tying the assertion to how many
    // cards the dashboard currently has.
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(storage, appPrefs));
    await tester.pumpAndSettle();

    // Page 1: Welcome.
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Page 2: Profile (defaults are fine).
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Page 3: Units & Body — select imperial.
    expect(find.text('Imperial (mi)'), findsOneWidget);
    await tester.tap(find.text('Imperial (mi)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Page 4: Sensor scan — skip (no real BLE hardware in tests).
    await tester.tap(find.byKey(const Key('scanSkipButton')));
    await tester.pumpAndSettle();

    // Page 5: Connection test (no device connected) — continue.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Page 6: Ready — finish.
    await tester.tap(find.byKey(const Key('onboardingFinishButton')));
    await tester.pumpAndSettle();

    // One-time crash reporting consent prompt — decline it.
    expect(find.text('Help improve OpenBike'), findsOneWidget);
    await tester.tap(find.text('No thanks'));
    await tester.pumpAndSettle();

    // Landed on Home, with the imperial unit system reflected in the
    // recent-ride distance.
    expect(find.text('OpenBike'), findsOneWidget);
    expect(find.textContaining('mi'), findsWidgets);
    expect(find.textContaining(' km'), findsNothing);
    expect(appPrefs.hasAskedCrashReportingConsent, isTrue);
    expect(appPrefs.crashReportingEnabled, isFalse);
  });

  testWidgets("'I'll set up later' from the welcome page lands on Home",
      (tester) async {
    await tester.pumpWidget(_wrap(storage, appPrefs));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('welcomeSkipButton')));
    await tester.pumpAndSettle();

    // One-time crash reporting consent prompt — accept it.
    expect(find.text('Help improve OpenBike'), findsOneWidget);
    await tester.tap(find.text('Send crash reports'));
    await tester.pumpAndSettle();

    expect(find.text('OpenBike'), findsOneWidget);
    expect(appPrefs.hasCompletedOnboarding, isTrue);
    expect(appPrefs.hasAskedCrashReportingConsent, isTrue);
    expect(appPrefs.crashReportingEnabled, isTrue);
  });

  testWidgets('consent prompt is not shown again on a later onboarding run',
      (tester) async {
    await appPrefs.setHasAskedCrashReportingConsent(true);

    await tester.pumpWidget(_wrap(storage, appPrefs));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('welcomeSkipButton')));
    await tester.pumpAndSettle();

    expect(find.text('Help improve OpenBike'), findsNothing);
    expect(find.text('OpenBike'), findsOneWidget);
  });

  testWidgets(
      'scan page explains a Bluetooth denial and links to Settings instead '
      'of silently finding nothing', (tester) async {
    final permissions = _MockPermissionHandler();
    when(() => permissions.requestAccess())
        .thenAnswer((_) async => BleAvailability.permissionDenied);
    when(() => permissions.openSettings()).thenAnswer((_) async => true);

    await tester.pumpWidget(_wrap(storage, appPrefs, overrides: [
      bleTransportProvider
          .overrideWithValue(BleTransport(permissionHandler: permissions)),
    ]));
    await tester.pumpAndSettle();
    await _goToScanPage(tester);

    await tester.tap(find.byKey(const Key('onboardingScanButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboardingScanError')), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboardingOpenSettingsButton')));
    verify(() => permissions.openSettings()).called(1);
  });

  testWidgets('a failed trainer connection is reported on the scan page',
      (tester) async {
    final pairing = _MockPairingService();
    when(() => pairing.assign(any(), any()))
        .thenAnswer((_) async => throw StateError('Request Control timed out'));
    when(() => pairing.dispose()).thenAnswer((_) async {});

    await tester.pumpWidget(_wrap(storage, appPrefs, overrides: [
      bleScanResultsProvider.overrideWith((ref) => Stream.value(const [
            BleScannedDevice(device: _trainer, rssi: -60, serviceUuids: []),
          ])),
      devicePairingServiceProvider.overrideWithValue(pairing),
    ]));
    await tester.pumpAndSettle();
    await _goToScanPage(tester);

    await tester.tap(find.text('KICKR CORE'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboardingConnectError')), findsOneWidget);
    expect(find.text('Connect Your Trainer'), findsOneWidget);
    expect(appPrefs.pairedDevices.forRole(SensorRole.trainer), isNull);
  });
}
