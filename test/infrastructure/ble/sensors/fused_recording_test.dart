import 'dart:async';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_bike/core/application/services/recording_engine.dart';
import 'package:open_bike/core/domain/entities/sensor_reading.dart';
import 'package:open_bike/core/domain/entities/trainer_device.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/ble/ble_connection.dart';
import 'package:open_bike/infrastructure/ble/ble_constants.dart';
import 'package:open_bike/infrastructure/ble/ftms/ftms_device_plugin.dart';
import 'package:open_bike/infrastructure/ble/sensors/sensor_fusion.dart';
import 'package:open_bike/infrastructure/persistence/app_database.dart';
import 'package:open_bike/infrastructure/persistence/drift_storage.dart';

class MockBleConnection extends Mock implements BleConnection {}

void main() {
  setUpAll(() {
    registerFallbackValue(Guid('00000000-0000-0000-0000-000000000000'));
    registerFallbackValue(<int>[]);
  });

  test('a ride on an FTMS trainer with an HR strap records heart rate '
      'every second', () async {
    final eventBus = EventBus();
    final db = AppDatabase(NativeDatabase.memory());
    final fusion = SensorFusion(eventBus: eventBus);
    final recorder =
        RecordingEngine(eventBus: eventBus, storage: DriftStorage(db));
    final controlPoint = StreamController<List<int>>.broadcast();
    final bikeData = StreamController<List<int>>.broadcast();
    final strap = StreamController<SensorReading>.broadcast();
    final timers = <Timer>[];
    addTearDown(() async {
      for (final t in timers) {
        t.cancel();
      }
      await recorder.dispose();
      await fusion.dispose();
      await Future.wait(
          [controlPoint.close(), bikeData.close(), strap.close(), db.close()]);
      eventBus.dispose();
    });

    final connection = MockBleConnection();
    when(() => connection.stateStream).thenAnswer((_) => const Stream.empty());
    when(() => connection.subscribe(any(), any())).thenAnswer((inv) async {
      final characteristic = inv.positionalArguments[1] as Guid;
      if (characteristic == BleConstants.ftmsControlPoint) {
        return controlPoint.stream;
      }
      if (characteristic == BleConstants.ftmsIndoorBikeData) {
        return bikeData.stream;
      }
      return const Stream<List<int>>.empty();
    });
    when(() => connection.read(any(), any()))
        .thenAnswer((_) async => Uint8List(8));
    // Acknowledge every control point write.
    when(() => connection.write(any(), any(), any())).thenAnswer((inv) async {
      final opCode = (inv.positionalArguments[2] as List<int>).first;
      Future<void>.delayed(const Duration(milliseconds: 5),
          () => controlPoint.add([0x80, opCode, 0x01]));
    });
    final trainer = FtmsTrainerAdapter(
      connection: connection,
      device: const TrainerDevice(
        id: 'kickr',
        name: 'KICKR',
        protocol: DeviceProtocol.bleFtms,
      ),
      eventBus: eventBus,
    );
    await trainer.initialize();

    // Paired the way DevicePairingService does it: the trainer at normal
    // priority, a dedicated strap at high. The trainer notifies power and
    // cadence (no heart rate) four times a second, as FTMS trainers do.
    fusion.addSource(SensorSource(id: 'trainer', stream: trainer.dataStream));
    fusion.addSource(SensorSource(
      id: 'heartRate',
      stream: strap.stream,
      priority: SensorPriority.high,
    ));
    timers.add(Timer.periodic(const Duration(milliseconds: 250), (_) {
      bikeData.add([0x44, 0x00, 0xB8, 0x0B, 0xB4, 0x00, 0xC8, 0x00]);
    }));
    timers.add(Timer.periodic(const Duration(milliseconds: 500), (_) {
      strap.add(SensorReading(
          timestamp: DateTime.now(), heartRate: const HeartRate(150)));
    }));
    // Devices are connected before a ride starts.
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    await recorder.start();
    await Future<void>.delayed(const Duration(milliseconds: 5500));
    final ride = await recorder.stop();

    expect(ride.readings.length, greaterThanOrEqualTo(4));
    expect(ride.readings.map((r) => r.heartRate?.bpm).toSet(), {150});
    expect(ride.readings.map((r) => r.power?.value).toSet(), {200});
  });
}
