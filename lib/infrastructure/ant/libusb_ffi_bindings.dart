// Minimal `dart:ffi` bindings for the subset of the libusb 1.0 C API that
// LibusbBackend needs: init/exit, device enumeration, open/close, claim
// interface, and bulk transfers. Not a full libusb wrapper — see
// docs/release/antplus-usb.md for why (and for where to source the
// platform binary this dlopens).
//
// Struct layouts and function signatures are taken from the public,
// ABI-stable libusb.h (https://libusb.sourceforge.io/api-1.0/).

import 'dart:ffi';
import 'dart:io';

// ---------------------------------------------------------------------------
// Opaque libusb handle types
// ---------------------------------------------------------------------------

final class LibusbContext extends Opaque {}

final class LibusbDevice extends Opaque {}

final class LibusbDeviceHandle extends Opaque {}

/// `struct libusb_device_descriptor` — fixed 18-byte USB device descriptor.
final class LibusbDeviceDescriptor extends Struct {
  @Uint8()
  external int bLength;
  @Uint8()
  external int bDescriptorType;
  @Uint16()
  external int bcdUSB;
  @Uint8()
  external int bDeviceClass;
  @Uint8()
  external int bDeviceSubClass;
  @Uint8()
  external int bDeviceProtocol;
  @Uint8()
  external int bMaxPacketSize0;
  @Uint16()
  external int idVendor;
  @Uint16()
  external int idProduct;
  @Uint16()
  external int bcdDevice;
  @Uint8()
  external int iManufacturer;
  @Uint8()
  external int iProduct;
  @Uint8()
  external int iSerialNumber;
  @Uint8()
  external int bNumConfigurations;
}

// ---------------------------------------------------------------------------
// Native / Dart function signatures
// ---------------------------------------------------------------------------

typedef _NativeInit = Int32 Function(Pointer<Pointer<LibusbContext>>);
typedef DartInit = int Function(Pointer<Pointer<LibusbContext>>);

typedef _NativeExit = Void Function(Pointer<LibusbContext>);
typedef DartExit = void Function(Pointer<LibusbContext>);

typedef _NativeGetDeviceList = IntPtr Function(
    Pointer<LibusbContext>, Pointer<Pointer<Pointer<LibusbDevice>>>);
typedef DartGetDeviceList = int Function(
    Pointer<LibusbContext>, Pointer<Pointer<Pointer<LibusbDevice>>>);

typedef _NativeFreeDeviceList = Void Function(
    Pointer<Pointer<LibusbDevice>>, Int32);
typedef DartFreeDeviceList = void Function(
    Pointer<Pointer<LibusbDevice>>, int);

typedef _NativeGetDeviceDescriptor = Int32 Function(
    Pointer<LibusbDevice>, Pointer<LibusbDeviceDescriptor>);
typedef DartGetDeviceDescriptor = int Function(
    Pointer<LibusbDevice>, Pointer<LibusbDeviceDescriptor>);

typedef _NativeOpen = Int32 Function(
    Pointer<LibusbDevice>, Pointer<Pointer<LibusbDeviceHandle>>);
typedef DartOpen = int Function(
    Pointer<LibusbDevice>, Pointer<Pointer<LibusbDeviceHandle>>);

typedef _NativeClose = Void Function(Pointer<LibusbDeviceHandle>);
typedef DartClose = void Function(Pointer<LibusbDeviceHandle>);

typedef _NativeSetConfiguration = Int32 Function(
    Pointer<LibusbDeviceHandle>, Int32);
typedef DartSetConfiguration = int Function(
    Pointer<LibusbDeviceHandle>, int);

typedef _NativeClaimInterface = Int32 Function(
    Pointer<LibusbDeviceHandle>, Int32);
typedef DartClaimInterface = int Function(Pointer<LibusbDeviceHandle>, int);

typedef _NativeReleaseInterface = Int32 Function(
    Pointer<LibusbDeviceHandle>, Int32);
