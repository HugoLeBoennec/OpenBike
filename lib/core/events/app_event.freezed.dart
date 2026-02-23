// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$SensorEvent {
  SensorReading get reading => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SensorEventCopyWith<SensorEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SensorEventCopyWith<$Res> {
  factory $SensorEventCopyWith(
          SensorEvent value, $Res Function(SensorEvent) then) =
      _$SensorEventCopyWithImpl<$Res, SensorEvent>;
  @useResult
  $Res call({SensorReading reading, String deviceId});

  $SensorReadingCopyWith<$Res> get reading;
}

/// @nodoc
class _$SensorEventCopyWithImpl<$Res, $Val extends SensorEvent>
    implements $SensorEventCopyWith<$Res> {
  _$SensorEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reading = null,
    Object? deviceId = null,
  }) {
    return _then(_value.copyWith(
      reading: null == reading
          ? _value.reading
          : reading // ignore: cast_nullable_to_non_nullable
              as SensorReading,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SensorReadingCopyWith<$Res> get reading {
    return $SensorReadingCopyWith<$Res>(_value.reading, (value) {
      return _then(_value.copyWith(reading: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_SensorEventCopyWith<$Res>
    implements $SensorEventCopyWith<$Res> {
  factory _$$_SensorEventCopyWith(
          _$_SensorEvent value, $Res Function(_$_SensorEvent) then) =
      __$$_SensorEventCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SensorReading reading, String deviceId});

  @override
  $SensorReadingCopyWith<$Res> get reading;
}

/// @nodoc
class __$$_SensorEventCopyWithImpl<$Res>
    extends _$SensorEventCopyWithImpl<$Res, _$_SensorEvent>
    implements _$$_SensorEventCopyWith<$Res> {
  __$$_SensorEventCopyWithImpl(
      _$_SensorEvent _value, $Res Function(_$_SensorEvent) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reading = null,
    Object? deviceId = null,
  }) {
    return _then(_$_SensorEvent(
      reading: null == reading
          ? _value.reading
          : reading // ignore: cast_nullable_to_non_nullable
              as SensorReading,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_SensorEvent implements _SensorEvent {
  const _$_SensorEvent({required this.reading, required this.deviceId});

  @override
  final SensorReading reading;
  @override
  final String deviceId;

  @override
  String toString() {
    return 'SensorEvent(reading: $reading, deviceId: $deviceId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SensorEvent &&
            (identical(other.reading, reading) || other.reading == reading) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, reading, deviceId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SensorEventCopyWith<_$_SensorEvent> get copyWith =>
      __$$_SensorEventCopyWithImpl<_$_SensorEvent>(this, _$identity);
}

abstract class _SensorEvent implements SensorEvent {
  const factory _SensorEvent(
      {required final SensorReading reading,
      required final String deviceId}) = _$_SensorEvent;

  @override
  SensorReading get reading;
  @override
  String get deviceId;
  @override
  @JsonKey(ignore: true)
  _$$_SensorEventCopyWith<_$_SensorEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TrainerEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TrainerDevice device) connected,
    required TResult Function(String deviceId) disconnected,
    required TResult Function(String deviceId) controlAcquired,
    required TResult Function(String deviceId, ControlMode mode) modeChanged,
    required TResult Function(String deviceId) physicalStop,
    required TResult Function(String deviceId) safetyStop,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TrainerDevice device)? connected,
    TResult? Function(String deviceId)? disconnected,
    TResult? Function(String deviceId)? controlAcquired,
    TResult? Function(String deviceId, ControlMode mode)? modeChanged,
    TResult? Function(String deviceId)? physicalStop,
    TResult? Function(String deviceId)? safetyStop,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TrainerDevice device)? connected,
    TResult Function(String deviceId)? disconnected,
    TResult Function(String deviceId)? controlAcquired,
    TResult Function(String deviceId, ControlMode mode)? modeChanged,
    TResult Function(String deviceId)? physicalStop,
    TResult Function(String deviceId)? safetyStop,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrainerConnected value) connected,
    required TResult Function(TrainerDisconnected value) disconnected,
    required TResult Function(TrainerControlAcquired value) controlAcquired,
    required TResult Function(TrainerModeChanged value) modeChanged,
    required TResult Function(TrainerPhysicalStop value) physicalStop,
    required TResult Function(TrainerSafetyStop value) safetyStop,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerConnected value)? connected,
    TResult? Function(TrainerDisconnected value)? disconnected,
    TResult? Function(TrainerControlAcquired value)? controlAcquired,
    TResult? Function(TrainerModeChanged value)? modeChanged,
    TResult? Function(TrainerPhysicalStop value)? physicalStop,
    TResult? Function(TrainerSafetyStop value)? safetyStop,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerConnected value)? connected,
    TResult Function(TrainerDisconnected value)? disconnected,
    TResult Function(TrainerControlAcquired value)? controlAcquired,
    TResult Function(TrainerModeChanged value)? modeChanged,
    TResult Function(TrainerPhysicalStop value)? physicalStop,
    TResult Function(TrainerSafetyStop value)? safetyStop,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerEventCopyWith<$Res> {
  factory $TrainerEventCopyWith(
          TrainerEvent value, $Res Function(TrainerEvent) then) =
      _$TrainerEventCopyWithImpl<$Res, TrainerEvent>;
}

/// @nodoc
class _$TrainerEventCopyWithImpl<$Res, $Val extends TrainerEvent>
    implements $TrainerEventCopyWith<$Res> {
  _$TrainerEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$TrainerConnectedCopyWith<$Res> {
  factory _$$TrainerConnectedCopyWith(
          _$TrainerConnected value, $Res Function(_$TrainerConnected) then) =
      __$$TrainerConnectedCopyWithImpl<$Res>;
  @useResult
  $Res call({TrainerDevice device});

  $TrainerDeviceCopyWith<$Res> get device;
}

/// @nodoc
class __$$TrainerConnectedCopyWithImpl<$Res>
    extends _$TrainerEventCopyWithImpl<$Res, _$TrainerConnected>
    implements _$$TrainerConnectedCopyWith<$Res> {
  __$$TrainerConnectedCopyWithImpl(
      _$TrainerConnected _value, $Res Function(_$TrainerConnected) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? device = null,
  }) {
    return _then(_$TrainerConnected(
      null == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as TrainerDevice,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $TrainerDeviceCopyWith<$Res> get device {
    return $TrainerDeviceCopyWith<$Res>(_value.device, (value) {
      return _then(_value.copyWith(device: value));
    });
  }
}

/// @nodoc

class _$TrainerConnected implements TrainerConnected {
  const _$TrainerConnected(this.device);

  @override
  final TrainerDevice device;

  @override
  String toString() {
    return 'TrainerEvent.connected(device: $device)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerConnected &&
            (identical(other.device, device) || other.device == device));
  }

  @override
  int get hashCode => Object.hash(runtimeType, device);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerConnectedCopyWith<_$TrainerConnected> get copyWith =>
      __$$TrainerConnectedCopyWithImpl<_$TrainerConnected>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TrainerDevice device) connected,
    required TResult Function(String deviceId) disconnected,
    required TResult Function(String deviceId) controlAcquired,
    required TResult Function(String deviceId, ControlMode mode) modeChanged,
    required TResult Function(String deviceId) physicalStop,
    required TResult Function(String deviceId) safetyStop,
  }) {
    return connected(device);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TrainerDevice device)? connected,
    TResult? Function(String deviceId)? disconnected,
    TResult? Function(String deviceId)? controlAcquired,
    TResult? Function(String deviceId, ControlMode mode)? modeChanged,
    TResult? Function(String deviceId)? physicalStop,
    TResult? Function(String deviceId)? safetyStop,
  }) {
    return connected?.call(device);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TrainerDevice device)? connected,
    TResult Function(String deviceId)? disconnected,
    TResult Function(String deviceId)? controlAcquired,
    TResult Function(String deviceId, ControlMode mode)? modeChanged,
    TResult Function(String deviceId)? physicalStop,
    TResult Function(String deviceId)? safetyStop,
    required TResult orElse(),
  }) {
    if (connected != null) {
      return connected(device);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrainerConnected value) connected,
    required TResult Function(TrainerDisconnected value) disconnected,
    required TResult Function(TrainerControlAcquired value) controlAcquired,
    required TResult Function(TrainerModeChanged value) modeChanged,
    required TResult Function(TrainerPhysicalStop value) physicalStop,
    required TResult Function(TrainerSafetyStop value) safetyStop,
  }) {
    return connected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerConnected value)? connected,
    TResult? Function(TrainerDisconnected value)? disconnected,
    TResult? Function(TrainerControlAcquired value)? controlAcquired,
    TResult? Function(TrainerModeChanged value)? modeChanged,
    TResult? Function(TrainerPhysicalStop value)? physicalStop,
    TResult? Function(TrainerSafetyStop value)? safetyStop,
  }) {
    return connected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerConnected value)? connected,
    TResult Function(TrainerDisconnected value)? disconnected,
    TResult Function(TrainerControlAcquired value)? controlAcquired,
    TResult Function(TrainerModeChanged value)? modeChanged,
    TResult Function(TrainerPhysicalStop value)? physicalStop,
    TResult Function(TrainerSafetyStop value)? safetyStop,
    required TResult orElse(),
  }) {
    if (connected != null) {
      return connected(this);
    }
    return orElse();
  }
}

abstract class TrainerConnected implements TrainerEvent {
  const factory TrainerConnected(final TrainerDevice device) =
      _$TrainerConnected;

  TrainerDevice get device;
  @JsonKey(ignore: true)
  _$$TrainerConnectedCopyWith<_$TrainerConnected> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrainerDisconnectedCopyWith<$Res> {
  factory _$$TrainerDisconnectedCopyWith(_$TrainerDisconnected value,
          $Res Function(_$TrainerDisconnected) then) =
      __$$TrainerDisconnectedCopyWithImpl<$Res>;
  @useResult
  $Res call({String deviceId});
}

/// @nodoc
class __$$TrainerDisconnectedCopyWithImpl<$Res>
    extends _$TrainerEventCopyWithImpl<$Res, _$TrainerDisconnected>
    implements _$$TrainerDisconnectedCopyWith<$Res> {
  __$$TrainerDisconnectedCopyWithImpl(
      _$TrainerDisconnected _value, $Res Function(_$TrainerDisconnected) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
  }) {
    return _then(_$TrainerDisconnected(
      null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TrainerDisconnected implements TrainerDisconnected {
  const _$TrainerDisconnected(this.deviceId);

  @override
  final String deviceId;

  @override
  String toString() {
    return 'TrainerEvent.disconnected(deviceId: $deviceId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerDisconnected &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerDisconnectedCopyWith<_$TrainerDisconnected> get copyWith =>
      __$$TrainerDisconnectedCopyWithImpl<_$TrainerDisconnected>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TrainerDevice device) connected,
    required TResult Function(String deviceId) disconnected,
    required TResult Function(String deviceId) controlAcquired,
    required TResult Function(String deviceId, ControlMode mode) modeChanged,
    required TResult Function(String deviceId) physicalStop,
    required TResult Function(String deviceId) safetyStop,
  }) {
    return disconnected(deviceId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TrainerDevice device)? connected,
    TResult? Function(String deviceId)? disconnected,
    TResult? Function(String deviceId)? controlAcquired,
    TResult? Function(String deviceId, ControlMode mode)? modeChanged,
    TResult? Function(String deviceId)? physicalStop,
    TResult? Function(String deviceId)? safetyStop,
  }) {
    return disconnected?.call(deviceId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TrainerDevice device)? connected,
    TResult Function(String deviceId)? disconnected,
    TResult Function(String deviceId)? controlAcquired,
    TResult Function(String deviceId, ControlMode mode)? modeChanged,
    TResult Function(String deviceId)? physicalStop,
    TResult Function(String deviceId)? safetyStop,
    required TResult orElse(),
  }) {
    if (disconnected != null) {
      return disconnected(deviceId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrainerConnected value) connected,
    required TResult Function(TrainerDisconnected value) disconnected,
    required TResult Function(TrainerControlAcquired value) controlAcquired,
    required TResult Function(TrainerModeChanged value) modeChanged,
    required TResult Function(TrainerPhysicalStop value) physicalStop,
    required TResult Function(TrainerSafetyStop value) safetyStop,
  }) {
    return disconnected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerConnected value)? connected,
    TResult? Function(TrainerDisconnected value)? disconnected,
    TResult? Function(TrainerControlAcquired value)? controlAcquired,
    TResult? Function(TrainerModeChanged value)? modeChanged,
    TResult? Function(TrainerPhysicalStop value)? physicalStop,
    TResult? Function(TrainerSafetyStop value)? safetyStop,
  }) {
    return disconnected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerConnected value)? connected,
    TResult Function(TrainerDisconnected value)? disconnected,
    TResult Function(TrainerControlAcquired value)? controlAcquired,
    TResult Function(TrainerModeChanged value)? modeChanged,
    TResult Function(TrainerPhysicalStop value)? physicalStop,
    TResult Function(TrainerSafetyStop value)? safetyStop,
    required TResult orElse(),
  }) {
    if (disconnected != null) {
      return disconnected(this);
    }
    return orElse();
  }
}

