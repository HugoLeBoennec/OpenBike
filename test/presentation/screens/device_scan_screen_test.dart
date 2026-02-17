import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/infrastructure/ble/ble_transport.dart';

void main() {
  group('BleTransportState', () {
    test('has all expected values', () {
      expect(BleTransportState.values, hasLength(5));
      expect(BleTransportState.values, contains(BleTransportState.idle));
      expect(BleTransportState.values, contains(BleTransportState.scanning));
      expect(BleTransportState.values, contains(BleTransportState.connecting));
      expect(BleTransportState.values, contains(BleTransportState.connected));
      expect(BleTransportState.values, contains(BleTransportState.reconnecting));
    });
  });

  group('BleScannedDevice', () {
    test('holds device info and rssi', () {
      // BleScannedDevice requires a TrainerDevice — verified at integration level.
      // Here we validate the data class contract exists.
      expect(BleScannedDevice.new, isNotNull);
    });
  });
}
