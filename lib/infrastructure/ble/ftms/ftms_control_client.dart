import 'dart:async';
import 'dart:typed_data';

import 'package:logging/logging.dart';

import '../ble_connection.dart';
import '../ble_constants.dart';

final _log = Logger('FtmsControlClient');

// ---------------------------------------------------------------------------
// FTMS Control Point opcodes
// ---------------------------------------------------------------------------

/// Opcodes sent by the client to the FTMS Control Point (0x2AD9).
class FtmsOpCode {
  FtmsOpCode._();

  static const int requestControl = 0x00;
  static const int reset = 0x01;
  static const int setTargetResistance = 0x04;
  static const int setTargetPower = 0x05;
  static const int startOrResume = 0x07;
  static const int stopOrPause = 0x08;
  static const int setSimulationParameters = 0x11;

  /// Opcode used in response indications.
  static const int responseCode = 0x80;
}

// ---------------------------------------------------------------------------
// FTMS result codes
// ---------------------------------------------------------------------------

/// Result codes returned in Control Point response indications.
enum FtmsResultCode {
  success,
  opcodeNotSupported,
  invalidParameter,
  operationFailed,
  controlNotPermitted,
  unknown,
}

FtmsResultCode _parseResultCode(int raw) {
  switch (raw) {
    case 0x01:
      return FtmsResultCode.success;
    case 0x02:
      return FtmsResultCode.opcodeNotSupported;
    case 0x03:
      return FtmsResultCode.invalidParameter;
    case 0x04:
      return FtmsResultCode.operationFailed;
    case 0x05:
      return FtmsResultCode.controlNotPermitted;
    default:
      return FtmsResultCode.unknown;
  }
}

// ---------------------------------------------------------------------------
// FTMS Machine Status codes (0x2ADA)
// ---------------------------------------------------------------------------

enum FtmsMachineStatus {
  reset,
  stoppedOrPausedByUser,
  stoppedBySafetyKey,
  startedOrResumedByUser,
  targetSpeedChanged,
  targetInclineChanged,
  targetResistanceChanged,
  targetPowerChanged,
  targetHeartRateChanged,
  indoorBikeSimulationParamsChanged,
  wheelCircumferenceChanged,
  spinDownStatus,
  targetCadenceChanged,
  controlPermissionLost,
  unknown,
}

FtmsMachineStatus _parseMachineStatus(int raw) {
  switch (raw) {
    case 0x01:
      return FtmsMachineStatus.reset;
    case 0x02:
      return FtmsMachineStatus.stoppedOrPausedByUser;
    case 0x03:
      return FtmsMachineStatus.stoppedBySafetyKey;
    case 0x04:
      return FtmsMachineStatus.startedOrResumedByUser;
    case 0x05:
      return FtmsMachineStatus.targetSpeedChanged;
    case 0x06:
      return FtmsMachineStatus.targetInclineChanged;
    case 0x07:
      return FtmsMachineStatus.targetResistanceChanged;
    case 0x08:
      return FtmsMachineStatus.targetPowerChanged;
    case 0x09:
      return FtmsMachineStatus.targetHeartRateChanged;
    case 0x12:
      return FtmsMachineStatus.indoorBikeSimulationParamsChanged;
    case 0x13:
      return FtmsMachineStatus.wheelCircumferenceChanged;
    case 0x14:
      return FtmsMachineStatus.spinDownStatus;
    case 0x15:
      return FtmsMachineStatus.targetCadenceChanged;
    case 0xFF:
      return FtmsMachineStatus.controlPermissionLost;
    default:
      return FtmsMachineStatus.unknown;
  }
}

// ---------------------------------------------------------------------------
// Feature flags (from 0x2ACC)
// ---------------------------------------------------------------------------

/// Parsed FTMS Feature characteristic (0x2ACC).
///
/// The characteristic contains two 32-bit bitmasks:
/// - Fitness Machine Features (4 bytes)
/// - Target Setting Features (4 bytes)
class FtmsFeatures {
  const FtmsFeatures({
    required this.machineFeatures,
    required this.targetFeatures,
  });