abstract class TrainerDisconnected implements TrainerEvent {
  const factory TrainerDisconnected(final String deviceId) =
      _$TrainerDisconnected;

  String get deviceId;
  @JsonKey(ignore: true)
  _$$TrainerDisconnectedCopyWith<_$TrainerDisconnected> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrainerControlAcquiredCopyWith<$Res> {
  factory _$$TrainerControlAcquiredCopyWith(_$TrainerControlAcquired value,
          $Res Function(_$TrainerControlAcquired) then) =
      __$$TrainerControlAcquiredCopyWithImpl<$Res>;
  @useResult
  $Res call({String deviceId});
}

/// @nodoc
class __$$TrainerControlAcquiredCopyWithImpl<$Res>
    extends _$TrainerEventCopyWithImpl<$Res, _$TrainerControlAcquired>
    implements _$$TrainerControlAcquiredCopyWith<$Res> {
  __$$TrainerControlAcquiredCopyWithImpl(_$TrainerControlAcquired _value,
      $Res Function(_$TrainerControlAcquired) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
  }) {
    return _then(_$TrainerControlAcquired(
      null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TrainerControlAcquired implements TrainerControlAcquired {
  const _$TrainerControlAcquired(this.deviceId);

  @override
  final String deviceId;

  @override
  String toString() {
    return 'TrainerEvent.controlAcquired(deviceId: $deviceId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerControlAcquired &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerControlAcquiredCopyWith<_$TrainerControlAcquired> get copyWith =>
      __$$TrainerControlAcquiredCopyWithImpl<_$TrainerControlAcquired>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TrainerDevice device) connected,
    required TResult Function(String deviceId) disconnected,
    required TResult Function(String deviceId) controlAcquired,
    required TResult Function(String deviceId, ControlMode mode) modeChanged,
    required TResult Function(String deviceId) physicalStop,
    required TResult Function(String deviceId) safetyStop,
  }) {
    return controlAcquired(deviceId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TrainerDevice device)? connected,
    TResult? Function(String deviceId)? disconnected,
    TResult? Function(String deviceId)? controlAcquired,
    TResult? Function(String deviceId, ControlMode mode)? modeChanged,
    TResult? Function(String deviceId)? physicalStop,
    TResult? Function(String deviceId)? safetyStop,
  }) {
    return controlAcquired?.call(deviceId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TrainerDevice device)? connected,
    TResult Function(String deviceId)? disconnected,
    TResult Function(String deviceId)? controlAcquired,
    TResult Function(String deviceId, ControlMode mode)? modeChanged,
    TResult Function(String deviceId)? physicalStop,
    TResult Function(String deviceId)? safetyStop,
    required TResult orElse(),
  }) {
    if (controlAcquired != null) {
      return controlAcquired(deviceId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrainerConnected value) connected,
    required TResult Function(TrainerDisconnected value) disconnected,
    required TResult Function(TrainerControlAcquired value) controlAcquired,
    required TResult Function(TrainerModeChanged value) modeChanged,
    required TResult Function(TrainerPhysicalStop value) physicalStop,
    required TResult Function(TrainerSafetyStop value) safetyStop,
  }) {
    return controlAcquired(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerConnected value)? connected,
    TResult? Function(TrainerDisconnected value)? disconnected,
    TResult? Function(TrainerControlAcquired value)? controlAcquired,
    TResult? Function(TrainerModeChanged value)? modeChanged,
    TResult? Function(TrainerPhysicalStop value)? physicalStop,
    TResult? Function(TrainerSafetyStop value)? safetyStop,
  }) {
    return controlAcquired?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerConnected value)? connected,
    TResult Function(TrainerDisconnected value)? disconnected,
    TResult Function(TrainerControlAcquired value)? controlAcquired,
    TResult Function(TrainerModeChanged value)? modeChanged,
    TResult Function(TrainerPhysicalStop value)? physicalStop,
    TResult Function(TrainerSafetyStop value)? safetyStop,
    required TResult orElse(),
  }) {
    if (controlAcquired != null) {
      return controlAcquired(this);
    }
    return orElse();
  }
}

abstract class TrainerControlAcquired implements TrainerEvent {
  const factory TrainerControlAcquired(final String deviceId) =
      _$TrainerControlAcquired;

  String get deviceId;
  @JsonKey(ignore: true)
  _$$TrainerControlAcquiredCopyWith<_$TrainerControlAcquired> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrainerModeChangedCopyWith<$Res> {
  factory _$$TrainerModeChangedCopyWith(_$TrainerModeChanged value,
          $Res Function(_$TrainerModeChanged) then) =
      __$$TrainerModeChangedCopyWithImpl<$Res>;
  @useResult
  $Res call({String deviceId, ControlMode mode});
}

/// @nodoc
class __$$TrainerModeChangedCopyWithImpl<$Res>
    extends _$TrainerEventCopyWithImpl<$Res, _$TrainerModeChanged>
    implements _$$TrainerModeChangedCopyWith<$Res> {
  __$$TrainerModeChangedCopyWithImpl(
      _$TrainerModeChanged _value, $Res Function(_$TrainerModeChanged) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? mode = null,
  }) {
    return _then(_$TrainerModeChanged(
      null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as ControlMode,
    ));
  }
}

/// @nodoc

class _$TrainerModeChanged implements TrainerModeChanged {
  const _$TrainerModeChanged(this.deviceId, this.mode);

  @override
  final String deviceId;
  @override
  final ControlMode mode;

  @override
  String toString() {
    return 'TrainerEvent.modeChanged(deviceId: $deviceId, mode: $mode)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerModeChanged &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.mode, mode) || other.mode == mode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId, mode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerModeChangedCopyWith<_$TrainerModeChanged> get copyWith =>
      __$$TrainerModeChangedCopyWithImpl<_$TrainerModeChanged>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TrainerDevice device) connected,
    required TResult Function(String deviceId) disconnected,
    required TResult Function(String deviceId) controlAcquired,
    required TResult Function(String deviceId, ControlMode mode) modeChanged,
    required TResult Function(String deviceId) physicalStop,
    required TResult Function(String deviceId) safetyStop,
  }) {
    return modeChanged(deviceId, mode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TrainerDevice device)? connected,
    TResult? Function(String deviceId)? disconnected,
    TResult? Function(String deviceId)? controlAcquired,
    TResult? Function(String deviceId, ControlMode mode)? modeChanged,
    TResult? Function(String deviceId)? physicalStop,
    TResult? Function(String deviceId)? safetyStop,
  }) {
    return modeChanged?.call(deviceId, mode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TrainerDevice device)? connected,
    TResult Function(String deviceId)? disconnected,
    TResult Function(String deviceId)? controlAcquired,
    TResult Function(String deviceId, ControlMode mode)? modeChanged,
    TResult Function(String deviceId)? physicalStop,
    TResult Function(String deviceId)? safetyStop,
    required TResult orElse(),
  }) {
    if (modeChanged != null) {
      return modeChanged(deviceId, mode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrainerConnected value) connected,
    required TResult Function(TrainerDisconnected value) disconnected,
    required TResult Function(TrainerControlAcquired value) controlAcquired,
    required TResult Function(TrainerModeChanged value) modeChanged,
    required TResult Function(TrainerPhysicalStop value) physicalStop,
    required TResult Function(TrainerSafetyStop value) safetyStop,
  }) {
    return modeChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerConnected value)? connected,
    TResult? Function(TrainerDisconnected value)? disconnected,
    TResult? Function(TrainerControlAcquired value)? controlAcquired,
    TResult? Function(TrainerModeChanged value)? modeChanged,
    TResult? Function(TrainerPhysicalStop value)? physicalStop,
    TResult? Function(TrainerSafetyStop value)? safetyStop,
  }) {
    return modeChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerConnected value)? connected,
    TResult Function(TrainerDisconnected value)? disconnected,
    TResult Function(TrainerControlAcquired value)? controlAcquired,
    TResult Function(TrainerModeChanged value)? modeChanged,
    TResult Function(TrainerPhysicalStop value)? physicalStop,
    TResult Function(TrainerSafetyStop value)? safetyStop,
    required TResult orElse(),
  }) {
    if (modeChanged != null) {
      return modeChanged(this);
    }
    return orElse();
  }
}

abstract class TrainerModeChanged implements TrainerEvent {
  const factory TrainerModeChanged(
      final String deviceId, final ControlMode mode) = _$TrainerModeChanged;

