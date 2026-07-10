import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_bike/infrastructure/ant/ant_constants.dart';
import 'package:open_bike/infrastructure/ant/ant_message.dart';
import 'package:open_bike/infrastructure/ant/ant_usb_transport.dart';

class MockUsbBackend extends Mock implements UsbBackend {}

class FakeUsbDeviceInfo extends Fake implements UsbDeviceInfo {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUsbDeviceInfo());
    registerFallbackValue(Uint8List(0));
  });

  late MockUsbBackend backend;
  late AntUsbTransport transport;

  setUp(() async {
    backend = MockUsbBackend();
    when(() => backend.init()).thenAnswer((_) async {});
    when(() => backend.getDeviceList()).thenAnswer((_) async => [
          UsbDeviceInfo(
            vendorId: AntConstants.vendorId,
            productId: AntConstants.productIds.first,
            name: 'Test ANT+ Stick',
          ),
        ]);
    when(() => backend.openDevice(any())).thenAnswer((_) async => true);
    when(() => backend.bulkTransferOut(any(), timeout: any(named: 'timeout')))
        .thenAnswer((_) async {});
    when(() => backend.bulkTransferIn(any(), timeout: any(named: 'timeout')))
        .thenAnswer((_) async => Uint8List(0));
    when(() => backend.dispose()).thenAnswer((_) async {});

    transport = AntUsbTransport(backend: backend);
    await transport.findAndOpenDongle();
  });

  tearDown(() async {
    await transport.dispose();
  });

  group('AntUsbTransport — requestChannelId', () {
    test('resolves the real device number from the dongle response',
        () async {
      final response = AntMessage(
        messageId: AntConstants.msgSetChannelId,
        // [channel, deviceNumberLSB, deviceNumberMSB, deviceType, transmissionType]
        data: const [0, 0xD2, 0x04, AntConstants.fecDeviceType, 5],
      );
      when(() =>
              backend.bulkTransferIn(any(), timeout: any(named: 'timeout')))
          .thenAnswer((_) async => Uint8List.fromList(response.toBytes()));

      final channelId = await transport.requestChannelId(0);

      expect(channelId.channelNumber, 0);
      expect(channelId.deviceNumber, 1234); // 0x04D2
      expect(channelId.deviceType, AntConstants.fecDeviceType);
      expect(channelId.transmissionType, 5);
    });

    test('sends a Request Message asking for the channel ID sub-message',
        () async {
      final response = AntMessage(
        messageId: AntConstants.msgSetChannelId,
        data: const [0, 0, 0, AntConstants.fecDeviceType, 0],
      );
      when(() =>
              backend.bulkTransferIn(any(), timeout: any(named: 'timeout')))
          .thenAnswer((_) async => Uint8List.fromList(response.toBytes()));

      await transport.requestChannelId(0);

      final sent = verify(() => backend.bulkTransferOut(captureAny(),
              timeout: any(named: 'timeout')))
          .captured
          .cast<Uint8List>();
      final requestMessages = sent
          .map(AntMessage.parse)
          .whereType<AntMessage>()
          .where((m) => m.messageId == AntConstants.msgRequestMessage);
      expect(requestMessages, isNotEmpty);
      expect(requestMessages.first.data,
          [0, AntConstants.msgSetChannelId]);
    });

    test('times out when the dongle never responds', () async {
      await expectLater(
        transport.requestChannelId(0).timeout(const Duration(seconds: 3)),
        throwsA(isA<Exception>()),
      );
    });
  });
}
