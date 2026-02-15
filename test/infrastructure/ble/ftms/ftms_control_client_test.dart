import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_bike/infrastructure/ble/ble_connection.dart';
import 'package:open_bike/infrastructure/ble/ble_constants.dart';
import 'package:open_bike/infrastructure/ble/ftms/ftms_control_client.dart';

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

/// Builds a minimal FTMS Feature payload (8 bytes, all zeros = no features).
List<int> featurePayload({
  int machineFeatures = 0,
  int targetFeatures = 0,
}) {
  final data = ByteData(8);
  data.setUint32(0, machineFeatures, Endian.little);
  data.setUint32(4, targetFeatures, Endian.little);
  return data.buffer.asUint8List();
}

void main() {
  late MockBleConnection mockConnection;
  late StreamController<List<int>> cpController;
  late StreamController<List<int>> statusController;

  setUpAll(() {
    registerFallbackValue(Guid('00000000-0000-0000-0000-000000000000'));
    registerFallbackValue(<int>[]);
  });

  setUp(() {
    mockConnection = MockBleConnection();
    cpController = StreamController<List<int>>.broadcast();
    statusController = StreamController<List<int>>.broadcast();
  });

  tearDown(() async {
    await cpController.close();
    await statusController.close();
  });

  /// Sets up the mock connection so that [FtmsControlClient.initialize] can
  /// proceed.  Returns a function to inject response indications.
  void setupMockForInitialize({
    int machineFeatures = 0,
    int targetFeatures = 0,
  }) {
    // subscribe to Control Point
    when(() => mockConnection.subscribe(
          BleConstants.ftmsService,
          BleConstants.ftmsControlPoint,
        )).thenAnswer((_) async => cpController.stream);

    // subscribe to Status
    when(() => mockConnection.subscribe(
          BleConstants.ftmsService,
          BleConstants.ftmsStatus,
        )).thenAnswer((_) async => statusController.stream);

    // read Feature
    when(() => mockConnection.read(
          BleConstants.ftmsService,
          BleConstants.ftmsFeature,
        )).thenAnswer((_) async => featurePayload(
          machineFeatures: machineFeatures,
          targetFeatures: targetFeatures,
        ));

    // write to Control Point
    when(() => mockConnection.write(
          any(),
          any(),
          any(),
        )).thenAnswer((_) async {});
  }

  group('FtmsControlClient', () {
    // -----------------------------------------------------------------------
    // Initialization
    // -----------------------------------------------------------------------

    test('initialize runs full handshake', () async {
      setupMockForInitialize(
        machineFeatures: 0x00004002, // cadence + power
        targetFeatures: 0x00002008, // target power + sim params
      );

      final client = FtmsControlClient(mockConnection);

      // Simulate responses arriving shortly after writes.
      Future<void>.delayed(const Duration(milliseconds: 50), () {
        // Response to Request Control (opcode 0x00)
        cpController.add(cpResponse(FtmsOpCode.requestControl));
      });
      Future<void>.delayed(const Duration(milliseconds: 100), () {
        // Response to Start/Resume (opcode 0x07)
        cpController.add(cpResponse(FtmsOpCode.startOrResume));
      });

      await client.initialize();

      expect(client.hasControl, isTrue);
      expect(client.features, isNotNull);
      expect(client.features!.supportsCadence, isTrue);
      expect(client.features!.supportsPower, isTrue);
      expect(client.features!.supportsTargetPower, isTrue);
      expect(client.features!.supportsSimulationParams, isTrue);

      await client.dispose();
    });

    test('initialize fails if Request Control is denied', () async {
      setupMockForInitialize();

      final client = FtmsControlClient(mockConnection);

      // Simulate failure response after a short delay.
      Future<void>.delayed(const Duration(milliseconds: 50), () {
        cpController
            .add(cpResponse(FtmsOpCode.requestControl, resultCode: 0x05));
      });

      await expectLater(
        client.initialize(),
        throwsA(isA<StateError>()),
      );

      await client.dispose();
    });

    // -----------------------------------------------------------------------
    // setTargetPower
    // -----------------------------------------------------------------------

    test('setTargetPower sends correct bytes', () async {
      setupMockForInitialize();

      final client = FtmsControlClient(mockConnection);

      // Fast-track initialization.
      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.requestControl));
      });
      Future<void>.delayed(const Duration(milliseconds: 20), () {
        cpController.add(cpResponse(FtmsOpCode.startOrResume));
      });
      await client.initialize();

      // Now test setTargetPower.
      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.setTargetPower));
      });

      final response = await client.setTargetPower(250);
      expect(response.isSuccess, isTrue);

      // Verify the write call had correct data.
      // 3 writes total: requestControl, startOrResume, setTargetPower
      final captured = verify(
        () => mockConnection.write(
          BleConstants.ftmsService,
          BleConstants.ftmsControlPoint,
          captureAny(),
        ),
      ).captured;

      // The last write should be setTargetPower.
      final powerBytes = captured.last as List<int>;
      expect(powerBytes[0], FtmsOpCode.setTargetPower); // 0x05
      // 250W as SINT16 LE
      final bd = ByteData.sublistView(Uint8List.fromList(powerBytes));
      expect(bd.getInt16(1, Endian.little), 250);

      await client.dispose();
    });

    test('setTargetPower clamps to 4000W', () async {
      setupMockForInitialize();

      final client = FtmsControlClient(mockConnection);
      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.requestControl));
      });
      Future<void>.delayed(const Duration(milliseconds: 20), () {
        cpController.add(cpResponse(FtmsOpCode.startOrResume));
      });
      await client.initialize();

      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.setTargetPower));
      });
      await client.setTargetPower(5000);

      final captured = verify(
        () => mockConnection.write(
          BleConstants.ftmsService,
          BleConstants.ftmsControlPoint,
          captureAny(),
        ),
      ).captured;

      final powerBytes = captured.last as List<int>;
      final bd = ByteData.sublistView(Uint8List.fromList(powerBytes));
      expect(bd.getInt16(1, Endian.little), 4000);

      await client.dispose();
    });

    // -----------------------------------------------------------------------
    // setSimulationParameters
    // -----------------------------------------------------------------------

    test('setSimulationParameters encodes correctly', () async {
      setupMockForInitialize();

      final client = FtmsControlClient(mockConnection);
      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.requestControl));
      });
      Future<void>.delayed(const Duration(milliseconds: 20), () {
        cpController.add(cpResponse(FtmsOpCode.startOrResume));
      });
      await client.initialize();

      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.setSimulationParameters));
      });

      // wind=2.5 m/s, grade=3.5%, crr=0.004, cda=0.51
      final response = await client.setSimulationParameters(
        windSpeed: 2.5,
        grade: 3.5,
        crr: 0.004,
        cda: 0.51,
      );
      expect(response.isSuccess, isTrue);

      final captured = verify(
        () => mockConnection.write(
          BleConstants.ftmsService,
          BleConstants.ftmsControlPoint,
          captureAny(),
        ),
      ).captured;

      final simBytes = captured.last as List<int>;
      expect(simBytes[0], FtmsOpCode.setSimulationParameters); // 0x11

      final bd = ByteData.sublistView(Uint8List.fromList(simBytes));
      // wind: 2.5 * 1000 = 2500
      expect(bd.getInt16(1, Endian.little), 2500);
      // grade: 3.5 * 100 = 350
      expect(bd.getInt16(3, Endian.little), 350);
      // crr: 0.004 * 10000 = 40
      expect(simBytes[5], 40);
      // cda: 0.51 * 100 = 51
      expect(simBytes[6], 51);

      await client.dispose();
    });

    // -----------------------------------------------------------------------
    // setTargetResistance
    // -----------------------------------------------------------------------

    test('setTargetResistance encodes correctly', () async {
      setupMockForInitialize();

      final client = FtmsControlClient(mockConnection);
      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.requestControl));
      });
      Future<void>.delayed(const Duration(milliseconds: 20), () {
        cpController.add(cpResponse(FtmsOpCode.startOrResume));
      });
      await client.initialize();

      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.setTargetResistance));
      });

      await client.setTargetResistance(12.5);

      final captured = verify(
        () => mockConnection.write(
          BleConstants.ftmsService,
          BleConstants.ftmsControlPoint,
          captureAny(),
        ),
      ).captured;

      final resBytes = captured.last as List<int>;
      expect(resBytes[0], FtmsOpCode.setTargetResistance); // 0x04
      // 12.5 * 10 = 125
      expect(resBytes[1], 125);

      await client.dispose();
    });

    // -----------------------------------------------------------------------
    // stopOrPause
    // -----------------------------------------------------------------------

    test('stopOrPause sends stop (0x01) by default', () async {
      setupMockForInitialize();

      final client = FtmsControlClient(mockConnection);
      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.requestControl));
      });
      Future<void>.delayed(const Duration(milliseconds: 20), () {
        cpController.add(cpResponse(FtmsOpCode.startOrResume));
      });
      await client.initialize();

      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.stopOrPause));
      });

      await client.stopOrPause();

      final captured = verify(
        () => mockConnection.write(
          BleConstants.ftmsService,
          BleConstants.ftmsControlPoint,
          captureAny(),
        ),
      ).captured;

      final stopBytes = captured.last as List<int>;
      expect(stopBytes[0], FtmsOpCode.stopOrPause); // 0x08
      expect(stopBytes[1], 0x01); // stop
      await client.dispose();
    });

    test('stopOrPause sends pause (0x02) when requested', () async {
      setupMockForInitialize();

      final client = FtmsControlClient(mockConnection);
      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.requestControl));
      });
      Future<void>.delayed(const Duration(milliseconds: 20), () {
        cpController.add(cpResponse(FtmsOpCode.startOrResume));
      });
      await client.initialize();

      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.stopOrPause));
      });

      await client.stopOrPause(pause: true);

      final captured = verify(
        () => mockConnection.write(
          BleConstants.ftmsService,
          BleConstants.ftmsControlPoint,
          captureAny(),
        ),
      ).captured;

      final pauseBytes = captured.last as List<int>;
      expect(pauseBytes[1], 0x02); // pause
      await client.dispose();
    });

    // -----------------------------------------------------------------------
    // Machine Status
    // -----------------------------------------------------------------------

    test('statusChanges emits parsed machine status', () async {
      setupMockForInitialize();

      final client = FtmsControlClient(mockConnection);
      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.requestControl));
      });
      Future<void>.delayed(const Duration(milliseconds: 20), () {
        cpController.add(cpResponse(FtmsOpCode.startOrResume));
      });
      await client.initialize();

      final statuses = <FtmsMachineStatus>[];
      client.statusChanges.listen(statuses.add);

      statusController.add([0x04]); // Started by user
      statusController.add([0x08]); // Target power changed
      statusController.add([0xFF]); // Control permission lost

      // Let events propagate.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(statuses, [
        FtmsMachineStatus.startedOrResumedByUser,
        FtmsMachineStatus.targetPowerChanged,
        FtmsMachineStatus.controlPermissionLost,
      ]);

      // Control should be lost after 0xFF.
      expect(client.hasControl, isFalse);

      await client.dispose();
    });

    // -----------------------------------------------------------------------
    // Feature parsing
    // -----------------------------------------------------------------------

    test('features are parsed correctly from 8-byte payload', () async {
      setupMockForInitialize(
        // Machine: cadence(1) + power(14) + HR(15)
        machineFeatures: 0x0000C002,
        // Target: resistance(2) + power(3) + sim(13)
        targetFeatures: 0x0000200C,
      );

      final client = FtmsControlClient(mockConnection);
      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.requestControl));
      });
      Future<void>.delayed(const Duration(milliseconds: 20), () {
        cpController.add(cpResponse(FtmsOpCode.startOrResume));
      });
      await client.initialize();

      expect(client.features!.supportsCadence, isTrue);
      expect(client.features!.supportsPower, isTrue);
      expect(client.features!.supportsHeartRate, isTrue);
      expect(client.features!.supportsTargetResistance, isTrue);
      expect(client.features!.supportsTargetPower, isTrue);
      expect(client.features!.supportsSimulationParams, isTrue);
      expect(client.features!.supportsAverageSpeed, isFalse);
      expect(client.features!.supportsTotalDistance, isFalse);

      await client.dispose();
    });

    // -----------------------------------------------------------------------
    // Dispose
    // -----------------------------------------------------------------------

    test('dispose resets hasControl', () async {
      setupMockForInitialize();

      final client = FtmsControlClient(mockConnection);
      Future<void>.delayed(const Duration(milliseconds: 10), () {
        cpController.add(cpResponse(FtmsOpCode.requestControl));
      });
      Future<void>.delayed(const Duration(milliseconds: 20), () {
        cpController.add(cpResponse(FtmsOpCode.startOrResume));
      });
      await client.initialize();
      expect(client.hasControl, isTrue);

      await client.dispose();
      expect(client.hasControl, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // FtmsFeatures unit tests
  // -------------------------------------------------------------------------

  group('FtmsFeatures', () {
    test('toString formats hex', () {
      const f = FtmsFeatures(machineFeatures: 0xABCD, targetFeatures: 0x1234);
      expect(f.toString(), contains('abcd'));
      expect(f.toString(), contains('1234'));
    });
  });

  // -------------------------------------------------------------------------
  // FtmsControlResponse unit tests
  // -------------------------------------------------------------------------

  group('FtmsControlResponse', () {
    test('isSuccess returns true for success result', () {
      const r = FtmsControlResponse(
        requestOpCode: 0x05,
        resultCode: FtmsResultCode.success,
      );
      expect(r.isSuccess, isTrue);
    });

    test('isSuccess returns false for failure', () {
      const r = FtmsControlResponse(
        requestOpCode: 0x05,
        resultCode: FtmsResultCode.operationFailed,
      );
      expect(r.isSuccess, isFalse);
    });

    test('toString includes opcode and result', () {
      const r = FtmsControlResponse(
        requestOpCode: 0x11,
        resultCode: FtmsResultCode.invalidParameter,
      );
      expect(r.toString(), contains('0x11'));
      expect(r.toString(), contains('invalidParameter'));
    });
  });

  // -------------------------------------------------------------------------
  // Opcode constants
  // -------------------------------------------------------------------------

  group('FtmsOpCode', () {
    test('opcodes match FTMS spec', () {
      expect(FtmsOpCode.requestControl, 0x00);
      expect(FtmsOpCode.reset, 0x01);
      expect(FtmsOpCode.setTargetResistance, 0x04);
      expect(FtmsOpCode.setTargetPower, 0x05);
      expect(FtmsOpCode.startOrResume, 0x07);
      expect(FtmsOpCode.stopOrPause, 0x08);
      expect(FtmsOpCode.setSimulationParameters, 0x11);
      expect(FtmsOpCode.responseCode, 0x80);
    });
  });
}