  String get deviceId;
  ControlMode get mode;
  @JsonKey(ignore: true)
  _$$TrainerModeChangedCopyWith<_$TrainerModeChanged> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrainerPhysicalStopCopyWith<$Res> {
  factory _$$TrainerPhysicalStopCopyWith(_$TrainerPhysicalStop value,
          $Res Function(_$TrainerPhysicalStop) then) =
      __$$TrainerPhysicalStopCopyWithImpl<$Res>;
  @useResult
  $Res call({String deviceId});
}

/// @nodoc
class __$$TrainerPhysicalStopCopyWithImpl<$Res>
    extends _$TrainerEventCopyWithImpl<$Res, _$TrainerPhysicalStop>
    implements _$$TrainerPhysicalStopCopyWith<$Res> {
  __$$TrainerPhysicalStopCopyWithImpl(
      _$TrainerPhysicalStop _value, $Res Function(_$TrainerPhysicalStop) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
  }) {
    return _then(_$TrainerPhysicalStop(
      null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TrainerPhysicalStop implements TrainerPhysicalStop {
  const _$TrainerPhysicalStop(this.deviceId);

  @override
  final String deviceId;

  @override
  String toString() {
    return 'TrainerEvent.physicalStop(deviceId: $deviceId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerPhysicalStop &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerPhysicalStopCopyWith<_$TrainerPhysicalStop> get copyWith =>
      __$$TrainerPhysicalStopCopyWithImpl<_$TrainerPhysicalStop>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TrainerDevice device) connected,
    required TResult Function(String deviceId) disconnected,
    required TResult Function(String deviceId) controlAcquired,
    required TResult Function(String deviceId, ControlMode mode) modeChanged,
    required TResult Function(String deviceId) physicalStop,
    required TResult Function(String deviceId) safetyStop,
  }) {
    return physicalStop(deviceId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TrainerDevice device)? connected,
    TResult? Function(String deviceId)? disconnected,
    TResult? Function(String deviceId)? controlAcquired,
    TResult? Function(String deviceId, ControlMode mode)? modeChanged,
    TResult? Function(String deviceId)? physicalStop,
    TResult? Function(String deviceId)? safetyStop,
  }) {
    return physicalStop?.call(deviceId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TrainerDevice device)? connected,
    TResult Function(String deviceId)? disconnected,
    TResult Function(String deviceId)? controlAcquired,
    TResult Function(String deviceId, ControlMode mode)? modeChanged,
    TResult Function(String deviceId)? physicalStop,
    TResult Function(String deviceId)? safetyStop,
    required TResult orElse(),
  }) {
    if (physicalStop != null) {
      return physicalStop(deviceId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrainerConnected value) connected,
    required TResult Function(TrainerDisconnected value) disconnected,
    required TResult Function(TrainerControlAcquired value) controlAcquired,
    required TResult Function(TrainerModeChanged value) modeChanged,
    required TResult Function(TrainerPhysicalStop value) physicalStop,
    required TResult Function(TrainerSafetyStop value) safetyStop,
  }) {
    return physicalStop(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerConnected value)? connected,
    TResult? Function(TrainerDisconnected value)? disconnected,
    TResult? Function(TrainerControlAcquired value)? controlAcquired,
    TResult? Function(TrainerModeChanged value)? modeChanged,
    TResult? Function(TrainerPhysicalStop value)? physicalStop,
    TResult? Function(TrainerSafetyStop value)? safetyStop,
  }) {
    return physicalStop?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerConnected value)? connected,
    TResult Function(TrainerDisconnected value)? disconnected,
    TResult Function(TrainerControlAcquired value)? controlAcquired,
    TResult Function(TrainerModeChanged value)? modeChanged,
    TResult Function(TrainerPhysicalStop value)? physicalStop,
    TResult Function(TrainerSafetyStop value)? safetyStop,
    required TResult orElse(),
  }) {
    if (physicalStop != null) {
      return physicalStop(this);
    }
    return orElse();
  }
}

abstract class TrainerPhysicalStop implements TrainerEvent {
  const factory TrainerPhysicalStop(final String deviceId) =
      _$TrainerPhysicalStop;

  String get deviceId;
  @JsonKey(ignore: true)
  _$$TrainerPhysicalStopCopyWith<_$TrainerPhysicalStop> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrainerSafetyStopCopyWith<$Res> {
  factory _$$TrainerSafetyStopCopyWith(_$TrainerSafetyStop value,
          $Res Function(_$TrainerSafetyStop) then) =
      __$$TrainerSafetyStopCopyWithImpl<$Res>;
  @useResult
  $Res call({String deviceId});
}

/// @nodoc
class __$$TrainerSafetyStopCopyWithImpl<$Res>
    extends _$TrainerEventCopyWithImpl<$Res, _$TrainerSafetyStop>
    implements _$$TrainerSafetyStopCopyWith<$Res> {
  __$$TrainerSafetyStopCopyWithImpl(
      _$TrainerSafetyStop _value, $Res Function(_$TrainerSafetyStop) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
  }) {
    return _then(_$TrainerSafetyStop(
      null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TrainerSafetyStop implements TrainerSafetyStop {
  const _$TrainerSafetyStop(this.deviceId);

  @override
  final String deviceId;

  @override
  String toString() {
    return 'TrainerEvent.safetyStop(deviceId: $deviceId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerSafetyStop &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerSafetyStopCopyWith<_$TrainerSafetyStop> get copyWith =>
      __$$TrainerSafetyStopCopyWithImpl<_$TrainerSafetyStop>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TrainerDevice device) connected,
    required TResult Function(String deviceId) disconnected,
    required TResult Function(String deviceId) controlAcquired,
    required TResult Function(String deviceId, ControlMode mode) modeChanged,
    required TResult Function(String deviceId) physicalStop,
    required TResult Function(String deviceId) safetyStop,
  }) {
    return safetyStop(deviceId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TrainerDevice device)? connected,
    TResult? Function(String deviceId)? disconnected,
    TResult? Function(String deviceId)? controlAcquired,
    TResult? Function(String deviceId, ControlMode mode)? modeChanged,
    TResult? Function(String deviceId)? physicalStop,
    TResult? Function(String deviceId)? safetyStop,
  }) {
    return safetyStop?.call(deviceId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TrainerDevice device)? connected,
    TResult Function(String deviceId)? disconnected,
    TResult Function(String deviceId)? controlAcquired,
    TResult Function(String deviceId, ControlMode mode)? modeChanged,
    TResult Function(String deviceId)? physicalStop,
    TResult Function(String deviceId)? safetyStop,
    required TResult orElse(),
  }) {
    if (safetyStop != null) {
      return safetyStop(deviceId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrainerConnected value) connected,
    required TResult Function(TrainerDisconnected value) disconnected,
    required TResult Function(TrainerControlAcquired value) controlAcquired,
    required TResult Function(TrainerModeChanged value) modeChanged,
    required TResult Function(TrainerPhysicalStop value) physicalStop,
    required TResult Function(TrainerSafetyStop value) safetyStop,
  }) {
    return safetyStop(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerConnected value)? connected,
    TResult? Function(TrainerDisconnected value)? disconnected,
    TResult? Function(TrainerControlAcquired value)? controlAcquired,
    TResult? Function(TrainerModeChanged value)? modeChanged,
    TResult? Function(TrainerPhysicalStop value)? physicalStop,
    TResult? Function(TrainerSafetyStop value)? safetyStop,
  }) {
    return safetyStop?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerConnected value)? connected,
    TResult Function(TrainerDisconnected value)? disconnected,
    TResult Function(TrainerControlAcquired value)? controlAcquired,
    TResult Function(TrainerModeChanged value)? modeChanged,
    TResult Function(TrainerPhysicalStop value)? physicalStop,
    TResult Function(TrainerSafetyStop value)? safetyStop,
    required TResult orElse(),
  }) {
    if (safetyStop != null) {
      return safetyStop(this);
    }
    return orElse();
  }
}

abstract class TrainerSafetyStop implements TrainerEvent {
  const factory TrainerSafetyStop(final String deviceId) = _$TrainerSafetyStop;

  String get deviceId;
  @JsonKey(ignore: true)
  _$$TrainerSafetyStopCopyWith<_$TrainerSafetyStop> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WorkoutEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Workout workout) started,
    required TResult Function(WorkoutStep step, int index) stepChanged,
    required TResult Function() completed,
    required TResult Function() paused,
    required TResult Function() resumed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Workout workout)? started,
    TResult? Function(WorkoutStep step, int index)? stepChanged,
    TResult? Function()? completed,
    TResult? Function()? paused,
    TResult? Function()? resumed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Workout workout)? started,
    TResult Function(WorkoutStep step, int index)? stepChanged,
    TResult Function()? completed,
    TResult Function()? paused,
    TResult Function()? resumed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WorkoutStarted value) started,
    required TResult Function(WorkoutStepChanged value) stepChanged,
    required TResult Function(WorkoutCompleted value) completed,
    required TResult Function(WorkoutPaused value) paused,
    required TResult Function(WorkoutResumed value) resumed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WorkoutStarted value)? started,
    TResult? Function(WorkoutStepChanged value)? stepChanged,
    TResult? Function(WorkoutCompleted value)? completed,
    TResult? Function(WorkoutPaused value)? paused,
    TResult? Function(WorkoutResumed value)? resumed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WorkoutStarted value)? started,
    TResult Function(WorkoutStepChanged value)? stepChanged,
    TResult Function(WorkoutCompleted value)? completed,
    TResult Function(WorkoutPaused value)? paused,
    TResult Function(WorkoutResumed value)? resumed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutEventCopyWith<$Res> {
  factory $WorkoutEventCopyWith(
          WorkoutEvent value, $Res Function(WorkoutEvent) then) =
      _$WorkoutEventCopyWithImpl<$Res, WorkoutEvent>;
}

