import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/ports/export_port.dart';
import 'package:open_bike/core/domain/ports/storage_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/export_queue_service.dart';
import 'package:open_bike/plugins/plugin_interfaces.dart';
import 'package:open_bike/plugins/plugin_manifest.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockStoragePort extends Mock implements StoragePort {}

class MockConnectivity extends Mock implements Connectivity {}

class MockExportPlugin extends Mock implements ExportPlugin {}

class FakeRide extends Fake implements Ride {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

AppDatabase _createInMemoryDb() {
  return AppDatabase(NativeDatabase.memory());
}

Ride _testRide() {
  final start = DateTime.utc(2025, 6, 15, 10, 0, 0);
  return Ride(
    id: 'ride-001',
    startTime: start,
    endTime: start.add(const Duration(seconds: 60)),
    status: RideStatus.finished,
    readings: [
      SensorReading(
        timestamp: start,
        power: const Watts(200),
        heartRate: const HeartRate(140),
        cadence: const Cadence(90),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late AppDatabase db;
  late MockStoragePort storage;
  late MockConnectivity connectivity;
  late MockExportPlugin stravaPlugin;
  late ExportQueueService service;

  setUpAll(() {
    registerFallbackValue(FakeRide());
    registerFallbackValue(ExportFormat.fit);
  });

  setUp(() async {
    db = _createInMemoryDb();
    storage = MockStoragePort();
    connectivity = MockConnectivity();
    stravaPlugin = MockExportPlugin();

    when(() => stravaPlugin.isAuthenticated).thenReturn(true);
    when(() => stravaPlugin.manifest).thenReturn(const PluginManifest(
      id: 'strava-export',
      name: 'Strava',
      version: '1.0.0',
      type: PluginType.export,
    ));

    // Default: online
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => ConnectivityResult.wifi);
    when(() => connectivity.onConnectivityChanged)
        .thenAnswer((_) => const Stream.empty());

    // Storage returns the test ride
    when(() => storage.getRide('ride-001'))
        .thenAnswer((_) async => _testRide());
    when(() => storage.getSensorReadings('ride-001'))
        .thenAnswer((_) async => _testRide().readings);
    when(() => storage.getLaps('ride-001'))
        .thenAnswer((_) async => []);

    service = ExportQueueService(
      db: db,
      storage: storage,
      plugins: {'strava-export': stravaPlugin},
      connectivity: connectivity,
    );
  });

  tearDown(() async {
    service.dispose();
    await db.close();
  });

  // =========================================================================
  // Enqueue
  // =========================================================================

  group('ExportQueueService — enqueue', () {
    test('adds item to database', () async {
      when(() => stravaPlugin.export(any(), format: any(named: 'format')))
          .thenAnswer((_) async => 'activity-123');

      await service.enqueue('ride-001', 'strava-export');

      final items = await service.getAll();
      expect(items, hasLength(1));
      expect(items.first.rideId, 'ride-001');
      expect(items.first.target, 'strava-export');
      // After enqueue + processQueue, the item may already be processed.
      expect(items.first.isPending || items.first.isUploading || items.first.isSuccess, isTrue);
    });

    test('emits queue update on stream', () async {
      final updates = <List<ExportQueueItem>>[];
      service.queueStream.listen(updates.add);

      await service.enqueue('ride-001', 'strava-export');

      // Give async processing time to complete
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(updates, isNotEmpty);
      expect(updates.last, isNotEmpty);
    });
  });

  // =========================================================================
  // Processing
  // =========================================================================

  group('ExportQueueService — processing', () {
    test('calls plugin.export on processQueue', () async {
      when(() => stravaPlugin.export(any(), format: any(named: 'format')))
          .thenAnswer((_) async => 'activity-123');

      await service.enqueue('ride-001', 'strava-export');
      await Future<void>.delayed(const Duration(milliseconds: 500));

      verify(() => stravaPlugin.export(any(), format: any(named: 'format')))
          .called(greaterThanOrEqualTo(1));
    });

    test('marks item as success after successful upload', () async {
      when(() => stravaPlugin.export(any(), format: any(named: 'format')))
          .thenAnswer((_) async => 'activity-123');

      await service.enqueue('ride-001', 'strava-export');
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final items = await service.getAll();
      expect(items.first.isSuccess, isTrue);
    });

    test('marks item as failed on plugin error', () async {
      when(() => stravaPlugin.export(any(), format: any(named: 'format')))
          .thenThrow(Exception('Upload failed'));

      await service.enqueue('ride-001', 'strava-export');
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final items = await service.getAll();
      expect(items.first.isFailed, isTrue);
      expect(items.first.retryCount, 1);
      expect(items.first.errorMessage, contains('Upload failed'));
    });

    test('skips unauthenticated plugins', () async {
      when(() => stravaPlugin.isAuthenticated).thenReturn(false);

      await service.enqueue('ride-001', 'strava-export');
      await Future<void>.delayed(const Duration(milliseconds: 200));

      verifyNever(
          () => stravaPlugin.export(any(), format: any(named: 'format')));

      final items = await service.getAll();
      expect(items.first.isPending, isTrue);
    });

    test('skips when offline', () async {
      when(() => connectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      await service.enqueue('ride-001', 'strava-export');
      await Future<void>.delayed(const Duration(milliseconds: 200));

      verifyNever(
          () => stravaPlugin.export(any(), format: any(named: 'format')));

      final items = await service.getAll();
      expect(items.first.isPending, isTrue);
    });

    test('fails permanently with unknown target', () async {
      await service.enqueue('ride-001', 'unknown-plugin');
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final items = await service.getAll();
      final item = items.firstWhere((i) => i.target == 'unknown-plugin');
      expect(item.isFailed, isTrue);
      expect(item.errorMessage, contains('No plugin registered'));
    });
  });

  // =========================================================================
  // Retry
  // =========================================================================

  group('ExportQueueService — retry', () {
    test('increments retryCount on failure', () async {
      when(() => stravaPlugin.export(any(), format: any(named: 'format')))
          .thenThrow(Exception('Network error'));

      await service.enqueue('ride-001', 'strava-export');
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final items = await service.getAll();
      expect(items.first.retryCount, greaterThanOrEqualTo(1));
    });

    test('manual retry resets retryCount and re-processes', () async {
      // First: fail the upload
      when(() => stravaPlugin.export(any(), format: any(named: 'format')))
          .thenThrow(Exception('Temporary error'));

      await service.enqueue('ride-001', 'strava-export');
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final failedItems = await service.getAll();
      expect(failedItems.first.isFailed, isTrue);

      // Now: succeed on retry
      when(() => stravaPlugin.export(any(), format: any(named: 'format')))
          .thenAnswer((_) async => 'activity-456');

      await service.retry(failedItems.first.id);
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final retriedItems = await service.getAll();
      expect(retriedItems.first.isSuccess, isTrue);
    });
  });

  // =========================================================================
  // Remove
  // =========================================================================

  group('ExportQueueService — remove', () {
    test('removes item from queue', () async {
      when(() => stravaPlugin.export(any(), format: any(named: 'format')))
          .thenAnswer((_) async => 'activity-123');

      await service.enqueue('ride-001', 'strava-export');
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final items = await service.getAll();
      expect(items, hasLength(1));

      await service.remove(items.first.id);

      final after = await service.getAll();
      expect(after, isEmpty);
    });
  });

  // =========================================================================
  // ExportQueueItem
  // =========================================================================

  group('ExportQueueItem', () {
    test('fromRow maps fields correctly', () {
      const row = ExportQueueRow(
        id: 42,
        rideId: 'ride-x',
        target: 'strava-export',
        status: 'uploading',
        retryCount: 2,
        lastAttempt: 1718440000000,
        errorMessage: 'timeout',
        createdAt: 1718430000000,
      );

      final item = ExportQueueItem.fromRow(row);
      expect(item.id, 42);
      expect(item.rideId, 'ride-x');
      expect(item.target, 'strava-export');
      expect(item.isUploading, isTrue);
      expect(item.retryCount, 2);
      expect(item.lastAttempt, isNotNull);
      expect(item.errorMessage, 'timeout');
    });

    test('status helpers are correct', () {
      final ts = DateTime(2025);
      expect(
        ExportQueueItem(
          id: 1, rideId: 'r', target: 't', status: 'pending',
          retryCount: 0, createdAt: ts,
        ).isPending,
        isTrue,
      );
      expect(
        ExportQueueItem(
          id: 1, rideId: 'r', target: 't', status: 'success',
          retryCount: 0, createdAt: ts,
        ).isSuccess,
        isTrue,
      );
      expect(
        ExportQueueItem(
          id: 1, rideId: 'r', target: 't', status: 'failed',
          retryCount: 3, createdAt: ts,
        ).isFailed,
        isTrue,
      );
    });
  });
}
