import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/ports/export_port.dart';
import 'package:open_bike/core/domain/ports/storage_port.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/export_queue_service.dart';
import 'package:open_bike/plugins/plugin_interfaces.dart';
import 'package:open_bike/plugins/plugin_manifest.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/ride_summary_widgets.dart';

class MockStoragePort extends Mock implements StoragePort {}

class MockConnectivity extends Mock implements Connectivity {}

class MockExportPlugin extends Mock implements ExportPlugin {}

class FakeRide extends Fake implements Ride {}

Ride _testRide(String id) => Ride(
      id: id,
      startTime: DateTime.utc(2025, 6, 15, 10, 0, 0),
      endTime: DateTime.utc(2025, 6, 15, 10, 1, 0),
      status: RideStatus.finished,
    );

void main() {
  late AppDatabase db;
  late MockStoragePort storage;
  late MockConnectivity connectivity;
  late MockExportPlugin plugin;
  late ExportQueueService service;

  setUpAll(() {
    registerFallbackValue(FakeRide());
    registerFallbackValue(ExportFormat.fit);
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    storage = MockStoragePort();
    when(() => storage.getRide(any())).thenAnswer(
        (i) async => _testRide(i.positionalArguments.first as String));
    when(() => storage.getSensorReadings(any())).thenAnswer((_) async => []);
    when(() => storage.getLaps(any())).thenAnswer((_) async => []);

    connectivity = MockConnectivity();
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);
    when(() => connectivity.onConnectivityChanged)
        .thenAnswer((_) => const Stream.empty());

    plugin = MockExportPlugin();
    when(() => plugin.manifest).thenReturn(const PluginManifest(
      id: 'fake-export',
      name: 'Fake Export',
      version: '1.0.0',
      type: PluginType.export,
    ));
    when(() => plugin.isAuthenticated).thenReturn(true);

    service = ExportQueueService(
      db: db,
      storage: storage,
      plugins: {'fake-export': plugin},
      connectivity: connectivity,
    );
  });

  tearDown(() async {
    service.dispose();
    await db.close();
  });

  Future<void> pump(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          exportQueueServiceProvider.overrideWithValue(service),
          exportPluginsProvider.overrideWithValue({'fake-export': plugin}),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ExportSection(rideId: 'ride-1')),
        ),
      ),
    );
  }

  group('ExportSection / ExportButton — queue status', () {
    testWidgets('shows Uploading… while the export is in flight', (tester) async {
      final completer = Completer<String>();
      when(() => plugin.export(any(), format: any(named: 'format')))
          .thenAnswer((_) => completer.future);

      await pump(tester);
      await tester.tap(find.text('Fake Export'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Uploading…'), findsOneWidget);

      completer.complete('activity-1');
      await tester.pumpAndSettle();

      expect(find.text('Uploaded'), findsOneWidget);
    });

    testWidgets('shows Retrying (n/5)… right after a failed attempt', (tester) async {
      when(() => plugin.export(any(), format: any(named: 'format')))
          .thenThrow(Exception('network error'));

      await pump(tester);
      await tester.tap(find.text('Fake Export'));
      await tester.pump();
      // Give the failed export() + queue update time to land, but stay well
      // under the 1s exponential-backoff timer for the next attempt.
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('Retrying (1/5)'), findsOneWidget);

      // Cancel the pending backoff Timer before the test ends — flutter_test
      // asserts no timers are left running when a test finishes, and the
      // shared tearDown's dispose() runs after that check.
      service.dispose();
    });

    testWidgets(
        'shows Failed with reason and a working Retry button once retries are exhausted',
        (tester) async {
      await pump(tester);

      // Seed a terminally-failed row directly (retryCount == maxRetries is
      // skipped by processQueue's WHERE clause, so this is safe to set up
      // without racing the service's own retry loop) *after* the widget has
      // subscribed to queueStream — it's a broadcast stream, so an event
      // emitted before anyone's listening would otherwise be lost.
      await db.into(db.exportQueue).insert(ExportQueueCompanion.insert(
            rideId: 'ride-1',
            target: 'fake-export',
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ));
      final row = (await db.select(db.exportQueue).get()).single;
      await (db.update(db.exportQueue)..where((t) => t.id.equals(row.id)))
          .write(const ExportQueueCompanion(
        status: Value('failed'),
        retryCount: Value(ExportQueueService.maxRetries),
        errorMessage: Value('boom'),
      ));
      await service.processQueue(); // pushes the seeded state onto queueStream
      await tester.pump();

      expect(find.text('Failed: boom'), findsOneWidget);
      expect(find.text('Retry Fake Export'), findsOneWidget);

      when(() => plugin.export(any(), format: any(named: 'format')))
          .thenAnswer((_) async => 'activity-2');

      await tester.tap(find.text('Retry Fake Export'));
      await tester.pumpAndSettle();

      expect(find.text('Uploaded'), findsOneWidget);
    });
  });
}
