import 'dart:async';
import 'dart:typed_data';

import 'package:logging/logging.dart';

import '../../core/domain/entities/sensor_reading.dart';
import '../../core/domain/ports/trainer_port.dart';
import '../../core/domain/value_objects/value_objects.dart';
import 'ble_connection.dart';
import 'ble_constants.dart';

final _log = Logger('FtmsClient');

/// FTMS (Fitness Machine Service) BLE client.
///
/// Implements [TrainerPort] on top of a [BleConnection].
class FtmsClient implements TrainerPort {
  FtmsClient(this._connection);

  final BleConnection _connection;
  final _dataController = StreamController<SensorReading>.broadcast();
  StreamSubscription? _dataSub;

  @override
  Stream<SensorReading> get dataStream => _dataController.stream;

  /// Subscribes to Indoor Bike Data notifications and starts parsing.
  Future<void> start() async {
    _log.info('Starting FTMS data stream');
    final stream = await _connection.subscribe(
      BleConstants.ftmsService,
      BleConstants.ftmsIndoorBikeData,
    );

    _dataSub = stream.listen(
      _parseIndoorBikeData,
      onError: (Object e) => _log.warning('Indoor bike data error: $e'),
    );
  }

  // ---------------------------------------------------------------------------
  // TrainerPort — control
  // ---------------------------------------------------------------------------

  @override
  Future<void> setTargetPower(Watts watts) async {
    final power = watts.value.round().clamp(0, 4000);
    _log.fine('setTargetPower(${power}W)');
    // FTMS op code 0x05 = Set Target Power
    final data = ByteData(3);
    data.setUint8(0, 0x05);
    data.setInt16(1, power, Endian.little);
    await _connection.write(
      BleConstants.ftmsService,
      BleConstants.ftmsControlPoint,
      data.buffer.asUint8List(),
    );
  }

  @override
  Future<void> setSimulationParams(
    double windSpeed,
    Grade grade,
    double crr,
    double cda,
  ) async {
    _log.fine('setSimulationParams(wind=$windSpeed, grade=${grade.percent}, '
        'crr=$crr, cda=$cda)');
    // FTMS op code 0x11 = Set Indoor Bike Simulation Parameters
    final data = ByteData(7);
    data.setUint8(0, 0x11);
    data.setInt16(1, (windSpeed * 1000).round(), Endian.little);
    data.setInt16(3, (grade.percent * 100).round(), Endian.little);
    data.setUint8(5, (crr * 10000).round());
    data.setUint8(6, (cda * 100).round());
    await _connection.write(
      BleConstants.ftmsService,
      BleConstants.ftmsControlPoint,
      data.buffer.asUint8List(),
    );
  }

  @override
  Future<void> setResistance(double percent) async {
    _log.fine('setResistance($percent%)');
    // FTMS op code 0x04 = Set Target Resistance Level
    final data = ByteData(3);
    data.setUint8(0, 0x04);
    data.setInt16(1, (percent * 10).round(), Endian.little);
    await _connection.write(
      BleConstants.ftmsService,
      BleConstants.ftmsControlPoint,
      data.buffer.asUint8List(),
    );
  }

  @override
  Future<void> disconnect() async {
    _log.info('FtmsClient disconnecting');
    await _dataSub?.cancel();
    _dataSub = null;
    await _dataController.close();
  }

  // ---------------------------------------------------------------------------
  // Indoor Bike Data parser
  // ---------------------------------------------------------------------------

  void _parseIndoorBikeData(List<int> raw) {
    if (raw.length < 2) return;

    final flags = raw[0] | (raw[1] << 8);
    var offset = 2;

    Watts? power;
    Cadence? cadence;
    Speed? speed;
    HeartRate? heartRate;

    // Bit 0: More Data (0 = Instantaneous Speed present)
    if (flags & 0x01 == 0 && offset + 2 <= raw.length) {
      final rawSpeed = raw[offset] | (raw[offset + 1] << 8);
      speed = Speed.fromFtmsRaw(rawSpeed);
      offset += 2;
    }

    // Bit 1: Average Speed
    if (flags & 0x02 != 0) offset += 2;

    // Bit 2: Instantaneous Cadence
    if (flags & 0x04 != 0 && offset + 2 <= raw.length) {
      final rawCadence = raw[offset] | (raw[offset + 1] << 8);
      cadence = Cadence.fromFtmsRaw(rawCadence);
      offset += 2;
    }

    // Bit 3: Average Cadence
    if (flags & 0x08 != 0) offset += 2;

    // Bit 4: Total Distance — 3 bytes
    if (flags & 0x10 != 0) offset += 3;

    // Bit 5: Resistance Level
    if (flags & 0x20 != 0) offset += 2;

    // Bit 6: Instantaneous Power
    if (flags & 0x40 != 0 && offset + 2 <= raw.length) {
      final rawPower = raw[offset] | (raw[offset + 1] << 8);
      power = Watts.fromFtmsRaw(rawPower);
      offset += 2;
    }

    // Bit 7: Average Power
    if (flags & 0x80 != 0) offset += 2;

    // Bit 8: Expended Energy — 5 bytes
    if (flags & 0x100 != 0) offset += 5;

    // Bit 9: Heart Rate
    if (flags & 0x200 != 0 && offset + 1 <= raw.length) {
      heartRate = HeartRate(raw[offset]);
      offset += 1;
    }

    _dataController.add(SensorReading(
      timestamp: DateTime.now(),
      power: power,
      cadence: cadence,
      speed: speed,
      heartRate: heartRate,
    ));
  }
}
