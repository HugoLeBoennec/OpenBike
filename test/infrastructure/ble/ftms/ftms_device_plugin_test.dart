import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_bike/core/domain/entities/trainer_device.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/infrastructure/ble/ble_connection.dart';
import 'package:open_bike/infrastructure/ble/ble_constants.dart';
import 'package:open_bike/infrastructure/ble/ftms/ftms_device_plugin.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockBleConnection extends Mock implements BleConnection {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a Control Point response indication payload:
/// [0x80, requestOpCode, resultCode]
List<int> cpResponse(int requestOpCode, {int resultCode = 0x01}) =>
    [0x80, requestOpCode, resultCode];

const _setSimOpCode = 0x11;

void main() {
  late MockBleConnection mockConnection;
  late StreamController<List<int>> cpController;
  late StreamController<List<int>> statusController;
  late StreamController<BleConnectionState> connStateController;
  late EventBus eventBus;

  setUpAll(() {
    registerFallbackValue(Guid('00000000-0000-0000-0000-000000000000'));
    registerFallbackValue(<int>[]);
  });

  setUp(() {
    mockConnection = MockBleConnection();
    cpController = StreamController<List<int>>.broadcast();
    statusController = StreamController<List<int>>.broadcast();
    connStateController = StreamController<BleConnectionState>.broadcast();
    eventBus = EventBus();

    when(() => mockConnection.stateStream)
        .thenAnswer((_) => connStateController.stream);

    when(() => mockConnection.subscribe(
          BleConstants.ftmsService,
          BleConstants.ftmsControlPoint,
        )).thenAnswer((_) async => cpController.stream);

    when(() => mockConnection.subscribe(
          BleConstants.ftmsService,
          BleConstants.ftmsStatus,
        )).thenAnswer((_) async => statusController.stream);

    when(() => mockConnection.subscribe(
          BleConstants.ftmsService,
          BleConstants.ftmsIndoorBikeData,
        )).thenAnswer((_) async => const Stream<List<int>>.empty());

    when(() => mockConnection.read(
          BleConstants.ftmsService,
          BleConstants.ftmsFeature,
        )).thenAnswer((_) async {
      final data = ByteData(8);
      data.setUint32(0, 0, Endian.little);
      data.setUint32(4, 0x00002000, Endian.little); // supportsSimulationParams
      return data.buffer.asUint8List();
    });

    when(() => mockConnection.write(any(), any(), any()))
        .thenAnswer((_) async {});
  });

  tearDown(() async {
    await cpController.close();
    await statusController.close();
    await connStateController.close();
    eventBus.dispose();
  });

  test('setSimulationParams applies the default 0.5 difficulty to grade',
      () async {
    final adapter = FtmsTrainerAdapter(
      connection: mockConnection,
      device: const TrainerDevice(
        id: 'dev1',
        name: 'Test Trainer',
        protocol: DeviceProtocol.bleFtms,
      ),
      eventBus: eventBus,
    );

    Future<void>.delayed(const Duration(milliseconds: 10), () {
      cpController.add(cpResponse(0x00)); // requestControl
    });
    Future<void>.delayed(const Duration(milliseconds: 20), () {
      cpController.add(cpResponse(0x07)); // startOrResume
    });
    await adapter.initialize();

    Future<void>.delayed(const Duration(milliseconds: 10), () {
      cpController.add(cpResponse(_setSimOpCode));
    });
    await adapter.setSimulationParams(0, const Grade(10.0), 0.004, 0.51);

    final captured = verify(
      () => mockConnection.write(
        BleConstants.ftmsService,
        BleConstants.ftmsControlPoint,
        captureAny(),
      ),
    ).captured;

    final simBytes = captured.last as List<int>;
    final bd = ByteData.sublistView(Uint8List.fromList(simBytes));
    // 10% grade * 0.5 difficulty = 5.0% → encoded as 500 (resolution 0.01).
    expect(bd.getInt16(3, Endian.little), 500);
  });

  test('setSimulationParams halves downhill grade again below zero',
      () async {
    final adapter = FtmsTrainerAdapter(
      connection: mockConnection,
      device: const TrainerDevice(
        id: 'dev1',
        name: 'Test Trainer',
        protocol: DeviceProtocol.bleFtms,
      ),
      eventBus: eventBus,
    );

    Future<void>.delayed(const Duration(milliseconds: 10), () {
      cpController.add(cpResponse(0x00));
    });
    Future<void>.delayed(const Duration(milliseconds: 20), () {
      cpController.add(cpResponse(0x07));
    });
    await adapter.initialize();

    adapter.difficulty = 1.0;

    Future<void>.delayed(const Duration(milliseconds: 10), () {
      cpController.add(cpResponse(_setSimOpCode));
    });
    await adapter.setSimulationParams(0, const Grade(-10.0), 0.004, 0.51);

    final captured = verify(
      () => mockConnection.write(
        BleConstants.ftmsService,
        BleConstants.ftmsControlPoint,
        captureAny(),
      ),
    ).captured;

    final simBytes = captured.last as List<int>;
    final bd = ByteData.sublistView(Uint8List.fromList(simBytes));
    // -10% grade * 1.0 difficulty = -10.0%, then halved (downhill) → -5.0%
    // → encoded as -500.
    expect(bd.getInt16(3, Endian.little), -500);
  });
}
