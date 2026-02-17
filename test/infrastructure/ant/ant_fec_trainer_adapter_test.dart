import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/app_event.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/ant/ant_constants.dart';
import 'package:open_bike/infrastructure/ant/ant_fec_trainer_adapter.dart';
import 'package:open_bike/infrastructure/ant/ant_message.dart';
import 'package:open_bike/infrastructure/ant/ant_usb_transport.dart';

class MockAntUsbTransport extends Mock implements AntUsbTransport {}

void main() {
  late MockAntUsbTransport mockTransport;
  late EventBus eventBus;
  late AntFecTrainerAdapter adapter;
  late StreamController<AntMessage> messageController;

  const device = TrainerDevice(
    id: 'ant_fec_0',
    name: 'Test ANT+ Trainer',
    protocol: DeviceProtocol.antFec,
    isControllable: true,
    supportedModes: [ControlMode.erg, ControlMode.simulation, ControlMode.resistance],
  );

  setUp(() {
    mockTransport = MockAntUsbTransport();
    eventBus = EventBus();
    messageController = StreamController<AntMessage>.broadcast();

    when(() => mockTransport.messageStream)
        .thenAnswer((_) => messageController.stream);
    when(() => mockTransport.sendAcknowledged(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockTransport.closeChannel(any()))
        .thenAnswer((_) async {});

    adapter = AntFecTrainerAdapter(
      transport: mockTransport,
      channelNumber: 0,
      device: device,
      eventBus: eventBus,
    );
  });

  tearDown(() async {
    messageController.close();
    eventBus.dispose();
  });

  group('AntFecTrainerAdapter — initialize', () {
    test('fires connected and controlAcquired events', () async {
      final events = <Object>[];
      eventBus.on<TrainerEvent>().listen(events.add);

      await adapter.initialize();
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(2));
      expect(events[0], isA<TrainerConnected>());
      expect(events[1], isA<TrainerControlAcquired>());
    });
  });

  group('AntFecTrainerAdapter — data parsing', () {
    setUp(() async {
      await adapter.initialize();
    });

    test('emits power and cadence from page 25 broadcast', () async {
      final readings = <SensorReading>[];
      adapter.dataStream.listen(readings.add);

      // Simulate a broadcast data message with page 25 payload.
      // Channel=0, page=25, eventCount=1, cadence=90,
      // accPower LE=0xC8,0x00 (200), instPower=200 (0xC8, 0x00), status=0
      messageController.add(AntMessage(
        messageId: AntConstants.msgBroadcastData,
        data: [0, 25, 1, 90, 0xC8, 0x00, 0xC8, 0x00, 0x00],
      ));

      await Future<void>.delayed(Duration.zero);

      expect(readings, hasLength(1));
      expect(readings[0].power?.value, 200);
      expect(readings[0].cadence?.rpm, 90);
    });

    test('emits heart rate from page 16 broadcast', () async {
      final readings = <SensorReading>[];
      adapter.dataStream.listen(readings.add);

      // Page 16: equipType=5, elapsed=0, dist=0, speed=0x1027 (10000=36km/h), HR=140, caps=0
      messageController.add(AntMessage(
        messageId: AntConstants.msgBroadcastData,
        data: [0, 16, 5, 0, 0, 0x10, 0x27, 140, 0x00],
      ));

      await Future<void>.delayed(Duration.zero);

      expect(readings, hasLength(1));
      expect(readings[0].heartRate?.bpm, 140);
    });

    test('ignores messages for other channels', () async {
      final readings = <SensorReading>[];
      adapter.dataStream.listen(readings.add);

      // Channel 1, not our channel 0.
      messageController.add(AntMessage(
        messageId: AntConstants.msgBroadcastData,
        data: [1, 25, 1, 90, 0xC8, 0x00, 0xC8, 0x00, 0x00],
      ));

      await Future<void>.delayed(Duration.zero);
      expect(readings, isEmpty);
    });

    test('ignores non-broadcast messages', () async {
      final readings = <SensorReading>[];
      adapter.dataStream.listen(readings.add);

      messageController.add(AntMessage(
        messageId: AntConstants.msgChannelResponse,
        data: [0, 25, 0],
      ));

      await Future<void>.delayed(Duration.zero);
      expect(readings, isEmpty);
    });
  });

  group('AntFecTrainerAdapter — control commands', () {
    setUp(() async {
      await adapter.initialize();
    });

    test('setTargetPower sends acknowledged data and fires erg mode', () async {
      final events = <Object>[];
      eventBus.on<TrainerEvent>().listen(events.add);

      await adapter.setTargetPower(const Watts(200));
      await Future<void>.delayed(Duration.zero);

      verify(() => mockTransport.sendAcknowledged(0, any())).called(1);

      // Last event should be modeChanged(erg).
      final modeEvent = events.whereType<TrainerModeChanged>().first;
      expect(modeEvent.mode, ControlMode.erg);
    });

    test('setResistance sends acknowledged data and fires resistance mode', () async {
      final events = <Object>[];
      eventBus.on<TrainerEvent>().listen(events.add);

      await adapter.setResistance(50.0);
      await Future<void>.delayed(Duration.zero);

      verify(() => mockTransport.sendAcknowledged(0, any())).called(1);

      final modeEvent = events.whereType<TrainerModeChanged>().first;
      expect(modeEvent.mode, ControlMode.resistance);
    });

    test('setSimulationParams sends two acknowledged messages', () async {
      await adapter.setSimulationParams(
        0,
        const Grade(5.0),
        0.004,
        0.5,
      );

      // Track resistance + wind resistance = 2 calls.
      verify(() => mockTransport.sendAcknowledged(0, any())).called(2);
    });
  });

  group('AntFecTrainerAdapter — disconnect', () {
    test('closes channel and fires disconnected event', () async {
      await adapter.initialize();

      final events = <Object>[];
      eventBus.on<TrainerEvent>().listen(events.add);

      await adapter.disconnect();
      await Future<void>.delayed(Duration.zero);

      verify(() => mockTransport.closeChannel(0)).called(1);

      final disconnected = events.whereType<TrainerDisconnected>().first;
      expect(disconnected.deviceId, 'ant_fec_0');
    });
  });
}
