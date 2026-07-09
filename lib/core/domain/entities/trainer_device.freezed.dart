// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TrainerDevice {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get manufacturer => throw _privateConstructorUsedError;
  DeviceProtocol get protocol => throw _privateConstructorUsedError;
  bool get isControllable => throw _privateConstructorUsedError;
  List<ControlMode> get supportedModes => throw _privateConstructorUsedError;

  /// Create a copy of TrainerDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerDeviceCopyWith<TrainerDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerDeviceCopyWith<$Res> {
  factory $TrainerDeviceCopyWith(
    TrainerDevice value,
    $Res Function(TrainerDevice) then,
  ) = _$TrainerDeviceCopyWithImpl<$Res, TrainerDevice>;
  @useResult
  $Res call({
    String id,
    String name,
    String? manufacturer,
    DeviceProtocol protocol,
    bool isControllable,
    List<ControlMode> supportedModes,
  });
}

/// @nodoc
class _$TrainerDeviceCopyWithImpl<$Res, $Val extends TrainerDevice>
    implements $TrainerDeviceCopyWith<$Res> {
  _$TrainerDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? manufacturer = freezed,
    Object? protocol = null,
    Object? isControllable = null,
    Object? supportedModes = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            manufacturer: freezed == manufacturer
                ? _value.manufacturer
                : manufacturer // ignore: cast_nullable_to_non_nullable
                      as String?,
            protocol: null == protocol
                ? _value.protocol
                : protocol // ignore: cast_nullable_to_non_nullable
                      as DeviceProtocol,
            isControllable: null == isControllable
                ? _value.isControllable
                : isControllable // ignore: cast_nullable_to_non_nullable
                      as bool,
            supportedModes: null == supportedModes
                ? _value.supportedModes
                : supportedModes // ignore: cast_nullable_to_non_nullable
                      as List<ControlMode>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerDeviceImplCopyWith<$Res>
    implements $TrainerDeviceCopyWith<$Res> {
  factory _$$TrainerDeviceImplCopyWith(
    _$TrainerDeviceImpl value,
    $Res Function(_$TrainerDeviceImpl) then,
  ) = __$$TrainerDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? manufacturer,
    DeviceProtocol protocol,
    bool isControllable,
    List<ControlMode> supportedModes,
  });
}

/// @nodoc
class __$$TrainerDeviceImplCopyWithImpl<$Res>
    extends _$TrainerDeviceCopyWithImpl<$Res, _$TrainerDeviceImpl>
    implements _$$TrainerDeviceImplCopyWith<$Res> {
  __$$TrainerDeviceImplCopyWithImpl(
    _$TrainerDeviceImpl _value,
    $Res Function(_$TrainerDeviceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? manufacturer = freezed,
    Object? protocol = null,
    Object? isControllable = null,
    Object? supportedModes = null,
  }) {
    return _then(
      _$TrainerDeviceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        manufacturer: freezed == manufacturer
            ? _value.manufacturer
            : manufacturer // ignore: cast_nullable_to_non_nullable
                  as String?,
        protocol: null == protocol
            ? _value.protocol
            : protocol // ignore: cast_nullable_to_non_nullable
                  as DeviceProtocol,
        isControllable: null == isControllable
            ? _value.isControllable
            : isControllable // ignore: cast_nullable_to_non_nullable
                  as bool,
        supportedModes: null == supportedModes
            ? _value._supportedModes
            : supportedModes // ignore: cast_nullable_to_non_nullable
                  as List<ControlMode>,
      ),
    );
  }
}

/// @nodoc

class _$TrainerDeviceImpl implements _TrainerDevice {
  const _$TrainerDeviceImpl({
    required this.id,
    required this.name,
    this.manufacturer,
    required this.protocol,
    this.isControllable = false,
    final List<ControlMode> supportedModes = const [],
  }) : _supportedModes = supportedModes;

  @override
  final String id;
  @override
  final String name;
  @override
  final String? manufacturer;
  @override
  final DeviceProtocol protocol;
  @override
  @JsonKey()
  final bool isControllable;
  final List<ControlMode> _supportedModes;
  @override
  @JsonKey()
  List<ControlMode> get supportedModes {
    if (_supportedModes is EqualUnmodifiableListView) return _supportedModes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_supportedModes);
  }

  @override
  String toString() {
    return 'TrainerDevice(id: $id, name: $name, manufacturer: $manufacturer, protocol: $protocol, isControllable: $isControllable, supportedModes: $supportedModes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerDeviceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.manufacturer, manufacturer) ||
                other.manufacturer == manufacturer) &&
            (identical(other.protocol, protocol) ||
                other.protocol == protocol) &&
            (identical(other.isControllable, isControllable) ||
                other.isControllable == isControllable) &&
            const DeepCollectionEquality().equals(
              other._supportedModes,
              _supportedModes,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    manufacturer,
    protocol,
    isControllable,
    const DeepCollectionEquality().hash(_supportedModes),
  );

  /// Create a copy of TrainerDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerDeviceImplCopyWith<_$TrainerDeviceImpl> get copyWith =>
      __$$TrainerDeviceImplCopyWithImpl<_$TrainerDeviceImpl>(this, _$identity);
}

abstract class _TrainerDevice implements TrainerDevice {
  const factory _TrainerDevice({
    required final String id,
    required final String name,
    final String? manufacturer,
    required final DeviceProtocol protocol,
    final bool isControllable,
    final List<ControlMode> supportedModes,
  }) = _$TrainerDeviceImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get manufacturer;
  @override
  DeviceProtocol get protocol;
  @override
  bool get isControllable;
  @override
  List<ControlMode> get supportedModes;

  /// Create a copy of TrainerDevice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerDeviceImplCopyWith<_$TrainerDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