/// @nodoc
class _$WorkoutEventCopyWithImpl<$Res, $Val extends WorkoutEvent>
    implements $WorkoutEventCopyWith<$Res> {
  _$WorkoutEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$WorkoutStartedCopyWith<$Res> {
  factory _$$WorkoutStartedCopyWith(
          _$WorkoutStarted value, $Res Function(_$WorkoutStarted) then) =
      __$$WorkoutStartedCopyWithImpl<$Res>;
  @useResult
  $Res call({Workout workout});

  $WorkoutCopyWith<$Res> get workout;
}

/// @nodoc
class __$$WorkoutStartedCopyWithImpl<$Res>
    extends _$WorkoutEventCopyWithImpl<$Res, _$WorkoutStarted>
    implements _$$WorkoutStartedCopyWith<$Res> {
  __$$WorkoutStartedCopyWithImpl(
      _$WorkoutStarted _value, $Res Function(_$WorkoutStarted) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workout = null,
  }) {
    return _then(_$WorkoutStarted(
      null == workout
          ? _value.workout
          : workout // ignore: cast_nullable_to_non_nullable
              as Workout,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $WorkoutCopyWith<$Res> get workout {
    return $WorkoutCopyWith<$Res>(_value.workout, (value) {
      return _then(_value.copyWith(workout: value));
    });
  }
}

/// @nodoc

class _$WorkoutStarted implements WorkoutStarted {
  const _$WorkoutStarted(this.workout);

  @override
  final Workout workout;

  @override
  String toString() {
    return 'WorkoutEvent.started(workout: $workout)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutStarted &&
            (identical(other.workout, workout) || other.workout == workout));
  }

  @override
  int get hashCode => Object.hash(runtimeType, workout);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutStartedCopyWith<_$WorkoutStarted> get copyWith =>
      __$$WorkoutStartedCopyWithImpl<_$WorkoutStarted>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Workout workout) started,
    required TResult Function(WorkoutStep step, int index) stepChanged,
    required TResult Function() completed,
    required TResult Function() paused,
    required TResult Function() resumed,
  }) {
    return started(workout);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Workout workout)? started,
    TResult? Function(WorkoutStep step, int index)? stepChanged,
    TResult? Function()? completed,
    TResult? Function()? paused,
    TResult? Function()? resumed,
  }) {
    return started?.call(workout);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Workout workout)? started,
    TResult Function(WorkoutStep step, int index)? stepChanged,
    TResult Function()? completed,
    TResult Function()? paused,
    TResult Function()? resumed,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(workout);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WorkoutStarted value) started,
    required TResult Function(WorkoutStepChanged value) stepChanged,
    required TResult Function(WorkoutCompleted value) completed,
    required TResult Function(WorkoutPaused value) paused,
    required TResult Function(WorkoutResumed value) resumed,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WorkoutStarted value)? started,
    TResult? Function(WorkoutStepChanged value)? stepChanged,
    TResult? Function(WorkoutCompleted value)? completed,
    TResult? Function(WorkoutPaused value)? paused,
    TResult? Function(WorkoutResumed value)? resumed,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WorkoutStarted value)? started,
    TResult Function(WorkoutStepChanged value)? stepChanged,
    TResult Function(WorkoutCompleted value)? completed,
    TResult Function(WorkoutPaused value)? paused,
    TResult Function(WorkoutResumed value)? resumed,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class WorkoutStarted implements WorkoutEvent {
  const factory WorkoutStarted(final Workout workout) = _$WorkoutStarted;

  Workout get workout;
  @JsonKey(ignore: true)
  _$$WorkoutStartedCopyWith<_$WorkoutStarted> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WorkoutStepChangedCopyWith<$Res> {
  factory _$$WorkoutStepChangedCopyWith(_$WorkoutStepChanged value,
          $Res Function(_$WorkoutStepChanged) then) =
      __$$WorkoutStepChangedCopyWithImpl<$Res>;
  @useResult
  $Res call({WorkoutStep step, int index});

  $WorkoutStepCopyWith<$Res> get step;
}

/// @nodoc
class __$$WorkoutStepChangedCopyWithImpl<$Res>
    extends _$WorkoutEventCopyWithImpl<$Res, _$WorkoutStepChanged>
    implements _$$WorkoutStepChangedCopyWith<$Res> {
  __$$WorkoutStepChangedCopyWithImpl(
      _$WorkoutStepChanged _value, $Res Function(_$WorkoutStepChanged) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? index = null,
  }) {
    return _then(_$WorkoutStepChanged(
      null == step
          ? _value.step
          : step // ignore: cast_nullable_to_non_nullable
              as WorkoutStep,
      null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $WorkoutStepCopyWith<$Res> get step {
    return $WorkoutStepCopyWith<$Res>(_value.step, (value) {
      return _then(_value.copyWith(step: value));
    });
  }
}

/// @nodoc

class _$WorkoutStepChanged implements WorkoutStepChanged {
  const _$WorkoutStepChanged(this.step, this.index);

  @override
  final WorkoutStep step;
  @override
  final int index;

  @override
  String toString() {
    return 'WorkoutEvent.stepChanged(step: $step, index: $index)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutStepChanged &&
            (identical(other.step, step) || other.step == step) &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(runtimeType, step, index);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutStepChangedCopyWith<_$WorkoutStepChanged> get copyWith =>
      __$$WorkoutStepChangedCopyWithImpl<_$WorkoutStepChanged>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Workout workout) started,
    required TResult Function(WorkoutStep step, int index) stepChanged,
    required TResult Function() completed,
    required TResult Function() paused,
    required TResult Function() resumed,
  }) {
    return stepChanged(step, index);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Workout workout)? started,
    TResult? Function(WorkoutStep step, int index)? stepChanged,
    TResult? Function()? completed,
    TResult? Function()? paused,
    TResult? Function()? resumed,
  }) {
    return stepChanged?.call(step, index);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Workout workout)? started,
    TResult Function(WorkoutStep step, int index)? stepChanged,
    TResult Function()? completed,
    TResult Function()? paused,
    TResult Function()? resumed,
    required TResult orElse(),
  }) {
    if (stepChanged != null) {
      return stepChanged(step, index);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WorkoutStarted value) started,
    required TResult Function(WorkoutStepChanged value) stepChanged,
    required TResult Function(WorkoutCompleted value) completed,
    required TResult Function(WorkoutPaused value) paused,
    required TResult Function(WorkoutResumed value) resumed,
  }) {
    return stepChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WorkoutStarted value)? started,
    TResult? Function(WorkoutStepChanged value)? stepChanged,
    TResult? Function(WorkoutCompleted value)? completed,
    TResult? Function(WorkoutPaused value)? paused,
    TResult? Function(WorkoutResumed value)? resumed,
  }) {
    return stepChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WorkoutStarted value)? started,
    TResult Function(WorkoutStepChanged value)? stepChanged,
    TResult Function(WorkoutCompleted value)? completed,
    TResult Function(WorkoutPaused value)? paused,
    TResult Function(WorkoutResumed value)? resumed,
    required TResult orElse(),
  }) {
    if (stepChanged != null) {
      return stepChanged(this);
    }
    return orElse();
  }
}

abstract class WorkoutStepChanged implements WorkoutEvent {
  const factory WorkoutStepChanged(final WorkoutStep step, final int index) =
      _$WorkoutStepChanged;

  WorkoutStep get step;
  int get index;
  @JsonKey(ignore: true)
  _$$WorkoutStepChangedCopyWith<_$WorkoutStepChanged> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WorkoutCompletedCopyWith<$Res> {
  factory _$$WorkoutCompletedCopyWith(
          _$WorkoutCompleted value, $Res Function(_$WorkoutCompleted) then) =
      __$$WorkoutCompletedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$WorkoutCompletedCopyWithImpl<$Res>
    extends _$WorkoutEventCopyWithImpl<$Res, _$WorkoutCompleted>
    implements _$$WorkoutCompletedCopyWith<$Res> {
  __$$WorkoutCompletedCopyWithImpl(
      _$WorkoutCompleted _value, $Res Function(_$WorkoutCompleted) _then)
      : super(_value, _then);
}

/// @nodoc

class _$WorkoutCompleted implements WorkoutCompleted {
  const _$WorkoutCompleted();

  @override
  String toString() {
    return 'WorkoutEvent.completed()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$WorkoutCompleted);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Workout workout) started,
    required TResult Function(WorkoutStep step, int index) stepChanged,
    required TResult Function() completed,
    required TResult Function() paused,
    required TResult Function() resumed,
  }) {
    return completed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Workout workout)? started,
    TResult? Function(WorkoutStep step, int index)? stepChanged,
    TResult? Function()? completed,
    TResult? Function()? paused,
    TResult? Function()? resumed,
  }) {
    return completed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Workout workout)? started,
    TResult Function(WorkoutStep step, int index)? stepChanged,
    TResult Function()? completed,
    TResult Function()? paused,
    TResult Function()? resumed,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WorkoutStarted value) started,
    required TResult Function(WorkoutStepChanged value) stepChanged,
    required TResult Function(WorkoutCompleted value) completed,
    required TResult Function(WorkoutPaused value) paused,
    required TResult Function(WorkoutResumed value) resumed,
  }) {
    return completed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WorkoutStarted value)? started,
    TResult? Function(WorkoutStepChanged value)? stepChanged,
    TResult? Function(WorkoutCompleted value)? completed,
    TResult? Function(WorkoutPaused value)? paused,
    TResult? Function(WorkoutResumed value)? resumed,
  }) {
    return completed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WorkoutStarted value)? started,
    TResult Function(WorkoutStepChanged value)? stepChanged,
    TResult Function(WorkoutCompleted value)? completed,
    TResult Function(WorkoutPaused value)? paused,
    TResult Function(WorkoutResumed value)? resumed,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class WorkoutCompleted implements WorkoutEvent {
  const factory WorkoutCompleted() = _$WorkoutCompleted;
}

/// @nodoc
abstract class _$$WorkoutPausedCopyWith<$Res> {
  factory _$$WorkoutPausedCopyWith(
          _$WorkoutPaused value, $Res Function(_$WorkoutPaused) then) =
      __$$WorkoutPausedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$WorkoutPausedCopyWithImpl<$Res>
    extends _$WorkoutEventCopyWithImpl<$Res, _$WorkoutPaused>
    implements _$$WorkoutPausedCopyWith<$Res> {
  __$$WorkoutPausedCopyWithImpl(
      _$WorkoutPaused _value, $Res Function(_$WorkoutPaused) _then)
      : super(_value, _then);
}

/// @nodoc

class _$WorkoutPaused implements WorkoutPaused {
  const _$WorkoutPaused();

  @override
  String toString() {
    return 'WorkoutEvent.paused()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$WorkoutPaused);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Workout workout) started,
    required TResult Function(WorkoutStep step, int index) stepChanged,
    required TResult Function() completed,
    required TResult Function() paused,
    required TResult Function() resumed,
  }) {
    return paused();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Workout workout)? started,
    TResult? Function(WorkoutStep step, int index)? stepChanged,
    TResult? Function()? completed,
    TResult? Function()? paused,
    TResult? Function()? resumed,
  }) {
    return paused?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Workout workout)? started,
    TResult Function(WorkoutStep step, int index)? stepChanged,
    TResult Function()? completed,
    TResult Function()? paused,
    TResult Function()? resumed,
    required TResult orElse(),
  }) {
    if (paused != null) {
      return paused();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WorkoutStarted value) started,
    required TResult Function(WorkoutStepChanged value) stepChanged,
    required TResult Function(WorkoutCompleted value) completed,
    required TResult Function(WorkoutPaused value) paused,
    required TResult Function(WorkoutResumed value) resumed,
  }) {
    return paused(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WorkoutStarted value)? started,
    TResult? Function(WorkoutStepChanged value)? stepChanged,
    TResult? Function(WorkoutCompleted value)? completed,
    TResult? Function(WorkoutPaused value)? paused,
    TResult? Function(WorkoutResumed value)? resumed,
  }) {
    return paused?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WorkoutStarted value)? started,
    TResult Function(WorkoutStepChanged value)? stepChanged,
    TResult Function(WorkoutCompleted value)? completed,
    TResult Function(WorkoutPaused value)? paused,
    TResult Function(WorkoutResumed value)? resumed,
    required TResult orElse(),
  }) {
    if (paused != null) {
      return paused(this);
    }
    return orElse();
  }
}

abstract class WorkoutPaused implements WorkoutEvent {
  const factory WorkoutPaused() = _$WorkoutPaused;
}

/// @nodoc
abstract class _$$WorkoutResumedCopyWith<$Res> {
  factory _$$WorkoutResumedCopyWith(
          _$WorkoutResumed value, $Res Function(_$WorkoutResumed) then) =
      __$$WorkoutResumedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$WorkoutResumedCopyWithImpl<$Res>
    extends _$WorkoutEventCopyWithImpl<$Res, _$WorkoutResumed>
    implements _$$WorkoutResumedCopyWith<$Res> {
  __$$WorkoutResumedCopyWithImpl(
      _$WorkoutResumed _value, $Res Function(_$WorkoutResumed) _then)
      : super(_value, _then);
}

/// @nodoc

class _$WorkoutResumed implements WorkoutResumed {
  const _$WorkoutResumed();

  @override
  String toString() {
    return 'WorkoutEvent.resumed()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$WorkoutResumed);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Workout workout) started,
    required TResult Function(WorkoutStep step, int index) stepChanged,
    required TResult Function() completed,
    required TResult Function() paused,
    required TResult Function() resumed,
  }) {
    return resumed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Workout workout)? started,
    TResult? Function(WorkoutStep step, int index)? stepChanged,
    TResult? Function()? completed,
    TResult? Function()? paused,
    TResult? Function()? resumed,
  }) {
    return resumed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Workout workout)? started,
    TResult Function(WorkoutStep step, int index)? stepChanged,
    TResult Function()? completed,
    TResult Function()? paused,
    TResult Function()? resumed,
    required TResult orElse(),
  }) {
    if (resumed != null) {
      return resumed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WorkoutStarted value) started,
    required TResult Function(WorkoutStepChanged value) stepChanged,
    required TResult Function(WorkoutCompleted value) completed,
    required TResult Function(WorkoutPaused value) paused,
    required TResult Function(WorkoutResumed value) resumed,
  }) {
    return resumed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WorkoutStarted value)? started,
    TResult? Function(WorkoutStepChanged value)? stepChanged,
    TResult? Function(WorkoutCompleted value)? completed,
    TResult? Function(WorkoutPaused value)? paused,
    TResult? Function(WorkoutResumed value)? resumed,
  }) {
    return resumed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WorkoutStarted value)? started,
    TResult Function(WorkoutStepChanged value)? stepChanged,
    TResult Function(WorkoutCompleted value)? completed,
    TResult Function(WorkoutPaused value)? paused,
    TResult Function(WorkoutResumed value)? resumed,
    required TResult orElse(),
  }) {
    if (resumed != null) {
      return resumed(this);
    }
    return orElse();
  }
}

