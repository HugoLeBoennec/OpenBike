import 'dart:async';
import 'dart:typed_data';

import 'package:logging/logging.dart';

import '../ble_connection.dart';
import '../ble_constants.dart';

// ---------------------------------------------------------------------------
// Trainer capability ranges (from 0x2AD8 / 0x2AD6)
// ---------------------------------------------------------------------------

/// Supported power range parsed from characteristic 0x2AD8.
///
/// Format: SINT16 min (W), SINT16 max (W), UINT16 increment (W) — LE.
class PowerRange {
  const PowerRange({
    required this.minWatts,
    required this.maxWatts,
    required this.incrementWatts,
  });

  final int minWatts;
  final int maxWatts;
  final int incrementWatts;

  static const defaultRange =
      PowerRange(minWatts: 0, maxWatts: 4000, incrementWatts: 1);

  /// Parses 6 raw bytes from characteristic 0x2AD8.
  static PowerRange fromBytes(List<int> raw) {
    if (raw.length < 6) return defaultRange;
    final bd = ByteData.sublistView(Uint8List.fromList(raw));
    return PowerRange(
      minWatts: bd.getInt16(0, Endian.little),
      maxWatts: bd.getInt16(2, Endian.little),
      incrementWatts: bd.getUint16(4, Endian.little),
    );
  }

  int clamp(int watts) => watts.clamp(minWatts, maxWatts);

  @override
  String toString() =>
      'PowerRange($minWatts–$maxWatts W, step $incrementWatts W)';
}

/// Supported resistance level range parsed from characteristic 0x2AD6.
///
/// Format: SINT16 min × 0.1, SINT16 max × 0.1, UINT16 inc × 0.1 — LE.
class ResistanceLevelRange {
  const ResistanceLevelRange({
    required this.min,
    required this.max,
    required this.increment,
  });

  final double min;
  final double max;
  final double increment;

  static const defaultRange =
      ResistanceLevelRange(min: 0, max: 25.5, increment: 0.1);

  /// Parses 6 raw bytes from characteristic 0x2AD6.
  static ResistanceLevelRange fromBytes(List<int> raw) {
    if (raw.length < 6) return defaultRange;
    final bd = ByteData.sublistView(Uint8List.fromList(raw));
    return ResistanceLevelRange(
      min: bd.getInt16(0, Endian.little) * 0.1,
      max: bd.getInt16(2, Endian.little) * 0.1,
      increment: bd.getUint16(4, Endian.little) * 0.1,
    );
  }

  double clamp(double level) => level.clamp(min, max);

