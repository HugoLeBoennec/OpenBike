import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/infrastructure/ant/ant_usb_transport.dart';
import 'package:open_bike/infrastructure/ant/libusb_backend.dart';
import 'package:open_bike/infrastructure/ant/libusb_ffi_bindings.dart';

/// A fake libusb "native" layer: pure Dart closures that behave like the
/// real C functions closely enough to exercise [LibusbBackend]'s pointer
/// handling (array indexing, struct reads/writes, buffer copies) without a
/// real libusb binary. Devices are identified by fabricated
/// `Pointer<LibusbDevice>` addresses; [getDeviceDescriptor] resolves them
/// back to vendor/product IDs from [devices].
class _FakeLibusb {
  _FakeLibusb(this.devices);

  final List<({int vendorId, int productId})> devices;

  final List<int> openCalls = [];
  final List<int> claimInterfaceCalls = [];
  bool closed = false;
  bool released = false;
  bool exited = false;
  Uint8List? lastBulkOut;
  Uint8List bulkInResponse = Uint8List(0);
  int bulkInResult = 0;
  int openResult = 0;
  int claimResult = 0;

  Pointer<Pointer<LibusbDevice>>? _deviceListPtr;

  int _deviceIndexOf(Pointer<LibusbDevice> device) => device.address - 1;

  late final bindings = LibusbBindings.raw(
    init: (ctxPtrPtr) {
      ctxPtrPtr.value = Pointer.fromAddress(1);
      return 0;
    },
    exit: (_) => exited = true,
    getDeviceList: (ctx, listPtrPtr) {
      final list = calloc<Pointer<LibusbDevice>>(devices.length);
      for (var i = 0; i < devices.length; i++) {
        list[i] = Pointer.fromAddress(i + 1);
      }
      _deviceListPtr = list;
      listPtrPtr.value = list;
      return devices.length;
    },
    freeDeviceList: (list, _) {
      calloc.free(list);
      _deviceListPtr = null;
    },
    getDeviceDescriptor: (device, descriptor) {
      final index = _deviceIndexOf(device);
      if (index < 0 || index >= devices.length) return -1;
      descriptor.ref.idVendor = devices[index].vendorId;
      descriptor.ref.idProduct = devices[index].productId;
      return 0;
    },
    open: (device, handlePtrPtr) {
      openCalls.add(_deviceIndexOf(device));
      if (openResult != 0) return openResult;
      handlePtrPtr.value = Pointer.fromAddress(100 + _deviceIndexOf(device));
      return 0;
    },
    close: (_) => closed = true,
    setConfiguration: (_, __) => 0,
    claimInterface: (_, interfaceNumber) {
      claimInterfaceCalls.add(interfaceNumber);
      return claimResult;
    },
    releaseInterface: (_, __) {
      released = true;
      return 0;
    },
    bulkTransfer: (handle, endpoint, data, length, actualLength, timeout) {
      if (endpoint == 0x01) {
        // OUT — capture what LibusbBackend wrote.
        lastBulkOut = Uint8List.fromList(data.asTypedList(length));
        actualLength.value = length;
        return 0;
      }
      // IN — hand back the configured canned response.
      final n = bulkInResponse.length.clamp(0, length);
      data.asTypedList(n).setAll(0, bulkInResponse.sublist(0, n));
      actualLength.value = n;
      return bulkInResult;
    },
  );

  void disposeNativeMemory() {
    if (_deviceListPtr != null) calloc.free(_deviceListPtr!);
  }
}

