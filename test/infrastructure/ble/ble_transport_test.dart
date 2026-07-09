import 'dart:async';

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
// Fakes — a BleConnection double that never touches a real platform channel,
// used via BleTransport's injectable connectionFactory seam to test
// multi-connection lifecycle without real BLE hardware.
// ---------------------------------------------------------------------------

class FakeBleConnection extends BleConnection {
  FakeBleConnection(String deviceId) : super(_mockDeviceFor(deviceId));

  static BluetoothDevice _mockDeviceFor(String deviceId) {
    final mock = MockBluetoothDevice();
    when(() => mock.remoteId).thenReturn(DeviceIdentifier(deviceId));
    return mock;
  }

  /// Set to `true` to make the next [connect] call throw (simulates a failed
  /// reconnect attempt).
  bool failNextConnect = false;

  int connectCalls = 0;
  int disconnectCalls = 0;

  final _stateController = StreamController<BleConnectionState>.broadcast();

  @override
  Stream<BleConnectionState> get stateStream => _stateController.stream;

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 15)}) async {
    connectCalls++;
    if (failNextConnect) {
      throw Exception('simulated connect failure');
    }
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    _stateController.add(BleConnectionState.disconnecting);
    _stateController.add(BleConnectionState.disconnected);
  }

  /// Simulates the peripheral dropping the connection unexpectedly (as
  /// opposed to a deliberate [disconnect] call).
  void simulateUnexpectedDrop() {
    _stateController.add(BleConnectionState.disconnected);
  }

  @override
  void dispose() {
    _stateController.close();
  }
}

/// Tracks every [FakeBleConnection] created for each device id, so tests can
/// inspect reconnect attempts (each attempt creates a fresh instance, mirroring
/// how [BleTransport] opens a brand new [BleConnection] per attempt).
class FakeConnectionFactory {
  final Map<String, List<FakeBleConnection>> instancesByDevice = {};

  /// Device ids whose *next created instance* should fail to connect.
  final Set<String> failNextFor = {};

  BleConnection call(String deviceId) {
    final conn = FakeBleConnection(deviceId);
    if (failNextFor.contains(deviceId)) {
      conn.failNextConnect = true;
    }
    instancesByDevice.putIfAbsent(deviceId, () => []).add(conn);
    return conn;
  }

  int attemptCount(String deviceId) =>
      instancesByDevice[deviceId]?.length ?? 0;

  FakeBleConnection? latest(String deviceId) =>
      instancesByDevice[deviceId]?.last;
}

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

    test('startScan sets lastScanError when permissions denied', () async {
      when(() => mockPermissions.requestPermissions())
          .thenAnswer((_) async => false);

      final transport = BleTransport(permissionHandler: mockPermissions);

      await transport.startScan();

      expect(transport.lastScanError, isNotNull);
      expect(transport.state, BleTransportState.idle);

      await transport.dispose();
    });

    test('startScan checks permissions', () async {
      when(() => mockPermissions.requestPermissions())
          .thenAnswer((_) async => false);

      final transport = BleTransport(permissionHandler: mockPermissions);

      await transport.startScan();

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

  group('BleTransport — multi-connection lifecycle', () {
    late FakeConnectionFactory factory;
    late BleTransport transport;

    setUp(() {
      factory = FakeConnectionFactory();
      transport = BleTransport(
        permissionHandler: mockPermissions,
        connectionFactory: factory.call,
        // Zero backoff so reconnect tests run fast.
        backoffCalculator: (_) => Duration.zero,
      );
    });

    tearDown(() async {
      await transport.dispose();
    });

    test('connects to a trainer and an HRM simultaneously', () async {
      await transport.connectToDevice('trainer-1');
      await transport.connectToDevice('hrm-1');

      expect(transport.connections.keys, containsAll(['trainer-1', 'hrm-1']));
      expect(transport.connections, hasLength(2));
      expect(transport.isConnected('trainer-1'), isTrue);
      expect(transport.isConnected('hrm-1'), isTrue);
      expect(factory.attemptCount('trainer-1'), 1);
      expect(factory.attemptCount('hrm-1'), 1);
    });

    test('activeConnection reflects the most-recently connected device',
        () async {
      await transport.connectToDevice('trainer-1');
      await transport.connectToDevice('hrm-1');

      expect(transport.activeConnection, transport.connectionFor('hrm-1'));
    });

    test('disconnecting one device leaves the other connected', () async {
      await transport.connectToDevice('trainer-1');
      await transport.connectToDevice('hrm-1');

      await transport.disconnectDeviceId('trainer-1');

      expect(transport.isConnected('trainer-1'), isFalse);
      expect(transport.isConnected('hrm-1'), isTrue);
      expect(factory.latest('trainer-1')!.disconnectCalls, 1);
      expect(factory.latest('hrm-1')!.disconnectCalls, 0);
    });

    test('manual disconnect does not trigger auto-reconnect', () async {
      await transport.connectToDevice('trainer-1');
      await transport.disconnectDeviceId('trainer-1');

      // Give any stray reconnect timers a chance to fire.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(transport.isConnected('trainer-1'), isFalse);
      expect(factory.attemptCount('trainer-1'), 1);
    });

    test(
        'unexpected drop on one device triggers its own reconnect without '
        'touching the other device', () async {
      await transport.connectToDevice('trainer-1');
      await transport.connectToDevice('hrm-1');

      factory.latest('trainer-1')!.simulateUnexpectedDrop();

      // Allow the zero-delay reconnect timer to fire.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(transport.isConnected('trainer-1'), isTrue);
      expect(factory.attemptCount('trainer-1'), 2); // initial + 1 reconnect
      expect(factory.attemptCount('hrm-1'), 1); // untouched
    });

    test('gives up after maxReconnectAttempts and removes only that device',
        () async {
      await transport.connectToDevice('trainer-1');
      await transport.connectToDevice('hrm-1');

      factory.failNextFor.add('trainer-1');
      factory.latest('trainer-1')!.simulateUnexpectedDrop();

      // Each retry also fails (failNextFor keeps every new instance failing).
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(transport.isConnected('trainer-1'), isFalse);
      expect(
        factory.attemptCount('trainer-1'),
        1 + BleTransport.maxReconnectAttempts,
      );
      expect(transport.isConnected('hrm-1'), isTrue);
    });

    test('reconnecting to an already-connected device replaces it cleanly',
        () async {
      await transport.connectToDevice('trainer-1');
      final first = factory.latest('trainer-1');

      await transport.connectToDevice('trainer-1');
      final second = factory.latest('trainer-1');

      expect(first, isNot(same(second)));
      expect(first!.disconnectCalls, 1);
      expect(transport.connections, hasLength(1));
    });

    test('disconnectAll clears every tracked connection', () async {
      await transport.connectToDevice('trainer-1');
      await transport.connectToDevice('hrm-1');

      await transport.disconnectAll();

      expect(transport.connections, isEmpty);
      expect(transport.state, BleTransportState.idle);
    });
  });
}
