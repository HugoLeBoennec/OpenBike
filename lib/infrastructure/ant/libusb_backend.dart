import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'ant_usb_transport.dart';
import 'libusb_ffi_bindings.dart';

/// [UsbBackend] implementation backed by libusb 1.0 via `dart:ffi` — see
/// [LibusbBindings] for the bound C functions and docs/release/antplus-usb.md
/// for where the platform binary this dlopens comes from.
///
/// Scoped to the one device family this app talks to (Dynastream/Garmin
/// ANT+ USB sticks, vendor `0x0FCF`): it hardcodes the interface number and
/// bulk endpoint addresses those sticks expose on interface 0 instead of
/// walking libusb's configuration/interface/endpoint descriptor tree, which
/// libusb doesn't need for a single, known device layout.
class LibusbBackend implements UsbBackend {
  LibusbBackend({LibusbBindings? bindings})
      : _libusb = bindings ?? LibusbBindings();

  final LibusbBindings _libusb;

  Pointer<LibusbContext> _ctx = nullptr;
  Pointer<Pointer<LibusbDevice>> _deviceListPtr = nullptr;
  int _deviceCount = 0;
  Pointer<LibusbDeviceHandle> _handle = nullptr;

  static const int _interfaceNumber = 0;
  static const int _endpointIn = 0x81;
  static const int _endpointOut = 0x01;

  @override
  Future<void> init() async {
    final ctxPtrPtr = calloc<Pointer<LibusbContext>>();
    try {
      final result = _libusb.init(ctxPtrPtr);
      if (result != 0) {
        throw StateError('libusb_init failed: error $result');
      }
      _ctx = ctxPtrPtr.value;
    } finally {
      calloc.free(ctxPtrPtr);
    }
  }

  @override
  Future<List<UsbDeviceInfo>> getDeviceList() async {
    _freeDeviceList();

    final listPtrPtr = calloc<Pointer<Pointer<LibusbDevice>>>();
    try {
      final count = _libusb.getDeviceList(_ctx, listPtrPtr);
      if (count < 0) return const [];

      _deviceListPtr = listPtrPtr.value;
      _deviceCount = count;

      final devices = <UsbDeviceInfo>[];
      final descriptor = calloc<LibusbDeviceDescriptor>();
      try {
        for (var i = 0; i < count; i++) {
          if (_libusb.getDeviceDescriptor(_deviceListPtr[i], descriptor) !=
              0) {
            continue;
          }
          devices.add(UsbDeviceInfo(
            vendorId: descriptor.ref.idVendor,
            productId: descriptor.ref.idProduct,
            name: '0x${descriptor.ref.idVendor.toRadixString(16)}:'
                '0x${descriptor.ref.idProduct.toRadixString(16)}',
          ));
        }
      } finally {
        calloc.free(descriptor);
      }
      return devices;
    } finally {
      calloc.free(listPtrPtr);
    }
  }

  @override
  Future<bool> openDevice(UsbDeviceInfo device) async {
    if (_deviceListPtr == nullptr) return false;

    Pointer<LibusbDevice> match = nullptr;
    final descriptor = calloc<LibusbDeviceDescriptor>();
    try {
      for (var i = 0; i < _deviceCount; i++) {
        final candidate = _deviceListPtr[i];
        if (_libusb.getDeviceDescriptor(candidate, descriptor) != 0) {
          continue;
        }
        if (descriptor.ref.idVendor == device.vendorId &&
            descriptor.ref.idProduct == device.productId) {
          match = candidate;
          break;
        }
      }
    } finally {
      calloc.free(descriptor);
    }
    if (match == nullptr) return false;

    final handlePtrPtr = calloc<Pointer<LibusbDeviceHandle>>();
    try {
      if (_libusb.open(match, handlePtrPtr) != 0) return false;
      _handle = handlePtrPtr.value;
    } finally {
      calloc.free(handlePtrPtr);
    }

    // The open handle stays valid independently of the enumeration list.
    _freeDeviceList();

    _libusb.setConfiguration(_handle, 1);
    if (_libusb.claimInterface(_handle, _interfaceNumber) != 0) {
      _libusb.close(_handle);
      _handle = nullptr;
      return false;
    }
    return true;
  }

  @override
  Future<Uint8List> bulkTransferIn(int maxLength, {int timeout = 50}) async {
    if (_handle == nullptr) return Uint8List(0);

    final buffer = calloc<Uint8>(maxLength);
    final actualLength = calloc<Int32>();
    try {
      // A non-zero result (commonly LIBUSB_ERROR_TIMEOUT) just means no
      // data arrived within the poll window — expected at a 20 ms poll
      // rate, same contract as every other UsbBackend implementation.
      final result = _libusb.bulkTransfer(
          _handle, _endpointIn, buffer, maxLength, actualLength, timeout);
      if (result != 0) return Uint8List(0);
      return Uint8List.fromList(buffer.asTypedList(actualLength.value));
    } finally {
      calloc.free(buffer);
      calloc.free(actualLength);
    }
  }

  @override
  Future<void> bulkTransferOut(Uint8List data, {int timeout = 1000}) async {
    if (_handle == nullptr) {
      throw StateError('USB device not open');
    }

    final buffer = calloc<Uint8>(data.length);
    final actualLength = calloc<Int32>();
    try {
      buffer.asTypedList(data.length).setAll(0, data);
      final result = _libusb.bulkTransfer(
          _handle, _endpointOut, buffer, data.length, actualLength, timeout);
      if (result != 0) {
        throw StateError('libusb_bulk_transfer (OUT) failed: error $result');
      }
    } finally {
      calloc.free(buffer);
      calloc.free(actualLength);
    }
  }

  @override
  Future<void> dispose() async {
    if (_handle != nullptr) {
      _libusb.releaseInterface(_handle, _interfaceNumber);
      _libusb.close(_handle);
      _handle = nullptr;
    }
    _freeDeviceList();
    if (_ctx != nullptr) {
      _libusb.exit(_ctx);
      _ctx = nullptr;
    }
  }

  void _freeDeviceList() {
    if (_deviceListPtr == nullptr) return;
    _libusb.freeDeviceList(_deviceListPtr, 1);
    _deviceListPtr = nullptr;
    _deviceCount = 0;
  }
}
