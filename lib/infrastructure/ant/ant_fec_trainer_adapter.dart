import 'dart:async';

import 'package:logging/logging.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/ports/trainer_port.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../core/events/app_event.dart';
import '../../core/events/event_bus.dart';
import 'ant_constants.dart';
import 'ant_fec_control.dart';
import 'ant_fec_parser.dart';
import 'ant_message.dart';
import 'ant_usb_transport.dart';

final _log = Logger('AntFecTrainerAdapter');

/// Adapts an ANT+ FE-C connection into the domain [TrainerPort] interface.
///
/// Mirrors [FtmsTrainerAdapter] but uses [AntUsbTransport] instead of BLE.
class AntFecTrainerAdapter implements TrainerPort {
  AntFecTrainerAdapter({
    required AntUsbTransport transport,
    required int channelNumber,
    required TrainerDevice device,
    required EventBus eventBus,
  })  : _transport = transport,
        _channelNumber = channelNumber,
        _device = device,
        _eventBus = eventBus;

  final AntUsbTransport _transport;
  final int _channelNumber;
  final TrainerDevice _device;
  final EventBus _eventBus;

  final _parser = AntFecParser();
  final _dataController = StreamController<SensorReading>.broadcast();
  StreamSubscription? _messageSub;

  @override
  Stream<SensorReading> get dataStream => _dataController.stream;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Subscribes to broadcast data on the transport and fires connected events.
  Future<void> initialize() async {
    _log.info('Initializing ANT+ FE-C adapter for ${_device.name}');

    _messageSub = _transport.messageStream.listen(_onMessage);

    _eventBus.fire(TrainerEvent.connected(_device));
    _eventBus.fire(TrainerEvent.controlAcquired(_device.id));

    _log.info('ANT+ FE-C adapter initialized');
  }

  // ---------------------------------------------------------------------------
  // Data parsing
  // ---------------------------------------------------------------------------

  void _onMessage(AntMessage msg) {
    // Only process broadcast data for our channel.
    if (msg.messageId != AntConstants.msgBroadcastData) return;
    if (msg.data.isEmpty || msg.data[0] != _channelNumber) return;

    // The payload is bytes 1–8 of msg.data (channel byte stripped).
    final payload = msg.data.sublist(1);
    if (payload.length < 8) return;

    final pageNumber = _parser.getPageNumber(payload);

    switch (pageNumber) {
      case AntConstants.pageGeneralFe:
        final data = _parser.parseGeneralFe(payload);
        _dataController.add(SensorReading(
          timestamp: DateTime.now(),
          heartRate: data.heartRate != null
              ? HeartRate(data.heartRate!)
              : null,
          speed: data.speed != null ? Speed(data.speed!) : null,
        ));
        break;

      case AntConstants.pageTrainerSpecific:
        final data = _parser.parseTrainerSpecific(payload);
        _dataController.add(SensorReading(
          timestamp: DateTime.now(),
          power: data.instantaneousPower != null
              ? Watts(data.instantaneousPower!.toDouble())
              : null,
          cadence: data.instantaneousCadence != null
              ? Cadence(data.instantaneousCadence!.toDouble())
              : null,
        ));
        break;

      case AntConstants.pageManufacturerInfo:
        final info = _parser.parseManufacturerInfo(payload);
        _log.fine('Manufacturer: ${info.manufacturerId}, '
            'model: ${info.modelNumber}, HW rev: ${info.hardwareRevision}');
        break;

      case AntConstants.pageProductInfo:
        final info = _parser.parseProductInfo(payload);
        _log.fine('SW rev: ${info.softwareRevision}, '
            'serial: ${info.serialNumber}');
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // TrainerPort — control commands
  // ---------------------------------------------------------------------------

  @override
  Future<void> setTargetPower(Watts watts) async {
    final payload = AntFecControl.targetPower(watts.value.round());
    await _transport.sendAcknowledged(_channelNumber, payload);
    _eventBus.fire(TrainerEvent.modeChanged(_device.id, ControlMode.erg));
  }

  @override
  Future<void> setSimulationParams(
    double windSpeed,
    Grade grade,
    double crr,
    double cda,
  ) async {
    final trackPayload = AntFecControl.trackResistance(grade.percent, crr);
    await _transport.sendAcknowledged(_channelNumber, trackPayload);

    final windPayload = AntFecControl.windResistance(windSpeed, crr, cda);
    await _transport.sendAcknowledged(_channelNumber, windPayload);

    _eventBus
        .fire(TrainerEvent.modeChanged(_device.id, ControlMode.simulation));
  }

  @override
  Future<void> setResistance(double percent) async {
    final payload = AntFecControl.basicResistance(percent);
    await _transport.sendAcknowledged(_channelNumber, payload);
    _eventBus
        .fire(TrainerEvent.modeChanged(_device.id, ControlMode.resistance));
  }

  @override
  Future<void> disconnect() async {
    _log.info('Disconnecting ANT+ FE-C adapter');

    await _messageSub?.cancel();
    _messageSub = null;

    try {
      await _transport.closeChannel(_channelNumber);
    } catch (e) {
      _log.warning('Failed to close channel on disconnect: $e');
    }

    await _dataController.close();
    _eventBus.fire(TrainerEvent.disconnected(_device.id));
  }
}
