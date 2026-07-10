import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/ports/export_port.dart';
import 'package:open_bike/core/domain/ports/storage_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/app_event.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/export_queue_service.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/plugins/plugin_interfaces.dart';
import 'package:open_bike/plugins/plugin_manifest.dart';
import 'package:open_bike/plugins/plugin_registry.dart';
import 'package:open_bike/presentation/state/providers.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class MockStoragePort extends Mock implements StoragePort {}

class MockConnectivity extends Mock implements Connectivity {}

class FakeExportPlugin implements ExportPlugin {
  FakeExportPlugin(this.id, {bool authenticated = true})
      : _authenticated = authenticated;

  final String id;
  final bool _authenticated;

  @override
  PluginManifest get manifest => PluginManifest(
        id: id,
        name: id,
        version: '1.0.0',
        type: PluginType.export,
      );

  @override
  bool get isAuthenticated => _authenticated;

  @override
  Future<void> authenticate() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<String> export(Ride ride,
      {ExportFormat format = ExportFormat.fit, Watts? ftp}) async {
    return 'exported';
  }
}

Ride _testRide(String id) => Ride(
      id: id,
      startTime: DateTime.utc(2025, 6, 15, 10, 0, 0),
      endTime: DateTime.utc(2025, 6, 15, 10, 1, 0),
      status: RideStatus.finished,
    );

Future<AppPreferences> _fakePrefs(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  return AppPreferences(await SharedPreferences.getInstance());
}

void main() {
  late EventBus eventBus;
  late AppDatabase db;
  late MockStoragePort storage;
  late MockConnectivity connectivity;

  setUpAll(() {
    registerFallbackValue(ExportFormat.fit);
  });

  setUp(() {
    eventBus = EventBus();
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
  });

  tearDown(() async {
    eventBus.dispose();
    await db.close();
  });

  ProviderContainer makeContainer(PluginRegistry registry, AppPreferences prefs) {
    final queueService = ExportQueueService(
      db: db,
      storage: storage,
      plugins: {
        for (final plugin in registry.getExportPlugins()) plugin.manifest.id: plugin,
      },
      connectivity: connectivity,
    );
    addTearDown(queueService.dispose);
    final container = ProviderContainer(overrides: [
      eventBusProvider.overrideWithValue(eventBus),
      pluginRegistryProvider.overrideWithValue(registry),
      appPreferencesProvider.overrideWithValue(prefs),
      exportQueueServiceProvider.overrideWithValue(queueService),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  test('enqueues an export for each enabled, authenticated target on stop',
      () async {
    final registry = PluginRegistry()..registerExport(FakeExportPlugin('fake-target'));
    final prefs = await _fakePrefs({
      'auto_upload_targets': ['fake-target'],
    });
    final container = makeContainer(registry, prefs);

    container.read(autoUploadProvider); // activate the listener
    eventBus.fire(RideEvent.stopped(_testRide('ride-1')));
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final items = await container.read(exportQueueServiceProvider).getAll();
    expect(
      items.any((i) => i.rideId == 'ride-1' && i.target == 'fake-target'),
      isTrue,
    );
  });

  test('does nothing when no auto-upload targets are enabled', () async {
    final registry = PluginRegistry()..registerExport(FakeExportPlugin('fake-target'));
    final prefs = await _fakePrefs(const {});
    final container = makeContainer(registry, prefs);

    container.read(autoUploadProvider);
    eventBus.fire(RideEvent.stopped(_testRide('ride-1')));
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final items = await container.read(exportQueueServiceProvider).getAll();
    expect(items, isEmpty);
  });

  test('skips a target that is enabled but not authenticated', () async {
    final registry = PluginRegistry()
      ..registerExport(FakeExportPlugin('fake-target', authenticated: false));
    final prefs = await _fakePrefs({
      'auto_upload_targets': ['fake-target'],
    });
    final container = makeContainer(registry, prefs);

    container.read(autoUploadProvider);
    eventBus.fire(RideEvent.stopped(_testRide('ride-1')));
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final items = await container.read(exportQueueServiceProvider).getAll();
    expect(items, isEmpty);
  });

  test('ignores non-stopped ride events', () async {
    final registry = PluginRegistry()..registerExport(FakeExportPlugin('fake-target'));
    final prefs = await _fakePrefs({
      'auto_upload_targets': ['fake-target'],
    });
    final container = makeContainer(registry, prefs);

    container.read(autoUploadProvider);
    eventBus.fire(const RideEvent.started('ride-1'));
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final items = await container.read(exportQueueServiceProvider).getAll();
    expect(items, isEmpty);
  });
}