  @override
  String toString() =>
      'ResistanceLevelRange($min–$max, step $increment)';
}

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
  bool get supportsSpinDown => targetFeatures & 0x00004000 != 0;

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
  PowerRange _powerRange = PowerRange.defaultRange;
  ResistanceLevelRange _resistanceRange = ResistanceLevelRange.defaultRange;

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

  /// Supported power range, read from 0x2AD8 during [initialize].
  PowerRange get powerRange => _powerRange;

  /// Supported resistance level range, read from 0x2AD6 during [initialize].
  ResistanceLevelRange get resistanceRange => _resistanceRange;

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
    _log.info('[BLE-DEBUG] Initializing FTMS control…');

    // Step 1: Subscribe to Control Point indications.
    _log.info('[BLE-DEBUG] Step 1: Subscribing to Control Point indications');
    final cpStream = await _connection.subscribe(
      BleConstants.ftmsService,
      BleConstants.ftmsControlPoint,
    );
    _controlPointSub = cpStream.listen(_onControlPointIndication);
    _log.info('[BLE-DEBUG] Step 1 OK — Control Point subscribed');

    // Step 2: Subscribe to Fitness Machine Status.
    _log.info('[BLE-DEBUG] Step 2: Subscribing to Fitness Machine Status');
    try {
      final statusStream = await _connection.subscribe(
        BleConstants.ftmsService,
        BleConstants.ftmsStatus,
      );
      _statusSub = statusStream.listen(_onMachineStatus);
      _log.info('[BLE-DEBUG] Step 2 OK — Machine Status subscribed');
    } catch (e) {
      _log.warning('[BLE-DEBUG] Step 2 SKIP — Status char not found: $e');
    }

    // Step 3: Read Fitness Machine Feature + capability ranges.
    _log.info('[BLE-DEBUG] Step 3: Reading Fitness Machine Feature');
    _features = await _readFeatures();
    _log.info('[BLE-DEBUG] Step 3 OK — features: $_features');

    _powerRange = await _readPowerRange();
    _log.info('[BLE-DEBUG] Step 3b OK — $_powerRange');

    _resistanceRange = await _readResistanceRange();
    _log.info('[BLE-DEBUG] Step 3c OK — $_resistanceRange');

    // Step 4: Request Control.
    _log.info('[BLE-DEBUG] Step 4: Requesting control');
    final controlResult = await _writeAndWaitResponse(
      FtmsOpCode.requestControl,
      Uint8List.fromList([FtmsOpCode.requestControl]),
    );
    if (!controlResult.isSuccess) {
      _log.severe('[BLE-DEBUG] Step 4 FAILED — ${controlResult.resultCode}');
      throw StateError(
        'FTMS Request Control failed: ${controlResult.resultCode}',
      );
    }
    _hasControl = true;
    _log.info('[BLE-DEBUG] Step 4 OK — control acquired');

    // Step 5: Start/Resume.
    _log.info('[BLE-DEBUG] Step 5: Sending Start/Resume');
    final startResult = await _writeAndWaitResponse(
      FtmsOpCode.startOrResume,
      Uint8List.fromList([FtmsOpCode.startOrResume]),
    );
    if (!startResult.isSuccess) {
      _log.warning('[BLE-DEBUG] Step 5 WARN — ${startResult.resultCode}');
    } else {
      _log.info('[BLE-DEBUG] Step 5 OK — trainer started');
    }

    _log.info('[BLE-DEBUG] FTMS initialization complete');
  }

  // ---------------------------------------------------------------------------
  // Commands
  // ---------------------------------------------------------------------------

  /// Sets target power in ERG mode.
  ///
  /// Skipped with a warning if 0x2ACC reports power targeting is unsupported.
  /// [watts] is clamped to the range from 0x2AD8.
  Future<FtmsControlResponse> setTargetPower(int watts) async {
    if (_features != null && !_features!.supportsTargetPower) {
      _log.warning('setTargetPower: trainer does not support ERG — skipping');
      return FtmsControlResponse(
        requestOpCode: FtmsOpCode.setTargetPower,
        resultCode: FtmsResultCode.opcodeNotSupported,
      );
    }
    final clamped = _powerRange.clamp(watts);
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
  /// Skipped with a warning if 0x2ACC reports simulation is unsupported.
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
    if (_features != null && !_features!.supportsSimulationParams) {
      _log.warning(
          'setSimulationParameters: trainer does not support SIM — skipping');
      return FtmsControlResponse(
        requestOpCode: FtmsOpCode.setSimulationParameters,
        resultCode: FtmsResultCode.opcodeNotSupported,
      );
    }
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
  /// Skipped with a warning if 0x2ACC reports resistance targeting is
  /// unsupported. [level] is clamped to the range from 0x2AD6.
  /// Resolution 0.1 → byte value = level × 10 (UINT8).
  Future<FtmsControlResponse> setTargetResistance(double level) async {
    if (_features != null && !_features!.supportsTargetResistance) {
      _log.warning(
          'setTargetResistance: trainer does not support resistance — skipping');
      return FtmsControlResponse(
        requestOpCode: FtmsOpCode.setTargetResistance,
        resultCode: FtmsResultCode.opcodeNotSupported,
      );
    }
    final clamped = _resistanceRange.clamp(level);
    _log.fine('setTargetResistance($clamped)');

    final data = ByteData(2);
    data.setUint8(0, FtmsOpCode.setTargetResistance);
    data.setUint8(1, (clamped * 10).round().clamp(0, 255));

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

  Future<PowerRange> _readPowerRange() async {
    try {
      final raw = await _connection.read(
        BleConstants.ftmsService,
        BleConstants.ftmsSupportedPowerRange,
      );
      return PowerRange.fromBytes(raw);
    } catch (e) {
      _log.warning('Failed to read Supported Power Range (0x2AD8): $e');
      return PowerRange.defaultRange;
    }
  }

  Future<ResistanceLevelRange> _readResistanceRange() async {
    try {
      final raw = await _connection.read(
        BleConstants.ftmsService,
        BleConstants.ftmsSupportedResistanceLevelRange,
      );
      return ResistanceLevelRange.fromBytes(raw);
    } catch (e) {
      _log.warning(
          'Failed to read Supported Resistance Level Range (0x2AD6): $e');
      return ResistanceLevelRange.defaultRange;
    }
  }

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
  ///
  /// Retries once on timeout (3 s per attempt). Returns an
  /// [FtmsResultCode.operationFailed] response after both attempts time out.
  Future<FtmsControlResponse> _writeAndWaitResponse(
    int expectedOpCode,
    List<int> data, {
    int maxAttempts = 2,
  }) async {
    const timeout = Duration(seconds: 3);
    final hex = '0x${expectedOpCode.toRadixString(16).padLeft(2, '0')}';

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      // Set up the response future *before* writing to avoid a race.
      final responseFuture = _responseController.stream
          .where((r) => r.requestOpCode == expectedOpCode)
          .first
          .timeout(timeout);

      _log.fine('→ opcode $hex attempt $attempt/$maxAttempts '
          '[${data.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(', ')}]');

      await _connection.write(
        BleConstants.ftmsService,
        BleConstants.ftmsControlPoint,
        data,
      );

      try {
        return await responseFuture;
      } on TimeoutException {
        if (attempt == maxAttempts) {
          _log.warning('commandTimeout: no response to $hex '
              'after $maxAttempts attempt(s)');
          return FtmsControlResponse(
            requestOpCode: expectedOpCode,
            resultCode: FtmsResultCode.operationFailed,
          );
        }
        _log.warning('Attempt $attempt timed out for $hex — retrying…');
      }
    }

    // Unreachable, but Dart requires a return statement.
    return FtmsControlResponse(
      requestOpCode: expectedOpCode,
      resultCode: FtmsResultCode.operationFailed,
    );
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
