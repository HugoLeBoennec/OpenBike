import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_bike/core/domain/entities/trainer_device.dart';
import 'package:open_bike/infrastructure/ble/ble_connection.dart';
import 'package:open_bike/infrastructure/ble/ble_permission_handler.dart';
import 'package:open_bike/infrastructure/ble/ble_transport.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockPermissionHandler extends Mock implements BlePermissionHandler {}

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockPermissionHandler mockPermissions;

  setUp(() {
    mockPermissions = MockPermissionHandler();
  });

  group('BleTransport', () {
    test('initial state is idle', () {
      final transport = BleTransport(permissionHandler: mockPermissions);
      expect(transport.state, BleTransportState.idle);
      expect(transport.activeConnection, isNull);
      transport.dispose();
    });

    test('startScan throws when permissions denied', () async {
      when(() => mockPermissions.requestPermissions())
          .thenAnswer((_) async => false);

      final transport = BleTransport(permissionHandler: mockPermissions);

      expect(
        () => transport.startScan(),
        throwsA(isA<StateError>()),
      );

      await transport.dispose();
    });

    test('startScan checks permissions', () async {
      when(() => mockPermissions.requestPermissions())
          .thenAnswer((_) async => false);

      final transport = BleTransport(permissionHandler: mockPermissions);

      // startScan will throw because permissions are denied, but we verify
      // that permissions were checked.
      try {
        await transport.startScan();
      } catch (_) {}

      verify(() => mockPermissions.requestPermissions()).called(1);

      await transport.dispose();
    });

    test('stopScan is no-op when not scanning', () async {
      final transport = BleTransport(permissionHandler: mockPermissions);

      await transport.stopScan();
      expect(transport.state, BleTransportState.idle);

      await transport.dispose();
    });

    test('autoReconnect defaults to true', () {
      final transport = BleTransport(permissionHandler: mockPermissions);
      expect(transport.autoReconnect, isTrue);
      transport.dispose();
    });

    test('autoReconnect can be toggled', () {
      final transport = BleTransport(permissionHandler: mockPermissions);
      transport.autoReconnect = false;
      expect(transport.autoReconnect, isFalse);
      transport.dispose();
    });

    test('disconnectDevice keeps state idle when no active connection',
        () async {
      final transport = BleTransport(permissionHandler: mockPermissions);

      await transport.disconnectDevice();

      expect(transport.state, BleTransportState.idle);
      expect(transport.activeConnection, isNull);

      await transport.dispose();
    });

    test('maxReconnectAttempts is 5', () {
      expect(BleTransport.maxReconnectAttempts, 5);
    });

    test('stateStream is a broadcast stream', () async {
      final transport = BleTransport(permissionHandler: mockPermissions);

      expect(transport.stateStream.isBroadcast, isTrue);

      await transport.dispose();
    });
  });

  group('BleScannedDevice', () {
    test('stores device, rssi and service uuids', () {
      const device = TrainerDevice(
        id: 'AA:BB:CC:DD:EE:FF',
        name: 'Test Trainer',
        protocol: DeviceProtocol.bleFtms,
        isControllable: true,
        supportedModes: [ControlMode.erg],
      );

      final scanned = BleScannedDevice(
        device: device,
        rssi: -65,
        serviceUuids: [Guid('00001826-0000-1000-8000-00805f9b34fb')],
      );

      expect(scanned.device.id, 'AA:BB:CC:DD:EE:FF');
      expect(scanned.device.name, 'Test Trainer');
      expect(scanned.rssi, -65);
      expect(scanned.serviceUuids, hasLength(1));
    });
  });

  group('BleConnection', () {
    test('initial mtu is 23', () {
      final mockDevice = MockBluetoothDevice();
      when(() => mockDevice.remoteId)
          .thenReturn(const DeviceIdentifier('test'));

      final connection = BleConnection(mockDevice);
      expect(connection.mtu, 23);
      expect(connection.deviceId, 'test');
      connection.dispose();
    });

    test('findCharacteristic returns null before connect', () {
      final mockDevice = MockBluetoothDevice();
      when(() => mockDevice.remoteId)
          .thenReturn(const DeviceIdentifier('test'));

      final connection = BleConnection(mockDevice);
      final result = connection.findCharacteristic(
        Guid('00001826-0000-1000-8000-00805f9b34fb'),
        Guid('00002ad2-0000-1000-8000-00805f9b34fb'),
      );
      expect(result, isNull);
      connection.dispose();
    });

    test('services is empty before connect', () {
      final mockDevice = MockBluetoothDevice();
      when(() => mockDevice.remoteId)
          .thenReturn(const DeviceIdentifier('test'));

      final connection = BleConnection(mockDevice);
      expect(connection.services, isEmpty);
      connection.dispose();
    });

    test('stateStream emits disconnecting then disconnected on disconnect',
        () async {
      final mockDevice = MockBluetoothDevice();
      when(() => mockDevice.remoteId)
          .thenReturn(const DeviceIdentifier('test'));
      when(() => mockDevice.disconnect()).thenAnswer((_) async {});

      final connection = BleConnection(mockDevice);

      // Use expectLater with emitsInOrder to handle async stream events.
      final expectation = expectLater(
        connection.stateStream,
        emitsInOrder([
          BleConnectionState.disconnecting,
          BleConnectionState.disconnected,
        ]),
      );

      await connection.disconnect();
      await expectation;

      connection.dispose();
    });
  });
}
