import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/ant/ant_constants.dart';
import 'package:open_bike/infrastructure/ant/ant_device_plugin.dart';
import 'package:open_bike/infrastructure/ant/ant_message.dart';
import 'package:open_bike/infrastructure/ant/ant_usb_transport.dart';

class MockAntUsbTransport extends Mock implements AntUsbTransport {}

void main() {
  late MockAntUsbTransport mockTransport;
  late EventBus eventBus;
  late AntDevicePlugin plugin;

  setUpAll(() {
    registerFallbackValue(
      const AntMessage(messageId: 0, data: []),
    );
  });

  setUp(() {
    mockTransport = MockAntUsbTransport();
    eventBus = EventBus();
    plugin = AntDevicePlugin(transport: mockTransport, eventBus: eventBus);

    when(() => mockTransport.state).thenReturn(AntTransportState.connected);
    when(() => mockTransport.initializeChannel(
          channelNumber: any(named: 'channelNumber'),
          deviceNumber: any(named: 'deviceNumber'),
          deviceType: any(named: 'deviceType'),
          transmissionType: any(named: 'transmissionType'),
        )).thenAnswer((_) async {});
    when(() => mockTransport.closeChannel(any())).thenAnswer((_) async {});
  });

  tearDown(() => eventBus.dispose());

  group('AntDevicePlugin — scan', () {
    test('resolves the discovered device id via requestChannelId', () async {
      final messageController = StreamController<AntMessage>.broadcast();
      addTearDown(messageController.close);

      when(() => mockTransport.messageStream)
          .thenAnswer((_) => messageController.stream);
      when(() => mockTransport.requestChannelId(0)).thenAnswer((_) async =>
          const AntChannelId(
            channelNumber: 0,
            deviceNumber: 1234,
            deviceType: AntConstants.fecDeviceType,
            transmissionType: 0,
          ));

      final future = plugin.scan(const Duration(milliseconds: 100));

      // Let scan() run past its `await initializeChannel(...)` so the
      // broadcast listener is actually attached before we emit.
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // A wildcard-channel broadcast (channel byte 0, >= 9 data bytes).
      messageController.add(AntMessage(
        messageId: AntConstants.msgBroadcastData,
        data: List.filled(9, 0),
      ));

      final devices = await future;

      expect(devices, hasLength(1));
      expect(devices.single.id, 'ant_fec_1234');
      expect(devices.single.protocol, DeviceProtocol.antFec);
      verify(() => mockTransport.requestChannelId(0)).called(1);
    });

    test('only requests the channel ID once per scan', () async {
      final messageController = StreamController<AntMessage>.broadcast();
      addTearDown(messageController.close);

      when(() => mockTransport.messageStream)
          .thenAnswer((_) => messageController.stream);
      when(() => mockTransport.requestChannelId(0)).thenAnswer((_) async =>
          const AntChannelId(
            channelNumber: 0,
            deviceNumber: 1234,
            deviceType: AntConstants.fecDeviceType,
            transmissionType: 0,
          ));

      final future = plugin.scan(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final broadcast = AntMessage(
        messageId: AntConstants.msgBroadcastData,
        data: List.filled(9, 0),
      );
      messageController
        ..add(broadcast)
        ..add(broadcast)
        ..add(broadcast);

      await future;

      verify(() => mockTransport.requestChannelId(0)).called(1);
    });
  });

  group('AntDevicePlugin — connect', () {
    const device = TrainerDevice(
      id: 'ant_fec_1234',
      name: 'ANT+ Trainer',
      protocol: DeviceProtocol.antFec,
      isControllable: true,
      supportedModes: [
        ControlMode.erg,
        ControlMode.simulation,
        ControlMode.resistance,
      ],
    );

    test('locks the channel to the device number encoded in device.id',
        () async {
      when(() => mockTransport.messageStream)
          .thenAnswer((_) => const Stream.empty());

      await plugin.connect(device);

      verify(() => mockTransport.initializeChannel(
            channelNumber: 0,
            deviceNumber: 1234,
            deviceType: AntConstants.fecDeviceType,
            transmissionType: 0,
          )).called(1);
    });

    test('falls back to the wildcard device number for an unrecognized id',
        () async {
      when(() => mockTransport.messageStream)
          .thenAnswer((_) => const Stream.empty());

      await plugin.connect(const TrainerDevice(
        id: 'some-other-id',
        name: 'ANT+ Trainer',
        protocol: DeviceProtocol.antFec,
        isControllable: true,
        supportedModes: [ControlMode.erg],
      ));

      verify(() => mockTransport.initializeChannel(
            channelNumber: 0,
            deviceNumber: 0,
            deviceType: AntConstants.fecDeviceType,
            transmissionType: 0,
          )).called(1);
    });
  });
}
