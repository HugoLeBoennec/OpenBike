import 'dart:async';
import 'dart:typed_data';

import 'package:logging/logging.dart';

import 'ant_constants.dart';
import 'ant_message.dart';

final _log = Logger('AntUsbTransport');

/// High-level state of the ANT+ USB transport.
enum AntTransportState { disconnected, connecting, connected, error }

// ---------------------------------------------------------------------------
// USB backend abstraction
// ---------------------------------------------------------------------------

/// Represents a discovered USB device.
class UsbDeviceInfo {
  const UsbDeviceInfo({
    required this.vendorId,
    required this.productId,
    required this.name,
  });

  final int vendorId;
  final int productId;
  final String name;
}

/// Abstract USB backend — isolates platform-specific USB I/O so the rest of
/// the ANT+ stack compiles without any USB package dependency.
///
/// Implement this interface using `dart:ffi` + libusb, `quick_usb`, or any
/// other raw USB library and pass it into [AntUsbTransport].
abstract class UsbBackend {
  /// Initialize the USB subsystem.
  Future<void> init();

  /// List all connected USB devices.
  Future<List<UsbDeviceInfo>> getDeviceList();

  /// Open a device, claim its first interface, and prepare for bulk I/O.
  /// Returns `true` on success.
  Future<bool> openDevice(UsbDeviceInfo device);

  /// Read up to [maxLength] bytes from the IN endpoint.
  /// Returns an empty list on timeout / no data.
  Future<Uint8List> bulkTransferIn(int maxLength, {int timeout = 50});

  /// Write [data] to the OUT endpoint.
  Future<void> bulkTransferOut(Uint8List data, {int timeout = 1000});

  /// Release the interface, close the device, and tear down.
  Future<void> dispose();
}

// ---------------------------------------------------------------------------
// AntUsbTransport
// ---------------------------------------------------------------------------

/// Manages communication with an ANT+ USB dongle.
///
/// Handles device discovery, bulk transfers, message framing, and the
/// ANT+ channel initialization sequence.
///
/// Requires a [UsbBackend] implementation to perform actual USB I/O.
class AntUsbTransport {
  AntUsbTransport({required UsbBackend backend}) : _backend = backend;

  final UsbBackend _backend;

  AntTransportState _state = AntTransportState.disconnected;
  final _stateController = StreamController<AntTransportState>.broadcast();
  final _messageController = StreamController<AntMessage>.broadcast();

  Timer? _readTimer;
  bool _isConnected = false;

  /// Stream of transport state changes.
  Stream<AntTransportState> get stateStream => _stateController.stream;

  /// Current transport state.
  AntTransportState get state => _state;

  /// Stream of parsed ANT+ messages received from the dongle.
  Stream<AntMessage> get messageStream => _messageController.stream;

  void _setState(AntTransportState newState) {
    _state = newState;
    _stateController.add(newState);
    _log.fine('State → $newState');
  }

  // ---------------------------------------------------------------------------
  // Dongle discovery + open
  // ---------------------------------------------------------------------------

