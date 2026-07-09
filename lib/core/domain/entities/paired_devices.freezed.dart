// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paired_devices.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PairedDevice {
  String get deviceId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DeviceProtocol get protocol => throw _privateConstructorUsedError;

  /// Create a copy of PairedDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PairedDeviceCopyWith<PairedDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PairedDeviceCopyWith<$Res> {
  factory $PairedDeviceCopyWith(
    PairedDevice value,
    $Res Function(PairedDevice) then,
  ) = _$PairedDeviceCopyWithImpl<$Res, PairedDevice>;
  @useResult
  $Res call({String deviceId, String name, DeviceProtocol protocol});
}

/// @nodoc
class _$PairedDeviceCopyWithImpl<$Res, $Val extends PairedDevice>
    implements $PairedDeviceCopyWith<$Res> {
  _$PairedDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PairedDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? name = null,
    Object? protocol = null,
  }) {
    return _then(
      _value.copyWith(
            deviceId: null == deviceId
                ? _value.deviceId
                : deviceId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            protocol: null == protocol
                ? _value.protocol
                : protocol // ignore: cast_nullable_to_non_nullable
                      as DeviceProtocol,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PairedDeviceImplCopyWith<$Res>
    implements $PairedDeviceCopyWith<$Res> {
  factory _$$PairedDeviceImplCopyWith(
    _$PairedDeviceImpl value,
    $Res Function(_$PairedDeviceImpl) then,
  ) = __$$PairedDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String deviceId, String name, DeviceProtocol protocol});
}

/// @nodoc
class __$$PairedDeviceImplCopyWithImpl<$Res>
    extends _$PairedDeviceCopyWithImpl<$Res, _$PairedDeviceImpl>
    implements _$$PairedDeviceImplCopyWith<$Res> {
  __$$PairedDeviceImplCopyWithImpl(
    _$PairedDeviceImpl _value,
    $Res Function(_$PairedDeviceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PairedDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? name = null,
    Object? protocol = null,
  }) {
    return _then(
      _$PairedDeviceImpl(
        deviceId: null == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        protocol: null == protocol
            ? _value.protocol
            : protocol // ignore: cast_nullable_to_non_nullable
                  as DeviceProtocol,
      ),
    );
  }
}

/// @nodoc

class _$PairedDeviceImpl extends _PairedDevice {
  const _$PairedDeviceImpl({
    required this.deviceId,
    required this.name,
    required this.protocol,
  }) : super._();

  @override
  final String deviceId;
  @override
  final String name;
  @override
  final DeviceProtocol protocol;

  @override
  String toString() {
    return 'PairedDevice(deviceId: $deviceId, name: $name, protocol: $protocol)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PairedDeviceImpl &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.protocol, protocol) ||
                other.protocol == protocol));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId, name, protocol);

  /// Create a copy of PairedDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PairedDeviceImplCopyWith<_$PairedDeviceImpl> get copyWith =>
      __$$PairedDeviceImplCopyWithImpl<_$PairedDeviceImpl>(this, _$identity);
}

abstract class _PairedDevice extends PairedDevice {
  const factory _PairedDevice({
    required final String deviceId,
    required final String name,
    required final DeviceProtocol protocol,
  }) = _$PairedDeviceImpl;
  const _PairedDevice._() : super._();

  @override
  String get deviceId;
  @override
  String get name;
  @override
  DeviceProtocol get protocol;

  /// Create a copy of PairedDevice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PairedDeviceImplCopyWith<_$PairedDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PairedDevices {
  Map<SensorRole, PairedDevice> get byRole =>
      throw _privateConstructorUsedError;

  /// Create a copy of PairedDevices
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PairedDevicesCopyWith<PairedDevices> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PairedDevicesCopyWith<$Res> {
  factory $PairedDevicesCopyWith(
    PairedDevices value,
    $Res Function(PairedDevices) then,
  ) = _$PairedDevicesCopyWithImpl<$Res, PairedDevices>;
  @useResult
  $Res call({Map<SensorRole, PairedDevice> byRole});
}

/// @nodoc
class _$PairedDevicesCopyWithImpl<$Res, $Val extends PairedDevices>
    implements $PairedDevicesCopyWith<$Res> {
  _$PairedDevicesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PairedDevices
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? byRole = null}) {
    return _then(
      _value.copyWith(
            byRole: null == byRole
                ? _value.byRole
                : byRole // ignore: cast_nullable_to_non_nullable
                      as Map<SensorRole, PairedDevice>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PairedDevicesImplCopyWith<$Res>
    implements $PairedDevicesCopyWith<$Res> {
  factory _$$PairedDevicesImplCopyWith(
    _$PairedDevicesImpl value,
    $Res Function(_$PairedDevicesImpl) then,
  ) = __$$PairedDevicesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<SensorRole, PairedDevice> byRole});
}

/// @nodoc
class __$$PairedDevicesImplCopyWithImpl<$Res>
    extends _$PairedDevicesCopyWithImpl<$Res, _$PairedDevicesImpl>
    implements _$$PairedDevicesImplCopyWith<$Res> {
  __$$PairedDevicesImplCopyWithImpl(
    _$PairedDevicesImpl _value,
    $Res Function(_$PairedDevicesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PairedDevices
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? byRole = null}) {
    return _then(
      _$PairedDevicesImpl(
        byRole: null == byRole
            ? _value._byRole
            : byRole // ignore: cast_nullable_to_non_nullable
                  as Map<SensorRole, PairedDevice>,
      ),
    );
  }
}

/// @nodoc

class _$PairedDevicesImpl extends _PairedDevices {
  const _$PairedDevicesImpl({
    final Map<SensorRole, PairedDevice> byRole =
        const <SensorRole, PairedDevice>{},
  }) : _byRole = byRole,
       super._();

  final Map<SensorRole, PairedDevice> _byRole;
  @override
  @JsonKey()
  Map<SensorRole, PairedDevice> get byRole {
    if (_byRole is EqualUnmodifiableMapView) return _byRole;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_byRole);
  }

  @override
  String toString() {
    return 'PairedDevices(byRole: $byRole)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PairedDevicesImpl &&
            const DeepCollectionEquality().equals(other._byRole, _byRole));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_byRole));

  /// Create a copy of PairedDevices
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PairedDevicesImplCopyWith<_$PairedDevicesImpl> get copyWith =>
      __$$PairedDevicesImplCopyWithImpl<_$PairedDevicesImpl>(this, _$identity);
}

abstract class _PairedDevices extends PairedDevices {
  const factory _PairedDevices({final Map<SensorRole, PairedDevice> byRole}) =
      _$PairedDevicesImpl;
  const _PairedDevices._() : super._();

  @override
  Map<SensorRole, PairedDevice> get byRole;

  /// Create a copy of PairedDevices
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PairedDevicesImplCopyWith<_$PairedDevicesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