abstract class WorkoutResumed implements WorkoutEvent {
  const factory WorkoutResumed() = _$WorkoutResumed;
}

/// @nodoc
mixin _$RideEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String rideId) started,
    required TResult Function(String rideId) paused,
    required TResult Function(String rideId) resumed,
    required TResult Function(String rideId, Lap lap) lapMarked,
    required TResult Function(Ride ride) stopped,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String rideId)? started,
    TResult? Function(String rideId)? paused,
    TResult? Function(String rideId)? resumed,
    TResult? Function(String rideId, Lap lap)? lapMarked,
    TResult? Function(Ride ride)? stopped,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String rideId)? started,
    TResult Function(String rideId)? paused,
    TResult Function(String rideId)? resumed,
    TResult Function(String rideId, Lap lap)? lapMarked,
    TResult Function(Ride ride)? stopped,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RideStarted value) started,
    required TResult Function(RidePaused value) paused,
    required TResult Function(RideResumed value) resumed,
    required TResult Function(RideLapMarked value) lapMarked,
    required TResult Function(RideStopped value) stopped,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RideStarted value)? started,
    TResult? Function(RidePaused value)? paused,
    TResult? Function(RideResumed value)? resumed,
    TResult? Function(RideLapMarked value)? lapMarked,
    TResult? Function(RideStopped value)? stopped,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RideStarted value)? started,
    TResult Function(RidePaused value)? paused,
    TResult Function(RideResumed value)? resumed,
    TResult Function(RideLapMarked value)? lapMarked,
    TResult Function(RideStopped value)? stopped,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RideEventCopyWith<$Res> {
  factory $RideEventCopyWith(RideEvent value, $Res Function(RideEvent) then) =
      _$RideEventCopyWithImpl<$Res, RideEvent>;
}

/// @nodoc
class _$RideEventCopyWithImpl<$Res, $Val extends RideEvent>
    implements $RideEventCopyWith<$Res> {
  _$RideEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$RideStartedCopyWith<$Res> {
  factory _$$RideStartedCopyWith(
          _$RideStarted value, $Res Function(_$RideStarted) then) =
      __$$RideStartedCopyWithImpl<$Res>;
  @useResult
  $Res call({String rideId});
}

/// @nodoc
class __$$RideStartedCopyWithImpl<$Res>
    extends _$RideEventCopyWithImpl<$Res, _$RideStarted>
    implements _$$RideStartedCopyWith<$Res> {
  __$$RideStartedCopyWithImpl(
      _$RideStarted _value, $Res Function(_$RideStarted) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
  }) {
    return _then(_$RideStarted(
      null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RideStarted implements RideStarted {
  const _$RideStarted(this.rideId);

  @override
  final String rideId;

  @override
  String toString() {
    return 'RideEvent.started(rideId: $rideId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RideStarted &&
            (identical(other.rideId, rideId) || other.rideId == rideId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RideStartedCopyWith<_$RideStarted> get copyWith =>
      __$$RideStartedCopyWithImpl<_$RideStarted>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String rideId) started,
    required TResult Function(String rideId) paused,
    required TResult Function(String rideId) resumed,
    required TResult Function(String rideId, Lap lap) lapMarked,
    required TResult Function(Ride ride) stopped,
  }) {
    return started(rideId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String rideId)? started,
    TResult? Function(String rideId)? paused,
    TResult? Function(String rideId)? resumed,
    TResult? Function(String rideId, Lap lap)? lapMarked,
    TResult? Function(Ride ride)? stopped,
  }) {
    return started?.call(rideId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String rideId)? started,
    TResult Function(String rideId)? paused,
    TResult Function(String rideId)? resumed,
    TResult Function(String rideId, Lap lap)? lapMarked,
    TResult Function(Ride ride)? stopped,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(rideId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RideStarted value) started,
    required TResult Function(RidePaused value) paused,
    required TResult Function(RideResumed value) resumed,
    required TResult Function(RideLapMarked value) lapMarked,
    required TResult Function(RideStopped value) stopped,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RideStarted value)? started,
    TResult? Function(RidePaused value)? paused,
    TResult? Function(RideResumed value)? resumed,
    TResult? Function(RideLapMarked value)? lapMarked,
    TResult? Function(RideStopped value)? stopped,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RideStarted value)? started,
    TResult Function(RidePaused value)? paused,
    TResult Function(RideResumed value)? resumed,
    TResult Function(RideLapMarked value)? lapMarked,
    TResult Function(RideStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class RideStarted implements RideEvent {
  const factory RideStarted(final String rideId) = _$RideStarted;

  String get rideId;
  @JsonKey(ignore: true)
  _$$RideStartedCopyWith<_$RideStarted> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RidePausedCopyWith<$Res> {
  factory _$$RidePausedCopyWith(
          _$RidePaused value, $Res Function(_$RidePaused) then) =
      __$$RidePausedCopyWithImpl<$Res>;
  @useResult
  $Res call({String rideId});
}

/// @nodoc
class __$$RidePausedCopyWithImpl<$Res>
    extends _$RideEventCopyWithImpl<$Res, _$RidePaused>
    implements _$$RidePausedCopyWith<$Res> {
  __$$RidePausedCopyWithImpl(
      _$RidePaused _value, $Res Function(_$RidePaused) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
  }) {
    return _then(_$RidePaused(
      null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RidePaused implements RidePaused {
  const _$RidePaused(this.rideId);

  @override
  final String rideId;

  @override
  String toString() {
    return 'RideEvent.paused(rideId: $rideId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RidePaused &&
            (identical(other.rideId, rideId) || other.rideId == rideId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RidePausedCopyWith<_$RidePaused> get copyWith =>
      __$$RidePausedCopyWithImpl<_$RidePaused>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String rideId) started,
    required TResult Function(String rideId) paused,
    required TResult Function(String rideId) resumed,
    required TResult Function(String rideId, Lap lap) lapMarked,
    required TResult Function(Ride ride) stopped,
  }) {
    return paused(rideId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String rideId)? started,
    TResult? Function(String rideId)? paused,
    TResult? Function(String rideId)? resumed,
    TResult? Function(String rideId, Lap lap)? lapMarked,
    TResult? Function(Ride ride)? stopped,
  }) {
    return paused?.call(rideId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String rideId)? started,
    TResult Function(String rideId)? paused,
    TResult Function(String rideId)? resumed,
    TResult Function(String rideId, Lap lap)? lapMarked,
    TResult Function(Ride ride)? stopped,
    required TResult orElse(),
  }) {
    if (paused != null) {
      return paused(rideId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RideStarted value) started,
    required TResult Function(RidePaused value) paused,
    required TResult Function(RideResumed value) resumed,
    required TResult Function(RideLapMarked value) lapMarked,
    required TResult Function(RideStopped value) stopped,
  }) {
    return paused(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RideStarted value)? started,
    TResult? Function(RidePaused value)? paused,
    TResult? Function(RideResumed value)? resumed,
    TResult? Function(RideLapMarked value)? lapMarked,
    TResult? Function(RideStopped value)? stopped,
  }) {
    return paused?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RideStarted value)? started,
    TResult Function(RidePaused value)? paused,
    TResult Function(RideResumed value)? resumed,
    TResult Function(RideLapMarked value)? lapMarked,
    TResult Function(RideStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (paused != null) {
      return paused(this);
    }
    return orElse();
  }
}

abstract class RidePaused implements RideEvent {
  const factory RidePaused(final String rideId) = _$RidePaused;

  String get rideId;
  @JsonKey(ignore: true)
  _$$RidePausedCopyWith<_$RidePaused> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RideResumedCopyWith<$Res> {
  factory _$$RideResumedCopyWith(
          _$RideResumed value, $Res Function(_$RideResumed) then) =
      __$$RideResumedCopyWithImpl<$Res>;
  @useResult
  $Res call({String rideId});
}

/// @nodoc
class __$$RideResumedCopyWithImpl<$Res>
    extends _$RideEventCopyWithImpl<$Res, _$RideResumed>
    implements _$$RideResumedCopyWith<$Res> {
  __$$RideResumedCopyWithImpl(
      _$RideResumed _value, $Res Function(_$RideResumed) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
  }) {
    return _then(_$RideResumed(
      null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RideResumed implements RideResumed {
  const _$RideResumed(this.rideId);

  @override
  final String rideId;

  @override
  String toString() {
    return 'RideEvent.resumed(rideId: $rideId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RideResumed &&
            (identical(other.rideId, rideId) || other.rideId == rideId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RideResumedCopyWith<_$RideResumed> get copyWith =>
      __$$RideResumedCopyWithImpl<_$RideResumed>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String rideId) started,
    required TResult Function(String rideId) paused,
    required TResult Function(String rideId) resumed,
    required TResult Function(String rideId, Lap lap) lapMarked,
    required TResult Function(Ride ride) stopped,
  }) {
    return resumed(rideId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String rideId)? started,
    TResult? Function(String rideId)? paused,
    TResult? Function(String rideId)? resumed,
    TResult? Function(String rideId, Lap lap)? lapMarked,
    TResult? Function(Ride ride)? stopped,
  }) {
    return resumed?.call(rideId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String rideId)? started,
    TResult Function(String rideId)? paused,
    TResult Function(String rideId)? resumed,
    TResult Function(String rideId, Lap lap)? lapMarked,
    TResult Function(Ride ride)? stopped,
    required TResult orElse(),
  }) {
    if (resumed != null) {
      return resumed(rideId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RideStarted value) started,
    required TResult Function(RidePaused value) paused,
    required TResult Function(RideResumed value) resumed,
    required TResult Function(RideLapMarked value) lapMarked,
    required TResult Function(RideStopped value) stopped,
  }) {
    return resumed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RideStarted value)? started,
    TResult? Function(RidePaused value)? paused,
    TResult? Function(RideResumed value)? resumed,
    TResult? Function(RideLapMarked value)? lapMarked,
    TResult? Function(RideStopped value)? stopped,
  }) {
    return resumed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RideStarted value)? started,
    TResult Function(RidePaused value)? paused,
    TResult Function(RideResumed value)? resumed,
    TResult Function(RideLapMarked value)? lapMarked,
    TResult Function(RideStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (resumed != null) {
      return resumed(this);
    }
    return orElse();
  }
}

abstract class RideResumed implements RideEvent {
  const factory RideResumed(final String rideId) = _$RideResumed;

  String get rideId;
  @JsonKey(ignore: true)
  _$$RideResumedCopyWith<_$RideResumed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RideLapMarkedCopyWith<$Res> {
  factory _$$RideLapMarkedCopyWith(
          _$RideLapMarked value, $Res Function(_$RideLapMarked) then) =
      __$$RideLapMarkedCopyWithImpl<$Res>;
  @useResult
  $Res call({String rideId, Lap lap});

  $LapCopyWith<$Res> get lap;
}

/// @nodoc
class __$$RideLapMarkedCopyWithImpl<$Res>
    extends _$RideEventCopyWithImpl<$Res, _$RideLapMarked>
    implements _$$RideLapMarkedCopyWith<$Res> {
  __$$RideLapMarkedCopyWithImpl(
      _$RideLapMarked _value, $Res Function(_$RideLapMarked) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? lap = null,
  }) {
    return _then(_$RideLapMarked(
      null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      null == lap
          ? _value.lap
          : lap // ignore: cast_nullable_to_non_nullable
              as Lap,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $LapCopyWith<$Res> get lap {
    return $LapCopyWith<$Res>(_value.lap, (value) {
      return _then(_value.copyWith(lap: value));
    });
  }
}

/// @nodoc

class _$RideLapMarked implements RideLapMarked {
  const _$RideLapMarked(this.rideId, this.lap);

  @override
  final String rideId;
  @override
  final Lap lap;

  @override
  String toString() {
    return 'RideEvent.lapMarked(rideId: $rideId, lap: $lap)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RideLapMarked &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.lap, lap) || other.lap == lap));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId, lap);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RideLapMarkedCopyWith<_$RideLapMarked> get copyWith =>
      __$$RideLapMarkedCopyWithImpl<_$RideLapMarked>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String rideId) started,
    required TResult Function(String rideId) paused,
    required TResult Function(String rideId) resumed,
    required TResult Function(String rideId, Lap lap) lapMarked,
    required TResult Function(Ride ride) stopped,
  }) {
    return lapMarked(rideId, lap);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String rideId)? started,
    TResult? Function(String rideId)? paused,
    TResult? Function(String rideId)? resumed,
    TResult? Function(String rideId, Lap lap)? lapMarked,
    TResult? Function(Ride ride)? stopped,
  }) {
    return lapMarked?.call(rideId, lap);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String rideId)? started,
    TResult Function(String rideId)? paused,
    TResult Function(String rideId)? resumed,
    TResult Function(String rideId, Lap lap)? lapMarked,
    TResult Function(Ride ride)? stopped,
    required TResult orElse(),
  }) {
    if (lapMarked != null) {
      return lapMarked(rideId, lap);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RideStarted value) started,
    required TResult Function(RidePaused value) paused,
    required TResult Function(RideResumed value) resumed,
    required TResult Function(RideLapMarked value) lapMarked,
    required TResult Function(RideStopped value) stopped,
  }) {
    return lapMarked(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RideStarted value)? started,
    TResult? Function(RidePaused value)? paused,
    TResult? Function(RideResumed value)? resumed,
    TResult? Function(RideLapMarked value)? lapMarked,
    TResult? Function(RideStopped value)? stopped,
  }) {
    return lapMarked?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RideStarted value)? started,
    TResult Function(RidePaused value)? paused,
    TResult Function(RideResumed value)? resumed,
    TResult Function(RideLapMarked value)? lapMarked,
    TResult Function(RideStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (lapMarked != null) {
      return lapMarked(this);
    }
    return orElse();
  }
}