void main() {
  group('LibusbBackend', () {
    test('getDeviceList resolves vendor/product IDs via the descriptor',
        () async {
      final fake = _FakeLibusb([
        (vendorId: 0x0FCF, productId: 0x1008),
        (vendorId: 0x1234, productId: 0x5678),
      ]);
      final backend = LibusbBackend(bindings: fake.bindings);
      await backend.init();

      final devices = await backend.getDeviceList();

      expect(devices, hasLength(2));
      expect(devices[0].vendorId, 0x0FCF);
      expect(devices[0].productId, 0x1008);
      expect(devices[1].vendorId, 0x1234);
      expect(devices[1].productId, 0x5678);

      await backend.dispose();
    });

    test('openDevice matches by vendor/product and claims interface 0',
        () async {
      final fake = _FakeLibusb([
        (vendorId: 0x0FCF, productId: 0x1008),
        (vendorId: 0x0FCF, productId: 0x1009),
      ]);
      final backend = LibusbBackend(bindings: fake.bindings);
      await backend.init();
      final devices = await backend.getDeviceList();

      final opened = await backend.openDevice(devices[1]);

      expect(opened, isTrue);
      expect(fake.openCalls, [1]); // matched the second fake device
      expect(fake.claimInterfaceCalls, [0]);

      await backend.dispose();
    });

    test('openDevice returns false when no device matches', () async {
      final fake = _FakeLibusb([(vendorId: 0x0FCF, productId: 0x1008)]);
      final backend = LibusbBackend(bindings: fake.bindings);
      await backend.init();
      await backend.getDeviceList();

      final opened = await backend.openDevice(
        const UsbDeviceInfo(vendorId: 0xDEAD, productId: 0xBEEF, name: 'x'),
      );

      expect(opened, isFalse);
      expect(fake.openCalls, isEmpty);

      await backend.dispose();
    });

    test('openDevice returns false when libusb_claim_interface fails',
        () async {
      final fake = _FakeLibusb([(vendorId: 0x0FCF, productId: 0x1008)])
        ..claimResult = -6; // LIBUSB_ERROR_BUSY
      final backend = LibusbBackend(bindings: fake.bindings);
      await backend.init();
      final devices = await backend.getDeviceList();

      final opened = await backend.openDevice(devices.single);

      expect(opened, isFalse);
      expect(fake.closed, isTrue); // rolled back the successful open

      await backend.dispose();
    });

    test('bulkTransferOut writes the exact bytes given', () async {
      final fake = _FakeLibusb([(vendorId: 0x0FCF, productId: 0x1008)]);
      final backend = LibusbBackend(bindings: fake.bindings);
      await backend.init();
      final devices = await backend.getDeviceList();
      await backend.openDevice(devices.single);

      await backend.bulkTransferOut(Uint8List.fromList([0xA4, 0x01, 0x4B]));

      expect(fake.lastBulkOut, [0xA4, 0x01, 0x4B]);

      await backend.dispose();
    });

    test('bulkTransferIn returns only the actually-read bytes', () async {
      final fake = _FakeLibusb([(vendorId: 0x0FCF, productId: 0x1008)])
        ..bulkInResponse = Uint8List.fromList([1, 2, 3]);
      final backend = LibusbBackend(bindings: fake.bindings);
      await backend.init();
      final devices = await backend.getDeviceList();
      await backend.openDevice(devices.single);

      final result = await backend.bulkTransferIn(64);

      expect(result, [1, 2, 3]);

      await backend.dispose();
    });

    test('bulkTransferIn returns empty bytes on a timeout-shaped error',
        () async {
      final fake = _FakeLibusb([(vendorId: 0x0FCF, productId: 0x1008)])
        ..bulkInResult = -7; // LIBUSB_ERROR_TIMEOUT
      final backend = LibusbBackend(bindings: fake.bindings);
      await backend.init();
      final devices = await backend.getDeviceList();
      await backend.openDevice(devices.single);

      final result = await backend.bulkTransferIn(64);

      expect(result, isEmpty);

      await backend.dispose();
    });

    test('dispose releases the interface, closes, and exits', () async {
      final fake = _FakeLibusb([(vendorId: 0x0FCF, productId: 0x1008)]);
      final backend = LibusbBackend(bindings: fake.bindings);
      await backend.init();
      final devices = await backend.getDeviceList();
      await backend.openDevice(devices.single);

      await backend.dispose();

      expect(fake.released, isTrue);
      expect(fake.closed, isTrue);
      expect(fake.exited, isTrue);
    });
  });
}