  final int machineFeatures;
  final int targetFeatures;

  bool get supportsAverageSpeed => machineFeatures & 0x00000001 != 0;
  bool get supportsCadence => machineFeatures & 0x00000002 != 0;
  bool get supportsTotalDistance => machineFeatures & 0x00000004 != 0;
  bool get supportsResistanceLevel => machineFeatures & 0x00000080 != 0;
  bool get supportsPower => machineFeatures & 0x00004000 != 0;
  bool get supportsHeartRate => machineFeatures & 0x00008000 != 0;

  bool get supportsTargetResistance => targetFeatures & 0x00000004 != 0;
  bool get supportsTargetPower => targetFeatures & 0x00000008 != 0;
  bool get supportsSimulationParams => targetFeatures & 0x00002000 != 0;

  @override
  String toString() => 'FtmsFeatures(machine=0x${machineFeatures.toRadixString(16)}, '
      'target=0x${targetFeatures.toRadixString(16)})';
}

// ---------------------------------------------------------------------------
// Control Point response
// ---------------------------------------------------------------------------

/// A parsed response indication from the FTMS Control Point.
class FtmsControlResponse {
  const FtmsControlResponse({
    required this.requestOpCode,
    required this.resultCode,
  });

  final int requestOpCode;
  final FtmsResultCode resultCode;

  bool get isSuccess => resultCode == FtmsResultCode.success;

  @override
  String toString() =>
      'FtmsControlResponse(opcode=0x${requestOpCode.toRadixString(16)}, '
      'result=$resultCode)';
}

// ---------------------------------------------------------------------------
// FtmsControlClient
// ---------------------------------------------------------------------------

/// Controls an FTMS trainer via the FTMS Control Point (0x2AD9).
///
/// Implements the full FTMS connection flow:
/// 1. Subscribe to Control Point indications
/// 2. Subscribe to Fitness Machine Status (0x2ADA) notifications
/// 3. Read Fitness Machine Feature (0x2ACC)
/// 4. Send Request Control (opcode 0x00), wait for success indication
/// 5. Send Start/Resume (opcode 0x07)
class FtmsControlClient {
  FtmsControlClient(this._connection);

  final BleConnection _connection;

  FtmsFeatures? _features;
  StreamSubscription? _controlPointSub;
  StreamSubscription? _statusSub;

  final _responseController =
      StreamController<FtmsControlResponse>.broadcast();
  final _statusController =
      StreamController<FtmsMachineStatus>.broadcast();

  /// Stream of Control Point response indications.
  Stream<FtmsControlResponse> get responses => _responseController.stream;

  /// Stream of Fitness Machine Status changes.
  Stream<FtmsMachineStatus> get statusChanges => _statusController.stream;

  /// The features read from the trainer, available after [initialize].
  FtmsFeatures? get features => _features;

  /// Whether control has been successfully acquired.
  bool get hasControl => _hasControl;
  bool _hasControl = false;

  // ---------------------------------------------------------------------------
  // Initialization — full FTMS connection flow
  // ---------------------------------------------------------------------------