abstract class RideLapMarked implements RideEvent {
  const factory RideLapMarked(final String rideId, final Lap lap) =
      _$RideLapMarked;

  String get rideId;
  Lap get lap;
  @JsonKey(ignore: true)
  _$$RideLapMarkedCopyWith<_$RideLapMarked> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RideStoppedCopyWith<$Res> {
  factory _$$RideStoppedCopyWith(
          _$RideStopped value, $Res Function(_$RideStopped) then) =
      __$$RideStoppedCopyWithImpl<$Res>;
  @useResult
  $Res call({Ride ride});

  $RideCopyWith<$Res> get ride;
}

/// @nodoc
class __$$RideStoppedCopyWithImpl<$Res>
    extends _$RideEventCopyWithImpl<$Res, _$RideStopped>
    implements _$$RideStoppedCopyWith<$Res> {
  __$$RideStoppedCopyWithImpl(
      _$RideStopped _value, $Res Function(_$RideStopped) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ride = null,
  }) {
    return _then(_$RideStopped(
      null == ride
          ? _value.ride
          : ride // ignore: cast_nullable_to_non_nullable
              as Ride,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $RideCopyWith<$Res> get ride {
    return $RideCopyWith<$Res>(_value.ride, (value) {
      return _then(_value.copyWith(ride: value));
    });
  }
}

/// @nodoc

class _$RideStopped implements RideStopped {
  const _$RideStopped(this.ride);

  @override
  final Ride ride;

  @override
  String toString() {
    return 'RideEvent.stopped(ride: $ride)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RideStopped &&
            (identical(other.ride, ride) || other.ride == ride));
  }

  @override
  int get hashCode => Object.hash(runtimeType, ride);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RideStoppedCopyWith<_$RideStopped> get copyWith =>
      __$$RideStoppedCopyWithImpl<_$RideStopped>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String rideId) started,
    required TResult Function(String rideId) paused,
    required TResult Function(String rideId) resumed,
    required TResult Function(String rideId, Lap lap) lapMarked,
    required TResult Function(Ride ride) stopped,
  }) {
    return stopped(ride);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String rideId)? started,
    TResult? Function(String rideId)? paused,
    TResult? Function(String rideId)? resumed,
    TResult? Function(String rideId, Lap lap)? lapMarked,
    TResult? Function(Ride ride)? stopped,
  }) {
    return stopped?.call(ride);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String rideId)? started,
    TResult Function(String rideId)? paused,
    TResult Function(String rideId)? resumed,
    TResult Function(String rideId, Lap lap)? lapMarked,
    TResult Function(Ride ride)? stopped,
    required TResult orElse(),
  }) {
    if (stopped != null) {
      return stopped(ride);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RideStarted value) started,
    required TResult Function(RidePaused value) paused,
    required TResult Function(RideResumed value) resumed,
    required TResult Function(RideLapMarked value) lapMarked,
    required TResult Function(RideStopped value) stopped,
  }) {
    return stopped(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RideStarted value)? started,
    TResult? Function(RidePaused value)? paused,
    TResult? Function(RideResumed value)? resumed,
    TResult? Function(RideLapMarked value)? lapMarked,
    TResult? Function(RideStopped value)? stopped,
  }) {
    return stopped?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RideStarted value)? started,
    TResult Function(RidePaused value)? paused,
    TResult Function(RideResumed value)? resumed,
    TResult Function(RideLapMarked value)? lapMarked,
    TResult Function(RideStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (stopped != null) {
      return stopped(this);
    }
    return orElse();
  }
}

abstract class RideStopped implements RideEvent {
  const factory RideStopped(final Ride ride) = _$RideStopped;

  Ride get ride;
  @JsonKey(ignore: true)
  _$$RideStoppedCopyWith<_$RideStopped> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SimulationEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Route route) started,
    required TResult Function(RoutePoint point, Speed speed) positionChanged,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() completed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Route route)? started,
    TResult? Function(RoutePoint point, Speed speed)? positionChanged,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? completed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Route route)? started,
    TResult Function(RoutePoint point, Speed speed)? positionChanged,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? completed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SimulationStarted value) started,
    required TResult Function(SimulationPositionChanged value) positionChanged,
    required TResult Function(SimulationPaused value) paused,
    required TResult Function(SimulationResumed value) resumed,
    required TResult Function(SimulationCompleted value) completed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SimulationStarted value)? started,
    TResult? Function(SimulationPositionChanged value)? positionChanged,
    TResult? Function(SimulationPaused value)? paused,
    TResult? Function(SimulationResumed value)? resumed,
    TResult? Function(SimulationCompleted value)? completed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SimulationStarted value)? started,
    TResult Function(SimulationPositionChanged value)? positionChanged,
    TResult Function(SimulationPaused value)? paused,
    TResult Function(SimulationResumed value)? resumed,
    TResult Function(SimulationCompleted value)? completed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimulationEventCopyWith<$Res> {
  factory $SimulationEventCopyWith(
          SimulationEvent value, $Res Function(SimulationEvent) then) =
      _$SimulationEventCopyWithImpl<$Res, SimulationEvent>;
}

/// @nodoc
class _$SimulationEventCopyWithImpl<$Res, $Val extends SimulationEvent>
    implements $SimulationEventCopyWith<$Res> {
  _$SimulationEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$SimulationStartedCopyWith<$Res> {
  factory _$$SimulationStartedCopyWith(
          _$SimulationStarted value, $Res Function(_$SimulationStarted) then) =
      __$$SimulationStartedCopyWithImpl<$Res>;
  @useResult
  $Res call({Route route});

  $RouteCopyWith<$Res> get route;
}

/// @nodoc
class __$$SimulationStartedCopyWithImpl<$Res>
    extends _$SimulationEventCopyWithImpl<$Res, _$SimulationStarted>
    implements _$$SimulationStartedCopyWith<$Res> {
  __$$SimulationStartedCopyWithImpl(
      _$SimulationStarted _value, $Res Function(_$SimulationStarted) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? route = null,
  }) {
    return _then(_$SimulationStarted(
      null == route
          ? _value.route
          : route // ignore: cast_nullable_to_non_nullable
              as Route,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $RouteCopyWith<$Res> get route {
    return $RouteCopyWith<$Res>(_value.route, (value) {
      return _then(_value.copyWith(route: value));
    });
  }
}

/// @nodoc

class _$SimulationStarted implements SimulationStarted {
  const _$SimulationStarted(this.route);

  @override
  final Route route;

  @override
  String toString() {
    return 'SimulationEvent.started(route: $route)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimulationStarted &&
            (identical(other.route, route) || other.route == route));
  }

  @override
  int get hashCode => Object.hash(runtimeType, route);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SimulationStartedCopyWith<_$SimulationStarted> get copyWith =>
      __$$SimulationStartedCopyWithImpl<_$SimulationStarted>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Route route) started,
    required TResult Function(RoutePoint point, Speed speed) positionChanged,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() completed,
  }) {
    return started(route);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Route route)? started,
    TResult? Function(RoutePoint point, Speed speed)? positionChanged,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? completed,
  }) {
    return started?.call(route);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Route route)? started,
    TResult Function(RoutePoint point, Speed speed)? positionChanged,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? completed,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(route);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SimulationStarted value) started,
    required TResult Function(SimulationPositionChanged value) positionChanged,
    required TResult Function(SimulationPaused value) paused,
    required TResult Function(SimulationResumed value) resumed,
    required TResult Function(SimulationCompleted value) completed,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SimulationStarted value)? started,
    TResult? Function(SimulationPositionChanged value)? positionChanged,
    TResult? Function(SimulationPaused value)? paused,
    TResult? Function(SimulationResumed value)? resumed,
    TResult? Function(SimulationCompleted value)? completed,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SimulationStarted value)? started,
    TResult Function(SimulationPositionChanged value)? positionChanged,
    TResult Function(SimulationPaused value)? paused,
    TResult Function(SimulationResumed value)? resumed,
    TResult Function(SimulationCompleted value)? completed,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class SimulationStarted implements SimulationEvent {
  const factory SimulationStarted(final Route route) = _$SimulationStarted;

  Route get route;
  @JsonKey(ignore: true)
  _$$SimulationStartedCopyWith<_$SimulationStarted> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SimulationPositionChangedCopyWith<$Res> {
  factory _$$SimulationPositionChangedCopyWith(
          _$SimulationPositionChanged value,
          $Res Function(_$SimulationPositionChanged) then) =
      __$$SimulationPositionChangedCopyWithImpl<$Res>;
  @useResult
  $Res call({RoutePoint point, Speed speed});

  $RoutePointCopyWith<$Res> get point;
  $SpeedCopyWith<$Res> get speed;
}

/// @nodoc
class __$$SimulationPositionChangedCopyWithImpl<$Res>
    extends _$SimulationEventCopyWithImpl<$Res, _$SimulationPositionChanged>
    implements _$$SimulationPositionChangedCopyWith<$Res> {
  __$$SimulationPositionChangedCopyWithImpl(_$SimulationPositionChanged _value,
      $Res Function(_$SimulationPositionChanged) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? point = null,
    Object? speed = null,
  }) {
    return _then(_$SimulationPositionChanged(
      null == point
          ? _value.point
          : point // ignore: cast_nullable_to_non_nullable
              as RoutePoint,
      null == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as Speed,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $RoutePointCopyWith<$Res> get point {
    return $RoutePointCopyWith<$Res>(_value.point, (value) {
      return _then(_value.copyWith(point: value));
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SpeedCopyWith<$Res> get speed {
    return $SpeedCopyWith<$Res>(_value.speed, (value) {
      return _then(_value.copyWith(speed: value));
    });
  }
}

/// @nodoc

class _$SimulationPositionChanged implements SimulationPositionChanged {
  const _$SimulationPositionChanged(this.point, this.speed);

  @override
  final RoutePoint point;
  @override
  final Speed speed;

  @override
  String toString() {
    return 'SimulationEvent.positionChanged(point: $point, speed: $speed)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimulationPositionChanged &&
            (identical(other.point, point) || other.point == point) &&
            (identical(other.speed, speed) || other.speed == speed));
  }

  @override
  int get hashCode => Object.hash(runtimeType, point, speed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SimulationPositionChangedCopyWith<_$SimulationPositionChanged>
      get copyWith => __$$SimulationPositionChangedCopyWithImpl<
          _$SimulationPositionChanged>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Route route) started,
    required TResult Function(RoutePoint point, Speed speed) positionChanged,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() completed,
  }) {
    return positionChanged(point, speed);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Route route)? started,
    TResult? Function(RoutePoint point, Speed speed)? positionChanged,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? completed,
  }) {
    return positionChanged?.call(point, speed);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Route route)? started,
    TResult Function(RoutePoint point, Speed speed)? positionChanged,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? completed,
    required TResult orElse(),
  }) {
    if (positionChanged != null) {
      return positionChanged(point, speed);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SimulationStarted value) started,
    required TResult Function(SimulationPositionChanged value) positionChanged,
    required TResult Function(SimulationPaused value) paused,
    required TResult Function(SimulationResumed value) resumed,
    required TResult Function(SimulationCompleted value) completed,
  }) {
    return positionChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SimulationStarted value)? started,
    TResult? Function(SimulationPositionChanged value)? positionChanged,
    TResult? Function(SimulationPaused value)? paused,
    TResult? Function(SimulationResumed value)? resumed,
    TResult? Function(SimulationCompleted value)? completed,
  }) {
    return positionChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SimulationStarted value)? started,
    TResult Function(SimulationPositionChanged value)? positionChanged,
    TResult Function(SimulationPaused value)? paused,
    TResult Function(SimulationResumed value)? resumed,
    TResult Function(SimulationCompleted value)? completed,
    required TResult orElse(),
  }) {
    if (positionChanged != null) {
      return positionChanged(this);
    }
    return orElse();
  }
}