  /// Scans for a Dynastream ANT+ USB dongle, opens it, and starts the read
  /// loop. Throws [StateError] if no dongle is found.
  Future<void> findAndOpenDongle() async {
    _setState(AntTransportState.connecting);

    try {
      await _backend.init();

      final devices = await _backend.getDeviceList();
      _log.info('Found ${devices.length} USB device(s)');

      UsbDeviceInfo? dongle;
      for (final d in devices) {
        if (d.vendorId == AntConstants.vendorId &&
            AntConstants.productIds.contains(d.productId)) {
          dongle = d;
          break;
        }
      }

      if (dongle == null) {
        _setState(AntTransportState.error);
        throw StateError('No ANT+ USB dongle found');
      }

      _log.info('Found ANT+ dongle: '
          'vendor=0x${dongle.vendorId.toRadixString(16)}, '
          'product=0x${dongle.productId.toRadixString(16)}');

      final opened = await _backend.openDevice(dongle);
      if (!opened) {
        _setState(AntTransportState.error);
        throw StateError('Failed to open ANT+ dongle');
      }

      _isConnected = true;
      _startReadLoop();
      _setState(AntTransportState.connected);
      _log.info('ANT+ dongle opened and read loop started');
    } catch (e) {
      if (_state != AntTransportState.error) {
        _setState(AntTransportState.error);
      }
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Read loop
  // ---------------------------------------------------------------------------

  void _startReadLoop() {
    _readTimer = Timer.periodic(const Duration(milliseconds: 20), (_) async {
      try {
        final data = await _backend.bulkTransferIn(64, timeout: 50);
        if (data.isEmpty) return;

        final messages = AntMessage.parseAll(data.toList());
        for (final msg in messages) {
          _messageController.add(msg);
        }
      } catch (_) {
        // Timeouts and empty reads are expected.
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Send
  // ---------------------------------------------------------------------------

  /// Sends a raw ANT+ message over USB bulk transfer OUT.
  Future<void> send(AntMessage message) async {
    if (!_isConnected) {
      throw StateError('ANT+ dongle not connected');
    }

    final bytes = message.toBytes();
    await _backend.bulkTransferOut(
      Uint8List.fromList(bytes),
      timeout: AntConstants.usbTransferTimeout,
    );
  }

  // ---------------------------------------------------------------------------
  // Channel initialization
  // ---------------------------------------------------------------------------

  /// Performs the full 7-step ANT+ channel initialization sequence:
  /// reset → set network key → assign channel → set channel ID →
  /// set period → set RF frequency → open channel.
  Future<void> initializeChannel({
    int channelNumber = 0,
    int deviceNumber = 0,
    int deviceType = AntConstants.fecDeviceType,
    int transmissionType = 0,
  }) async {
    _log.info('Initializing ANT+ channel $channelNumber '
        '(device=$deviceNumber, type=$deviceType)');

    // 1. Reset system
    await send(AntMessage(messageId: AntConstants.msgResetSystem, data: [0x00]));
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Drain the startup message
    await _waitForResponse(AntConstants.msgStartup);

    // 2. Set network key (network 0)
    await send(AntMessage(
      messageId: AntConstants.msgSetNetworkKey,
      data: [0x00, ...AntConstants.antPlusNetworkKey],
    ));
    await _waitForResponse(AntConstants.msgChannelResponse);

    // 3. Assign channel (receive, network 0)
    await send(AntMessage(
      messageId: AntConstants.msgAssignChannel,
      data: [channelNumber, AntConstants.channelTypeReceive, 0x00],
    ));
    await _waitForResponse(AntConstants.msgChannelResponse);

    // 4. Set channel ID
    await send(AntMessage(
      messageId: AntConstants.msgSetChannelId,
      data: [
        channelNumber,
        deviceNumber & 0xFF,
        (deviceNumber >> 8) & 0xFF,
        deviceType,
        transmissionType,
      ],
    ));
    await _waitForResponse(AntConstants.msgChannelResponse);

    // 5. Set channel period (little-endian)
    await send(AntMessage(
      messageId: AntConstants.msgSetChannelPeriod,
      data: [
        channelNumber,
        AntConstants.fecChannelPeriod & 0xFF,
        (AntConstants.fecChannelPeriod >> 8) & 0xFF,
      ],
    ));
    await _waitForResponse(AntConstants.msgChannelResponse);

    // 6. Set RF frequency
    await send(AntMessage(
      messageId: AntConstants.msgSetRfFrequency,
      data: [channelNumber, AntConstants.fecRfFrequency],
    ));
    await _waitForResponse(AntConstants.msgChannelResponse);

    // 7. Open channel
    await send(AntMessage(
      messageId: AntConstants.msgOpenChannel,
      data: [channelNumber],
    ));
    await _waitForResponse(AntConstants.msgChannelResponse);

    _log.info('ANT+ channel $channelNumber initialized');
  }

  /// Closes an ANT+ channel.
  Future<void> closeChannel(int channelNumber) async {
    _log.info('Closing ANT+ channel $channelNumber');
    await send(AntMessage(
      messageId: AntConstants.msgCloseChannel,
      data: [channelNumber],
    ));
    await _waitForResponse(AntConstants.msgChannelResponse);
  }

  /// Sends an acknowledged data message on the given channel.
  Future<void> sendAcknowledged(int channelNumber, List<int> payload) async {
    await send(AntMessage(
      messageId: AntConstants.msgAcknowledgedData,
      data: [channelNumber, ...payload],
    ));
  }

  // ---------------------------------------------------------------------------
  // Response waiting
  // ---------------------------------------------------------------------------

  Future<AntMessage> _waitForResponse(
    int expectedMsgId, {
    Duration timeout = const Duration(seconds: 2),
  }) {
    return messageStream
        .where((msg) => msg.messageId == expectedMsgId)
        .first
        .timeout(timeout, onTimeout: () {
      throw TimeoutException(
        'Timed out waiting for ANT+ response 0x${expectedMsgId.toRadixString(16)}',
        timeout,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Releases USB resources and closes all streams.
  Future<void> dispose() async {
    _readTimer?.cancel();
    _readTimer = null;

    if (_isConnected) {
      try {
        await _backend.dispose();
      } catch (e) {
        _log.warning('Error releasing USB device: $e');
      }
    }

    _isConnected = false;
    _setState(AntTransportState.disconnected);
    await _messageController.close();
    await _stateController.close();
  }
}
