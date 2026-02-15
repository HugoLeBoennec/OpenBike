import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Standard BLE GATT service and characteristic UUIDs for cycling sensors
/// and fitness machines.
class BleConstants {
  BleConstants._();

  // ---------------------------------------------------------------------------
  // FTMS — Fitness Machine Service (0x1826)
  // ---------------------------------------------------------------------------

  static final ftmsService =
      Guid('00001826-0000-1000-8000-00805f9b34fb');

  static final ftmsIndoorBikeData =
      Guid('00002ad2-0000-1000-8000-00805f9b34fb');

  static final ftmsControlPoint =
      Guid('00002ad9-0000-1000-8000-00805f9b34fb');

  static final ftmsStatus =
      Guid('00002ada-0000-1000-8000-00805f9b34fb');

  static final ftmsFeature =
      Guid('00002acc-0000-1000-8000-00805f9b34fb');

  // ---------------------------------------------------------------------------
  // CPS — Cycling Power Service (0x1818)
  // ---------------------------------------------------------------------------

  static final cpsService =
      Guid('00001818-0000-1000-8000-00805f9b34fb');

  static final cpsMeasurement =
      Guid('00002a63-0000-1000-8000-00805f9b34fb');

  // ---------------------------------------------------------------------------
  // CSC — Cycling Speed and Cadence (0x1816)
  // ---------------------------------------------------------------------------

  static final cscService =
      Guid('00001816-0000-1000-8000-00805f9b34fb');

  static final cscMeasurement =
      Guid('00002a5b-0000-1000-8000-00805f9b34fb');

  // ---------------------------------------------------------------------------
  // HRS — Heart Rate Service (0x180D)
  // ---------------------------------------------------------------------------

  static final hrsService =
      Guid('0000180d-0000-1000-8000-00805f9b34fb');

  static final hrsMeasurement =
      Guid('00002a37-0000-1000-8000-00805f9b34fb');

  // ---------------------------------------------------------------------------
  // CCC Descriptor (Client Characteristic Configuration)
  // ---------------------------------------------------------------------------

  static final cccDescriptor =
      Guid('00002902-0000-1000-8000-00805f9b34fb');

  // ---------------------------------------------------------------------------
  // All known service UUIDs (used by scanner filter)
  // ---------------------------------------------------------------------------

  static final List<Guid> knownServiceUuids = [
    ftmsService,
    cpsService,
    cscService,
    hrsService,
  ];
}
