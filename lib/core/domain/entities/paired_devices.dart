import 'package:freezed_annotation/freezed_annotation.dart';

import 'trainer_device.dart';

part 'paired_devices.freezed.dart';

/// The role a paired sensor plays in a ride.
///
/// A device is assigned to at most one role at a time; assigning a new
/// device to a role replaces whatever was previously paired there.
enum SensorRole { trainer, heartRate, power, cadenceSpeed }

/// A device the user has explicitly paired to a [SensorRole].
///
/// Stores just enough to reconnect and to select the right [DevicePlugin]
/// without re-scanning (name/protocol are cached from the scan result at
/// pairing time).
///
/// Encoding methods are named [encode]/[decode] rather than `toJson`/
/// `fromJson` — those exact names make freezed emit calls into a
/// json_serializable `.g.dart` part that this project doesn't generate.
@freezed
class PairedDevice with _$PairedDevice {
  const factory PairedDevice({
    required String deviceId,
    required String name,
    required DeviceProtocol protocol,
  }) = _PairedDevice;

  const PairedDevice._();

  Map<String, dynamic> encode() => {
        'deviceId': deviceId,
        'name': name,
        'protocol': protocol.name,
      };

  static PairedDevice decode(Map<String, dynamic> json) => PairedDevice(
        deviceId: json['deviceId'] as String,
        name: json['name'] as String,
        protocol: DeviceProtocol.values.byName(json['protocol'] as String),
      );
}

/// Role → paired device assignments, persisted via [AppPreferences].
@freezed
class PairedDevices with _$PairedDevices {
  const factory PairedDevices({
    @Default(<SensorRole, PairedDevice>{}) Map<SensorRole, PairedDevice> byRole,
  }) = _PairedDevices;

  const PairedDevices._();

  /// The device paired to [role], or `null` if no device is assigned.
  PairedDevice? forRole(SensorRole role) => byRole[role];

  /// Returns a copy with [device] assigned to [role].
  PairedDevices withRole(SensorRole role, PairedDevice device) =>
      copyWith(byRole: {...byRole, role: device});

  /// Returns a copy with [role] unassigned.
  PairedDevices withoutRole(SensorRole role) {
    final updated = {...byRole}..remove(role);
    return copyWith(byRole: updated);
  }

  /// Returns the role [deviceId] is paired to, or `null`.
  SensorRole? roleForDevice(String deviceId) {
    for (final entry in byRole.entries) {
      if (entry.value.deviceId == deviceId) return entry.key;
    }
    return null;
  }

  Map<String, dynamic> encode() => {
        for (final entry in byRole.entries) entry.key.name: entry.value.encode(),
      };

  static PairedDevices decode(Map<String, dynamic> json) => PairedDevices(
        byRole: {
          for (final entry in json.entries)
            if (_roleByName(entry.key) != null)
              _roleByName(entry.key)!:
                  PairedDevice.decode(entry.value as Map<String, dynamic>),
        },
      );

  static SensorRole? _roleByName(String name) {
    for (final role in SensorRole.values) {
      if (role.name == name) return role;
    }
    return null;
  }
}
