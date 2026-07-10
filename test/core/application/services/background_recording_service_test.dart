import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_bike/core/application/services/background_recording_service.dart';
import 'package:open_bike/core/application/services/recording_engine.dart';
import 'package:open_bike/core/domain/entities/lap.dart';
import 'package:open_bike/core/domain/entities/ride.dart';
import 'package:open_bike/core/domain/entities/sensor_reading.dart';
import 'package:open_bike/core/domain/ports/storage_port.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/foreground/foreground_service_controller.dart';

// ---------------------------------------------------------------------------
// Fakes / mocks
// ---------------------------------------------------------------------------

class MockStoragePort extends Mock implements StoragePort {}

class FakeRide extends Fake implements Ride {}

class FakeSensorReading extends Fake implements SensorReading {}

class FakeLap extends Fake implements Lap {}

/// Records every call so tests can assert on start/stop/update ordering
/// without a real Android foreground service.
class FakeForegroundServiceController implements ForegroundServiceController {
  int startCalls = 0;
  int stopCalls = 0;
  int updateCalls = 0;
  bool running = false;
  String? lastText;

  @override
  Future<void> start({required String title, required String text}) async {
    startCalls++;
    running = true;
    lastText = text;
  }

  @override
  Future<void> update({String? title, String? text}) async {
    updateCalls++;
    if (text != null) lastText = text;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    running = false;
  }
}

void main() {
  late EventBus eventBus;
  late MockStoragePort storage;
  late RecordingEngine engine;
  late FakeForegroundServiceController controller;
  late BackgroundRecordingService service;

  setUpAll(() {
    registerFallbackValue(FakeRide());
    registerFallbackValue(<SensorReading>[]);
    registerFallbackValue(<Lap>[]);
  });

  setUp(() {
    eventBus = EventBus();
    storage = MockStoragePort();
    when(() => storage.saveRide(any())).thenAnswer((_) async {});
    when(() => storage.saveSensorReadings(any(), any()))
        .thenAnswer((_) async {});
    when(() => storage.saveLaps(any(), any())).thenAnswer((_) async {});
    when(() => storage.savePersonalRecords(any())).thenAnswer((_) async {});

    engine = RecordingEngine(eventBus: eventBus, storage: storage);
    controller = FakeForegroundServiceController();
    service = BackgroundRecordingService(
      recordingEngine: engine,
      controller: controller,
      // Long interval — tests drive notification content directly via
      // engine state rather than waiting on the periodic timer.
      notificationUpdateInterval: const Duration(minutes: 10),
    );
  });

  tearDown(() async {
    await service.dispose();
    await engine.dispose();
    eventBus.dispose();
  });

  group('BackgroundRecordingService — lifecycle bound to RecordingState', () {
    test('does not start the service before recording begins', () {
      expect(controller.startCalls, 0);
      expect(service.isServiceRunning, isFalse);
    });

    test('starts the foreground service when recording starts', () async {
      await engine.start();
      await pumpEventQueue();

      expect(controller.startCalls, 1);
      expect(service.isServiceRunning, isTrue);
    });

    test('does not start a second time across pause/resume', () async {
      await engine.start();
      await pumpEventQueue();
      engine.pause();
      engine.resume();
      await pumpEventQueue();

      expect(controller.startCalls, 1);
      expect(service.isServiceRunning, isTrue);
    });

    test('stays running through pause', () async {
      await engine.start();
      await pumpEventQueue();
      engine.pause();
      await pumpEventQueue();

      expect(controller.stopCalls, 0);
      expect(service.isServiceRunning, isTrue);
    });

    test('stops the foreground service when recording stops', () async {
      await engine.start();
      await pumpEventQueue();
      await engine.stop();
      await pumpEventQueue();

      expect(controller.stopCalls, 1);
      expect(service.isServiceRunning, isFalse);
    });

    test('a fresh start after stop restarts the service', () async {
      await engine.start();
      await pumpEventQueue();
      await engine.stop();
      await pumpEventQueue();
      await engine.start();
      await pumpEventQueue();

      expect(controller.startCalls, 2);
      expect(service.isServiceRunning, isTrue);
    });

    test('start notification includes elapsed time and current power',
        () async {
      await engine.start();
      await pumpEventQueue();

      expect(controller.lastText, contains('00:00:00'));
      expect(controller.lastText, contains('-- W')); // no reading yet
    });

    test('dispose stops the service if still running', () async {
      await engine.start();
      await pumpEventQueue();
      await service.dispose();

      expect(controller.stopCalls, 1);
    });

    test('dispose is a no-op (no stop call) when never started', () async {
      await service.dispose();
      expect(controller.stopCalls, 0);
    });
  });
}
