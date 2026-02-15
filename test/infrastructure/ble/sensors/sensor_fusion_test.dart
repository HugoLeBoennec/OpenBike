import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/domain/entities/sensor_reading.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/app_event.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/ble/sensors/sensor_fusion.dart';

void main() {
  late EventBus eventBus;
  late SensorFusion fusion;

  setUp(() {
    eventBus = EventBus();
    fusion = SensorFusion(eventBus: eventBus, deviceId: 'test-fusion');
  });

  tearDown(() async {
    await fusion.dispose();
    eventBus.dispose();
  });

  group('SensorFusion — single source', () {
    test('emits fused reading after 1 Hz tick', () async {
      final controller = StreamController<SensorReading>.broadcast();

      fusion.addSource(SensorSource(
        id: 'power-meter',
        stream: controller.stream,
        priority: SensorPriority.high,
      ));

      // Listen before emitting.
      final futureReading = fusion.stream.first;

      // Emit a sensor reading.
      controller.add(SensorReading(
        timestamp: DateTime.now(),
        power: const Watts(250),
        cadence: const Cadence(90),
      ));

      // The timer fires at 1 Hz — wait for the fused output.
      final fused = await futureReading.timeout(const Duration(seconds: 3));

      expect(fused.power?.value, 250);
      expect(fused.cadence?.rpm, 90);
      expect(fused.heartRate, isNull);

      await controller.close();
    });

    test('fires SensorEvent on EventBus', () async {
      final controller = StreamController<SensorReading>.broadcast();

      fusion.addSource(SensorSource(
        id: 'hr-monitor',
        stream: controller.stream,
      ));

      final futureEvent = eventBus.on<SensorEvent>().first;

      controller.add(SensorReading(
        timestamp: DateTime.now(),
        heartRate: const HeartRate(155),
      ));

      final event = await futureEvent.timeout(const Duration(seconds: 3));

      expect(event.deviceId, 'test-fusion');
      expect(event.reading.heartRate?.bpm, 155);

      await controller.close();
    });

    test('does not emit when no data arrives (not dirty)', () async {
      final controller = StreamController<SensorReading>.broadcast();

      fusion.addSource(SensorSource(
        id: 'idle-source',
        stream: controller.stream,
      ));

      // Wait more than 1 tick without sending data.
      bool received = false;
      final sub = fusion.stream.listen((_) => received = true);

      await Future<void>.delayed(const Duration(milliseconds: 1500));

      expect(received, isFalse);

      await sub.cancel();
      await controller.close();
    });
  });

  group('SensorFusion — priority-based fusion', () {
    test('higher priority source wins for same field', () async {
      final trainerController = StreamController<SensorReading>.broadcast();
      final externalPmController = StreamController<SensorReading>.broadcast();

      // Trainer provides power at normal priority.
      fusion.addSource(SensorSource(
        id: 'trainer',
        stream: trainerController.stream,
        priority: SensorPriority.normal,
      ));

      // External power meter at high priority.
      fusion.addSource(SensorSource(
        id: 'external-pm',
        stream: externalPmController.stream,
        priority: SensorPriority.high,
      ));

      final futureReading = fusion.stream.first;

      // Both emit power data.
      trainerController.add(SensorReading(
        timestamp: DateTime.now(),
        power: const Watts(200), // trainer says 200W
      ));
      externalPmController.add(SensorReading(
        timestamp: DateTime.now(),
        power: const Watts(215), // external PM says 215W
      ));

      // Allow microtask queue to process both events.
      await Future<void>.delayed(Duration.zero);

      final fused = await futureReading.timeout(const Duration(seconds: 3));

      // External PM (high priority) should win.
      expect(fused.power?.value, 215);

      await trainerController.close();
      await externalPmController.close();
    });

    test('merges different fields from different sources', () async {
      final hrController = StreamController<SensorReading>.broadcast();
      final powerController = StreamController<SensorReading>.broadcast();

      fusion.addSource(SensorSource(
        id: 'hr-strap',
        stream: hrController.stream,
        priority: SensorPriority.normal,
      ));
      fusion.addSource(SensorSource(
        id: 'power-meter',
        stream: powerController.stream,
        priority: SensorPriority.normal,
      ));

      final futureReading = fusion.stream.first;

      // HR strap sends heart rate.
      hrController.add(SensorReading(
        timestamp: DateTime.now(),
        heartRate: const HeartRate(142),
      ));

      // Power meter sends power + cadence.
      powerController.add(SensorReading(
        timestamp: DateTime.now(),
        power: const Watts(180),
        cadence: const Cadence(88),
      ));

      await Future<void>.delayed(Duration.zero);

      final fused = await futureReading.timeout(const Duration(seconds: 3));

      // Fused reading should contain all three fields.
      expect(fused.heartRate?.bpm, 142);
      expect(fused.power?.value, 180);
      expect(fused.cadence?.rpm, 88);

      await hrController.close();
      await powerController.close();
    });

    test('equal priority uses last-updated source (map iteration order)', () async {
      final source1 = StreamController<SensorReading>.broadcast();
      final source2 = StreamController<SensorReading>.broadcast();

      fusion.addSource(SensorSource(
        id: 'source-1',
        stream: source1.stream,
        priority: SensorPriority.normal,
      ));
      fusion.addSource(SensorSource(
        id: 'source-2',
        stream: source2.stream,
        priority: SensorPriority.normal,
      ));

      final futureReading = fusion.stream.first;

      // Both sources provide cadence — source-2 added last wins (>= comparison).
      source1.add(SensorReading(
        timestamp: DateTime.now(),
        cadence: const Cadence(85),
      ));
      source2.add(SensorReading(
        timestamp: DateTime.now(),
        cadence: const Cadence(90),
      ));

      await Future<void>.delayed(Duration.zero);

      final fused = await futureReading.timeout(const Duration(seconds: 3));

      // With >= comparison and map iteration order, source-2 (last iterated) wins.
      expect(fused.cadence?.rpm, 90);

      await source1.close();
      await source2.close();
    });
  });

  group('SensorFusion — source management', () {
    test('removeSource stops listening to that source', () async {
      final controller = StreamController<SensorReading>.broadcast();

      fusion.addSource(SensorSource(
        id: 'removable',
        stream: controller.stream,
      ));

      fusion.removeSource('removable');

      // Emit data after removal — should not trigger fusion output.
      controller.add(SensorReading(
        timestamp: DateTime.now(),
        power: const Watts(100),
      ));

      bool received = false;
      final sub = fusion.stream.listen((_) => received = true);

      await Future<void>.delayed(const Duration(milliseconds: 1500));

      expect(received, isFalse);

      await sub.cancel();
      await controller.close();
    });

    test('addSource with same id replaces previous source', () async {
      final first = StreamController<SensorReading>.broadcast();
      final second = StreamController<SensorReading>.broadcast();

      fusion.addSource(SensorSource(
        id: 'pm',
        stream: first.stream,
        priority: SensorPriority.normal,
      ));

      // Replace with higher priority.
      fusion.addSource(SensorSource(
        id: 'pm',
        stream: second.stream,
        priority: SensorPriority.high,
      ));

      final futureReading = fusion.stream.first;

      // Old stream should be ignored.
      first.add(SensorReading(
        timestamp: DateTime.now(),
        power: const Watts(100),
      ));

      // New stream should be used.
      second.add(SensorReading(
        timestamp: DateTime.now(),
        power: const Watts(200),
      ));

      await Future<void>.delayed(Duration.zero);

      final fused = await futureReading.timeout(const Duration(seconds: 3));
      expect(fused.power?.value, 200);

      await first.close();
      await second.close();
    });
  });

  group('SensorFusion — dispose', () {
    test('dispose closes the output stream', () async {
      await fusion.dispose();

      expect(fusion.stream.isBroadcast, isTrue);
      // After dispose, adding a listener should complete with done.
      final readings = <SensorReading>[];
      await fusion.stream.listen(readings.add).asFuture<void>();
      expect(readings, isEmpty);
    });
  });
}
