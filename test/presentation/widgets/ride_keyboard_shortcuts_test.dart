import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_bike/core/application/services/recording_engine.dart';
import 'package:open_bike/core/domain/entities/ride.dart';
import 'package:open_bike/core/domain/ports/storage_port.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/ride_keyboard_shortcuts.dart';

class MockStoragePort extends Mock implements StoragePort {}

class FakeRide extends Fake implements Ride {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // window_manager talks to a native plugin over this channel — stub it out
  // so the `F` shortcut's fullscreen toggle doesn't throw in the test host.
  const windowManagerChannel = MethodChannel('window_manager');
  TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(windowManagerChannel, (call) async {
    if (call.method == 'isFullScreen') return false;
    return null;
  });

  setUpAll(() {
    registerFallbackValue(FakeRide());
  });

  late EventBus eventBus;
  late MockStoragePort storage;
  late RecordingEngine engine;

  setUp(() {
    eventBus = EventBus();
    storage = MockStoragePort();
    when(() => storage.saveRide(any())).thenAnswer((_) async {});
    when(() => storage.saveRide(any(), ftp: any(named: 'ftp')))
        .thenAnswer((_) async {});
    engine = RecordingEngine(eventBus: eventBus, storage: storage);
  });

  // RecordingEngine.start() spins up a periodic 1 Hz timer; the widget test
  // binding asserts no timers are left pending once a test body returns, so
  // every test that starts recording must dispose the engine itself before
  // finishing (a tearDown runs too late to satisfy that check). Disposal
  // cancels stream subscriptions, which needs the real event loop — hence
  // `tester.runAsync` rather than a bare await.
  Future<void> disposeEngine(WidgetTester tester) async {
    await tester.runAsync(() => engine.dispose());
    eventBus.dispose();
  }

  Widget wrap() {
    return ProviderScope(
      overrides: [recordingEngineProvider.overrideWithValue(engine)],
      child: const MaterialApp(
        home: Scaffold(
          body: RideKeyboardShortcuts(child: SizedBox.expand()),
        ),
      ),
    );
  }

  /// Wraps the shortcuts in a real router (started at `/ride`) so the
  /// idle-Esc path — which navigates home via `leaveRide` — has somewhere
  /// to go and can be asserted on.
  Widget wrapWithRouter() {
    final router = GoRouter(
      initialLocation: '/ride',
      routes: [
        GoRoute(
          path: '/ride',
          builder: (_, __) => const Scaffold(
            body: RideKeyboardShortcuts(child: SizedBox.expand()),
          ),
        ),
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('home marker')),
        ),
      ],
    );
    return ProviderScope(
      overrides: [recordingEngineProvider.overrideWithValue(engine)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('maps each key to its intent (activator table)', (_) async {
    const map = RideKeyboardShortcuts.shortcutMap;
    expect(
      map[const SingleActivator(LogicalKeyboardKey.space)],
      isA<StartPauseResumeIntent>(),
    );
    expect(
      map[const SingleActivator(LogicalKeyboardKey.keyL)],
      isA<MarkLapIntent>(),
    );
    expect(
      map[const SingleActivator(LogicalKeyboardKey.escape)],
      isA<StopRideIntent>(),
    );
    expect(
      map[const SingleActivator(LogicalKeyboardKey.keyF)],
      isA<ToggleFullscreenIntent>(),
    );
  });

  testWidgets('Space starts recording when idle', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump();
    expect(engine.state, RecordingState.idle);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(engine.state, RecordingState.recording);
    await disposeEngine(tester);
  });

  testWidgets('Space pauses then resumes an active recording', (tester) async {
    engine.start();
    await tester.pumpWidget(wrap());
    await tester.pump();
    expect(engine.state, RecordingState.recording);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(engine.state, RecordingState.paused);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(engine.state, RecordingState.recording);
    await disposeEngine(tester);
  });

  testWidgets('L marks a lap and shows a snackbar', (tester) async {
    engine.start();
    await tester.pumpWidget(wrap());
    await tester.pump();
    expect(engine.lapCount, 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
    await tester.pump();

    expect(engine.lapCount, 1);
    expect(find.byType(SnackBar), findsOneWidget);
    await disposeEngine(tester);
  });

  testWidgets('Esc opens the end-ride confirmation dialog', (tester) async {
    engine.start();
    await tester.pumpWidget(wrap());
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(find.text('End ride?'), findsOneWidget);
    expect(engine.state, RecordingState.recording);
    await disposeEngine(tester);
  });

  testWidgets('Esc leaves the screen when idle instead of ending a ride',
      (tester) async {
    await tester.pumpWidget(wrapWithRouter());
    await tester.pumpAndSettle();
    expect(engine.state, RecordingState.idle);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    // No "stop & save" prompt for an idle engine — it just leaves.
    expect(find.text('End ride?'), findsNothing);
    expect(find.text('home marker'), findsOneWidget);
    await disposeEngine(tester);
  });

  testWidgets('F toggles fullscreen without throwing', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await disposeEngine(tester);
  });
}