  /// Runs the complete FTMS initialization handshake.
  ///
  /// 1. Subscribe to Control Point indications
  /// 2. Subscribe to Fitness Machine Status notifications
  /// 3. Read Fitness Machine Feature
  /// 4. Request Control
  /// 5. Start/Resume
  ///
  /// Throws if any step fails.
  Future<void> initialize() async {
    _log.info('Initializing FTMS control…');

    // Step 1: Subscribe to Control Point indications.
    _log.fine('Step 1: Subscribing to Control Point indications');
    final cpStream = await _connection.subscribe(
      BleConstants.ftmsService,
      BleConstants.ftmsControlPoint,
    );
    _controlPointSub = cpStream.listen(_onControlPointIndication);

    // Step 2: Subscribe to Fitness Machine Status.
    _log.fine('Step 2: Subscribing to Fitness Machine Status');
    try {
      final statusStream = await _connection.subscribe(
        BleConstants.ftmsService,
        BleConstants.ftmsStatus,
      );
      _statusSub = statusStream.listen(_onMachineStatus);
    } catch (e) {
      _log.warning('FTMS Status characteristic not found — skipping: $e');
    }

    // Step 3: Read Fitness Machine Feature.
    _log.fine('Step 3: Reading Fitness Machine Feature');
    _features = await _readFeatures();
    _log.info('FTMS features: $_features');

    // Step 4: Request Control.
    _log.fine('Step 4: Requesting control');
    final controlResult = await _writeAndWaitResponse(
      FtmsOpCode.requestControl,
      Uint8List.fromList([FtmsOpCode.requestControl]),
    );
    if (!controlResult.isSuccess) {
      throw StateError(
        'FTMS Request Control failed: ${controlResult.resultCode}',
      );
    }
    _hasControl = true;
    _log.info('FTMS control acquired');

    // Step 5: Start/Resume.
    _log.fine('Step 5: Sending Start/Resume');
    final startResult = await _writeAndWaitResponse(
      FtmsOpCode.startOrResume,
      Uint8List.fromList([FtmsOpCode.startOrResume]),
    );
    if (!startResult.isSuccess) {
      _log.warning('FTMS Start/Resume response: ${startResult.resultCode}');
    }

    _log.info('FTMS initialization complete');
  }

  // ---------------------------------------------------------------------------
  // Commands
  // ---------------------------------------------------------------------------

  /// Sets target power in ERG mode.
  ///
  /// [watts] is clamped to 0–4000 W.
  Future<FtmsControlResponse> setTargetPower(int watts) async {
    final clamped = watts.clamp(0, 4000);
    _log.fine('setTargetPower(${clamped}W)');

    final data = ByteData(3);
    data.setUint8(0, FtmsOpCode.setTargetPower);
    data.setInt16(1, clamped, Endian.little);

    return _writeAndWaitResponse(
      FtmsOpCode.setTargetPower,
      data.buffer.asUint8List(),
    );
  }

  /// Sets simulation parameters for SIM mode.
  ///
  /// - [windSpeed]: m/s, resolution 0.001 (SINT16)
  /// - [grade]: %, resolution 0.01 (SINT16)
  /// - [crr]: coefficient, resolution 0.0001 (UINT8)
  /// - [cda]: kg/m², resolution 0.01 (UINT8)
  Future<FtmsControlResponse> setSimulationParameters({
    required double windSpeed,
    required double grade,
    required double crr,
    required double cda,
  }) async {
    _log.fine('setSimulationParameters(wind=$windSpeed, grade=$grade, '
        'crr=$crr, cda=$cda)');

    final data = ByteData(7);
    data.setUint8(0, FtmsOpCode.setSimulationParameters);
    data.setInt16(1, (windSpeed * 1000).round(), Endian.little);
    data.setInt16(3, (grade * 100).round(), Endian.little);
    data.setUint8(5, (crr * 10000).round().clamp(0, 255));
    data.setUint8(6, (cda * 100).round().clamp(0, 255));

    return _writeAndWaitResponse(
      FtmsOpCode.setSimulationParameters,
      data.buffer.asUint8List(),
    );
  }

  /// Sets target resistance level.
  ///
  /// [level]: unitless, resolution 0.1 (UINT8).
  Future<FtmsControlResponse> setTargetResistance(double level) async {
    _log.fine('setTargetResistance($level)');

    final data = ByteData(2);
    data.setUint8(0, FtmsOpCode.setTargetResistance);
    data.setUint8(1, (level * 10).round().clamp(0, 255));

    return _writeAndWaitResponse(
      FtmsOpCode.setTargetResistance,
      data.buffer.asUint8List(),
    );
  }