abstract class SimulationPositionChanged implements SimulationEvent {
  const factory SimulationPositionChanged(
      final RoutePoint point, final Speed speed) = _$SimulationPositionChanged;

  RoutePoint get point;
  Speed get speed;
  @JsonKey(ignore: true)
  _$$SimulationPositionChangedCopyWith<_$SimulationPositionChanged>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SimulationPausedCopyWith<$Res> {
  factory _$$SimulationPausedCopyWith(
          _$SimulationPaused value, $Res Function(_$SimulationPaused) then) =
      __$$SimulationPausedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SimulationPausedCopyWithImpl<$Res>
    extends _$SimulationEventCopyWithImpl<$Res, _$SimulationPaused>
    implements _$$SimulationPausedCopyWith<$Res> {
  __$$SimulationPausedCopyWithImpl(
      _$SimulationPaused _value, $Res Function(_$SimulationPaused) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SimulationPaused implements SimulationPaused {
  const _$SimulationPaused();

  @override
  String toString() {
    return 'SimulationEvent.paused()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SimulationPaused);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Route route) started,
    required TResult Function(RoutePoint point, Speed speed) positionChanged,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() completed,
  }) {
    return paused();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Route route)? started,
    TResult? Function(RoutePoint point, Speed speed)? positionChanged,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? completed,
  }) {
    return paused?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Route route)? started,
    TResult Function(RoutePoint point, Speed speed)? positionChanged,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? completed,
    required TResult orElse(),
  }) {
    if (paused != null) {
      return paused();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SimulationStarted value) started,
    required TResult Function(SimulationPositionChanged value) positionChanged,
    required TResult Function(SimulationPaused value) paused,
    required TResult Function(SimulationResumed value) resumed,
    required TResult Function(SimulationCompleted value) completed,
  }) {
    return paused(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SimulationStarted value)? started,
    TResult? Function(SimulationPositionChanged value)? positionChanged,
    TResult? Function(SimulationPaused value)? paused,
    TResult? Function(SimulationResumed value)? resumed,
    TResult? Function(SimulationCompleted value)? completed,
  }) {
    return paused?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SimulationStarted value)? started,
    TResult Function(SimulationPositionChanged value)? positionChanged,
    TResult Function(SimulationPaused value)? paused,
    TResult Function(SimulationResumed value)? resumed,
    TResult Function(SimulationCompleted value)? completed,
    required TResult orElse(),
  }) {
    if (paused != null) {
      return paused(this);
    }
    return orElse();
  }
}

abstract class SimulationPaused implements SimulationEvent {
  const factory SimulationPaused() = _$SimulationPaused;
}

/// @nodoc
abstract class _$$SimulationResumedCopyWith<$Res> {
  factory _$$SimulationResumedCopyWith(
          _$SimulationResumed value, $Res Function(_$SimulationResumed) then) =
      __$$SimulationResumedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SimulationResumedCopyWithImpl<$Res>
    extends _$SimulationEventCopyWithImpl<$Res, _$SimulationResumed>
    implements _$$SimulationResumedCopyWith<$Res> {
  __$$SimulationResumedCopyWithImpl(
      _$SimulationResumed _value, $Res Function(_$SimulationResumed) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SimulationResumed implements SimulationResumed {
  const _$SimulationResumed();

  @override
  String toString() {
    return 'SimulationEvent.resumed()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SimulationResumed);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Route route) started,
    required TResult Function(RoutePoint point, Speed speed) positionChanged,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() completed,
  }) {
    return resumed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Route route)? started,
    TResult? Function(RoutePoint point, Speed speed)? positionChanged,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? completed,
  }) {
    return resumed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Route route)? started,
    TResult Function(RoutePoint point, Speed speed)? positionChanged,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? completed,
    required TResult orElse(),
  }) {
    if (resumed != null) {
      return resumed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SimulationStarted value) started,
    required TResult Function(SimulationPositionChanged value) positionChanged,
    required TResult Function(SimulationPaused value) paused,
    required TResult Function(SimulationResumed value) resumed,
    required TResult Function(SimulationCompleted value) completed,
  }) {
    return resumed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SimulationStarted value)? started,
    TResult? Function(SimulationPositionChanged value)? positionChanged,
    TResult? Function(SimulationPaused value)? paused,
    TResult? Function(SimulationResumed value)? resumed,
    TResult? Function(SimulationCompleted value)? completed,
  }) {
    return resumed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SimulationStarted value)? started,
    TResult Function(SimulationPositionChanged value)? positionChanged,
    TResult Function(SimulationPaused value)? paused,
    TResult Function(SimulationResumed value)? resumed,
    TResult Function(SimulationCompleted value)? completed,
    required TResult orElse(),
  }) {
    if (resumed != null) {
      return resumed(this);
    }
    return orElse();
  }
}

abstract class SimulationResumed implements SimulationEvent {
  const factory SimulationResumed() = _$SimulationResumed;
}

/// @nodoc
abstract class _$$SimulationCompletedCopyWith<$Res> {
  factory _$$SimulationCompletedCopyWith(_$SimulationCompleted value,
          $Res Function(_$SimulationCompleted) then) =
      __$$SimulationCompletedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SimulationCompletedCopyWithImpl<$Res>
    extends _$SimulationEventCopyWithImpl<$Res, _$SimulationCompleted>
    implements _$$SimulationCompletedCopyWith<$Res> {
  __$$SimulationCompletedCopyWithImpl(
      _$SimulationCompleted _value, $Res Function(_$SimulationCompleted) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SimulationCompleted implements SimulationCompleted {
  const _$SimulationCompleted();

  @override
  String toString() {
    return 'SimulationEvent.completed()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SimulationCompleted);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Route route) started,
    required TResult Function(RoutePoint point, Speed speed) positionChanged,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() completed,
  }) {
    return completed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Route route)? started,
    TResult? Function(RoutePoint point, Speed speed)? positionChanged,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? completed,
  }) {
    return completed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Route route)? started,
    TResult Function(RoutePoint point, Speed speed)? positionChanged,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? completed,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SimulationStarted value) started,
    required TResult Function(SimulationPositionChanged value) positionChanged,
    required TResult Function(SimulationPaused value) paused,
    required TResult Function(SimulationResumed value) resumed,
    required TResult Function(SimulationCompleted value) completed,
  }) {
    return completed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SimulationStarted value)? started,
    TResult? Function(SimulationPositionChanged value)? positionChanged,
    TResult? Function(SimulationPaused value)? paused,
    TResult? Function(SimulationResumed value)? resumed,
    TResult? Function(SimulationCompleted value)? completed,
  }) {
    return completed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SimulationStarted value)? started,
    TResult Function(SimulationPositionChanged value)? positionChanged,
    TResult Function(SimulationPaused value)? paused,
    TResult Function(SimulationResumed value)? resumed,
    TResult Function(SimulationCompleted value)? completed,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class SimulationCompleted implements SimulationEvent {
  const factory SimulationCompleted() = _$SimulationCompleted;
}

/// @nodoc
mixin _$ExportEvent {
  String get rideId => throw _privateConstructorUsedError;
  String get target => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String rideId, String target) queued,
    required TResult Function(String rideId, String target) uploading,
    required TResult Function(String rideId, String target) success,
    required TResult Function(String rideId, String target, String error)
        failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String rideId, String target)? queued,
    TResult? Function(String rideId, String target)? uploading,
    TResult? Function(String rideId, String target)? success,
    TResult? Function(String rideId, String target, String error)? failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String rideId, String target)? queued,
    TResult Function(String rideId, String target)? uploading,
    TResult Function(String rideId, String target)? success,
    TResult Function(String rideId, String target, String error)? failed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExportQueued value) queued,
    required TResult Function(ExportUploading value) uploading,
    required TResult Function(ExportSuccess value) success,
    required TResult Function(ExportFailed value) failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExportQueued value)? queued,
    TResult? Function(ExportUploading value)? uploading,
    TResult? Function(ExportSuccess value)? success,
    TResult? Function(ExportFailed value)? failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExportQueued value)? queued,
    TResult Function(ExportUploading value)? uploading,
    TResult Function(ExportSuccess value)? success,
    TResult Function(ExportFailed value)? failed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ExportEventCopyWith<ExportEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExportEventCopyWith<$Res> {
  factory $ExportEventCopyWith(
          ExportEvent value, $Res Function(ExportEvent) then) =
      _$ExportEventCopyWithImpl<$Res, ExportEvent>;
  @useResult
  $Res call({String rideId, String target});
}

