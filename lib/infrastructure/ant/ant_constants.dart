/// ANT+ protocol constants for USB dongle communication and FE-C profile.
class AntConstants {
  AntConstants._();

  // ---------------------------------------------------------------------------
  // USB — Dynastream (Garmin) ANT+ dongles
  // ---------------------------------------------------------------------------

  static const int vendorId = 0x0FCF;
  static const List<int> productIds = [0x1008, 0x1009];

  // ---------------------------------------------------------------------------
  // ANT+ message structure
  // ---------------------------------------------------------------------------

  static const int syncByte = 0xA4;

  // Message IDs
  static const int msgResetSystem = 0x4A;
  static const int msgSetNetworkKey = 0x46;
  static const int msgAssignChannel = 0x42;
  static const int msgSetChannelId = 0x51;
  static const int msgSetChannelPeriod = 0x43;
  static const int msgSetRfFrequency = 0x45;
  static const int msgOpenChannel = 0x4B;
  static const int msgCloseChannel = 0x4C;
  static const int msgRequestMessage = 0x4D;
  static const int msgBroadcastData = 0x4E;
  static const int msgAcknowledgedData = 0x4F;
  static const int msgChannelResponse = 0x40;
  static const int msgStartup = 0x6F;

  // ANT+ public network key
  static const List<int> antPlusNetworkKey = [
    0xB9, 0xA5, 0x21, 0xFB, 0xBD, 0x72, 0xC3, 0x45,
  ];

  // Channel types
  static const int channelTypeReceive = 0x00;

  // Channel response codes
  static const int responseNoError = 0x00;
  static const int eventRxSearchTimeout = 0x01;
  static const int eventChannelClosed = 0x07;

  // ---------------------------------------------------------------------------
  // FE-C profile
  // ---------------------------------------------------------------------------

  static const int fecDeviceType = 17;
  static const int fecChannelPeriod = 8192; // 32768 / 4 Hz
  static const int fecRfFrequency = 57; // 2457 MHz

  // Data pages (received FROM trainer)
  static const int pageGeneralFe = 16;
  static const int pageTrainerSpecific = 25;
  static const int pageManufacturerInfo = 80;
  static const int pageProductInfo = 81;

  // Control pages (sent TO trainer)
  static const int pageBasicResistance = 48;
  static const int pageTargetPower = 49;
  static const int pageWindResistance = 50;
  static const int pageTrackResistance = 51;

  // ---------------------------------------------------------------------------
  // USB endpoints (typical for ANT+ sticks)
  // ---------------------------------------------------------------------------

  static const int usbInterfaceNumber = 0;
  static const int usbTransferTimeout = 1000;
}