typedef DartReleaseInterface = int Function(
    Pointer<LibusbDeviceHandle>, int);

typedef _NativeBulkTransfer = Int32 Function(
    Pointer<LibusbDeviceHandle>,
    Uint8,
    Pointer<Uint8>,
    Int32,
    Pointer<Int32>,
    Uint32);
typedef DartBulkTransfer = int Function(Pointer<LibusbDeviceHandle>, int,
    Pointer<Uint8>, int, Pointer<Int32>, int);

// ---------------------------------------------------------------------------
// Bindings
// ---------------------------------------------------------------------------

/// Loads libusb and exposes the handful of functions [LibusbBackend] calls.
///
/// libusb error code `0` is `LIBUSB_SUCCESS`; negative values are errors.
class LibusbBindings {
  factory LibusbBindings() => LibusbBindings._(_open());

  /// Builds bindings from plain Dart function values instead of resolving
  /// symbols from a loaded library — lets tests exercise [LibusbBackend]'s
  /// pointer-handling logic against fake "native" behavior without a real
  /// libusb binary.
  LibusbBindings.raw({
    required this.init,
    required this.exit,
    required this.getDeviceList,
    required this.freeDeviceList,
    required this.getDeviceDescriptor,
    required this.open,
    required this.close,
    required this.setConfiguration,
    required this.claimInterface,
    required this.releaseInterface,
    required this.bulkTransfer,
  });

  LibusbBindings._(DynamicLibrary lib)
      : init = lib.lookupFunction<_NativeInit, DartInit>('libusb_init'),
        exit = lib.lookupFunction<_NativeExit, DartExit>('libusb_exit'),
        getDeviceList = lib.lookupFunction<_NativeGetDeviceList,
            DartGetDeviceList>('libusb_get_device_list'),
        freeDeviceList = lib.lookupFunction<_NativeFreeDeviceList,
            DartFreeDeviceList>('libusb_free_device_list'),
        getDeviceDescriptor = lib.lookupFunction<_NativeGetDeviceDescriptor,
            DartGetDeviceDescriptor>('libusb_get_device_descriptor'),
        open = lib.lookupFunction<_NativeOpen, DartOpen>('libusb_open'),
        close = lib.lookupFunction<_NativeClose, DartClose>('libusb_close'),
        setConfiguration = lib.lookupFunction<_NativeSetConfiguration,
            DartSetConfiguration>('libusb_set_configuration'),
        claimInterface = lib.lookupFunction<_NativeClaimInterface,
            DartClaimInterface>('libusb_claim_interface'),
        releaseInterface = lib.lookupFunction<_NativeReleaseInterface,
            DartReleaseInterface>('libusb_release_interface'),
        bulkTransfer = lib.lookupFunction<_NativeBulkTransfer,
            DartBulkTransfer>('libusb_bulk_transfer');

  final DartInit init;
  final DartExit exit;
  final DartGetDeviceList getDeviceList;
  final DartFreeDeviceList freeDeviceList;
  final DartGetDeviceDescriptor getDeviceDescriptor;
  final DartOpen open;
  final DartClose close;
  final DartSetConfiguration setConfiguration;
  final DartClaimInterface claimInterface;
  final DartReleaseInterface releaseInterface;
  final DartBulkTransfer bulkTransfer;

  /// Resolves the platform-specific libusb shared library. Ships as a
  /// bundled binary next to the app executable on desktop platforms — see
  /// docs/release/antplus-usb.md for how it gets there.
  static DynamicLibrary _open() {
    if (Platform.isWindows) return DynamicLibrary.open('libusb-1.0.dll');
    if (Platform.isMacOS) return DynamicLibrary.open('libusb-1.0.dylib');
    if (Platform.isLinux) return DynamicLibrary.open('libusb-1.0.so.0');
    throw UnsupportedError(
        'LibusbBackend is only available on Windows, macOS, and Linux.');
  }
}