/// @nodoc
class _$ExportEventCopyWithImpl<$Res, $Val extends ExportEvent>
    implements $ExportEventCopyWith<$Res> {
  _$ExportEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? target = null,
  }) {
    return _then(_value.copyWith(
      rideId: null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExportQueuedCopyWith<$Res>
    implements $ExportEventCopyWith<$Res> {
  factory _$$ExportQueuedCopyWith(
          _$ExportQueued value, $Res Function(_$ExportQueued) then) =
      __$$ExportQueuedCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rideId, String target});
}

/// @nodoc
class __$$ExportQueuedCopyWithImpl<$Res>
    extends _$ExportEventCopyWithImpl<$Res, _$ExportQueued>
    implements _$$ExportQueuedCopyWith<$Res> {
  __$$ExportQueuedCopyWithImpl(
      _$ExportQueued _value, $Res Function(_$ExportQueued) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? target = null,
  }) {
    return _then(_$ExportQueued(
      null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ExportQueued implements ExportQueued {
  const _$ExportQueued(this.rideId, this.target);

  @override
  final String rideId;
  @override
  final String target;

  @override
  String toString() {
    return 'ExportEvent.queued(rideId: $rideId, target: $target)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportQueued &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.target, target) || other.target == target));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId, target);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportQueuedCopyWith<_$ExportQueued> get copyWith =>
      __$$ExportQueuedCopyWithImpl<_$ExportQueued>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String rideId, String target) queued,
    required TResult Function(String rideId, String target) uploading,
    required TResult Function(String rideId, String target) success,
    required TResult Function(String rideId, String target, String error)
        failed,
  }) {
    return queued(rideId, target);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String rideId, String target)? queued,
    TResult? Function(String rideId, String target)? uploading,
    TResult? Function(String rideId, String target)? success,
    TResult? Function(String rideId, String target, String error)? failed,
  }) {
    return queued?.call(rideId, target);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String rideId, String target)? queued,
    TResult Function(String rideId, String target)? uploading,
    TResult Function(String rideId, String target)? success,
    TResult Function(String rideId, String target, String error)? failed,
    required TResult orElse(),
  }) {
    if (queued != null) {
      return queued(rideId, target);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExportQueued value) queued,
    required TResult Function(ExportUploading value) uploading,
    required TResult Function(ExportSuccess value) success,
    required TResult Function(ExportFailed value) failed,
  }) {
    return queued(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExportQueued value)? queued,
    TResult? Function(ExportUploading value)? uploading,
    TResult? Function(ExportSuccess value)? success,
    TResult? Function(ExportFailed value)? failed,
  }) {
    return queued?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExportQueued value)? queued,
    TResult Function(ExportUploading value)? uploading,
    TResult Function(ExportSuccess value)? success,
    TResult Function(ExportFailed value)? failed,
    required TResult orElse(),
  }) {
    if (queued != null) {
      return queued(this);
    }
    return orElse();
  }
}

abstract class ExportQueued implements ExportEvent {
  const factory ExportQueued(final String rideId, final String target) =
      _$ExportQueued;

  @override
  String get rideId;
  @override
  String get target;
  @override
  @JsonKey(ignore: true)
  _$$ExportQueuedCopyWith<_$ExportQueued> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ExportUploadingCopyWith<$Res>
    implements $ExportEventCopyWith<$Res> {
  factory _$$ExportUploadingCopyWith(
          _$ExportUploading value, $Res Function(_$ExportUploading) then) =
      __$$ExportUploadingCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rideId, String target});
}

/// @nodoc
class __$$ExportUploadingCopyWithImpl<$Res>
    extends _$ExportEventCopyWithImpl<$Res, _$ExportUploading>
    implements _$$ExportUploadingCopyWith<$Res> {
  __$$ExportUploadingCopyWithImpl(
      _$ExportUploading _value, $Res Function(_$ExportUploading) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? target = null,
  }) {
    return _then(_$ExportUploading(
      null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ExportUploading implements ExportUploading {
  const _$ExportUploading(this.rideId, this.target);

  @override
  final String rideId;
  @override
  final String target;

  @override
  String toString() {
    return 'ExportEvent.uploading(rideId: $rideId, target: $target)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportUploading &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.target, target) || other.target == target));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId, target);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportUploadingCopyWith<_$ExportUploading> get copyWith =>
      __$$ExportUploadingCopyWithImpl<_$ExportUploading>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String rideId, String target) queued,
    required TResult Function(String rideId, String target) uploading,
    required TResult Function(String rideId, String target) success,
    required TResult Function(String rideId, String target, String error)
        failed,
  }) {
    return uploading(rideId, target);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String rideId, String target)? queued,
    TResult? Function(String rideId, String target)? uploading,
    TResult? Function(String rideId, String target)? success,
    TResult? Function(String rideId, String target, String error)? failed,
  }) {
    return uploading?.call(rideId, target);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String rideId, String target)? queued,
    TResult Function(String rideId, String target)? uploading,
    TResult Function(String rideId, String target)? success,
    TResult Function(String rideId, String target, String error)? failed,
    required TResult orElse(),
  }) {
    if (uploading != null) {
      return uploading(rideId, target);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExportQueued value) queued,
    required TResult Function(ExportUploading value) uploading,
    required TResult Function(ExportSuccess value) success,
    required TResult Function(ExportFailed value) failed,
  }) {
    return uploading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExportQueued value)? queued,
    TResult? Function(ExportUploading value)? uploading,
    TResult? Function(ExportSuccess value)? success,
    TResult? Function(ExportFailed value)? failed,
  }) {
    return uploading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExportQueued value)? queued,
    TResult Function(ExportUploading value)? uploading,
    TResult Function(ExportSuccess value)? success,
    TResult Function(ExportFailed value)? failed,
    required TResult orElse(),
  }) {
    if (uploading != null) {
      return uploading(this);
    }
    return orElse();
  }
}

abstract class ExportUploading implements ExportEvent {
  const factory ExportUploading(final String rideId, final String target) =
      _$ExportUploading;

  @override
  String get rideId;
  @override
  String get target;
  @override
  @JsonKey(ignore: true)
  _$$ExportUploadingCopyWith<_$ExportUploading> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ExportSuccessCopyWith<$Res>
    implements $ExportEventCopyWith<$Res> {
  factory _$$ExportSuccessCopyWith(
          _$ExportSuccess value, $Res Function(_$ExportSuccess) then) =
      __$$ExportSuccessCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rideId, String target});
}

/// @nodoc
class __$$ExportSuccessCopyWithImpl<$Res>
    extends _$ExportEventCopyWithImpl<$Res, _$ExportSuccess>
    implements _$$ExportSuccessCopyWith<$Res> {
  __$$ExportSuccessCopyWithImpl(
      _$ExportSuccess _value, $Res Function(_$ExportSuccess) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? target = null,
  }) {
    return _then(_$ExportSuccess(
      null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ExportSuccess implements ExportSuccess {
  const _$ExportSuccess(this.rideId, this.target);

  @override
  final String rideId;
  @override
  final String target;

  @override
  String toString() {
    return 'ExportEvent.success(rideId: $rideId, target: $target)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportSuccess &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.target, target) || other.target == target));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId, target);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportSuccessCopyWith<_$ExportSuccess> get copyWith =>
      __$$ExportSuccessCopyWithImpl<_$ExportSuccess>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String rideId, String target) queued,
    required TResult Function(String rideId, String target) uploading,
    required TResult Function(String rideId, String target) success,
    required TResult Function(String rideId, String target, String error)
        failed,
  }) {
    return success(rideId, target);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String rideId, String target)? queued,
    TResult? Function(String rideId, String target)? uploading,
    TResult? Function(String rideId, String target)? success,
    TResult? Function(String rideId, String target, String error)? failed,
  }) {
    return success?.call(rideId, target);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String rideId, String target)? queued,
    TResult Function(String rideId, String target)? uploading,
    TResult Function(String rideId, String target)? success,
    TResult Function(String rideId, String target, String error)? failed,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(rideId, target);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExportQueued value) queued,
    required TResult Function(ExportUploading value) uploading,
    required TResult Function(ExportSuccess value) success,
    required TResult Function(ExportFailed value) failed,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExportQueued value)? queued,
    TResult? Function(ExportUploading value)? uploading,
    TResult? Function(ExportSuccess value)? success,
    TResult? Function(ExportFailed value)? failed,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExportQueued value)? queued,
    TResult Function(ExportUploading value)? uploading,
    TResult Function(ExportSuccess value)? success,
    TResult Function(ExportFailed value)? failed,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class ExportSuccess implements ExportEvent {
  const factory ExportSuccess(final String rideId, final String target) =
      _$ExportSuccess;

  @override
  String get rideId;
  @override
  String get target;
  @override
  @JsonKey(ignore: true)
  _$$ExportSuccessCopyWith<_$ExportSuccess> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ExportFailedCopyWith<$Res>
    implements $ExportEventCopyWith<$Res> {
  factory _$$ExportFailedCopyWith(
          _$ExportFailed value, $Res Function(_$ExportFailed) then) =
      __$$ExportFailedCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rideId, String target, String error});
}

/// @nodoc
class __$$ExportFailedCopyWithImpl<$Res>
    extends _$ExportEventCopyWithImpl<$Res, _$ExportFailed>
    implements _$$ExportFailedCopyWith<$Res> {
  __$$ExportFailedCopyWithImpl(
      _$ExportFailed _value, $Res Function(_$ExportFailed) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? target = null,
    Object? error = null,
  }) {
    return _then(_$ExportFailed(
      null == rideId
          ? _value.rideId
          : rideId // ignore: cast_nullable_to_non_nullable
              as String,
      null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as String,
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ExportFailed implements ExportFailed {
  const _$ExportFailed(this.rideId, this.target, this.error);

  @override
  final String rideId;
  @override
  final String target;
  @override
  final String error;

  @override
  String toString() {
    return 'ExportEvent.failed(rideId: $rideId, target: $target, error: $error)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportFailed &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId, target, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportFailedCopyWith<_$ExportFailed> get copyWith =>
      __$$ExportFailedCopyWithImpl<_$ExportFailed>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String rideId, String target) queued,
    required TResult Function(String rideId, String target) uploading,
    required TResult Function(String rideId, String target) success,
    required TResult Function(String rideId, String target, String error)
        failed,
  }) {
    return failed(rideId, target, error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String rideId, String target)? queued,
    TResult? Function(String rideId, String target)? uploading,
    TResult? Function(String rideId, String target)? success,
    TResult? Function(String rideId, String target, String error)? failed,
  }) {
    return failed?.call(rideId, target, error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String rideId, String target)? queued,
    TResult Function(String rideId, String target)? uploading,
    TResult Function(String rideId, String target)? success,
    TResult Function(String rideId, String target, String error)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(rideId, target, error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExportQueued value) queued,
    required TResult Function(ExportUploading value) uploading,
    required TResult Function(ExportSuccess value) success,
    required TResult Function(ExportFailed value) failed,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExportQueued value)? queued,
    TResult? Function(ExportUploading value)? uploading,
    TResult? Function(ExportSuccess value)? success,
    TResult? Function(ExportFailed value)? failed,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExportQueued value)? queued,
    TResult Function(ExportUploading value)? uploading,
    TResult Function(ExportSuccess value)? success,
    TResult Function(ExportFailed value)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class ExportFailed implements ExportEvent {
  const factory ExportFailed(
          final String rideId, final String target, final String error) =
      _$ExportFailed;

  @override
  String get rideId;
  @override
  String get target;
  String get error;
  @override
  @JsonKey(ignore: true)
  _$$ExportFailedCopyWith<_$ExportFailed> get copyWith =>
      throw _privateConstructorUsedError;
}
