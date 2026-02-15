import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';

import '../../core/domain/entities/sensor_reading.dart';
import '../../core/domain/ports/sensor_port.dart';
import '../../core/domain/value_objects/value_objects.dart';
import 'ble_connection.dart';
import 'ble_constants.dart';

final _log = Logger('BleSensorReader');

/// Reads CPS, CSC, and HRS BLE characteristics via a [BleConnection] and
/// emits unified [SensorReading]s.
///
/// Implements [SensorPort].
class BleSensorReader implements SensorPort {
  BleSensorReader(this._connection);

  final BleConnection _connection;
  final _dataController = StreamController<SensorReading>.broadcast();
  final List<StreamSubscription> _subscriptions = [];

  @override
  Stream<SensorReading> get dataStream => _dataController.stream;

  /// Subscribes to all available sensor characteristics on the connection.
  Future<void> start() async {
    _log.info('Starting sensor reader');

    await _trySubscribe(
      BleConstants.cpsService,
      BleConstants.cpsMeasurement,
      _parseCpsMeasurement,
    );
    await _trySubscribe(
      BleConstants.cscService,
      BleConstants.cscMeasurement,
      _parseCscMeasurement,
    );
    await _trySubscribe(
      BleConstants.hrsService,
      BleConstants.hrsMeasurement,
      _parseHrsMeasurement,
    );
  }

  Future<void> _trySubscribe(
    Guid serviceUuid,
    Guid charUuid,
    void Function(List<int>) parser,
  ) async {
    final char = _connection.findCharacteristic(serviceUuid, charUuid);
    if (char == null) {
      _log.fine('Characteristic $charUuid not found — skipping');
      return;
    }

    try {
      final stream = await _connection.subscribe(serviceUuid, charUuid);
      _subscriptions.add(stream.listen(parser));
      _log.info('Subscribed to $charUuid');
    } catch (e) {
      _log.warning('Failed to subscribe to $charUuid: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Parsers
  // ---------------------------------------------------------------------------

  void _parseCpsMeasurement(List<int> data) {
    if (data.length < 4) return;
    final power = data[2] | (data[3] << 8);
    _dataController.add(SensorReading(
      timestamp: DateTime.now(),
      power: Watts(power.toDouble()),
    ));
  }

  void _parseCscMeasurement(List<int> data) {
    if (data.isEmpty) return;
    // CSC Measurement flags byte 0.  Bit 1 = Crank Revolution Data present.
    final flags = data[0];
    if (flags & 0x02 != 0 && data.length >= 5) {
      // Cumulative crank revolutions (uint16) at offset 1,
      // Last crank event time (uint16, 1/1024 s) at offset 3.
      // For now we emit raw crank RPM approximation in next iteration.
      _log.finer('CSC crank data received (${data.length} bytes)');
    }
  }

  void _parseHrsMeasurement(List<int> data) {
    if (data.length < 2) return;
    final flags = data[0];
    final hr = (flags & 0x01) == 0
        ? data[1]
        : (data[1] | (data[2] << 8));
    _dataController.add(SensorReading(
      timestamp: DateTime.now(),
      heartRate: HeartRate(hr),
    ));
  }

  // ---------------------------------------------------------------------------
  // SensorPort — disconnect
  // ---------------------------------------------------------------------------

  @override
  Future<void> disconnect() async {
    _log.info('Sensor reader disconnecting');
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    await _dataController.close();
  }
}