  /// Sends Stop or Pause (opcode 0x08).
  ///
  /// [pause]: `true` for pause (0x02), `false` for stop (0x01).
  Future<FtmsControlResponse> stopOrPause({bool pause = false}) async {
    _log.fine(pause ? 'Pausing' : 'Stopping');

    final data = Uint8List.fromList([
      FtmsOpCode.stopOrPause,
      pause ? 0x02 : 0x01,
    ]);

    return _writeAndWaitResponse(FtmsOpCode.stopOrPause, data);
  }

  /// Sends Reset (opcode 0x01).
  Future<FtmsControlResponse> reset() async {
    _log.fine('Resetting');
    return _writeAndWaitResponse(
      FtmsOpCode.reset,
      Uint8List.fromList([FtmsOpCode.reset]),
    );
  }

  // ---------------------------------------------------------------------------
  // Feature read
  // ---------------------------------------------------------------------------

  Future<FtmsFeatures> _readFeatures() async {
    try {
      final raw = await _connection.read(
        BleConstants.ftmsService,
        BleConstants.ftmsFeature,
      );

      if (raw.length < 8) {
        _log.warning('FTMS Feature too short (${raw.length} bytes), '
            'using empty features');
        return const FtmsFeatures(machineFeatures: 0, targetFeatures: 0);
      }

      final bytes = ByteData.sublistView(Uint8List.fromList(raw));
      return FtmsFeatures(
        machineFeatures: bytes.getUint32(0, Endian.little),
        targetFeatures: bytes.getUint32(4, Endian.little),
      );
    } catch (e) {
      _log.warning('Failed to read FTMS Feature: $e');
      return const FtmsFeatures(machineFeatures: 0, targetFeatures: 0);
    }
  }

  // ---------------------------------------------------------------------------
  // Write + wait for response indication
  // ---------------------------------------------------------------------------

  /// Writes a command and waits for the matching response indication.
  Future<FtmsControlResponse> _writeAndWaitResponse(
    int expectedOpCode,
    List<int> data, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    // Set up a future that resolves on the first matching response.
    final responseFuture = _responseController.stream
        .where((r) => r.requestOpCode == expectedOpCode)
        .first
        .timeout(timeout, onTimeout: () {
      _log.warning('Timeout waiting for response to opcode '
          '0x${expectedOpCode.toRadixString(16)}');
      return FtmsControlResponse(
        requestOpCode: expectedOpCode,
        resultCode: FtmsResultCode.operationFailed,
      );
    });

    await _connection.write(
      BleConstants.ftmsService,
      BleConstants.ftmsControlPoint,
      data,
    );

    return responseFuture;
  }

  // ---------------------------------------------------------------------------
  // Indication / notification parsers
  // ---------------------------------------------------------------------------

  void _onControlPointIndication(List<int> raw) {
    // Response format: [0x80, RequestOpCode, ResultCode, …optional params]
    if (raw.length < 3) {
      _log.warning('Control Point indication too short (${raw.length} bytes)');
      return;
    }

    if (raw[0] != FtmsOpCode.responseCode) {
      _log.fine('Control Point non-response indication: 0x${raw[0].toRadixString(16)}');
      return;
    }

    final response = FtmsControlResponse(
      requestOpCode: raw[1],
      resultCode: _parseResultCode(raw[2]),
    );

    _log.fine('Control Point response: $response');
    _responseController.add(response);
  }

  void _onMachineStatus(List<int> raw) {
    if (raw.isEmpty) return;

    final status = _parseMachineStatus(raw[0]);
    _log.fine('Machine Status: $status');
    _statusController.add(status);

    if (status == FtmsMachineStatus.controlPermissionLost) {
      _hasControl = false;
      _log.warning('FTMS control permission lost');
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Releases resources. Does NOT disconnect the BLE connection.
  Future<void> dispose() async {
    await _controlPointSub?.cancel();
    _controlPointSub = null;
    await _statusSub?.cancel();
    _statusSub = null;
    await _responseController.close();
    await _statusController.close();
    _hasControl = false;
  }
}
