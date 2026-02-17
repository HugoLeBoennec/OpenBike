import 'dart:async';

import 'package:logging/logging.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/ports/trainer_port.dart';
import '../../core/events/event_bus.dart';
import '../../plugins/plugin_interfaces.dart';
import '../../plugins/plugin_manifest.dart';
import 'ant_constants.dart';
import 'ant_fec_trainer_adapter.dart';

import 'ant_usb_transport.dart';

final _log = Logger('AntDevicePlugin');

/// Plugin that drives ANT+ FE-C trainers over a USB dongle.
///
/// Mirrors [FtmsDevicePlugin] but uses [AntUsbTransport] instead of BLE.
class AntDevicePlugin implements DevicePlugin {
  AntDevicePlugin({
    required AntUsbTransport transport,
    required EventBus eventBus,
  })  : _transport = transport,
        _eventBus = eventBus;

  final AntUsbTransport _transport;
  final EventBus _eventBus;

  @override
  PluginManifest get manifest => const PluginManifest(
        id: 'openbike.ant_fec',
        name: 'ANT+ FE-C Trainer',
        version: '0.1.0',
        type: PluginType.device,
        author: 'OpenBike',
        description: 'ANT+ FE-C indoor bike trainer support via USB dongle.',
        capabilities: ['erg', 'simulation', 'resistance'],
      );

  @override
  bool canHandle(TrainerDevice device) =>
      device.protocol == DeviceProtocol.antFec;

  @override
  Future<List<TrainerDevice>> scan(Duration timeout) async {
    final devices = <String, TrainerDevice>{};

    try {
      // Open the dongle if not already connected.
      if (_transport.state != AntTransportState.connected) {
        await _transport.findAndOpenDongle();
      }

      // Initialize a wildcard channel (deviceNumber=0) to receive all FE-C
      // broadcasts on the network.
      await _transport.initializeChannel(
        channelNumber: 0,
        deviceNumber: 0,
        deviceType: AntConstants.fecDeviceType,
        transmissionType: 0,
      );

      // Listen for broadcast data to discover trainers.
      final sub = _transport.messageStream.listen((msg) {
        if (msg.messageId != AntConstants.msgBroadcastData) return;
        if (msg.data.length < 9) return;

        // Channel number is byte 0, payload bytes 1-8.
        final channelByte = msg.data[0];
        if (channelByte != 0) return;

        // Use a simple device ID derived from the broadcast source.
        // In a full implementation we'd request the channel ID to get the
        // actual device number. For now, use page data to identify.
        const deviceId = 'ant_fec_0';
        if (!devices.containsKey(deviceId)) {
          devices[deviceId] = TrainerDevice(
            id: deviceId,
            name: 'ANT+ Trainer',
            protocol: DeviceProtocol.antFec,
            isControllable: true,
            supportedModes: [
              ControlMode.erg,
              ControlMode.simulation,
              ControlMode.resistance,
            ],
          );
          _log.info('Discovered ANT+ FE-C trainer: $deviceId');
        }
      });

      // Wait for the scan duration.
      await Future<void>.delayed(timeout);
      await sub.cancel();

      // Close the wildcard channel.
      try {
        await _transport.closeChannel(0);
      } catch (e) {
        _log.warning('Failed to close scan channel: $e');
      }
    } catch (e) {
      _log.warning('ANT+ scan failed: $e');
    }

    _log.info('Scan found ${devices.length} ANT+ FE-C device(s)');
    return devices.values.toList();
  }

  @override
  Future<TrainerPort> connect(TrainerDevice device) async {
    _log.info('Connecting to ANT+ FE-C device ${device.name} (${device.id})');

    // Open the dongle if not already connected.
    if (_transport.state != AntTransportState.connected) {
      await _transport.findAndOpenDongle();
    }

    // Initialize a channel locked to the device.
    const channelNumber = 0;
    await _transport.initializeChannel(
      channelNumber: channelNumber,
      deviceNumber: 0, // Accept any device number for now.
      deviceType: AntConstants.fecDeviceType,
      transmissionType: 0,
    );

    final adapter = AntFecTrainerAdapter(
      transport: _transport,
      channelNumber: channelNumber,
      device: device,
      eventBus: _eventBus,
    );

    await adapter.initialize();
    return adapter;
  }
}
