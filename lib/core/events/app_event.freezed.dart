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
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SensorEvent {
  SensorReading get reading => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;

  /// Create a copy of SensorEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SensorEventCopyWith<SensorEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SensorEventCopyWith<$Res> {
  factory $SensorEventCopyWith(
    SensorEvent value,
    $Res Function(SensorEvent) then,
  ) = _$SensorEventCopyWithImpl<$Res, SensorEvent>;
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

  /// Create a copy of SensorEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reading = null, Object? deviceId = null}) {
    return _then(
      _value.copyWith(
            reading: null == reading
                ? _value.reading
                : reading // ignore: cast_nullable_to_non_nullable
                      as SensorReading,
            deviceId: null == deviceId
                ? _value.deviceId
                : deviceId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of SensorEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SensorReadingCopyWith<$Res> get reading {
    return $SensorReadingCopyWith<$Res>(_value.reading, (value) {
      return _then(_value.copyWith(reading: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SensorEventImplCopyWith<$Res>
    implements $SensorEventCopyWith<$Res> {
  factory _$$SensorEventImplCopyWith(
    _$SensorEventImpl value,
    $Res Function(_$SensorEventImpl) then,
  ) = __$$SensorEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SensorReading reading, String deviceId});

  @override
  $SensorReadingCopyWith<$Res> get reading;
}

/// @nodoc
class __$$SensorEventImplCopyWithImpl<$Res>
    extends _$SensorEventCopyWithImpl<$Res, _$SensorEventImpl>
    implements _$$SensorEventImplCopyWith<$Res> {
  __$$SensorEventImplCopyWithImpl(
    _$SensorEventImpl _value,
    $Res Function(_$SensorEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SensorEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reading = null, Object? deviceId = null}) {
    return _then(
      _$SensorEventImpl(
        reading: null == reading
            ? _value.reading
            : reading // ignore: cast_nullable_to_non_nullable
                  as SensorReading,
        deviceId: null == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SensorEventImpl implements _SensorEvent {
  const _$SensorEventImpl({required this.reading, required this.deviceId});

  @override
  final SensorReading reading;
  @override
  final String deviceId;

  @override
  String toString() {
    return 'SensorEvent(reading: $reading, deviceId: $deviceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SensorEventImpl &&
            (identical(other.reading, reading) || other.reading == reading) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, reading, deviceId);

  /// Create a copy of SensorEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SensorEventImplCopyWith<_$SensorEventImpl> get copyWith =>
      __$$SensorEventImplCopyWithImpl<_$SensorEventImpl>(this, _$identity);
}

abstract class _SensorEvent implements SensorEvent {
  const factory _SensorEvent({
    required final SensorReading reading,
    required final String deviceId,
  }) = _$SensorEventImpl;

  @override
  SensorReading get reading;
  @override
  String get deviceId;

  /// Create a copy of SensorEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SensorEventImplCopyWith<_$SensorEventImpl> get copyWith =>
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
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TrainerDevice device)? connected,
    TResult? Function(String deviceId)? disconnected,
    TResult? Function(String deviceId)? controlAcquired,
    TResult? Function(String deviceId, ControlMode mode)? modeChanged,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TrainerDevice device)? connected,
    TResult Function(String deviceId)? disconnected,
    TResult Function(String deviceId)? controlAcquired,
    TResult Function(String deviceId, ControlMode mode)? modeChanged,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrainerConnected value) connected,
    required TResult Function(TrainerDisconnected value) disconnected,
    required TResult Function(TrainerControlAcquired value) controlAcquired,
    required TResult Function(TrainerModeChanged value) modeChanged,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerConnected value)? connected,
    TResult? Function(TrainerDisconnected value)? disconnected,
    TResult? Function(TrainerControlAcquired value)? controlAcquired,
    TResult? Function(TrainerModeChanged value)? modeChanged,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerConnected value)? connected,
    TResult Function(TrainerDisconnected value)? disconnected,
    TResult Function(TrainerControlAcquired value)? controlAcquired,
    TResult Function(TrainerModeChanged value)? modeChanged,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerEventCopyWith<$Res> {
  factory $TrainerEventCopyWith(
    TrainerEvent value,
    $Res Function(TrainerEvent) then,
  ) = _$TrainerEventCopyWithImpl<$Res, TrainerEvent>;
}

/// @nodoc
class _$TrainerEventCopyWithImpl<$Res, $Val extends TrainerEvent>
    implements $TrainerEventCopyWith<$Res> {
  _$TrainerEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$TrainerConnectedImplCopyWith<$Res> {
  factory _$$TrainerConnectedImplCopyWith(
    _$TrainerConnectedImpl value,
    $Res Function(_$TrainerConnectedImpl) then,
  ) = __$$TrainerConnectedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({TrainerDevice device});

  $TrainerDeviceCopyWith<$Res> get device;
}

/// @nodoc
class __$$TrainerConnectedImplCopyWithImpl<$Res>
    extends _$TrainerEventCopyWithImpl<$Res, _$TrainerConnectedImpl>
    implements _$$TrainerConnectedImplCopyWith<$Res> {
  __$$TrainerConnectedImplCopyWithImpl(
    _$TrainerConnectedImpl _value,
    $Res Function(_$TrainerConnectedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? device = null}) {
    return _then(
      _$TrainerConnectedImpl(
        null == device
            ? _value.device
            : device // ignore: cast_nullable_to_non_nullable
                  as TrainerDevice,
      ),
    );
  }

  /// Create a copy of TrainerEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrainerDeviceCopyWith<$Res> get device {
    return $TrainerDeviceCopyWith<$Res>(_value.device, (value) {
      return _then(_value.copyWith(device: value));
    });
  }
}

/// @nodoc

class _$TrainerConnectedImpl implements TrainerConnected {
  const _$TrainerConnectedImpl(this.device);

  @override
  final TrainerDevice device;

  @override
  String toString() {
    return 'TrainerEvent.connected(device: $device)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerConnectedImpl &&
            (identical(other.device, device) || other.device == device));
  }

  @override
  int get hashCode => Object.hash(runtimeType, device);

  /// Create a copy of TrainerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerConnectedImplCopyWith<_$TrainerConnectedImpl> get copyWith =>
      __$$TrainerConnectedImplCopyWithImpl<_$TrainerConnectedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TrainerDevice device) connected,
    required TResult Function(String deviceId) disconnected,
    required TResult Function(String deviceId) controlAcquired,
    required TResult Function(String deviceId, ControlMode mode) modeChanged,
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
      _$TrainerConnectedImpl;

  TrainerDevice get device;

  /// Create a copy of TrainerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerConnectedImplCopyWith<_$TrainerConnectedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrainerDisconnectedImplCopyWith<$Res> {
  factory _$$TrainerDisconnectedImplCopyWith(
    _$TrainerDisconnectedImpl value,
    $Res Function(_$TrainerDisconnectedImpl) then,
  ) = __$$TrainerDisconnectedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String deviceId});
}

/// @nodoc
class __$$TrainerDisconnectedImplCopyWithImpl<$Res>
    extends _$TrainerEventCopyWithImpl<$Res, _$TrainerDisconnectedImpl>
    implements _$$TrainerDisconnectedImplCopyWith<$Res> {
  __$$TrainerDisconnectedImplCopyWithImpl(
    _$TrainerDisconnectedImpl _value,
    $Res Function(_$TrainerDisconnectedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? deviceId = null}) {
    return _then(
      _$TrainerDisconnectedImpl(
        null == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TrainerDisconnectedImpl implements TrainerDisconnected {
  const _$TrainerDisconnectedImpl(this.deviceId);

  @override
  final String deviceId;

  @override
  String toString() {
    return 'TrainerEvent.disconnected(deviceId: $deviceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerDisconnectedImpl &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId);

  /// Create a copy of TrainerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerDisconnectedImplCopyWith<_$TrainerDisconnectedImpl> get copyWith =>
      __$$TrainerDisconnectedImplCopyWithImpl<_$TrainerDisconnectedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TrainerDevice device) connected,
    required TResult Function(String deviceId) disconnected,
    required TResult Function(String deviceId) controlAcquired,
    required TResult Function(String deviceId, ControlMode mode) modeChanged,
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
      _$TrainerDisconnectedImpl;

  String get deviceId;

  /// Create a copy of TrainerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerDisconnectedImplCopyWith<_$TrainerDisconnectedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrainerControlAcquiredImplCopyWith<$Res> {
  factory _$$TrainerControlAcquiredImplCopyWith(
    _$TrainerControlAcquiredImpl value,
    $Res Function(_$TrainerControlAcquiredImpl) then,
  ) = __$$TrainerControlAcquiredImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String deviceId});
}

/// @nodoc
class __$$TrainerControlAcquiredImplCopyWithImpl<$Res>
    extends _$TrainerEventCopyWithImpl<$Res, _$TrainerControlAcquiredImpl>
    implements _$$TrainerControlAcquiredImplCopyWith<$Res> {
  __$$TrainerControlAcquiredImplCopyWithImpl(
    _$TrainerControlAcquiredImpl _value,
    $Res Function(_$TrainerControlAcquiredImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? deviceId = null}) {
    return _then(
      _$TrainerControlAcquiredImpl(
        null == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TrainerControlAcquiredImpl implements TrainerControlAcquired {
  const _$TrainerControlAcquiredImpl(this.deviceId);

  @override
  final String deviceId;

  @override
  String toString() {
    return 'TrainerEvent.controlAcquired(deviceId: $deviceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerControlAcquiredImpl &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId);

  /// Create a copy of TrainerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerControlAcquiredImplCopyWith<_$TrainerControlAcquiredImpl>
  get copyWith =>
      __$$TrainerControlAcquiredImplCopyWithImpl<_$TrainerControlAcquiredImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TrainerDevice device) connected,
    required TResult Function(String deviceId) disconnected,
    required TResult Function(String deviceId) controlAcquired,
    required TResult Function(String deviceId, ControlMode mode) modeChanged,
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
      _$TrainerControlAcquiredImpl;

  String get deviceId;

  /// Create a copy of TrainerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerControlAcquiredImplCopyWith<_$TrainerControlAcquiredImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrainerModeChangedImplCopyWith<$Res> {
  factory _$$TrainerModeChangedImplCopyWith(
    _$TrainerModeChangedImpl value,
    $Res Function(_$TrainerModeChangedImpl) then,
  ) = __$$TrainerModeChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String deviceId, ControlMode mode});
}

/// @nodoc
class __$$TrainerModeChangedImplCopyWithImpl<$Res>
    extends _$TrainerEventCopyWithImpl<$Res, _$TrainerModeChangedImpl>
    implements _$$TrainerModeChangedImplCopyWith<$Res> {
  __$$TrainerModeChangedImplCopyWithImpl(
    _$TrainerModeChangedImpl _value,
    $Res Function(_$TrainerModeChangedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? deviceId = null, Object? mode = null}) {
    return _then(
      _$TrainerModeChangedImpl(
        null == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        null == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as ControlMode,
      ),
    );
  }
}

/// @nodoc

class _$TrainerModeChangedImpl implements TrainerModeChanged {
  const _$TrainerModeChangedImpl(this.deviceId, this.mode);

  @override
  final String deviceId;
  @override
  final ControlMode mode;

  @override
  String toString() {
    return 'TrainerEvent.modeChanged(deviceId: $deviceId, mode: $mode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerModeChangedImpl &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.mode, mode) || other.mode == mode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceId, mode);

  /// Create a copy of TrainerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerModeChangedImplCopyWith<_$TrainerModeChangedImpl> get copyWith =>
      __$$TrainerModeChangedImplCopyWithImpl<_$TrainerModeChangedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TrainerDevice device) connected,
    required TResult Function(String deviceId) disconnected,
    required TResult Function(String deviceId) controlAcquired,
    required TResult Function(String deviceId, ControlMode mode) modeChanged,
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
    final String deviceId,
    final ControlMode mode,
  ) = _$TrainerModeChangedImpl;

  String get deviceId;
  ControlMode get mode;

  /// Create a copy of TrainerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerModeChangedImplCopyWith<_$TrainerModeChangedImpl> get copyWith =>
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
    required TResult Function() stopped,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Workout workout)? started,
    TResult? Function(WorkoutStep step, int index)? stepChanged,
    TResult? Function()? completed,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? stopped,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Workout workout)? started,
    TResult Function(WorkoutStep step, int index)? stepChanged,
    TResult Function()? completed,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? stopped,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WorkoutStarted value) started,
    required TResult Function(WorkoutStepChanged value) stepChanged,
    required TResult Function(WorkoutCompleted value) completed,
    required TResult Function(WorkoutPaused value) paused,
    required TResult Function(WorkoutResumed value) resumed,
    required TResult Function(WorkoutStopped value) stopped,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WorkoutStarted value)? started,
    TResult? Function(WorkoutStepChanged value)? stepChanged,
    TResult? Function(WorkoutCompleted value)? completed,
    TResult? Function(WorkoutPaused value)? paused,
    TResult? Function(WorkoutResumed value)? resumed,
    TResult? Function(WorkoutStopped value)? stopped,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WorkoutStarted value)? started,
    TResult Function(WorkoutStepChanged value)? stepChanged,
    TResult Function(WorkoutCompleted value)? completed,
    TResult Function(WorkoutPaused value)? paused,
    TResult Function(WorkoutResumed value)? resumed,
    TResult Function(WorkoutStopped value)? stopped,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutEventCopyWith<$Res> {
  factory $WorkoutEventCopyWith(
    WorkoutEvent value,
    $Res Function(WorkoutEvent) then,
  ) = _$WorkoutEventCopyWithImpl<$Res, WorkoutEvent>;
}

/// @nodoc
class _$WorkoutEventCopyWithImpl<$Res, $Val extends WorkoutEvent>
    implements $WorkoutEventCopyWith<$Res> {
  _$WorkoutEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$WorkoutStartedImplCopyWith<$Res> {
  factory _$$WorkoutStartedImplCopyWith(
    _$WorkoutStartedImpl value,
    $Res Function(_$WorkoutStartedImpl) then,
  ) = __$$WorkoutStartedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Workout workout});

  $WorkoutCopyWith<$Res> get workout;
}

/// @nodoc
class __$$WorkoutStartedImplCopyWithImpl<$Res>
    extends _$WorkoutEventCopyWithImpl<$Res, _$WorkoutStartedImpl>
    implements _$$WorkoutStartedImplCopyWith<$Res> {
  __$$WorkoutStartedImplCopyWithImpl(
    _$WorkoutStartedImpl _value,
    $Res Function(_$WorkoutStartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? workout = null}) {
    return _then(
      _$WorkoutStartedImpl(
        null == workout
            ? _value.workout
            : workout // ignore: cast_nullable_to_non_nullable
                  as Workout,
      ),
    );
  }

  /// Create a copy of WorkoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorkoutCopyWith<$Res> get workout {
    return $WorkoutCopyWith<$Res>(_value.workout, (value) {
      return _then(_value.copyWith(workout: value));
    });
  }
}

/// @nodoc

class _$WorkoutStartedImpl implements WorkoutStarted {
  const _$WorkoutStartedImpl(this.workout);

  @override
  final Workout workout;

  @override
  String toString() {
    return 'WorkoutEvent.started(workout: $workout)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutStartedImpl &&
            (identical(other.workout, workout) || other.workout == workout));
  }

  @override
  int get hashCode => Object.hash(runtimeType, workout);

  /// Create a copy of WorkoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutStartedImplCopyWith<_$WorkoutStartedImpl> get copyWith =>
      __$$WorkoutStartedImplCopyWithImpl<_$WorkoutStartedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Workout workout) started,
    required TResult Function(WorkoutStep step, int index) stepChanged,
    required TResult Function() completed,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() stopped,
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
    TResult? Function()? stopped,
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
    TResult Function()? stopped,
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
    required TResult Function(WorkoutStopped value) stopped,
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
    TResult? Function(WorkoutStopped value)? stopped,
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
    TResult Function(WorkoutStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class WorkoutStarted implements WorkoutEvent {
  const factory WorkoutStarted(final Workout workout) = _$WorkoutStartedImpl;

  Workout get workout;

  /// Create a copy of WorkoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutStartedImplCopyWith<_$WorkoutStartedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WorkoutStepChangedImplCopyWith<$Res> {
  factory _$$WorkoutStepChangedImplCopyWith(
    _$WorkoutStepChangedImpl value,
    $Res Function(_$WorkoutStepChangedImpl) then,
  ) = __$$WorkoutStepChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({WorkoutStep step, int index});

  $WorkoutStepCopyWith<$Res> get step;
}

/// @nodoc
class __$$WorkoutStepChangedImplCopyWithImpl<$Res>
    extends _$WorkoutEventCopyWithImpl<$Res, _$WorkoutStepChangedImpl>
    implements _$$WorkoutStepChangedImplCopyWith<$Res> {
  __$$WorkoutStepChangedImplCopyWithImpl(
    _$WorkoutStepChangedImpl _value,
    $Res Function(_$WorkoutStepChangedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? step = null, Object? index = null}) {
    return _then(
      _$WorkoutStepChangedImpl(
        null == step
            ? _value.step
            : step // ignore: cast_nullable_to_non_nullable
                  as WorkoutStep,
        null == index
            ? _value.index
            : index // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }

  /// Create a copy of WorkoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorkoutStepCopyWith<$Res> get step {
    return $WorkoutStepCopyWith<$Res>(_value.step, (value) {
      return _then(_value.copyWith(step: value));
    });
  }
}

/// @nodoc

class _$WorkoutStepChangedImpl implements WorkoutStepChanged {
  const _$WorkoutStepChangedImpl(this.step, this.index);

  @override
  final WorkoutStep step;
  @override
  final int index;

  @override
  String toString() {
    return 'WorkoutEvent.stepChanged(step: $step, index: $index)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutStepChangedImpl &&
            (identical(other.step, step) || other.step == step) &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(runtimeType, step, index);

  /// Create a copy of WorkoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutStepChangedImplCopyWith<_$WorkoutStepChangedImpl> get copyWith =>
      __$$WorkoutStepChangedImplCopyWithImpl<_$WorkoutStepChangedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Workout workout) started,
    required TResult Function(WorkoutStep step, int index) stepChanged,
    required TResult Function() completed,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() stopped,
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
    TResult? Function()? stopped,
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
    TResult Function()? stopped,
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
    required TResult Function(WorkoutStopped value) stopped,
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
    TResult? Function(WorkoutStopped value)? stopped,
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
    TResult Function(WorkoutStopped value)? stopped,
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
      _$WorkoutStepChangedImpl;

  WorkoutStep get step;
  int get index;

  /// Create a copy of WorkoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutStepChangedImplCopyWith<_$WorkoutStepChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WorkoutCompletedImplCopyWith<$Res> {
  factory _$$WorkoutCompletedImplCopyWith(
    _$WorkoutCompletedImpl value,
    $Res Function(_$WorkoutCompletedImpl) then,
  ) = __$$WorkoutCompletedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$WorkoutCompletedImplCopyWithImpl<$Res>
    extends _$WorkoutEventCopyWithImpl<$Res, _$WorkoutCompletedImpl>
    implements _$$WorkoutCompletedImplCopyWith<$Res> {
  __$$WorkoutCompletedImplCopyWithImpl(
    _$WorkoutCompletedImpl _value,
    $Res Function(_$WorkoutCompletedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkoutEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$WorkoutCompletedImpl implements WorkoutCompleted {
  const _$WorkoutCompletedImpl();

  @override
  String toString() {
    return 'WorkoutEvent.completed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$WorkoutCompletedImpl);
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
    required TResult Function() stopped,
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
    TResult? Function()? stopped,
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
    TResult Function()? stopped,
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
    required TResult Function(WorkoutStopped value) stopped,
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
    TResult? Function(WorkoutStopped value)? stopped,
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
    TResult Function(WorkoutStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class WorkoutCompleted implements WorkoutEvent {
  const factory WorkoutCompleted() = _$WorkoutCompletedImpl;
}

/// @nodoc
abstract class _$$WorkoutPausedImplCopyWith<$Res> {
  factory _$$WorkoutPausedImplCopyWith(
    _$WorkoutPausedImpl value,
    $Res Function(_$WorkoutPausedImpl) then,
  ) = __$$WorkoutPausedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$WorkoutPausedImplCopyWithImpl<$Res>
    extends _$WorkoutEventCopyWithImpl<$Res, _$WorkoutPausedImpl>
    implements _$$WorkoutPausedImplCopyWith<$Res> {
  __$$WorkoutPausedImplCopyWithImpl(
    _$WorkoutPausedImpl _value,
    $Res Function(_$WorkoutPausedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkoutEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$WorkoutPausedImpl implements WorkoutPaused {
  const _$WorkoutPausedImpl();

  @override
  String toString() {
    return 'WorkoutEvent.paused()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$WorkoutPausedImpl);
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
    required TResult Function() stopped,
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
    TResult? Function()? stopped,
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
    TResult Function()? stopped,
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
    required TResult Function(WorkoutStopped value) stopped,
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
    TResult? Function(WorkoutStopped value)? stopped,
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
    TResult Function(WorkoutStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (paused != null) {
      return paused(this);
    }
    return orElse();
  }
}

abstract class WorkoutPaused implements WorkoutEvent {
  const factory WorkoutPaused() = _$WorkoutPausedImpl;
}

/// @nodoc
abstract class _$$WorkoutResumedImplCopyWith<$Res> {
  factory _$$WorkoutResumedImplCopyWith(
    _$WorkoutResumedImpl value,
    $Res Function(_$WorkoutResumedImpl) then,
  ) = __$$WorkoutResumedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$WorkoutResumedImplCopyWithImpl<$Res>
    extends _$WorkoutEventCopyWithImpl<$Res, _$WorkoutResumedImpl>
    implements _$$WorkoutResumedImplCopyWith<$Res> {
  __$$WorkoutResumedImplCopyWithImpl(
    _$WorkoutResumedImpl _value,
    $Res Function(_$WorkoutResumedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkoutEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$WorkoutResumedImpl implements WorkoutResumed {
  const _$WorkoutResumedImpl();

  @override
  String toString() {
    return 'WorkoutEvent.resumed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$WorkoutResumedImpl);
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
    required TResult Function() stopped,
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
    TResult? Function()? stopped,
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
    TResult Function()? stopped,
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
    required TResult Function(WorkoutStopped value) stopped,
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
    TResult? Function(WorkoutStopped value)? stopped,
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
    TResult Function(WorkoutStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (resumed != null) {
      return resumed(this);
    }
    return orElse();
  }
}

abstract class WorkoutResumed implements WorkoutEvent {
  const factory WorkoutResumed() = _$WorkoutResumedImpl;
}

/// @nodoc
abstract class _$$WorkoutStoppedImplCopyWith<$Res> {
  factory _$$WorkoutStoppedImplCopyWith(
    _$WorkoutStoppedImpl value,
    $Res Function(_$WorkoutStoppedImpl) then,
  ) = __$$WorkoutStoppedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$WorkoutStoppedImplCopyWithImpl<$Res>
    extends _$WorkoutEventCopyWithImpl<$Res, _$WorkoutStoppedImpl>
    implements _$$WorkoutStoppedImplCopyWith<$Res> {
  __$$WorkoutStoppedImplCopyWithImpl(
    _$WorkoutStoppedImpl _value,
    $Res Function(_$WorkoutStoppedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkoutEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$WorkoutStoppedImpl implements WorkoutStopped {
  const _$WorkoutStoppedImpl();

  @override
  String toString() {
    return 'WorkoutEvent.stopped()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$WorkoutStoppedImpl);
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
    required TResult Function() stopped,
  }) {
    return stopped();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Workout workout)? started,
    TResult? Function(WorkoutStep step, int index)? stepChanged,
    TResult? Function()? completed,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? stopped,
  }) {
    return stopped?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Workout workout)? started,
    TResult Function(WorkoutStep step, int index)? stepChanged,
    TResult Function()? completed,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? stopped,
    required TResult orElse(),
  }) {
    if (stopped != null) {
      return stopped();
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
    required TResult Function(WorkoutStopped value) stopped,
  }) {
    return stopped(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WorkoutStarted value)? started,
    TResult? Function(WorkoutStepChanged value)? stepChanged,
    TResult? Function(WorkoutCompleted value)? completed,
    TResult? Function(WorkoutPaused value)? paused,
    TResult? Function(WorkoutResumed value)? resumed,
    TResult? Function(WorkoutStopped value)? stopped,
  }) {
    return stopped?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WorkoutStarted value)? started,
    TResult Function(WorkoutStepChanged value)? stepChanged,
    TResult Function(WorkoutCompleted value)? completed,
    TResult Function(WorkoutPaused value)? paused,
    TResult Function(WorkoutResumed value)? resumed,
    TResult Function(WorkoutStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (stopped != null) {
      return stopped(this);
    }
    return orElse();
  }
}

abstract class WorkoutStopped implements WorkoutEvent {
  const factory WorkoutStopped() = _$WorkoutStoppedImpl;
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
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String rideId)? started,
    TResult? Function(String rideId)? paused,
    TResult? Function(String rideId)? resumed,
    TResult? Function(String rideId, Lap lap)? lapMarked,
    TResult? Function(Ride ride)? stopped,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String rideId)? started,
    TResult Function(String rideId)? paused,
    TResult Function(String rideId)? resumed,
    TResult Function(String rideId, Lap lap)? lapMarked,
    TResult Function(Ride ride)? stopped,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RideStarted value) started,
    required TResult Function(RidePaused value) paused,
    required TResult Function(RideResumed value) resumed,
    required TResult Function(RideLapMarked value) lapMarked,
    required TResult Function(RideStopped value) stopped,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RideStarted value)? started,
    TResult? Function(RidePaused value)? paused,
    TResult? Function(RideResumed value)? resumed,
    TResult? Function(RideLapMarked value)? lapMarked,
    TResult? Function(RideStopped value)? stopped,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RideStarted value)? started,
    TResult Function(RidePaused value)? paused,
    TResult Function(RideResumed value)? resumed,
    TResult Function(RideLapMarked value)? lapMarked,
    TResult Function(RideStopped value)? stopped,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
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

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RideStartedImplCopyWith<$Res> {
  factory _$$RideStartedImplCopyWith(
    _$RideStartedImpl value,
    $Res Function(_$RideStartedImpl) then,
  ) = __$$RideStartedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String rideId});
}

/// @nodoc
class __$$RideStartedImplCopyWithImpl<$Res>
    extends _$RideEventCopyWithImpl<$Res, _$RideStartedImpl>
    implements _$$RideStartedImplCopyWith<$Res> {
  __$$RideStartedImplCopyWithImpl(
    _$RideStartedImpl _value,
    $Res Function(_$RideStartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rideId = null}) {
    return _then(
      _$RideStartedImpl(
        null == rideId
            ? _value.rideId
            : rideId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$RideStartedImpl implements RideStarted {
  const _$RideStartedImpl(this.rideId);

  @override
  final String rideId;

  @override
  String toString() {
    return 'RideEvent.started(rideId: $rideId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RideStartedImpl &&
            (identical(other.rideId, rideId) || other.rideId == rideId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId);

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RideStartedImplCopyWith<_$RideStartedImpl> get copyWith =>
      __$$RideStartedImplCopyWithImpl<_$RideStartedImpl>(this, _$identity);

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
  const factory RideStarted(final String rideId) = _$RideStartedImpl;

  String get rideId;

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RideStartedImplCopyWith<_$RideStartedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RidePausedImplCopyWith<$Res> {
  factory _$$RidePausedImplCopyWith(
    _$RidePausedImpl value,
    $Res Function(_$RidePausedImpl) then,
  ) = __$$RidePausedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String rideId});
}

/// @nodoc
class __$$RidePausedImplCopyWithImpl<$Res>
    extends _$RideEventCopyWithImpl<$Res, _$RidePausedImpl>
    implements _$$RidePausedImplCopyWith<$Res> {
  __$$RidePausedImplCopyWithImpl(
    _$RidePausedImpl _value,
    $Res Function(_$RidePausedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rideId = null}) {
    return _then(
      _$RidePausedImpl(
        null == rideId
            ? _value.rideId
            : rideId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$RidePausedImpl implements RidePaused {
  const _$RidePausedImpl(this.rideId);

  @override
  final String rideId;

  @override
  String toString() {
    return 'RideEvent.paused(rideId: $rideId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RidePausedImpl &&
            (identical(other.rideId, rideId) || other.rideId == rideId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId);

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RidePausedImplCopyWith<_$RidePausedImpl> get copyWith =>
      __$$RidePausedImplCopyWithImpl<_$RidePausedImpl>(this, _$identity);

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
  const factory RidePaused(final String rideId) = _$RidePausedImpl;

  String get rideId;

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RidePausedImplCopyWith<_$RidePausedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RideResumedImplCopyWith<$Res> {
  factory _$$RideResumedImplCopyWith(
    _$RideResumedImpl value,
    $Res Function(_$RideResumedImpl) then,
  ) = __$$RideResumedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String rideId});
}

/// @nodoc
class __$$RideResumedImplCopyWithImpl<$Res>
    extends _$RideEventCopyWithImpl<$Res, _$RideResumedImpl>
    implements _$$RideResumedImplCopyWith<$Res> {
  __$$RideResumedImplCopyWithImpl(
    _$RideResumedImpl _value,
    $Res Function(_$RideResumedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rideId = null}) {
    return _then(
      _$RideResumedImpl(
        null == rideId
            ? _value.rideId
            : rideId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$RideResumedImpl implements RideResumed {
  const _$RideResumedImpl(this.rideId);

  @override
  final String rideId;

  @override
  String toString() {
    return 'RideEvent.resumed(rideId: $rideId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RideResumedImpl &&
            (identical(other.rideId, rideId) || other.rideId == rideId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId);

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RideResumedImplCopyWith<_$RideResumedImpl> get copyWith =>
      __$$RideResumedImplCopyWithImpl<_$RideResumedImpl>(this, _$identity);

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
  const factory RideResumed(final String rideId) = _$RideResumedImpl;

  String get rideId;

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RideResumedImplCopyWith<_$RideResumedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RideLapMarkedImplCopyWith<$Res> {
  factory _$$RideLapMarkedImplCopyWith(
    _$RideLapMarkedImpl value,
    $Res Function(_$RideLapMarkedImpl) then,
  ) = __$$RideLapMarkedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String rideId, Lap lap});

  $LapCopyWith<$Res> get lap;
}

/// @nodoc
class __$$RideLapMarkedImplCopyWithImpl<$Res>
    extends _$RideEventCopyWithImpl<$Res, _$RideLapMarkedImpl>
    implements _$$RideLapMarkedImplCopyWith<$Res> {
  __$$RideLapMarkedImplCopyWithImpl(
    _$RideLapMarkedImpl _value,
    $Res Function(_$RideLapMarkedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rideId = null, Object? lap = null}) {
    return _then(
      _$RideLapMarkedImpl(
        null == rideId
            ? _value.rideId
            : rideId // ignore: cast_nullable_to_non_nullable
                  as String,
        null == lap
            ? _value.lap
            : lap // ignore: cast_nullable_to_non_nullable
                  as Lap,
      ),
    );
  }

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LapCopyWith<$Res> get lap {
    return $LapCopyWith<$Res>(_value.lap, (value) {
      return _then(_value.copyWith(lap: value));
    });
  }
}

/// @nodoc

class _$RideLapMarkedImpl implements RideLapMarked {
  const _$RideLapMarkedImpl(this.rideId, this.lap);

  @override
  final String rideId;
  @override
  final Lap lap;

  @override
  String toString() {
    return 'RideEvent.lapMarked(rideId: $rideId, lap: $lap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RideLapMarkedImpl &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.lap, lap) || other.lap == lap));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId, lap);

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RideLapMarkedImplCopyWith<_$RideLapMarkedImpl> get copyWith =>
      __$$RideLapMarkedImplCopyWithImpl<_$RideLapMarkedImpl>(this, _$identity);

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
      _$RideLapMarkedImpl;

  String get rideId;
  Lap get lap;

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RideLapMarkedImplCopyWith<_$RideLapMarkedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RideStoppedImplCopyWith<$Res> {
  factory _$$RideStoppedImplCopyWith(
    _$RideStoppedImpl value,
    $Res Function(_$RideStoppedImpl) then,
  ) = __$$RideStoppedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Ride ride});

  $RideCopyWith<$Res> get ride;
}

/// @nodoc
class __$$RideStoppedImplCopyWithImpl<$Res>
    extends _$RideEventCopyWithImpl<$Res, _$RideStoppedImpl>
    implements _$$RideStoppedImplCopyWith<$Res> {
  __$$RideStoppedImplCopyWithImpl(
    _$RideStoppedImpl _value,
    $Res Function(_$RideStoppedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? ride = null}) {
    return _then(
      _$RideStoppedImpl(
        null == ride
            ? _value.ride
            : ride // ignore: cast_nullable_to_non_nullable
                  as Ride,
      ),
    );
  }

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RideCopyWith<$Res> get ride {
    return $RideCopyWith<$Res>(_value.ride, (value) {
      return _then(_value.copyWith(ride: value));
    });
  }
}

/// @nodoc

class _$RideStoppedImpl implements RideStopped {
  const _$RideStoppedImpl(this.ride);

  @override
  final Ride ride;

  @override
  String toString() {
    return 'RideEvent.stopped(ride: $ride)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RideStoppedImpl &&
            (identical(other.ride, ride) || other.ride == ride));
  }

  @override
  int get hashCode => Object.hash(runtimeType, ride);

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RideStoppedImplCopyWith<_$RideStoppedImpl> get copyWith =>
      __$$RideStoppedImplCopyWithImpl<_$RideStoppedImpl>(this, _$identity);

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
  const factory RideStopped(final Ride ride) = _$RideStoppedImpl;

  Ride get ride;

  /// Create a copy of RideEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RideStoppedImplCopyWith<_$RideStoppedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SimulationEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Route route) started,
    required TResult Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )
    positionChanged,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() completed,
    required TResult Function() stopped,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Route route)? started,
    TResult? Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )?
    positionChanged,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? completed,
    TResult? Function()? stopped,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Route route)? started,
    TResult Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )?
    positionChanged,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? completed,
    TResult Function()? stopped,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SimulationStarted value) started,
    required TResult Function(SimulationPositionChanged value) positionChanged,
    required TResult Function(SimulationPaused value) paused,
    required TResult Function(SimulationResumed value) resumed,
    required TResult Function(SimulationCompleted value) completed,
    required TResult Function(SimulationStopped value) stopped,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SimulationStarted value)? started,
    TResult? Function(SimulationPositionChanged value)? positionChanged,
    TResult? Function(SimulationPaused value)? paused,
    TResult? Function(SimulationResumed value)? resumed,
    TResult? Function(SimulationCompleted value)? completed,
    TResult? Function(SimulationStopped value)? stopped,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SimulationStarted value)? started,
    TResult Function(SimulationPositionChanged value)? positionChanged,
    TResult Function(SimulationPaused value)? paused,
    TResult Function(SimulationResumed value)? resumed,
    TResult Function(SimulationCompleted value)? completed,
    TResult Function(SimulationStopped value)? stopped,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimulationEventCopyWith<$Res> {
  factory $SimulationEventCopyWith(
    SimulationEvent value,
    $Res Function(SimulationEvent) then,
  ) = _$SimulationEventCopyWithImpl<$Res, SimulationEvent>;
}

/// @nodoc
class _$SimulationEventCopyWithImpl<$Res, $Val extends SimulationEvent>
    implements $SimulationEventCopyWith<$Res> {
  _$SimulationEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimulationEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SimulationStartedImplCopyWith<$Res> {
  factory _$$SimulationStartedImplCopyWith(
    _$SimulationStartedImpl value,
    $Res Function(_$SimulationStartedImpl) then,
  ) = __$$SimulationStartedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Route route});

  $RouteCopyWith<$Res> get route;
}

/// @nodoc
class __$$SimulationStartedImplCopyWithImpl<$Res>
    extends _$SimulationEventCopyWithImpl<$Res, _$SimulationStartedImpl>
    implements _$$SimulationStartedImplCopyWith<$Res> {
  __$$SimulationStartedImplCopyWithImpl(
    _$SimulationStartedImpl _value,
    $Res Function(_$SimulationStartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SimulationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? route = null}) {
    return _then(
      _$SimulationStartedImpl(
        null == route
            ? _value.route
            : route // ignore: cast_nullable_to_non_nullable
                  as Route,
      ),
    );
  }

  /// Create a copy of SimulationEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RouteCopyWith<$Res> get route {
    return $RouteCopyWith<$Res>(_value.route, (value) {
      return _then(_value.copyWith(route: value));
    });
  }
}

/// @nodoc

class _$SimulationStartedImpl implements SimulationStarted {
  const _$SimulationStartedImpl(this.route);

  @override
  final Route route;

  @override
  String toString() {
    return 'SimulationEvent.started(route: $route)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimulationStartedImpl &&
            (identical(other.route, route) || other.route == route));
  }

  @override
  int get hashCode => Object.hash(runtimeType, route);

  /// Create a copy of SimulationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimulationStartedImplCopyWith<_$SimulationStartedImpl> get copyWith =>
      __$$SimulationStartedImplCopyWithImpl<_$SimulationStartedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Route route) started,
    required TResult Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )
    positionChanged,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() completed,
    required TResult Function() stopped,
  }) {
    return started(route);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Route route)? started,
    TResult? Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )?
    positionChanged,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? completed,
    TResult? Function()? stopped,
  }) {
    return started?.call(route);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Route route)? started,
    TResult Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )?
    positionChanged,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? completed,
    TResult Function()? stopped,
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
    required TResult Function(SimulationStopped value) stopped,
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
    TResult? Function(SimulationStopped value)? stopped,
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
    TResult Function(SimulationStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class SimulationStarted implements SimulationEvent {
  const factory SimulationStarted(final Route route) = _$SimulationStartedImpl;

  Route get route;

  /// Create a copy of SimulationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimulationStartedImplCopyWith<_$SimulationStartedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SimulationPositionChangedImplCopyWith<$Res> {
  factory _$$SimulationPositionChangedImplCopyWith(
    _$SimulationPositionChangedImpl value,
    $Res Function(_$SimulationPositionChangedImpl) then,
  ) = __$$SimulationPositionChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    RoutePoint point,
    Speed speed,
    double distanceCovered,
    double elevationGain,
  });

  $RoutePointCopyWith<$Res> get point;
  $SpeedCopyWith<$Res> get speed;
}

/// @nodoc
class __$$SimulationPositionChangedImplCopyWithImpl<$Res>
    extends _$SimulationEventCopyWithImpl<$Res, _$SimulationPositionChangedImpl>
    implements _$$SimulationPositionChangedImplCopyWith<$Res> {
  __$$SimulationPositionChangedImplCopyWithImpl(
    _$SimulationPositionChangedImpl _value,
    $Res Function(_$SimulationPositionChangedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SimulationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? point = null,
    Object? speed = null,
    Object? distanceCovered = null,
    Object? elevationGain = null,
  }) {
    return _then(
      _$SimulationPositionChangedImpl(
        null == point
            ? _value.point
            : point // ignore: cast_nullable_to_non_nullable
                  as RoutePoint,
        null == speed
            ? _value.speed
            : speed // ignore: cast_nullable_to_non_nullable
                  as Speed,
        null == distanceCovered
            ? _value.distanceCovered
            : distanceCovered // ignore: cast_nullable_to_non_nullable
                  as double,
        null == elevationGain
            ? _value.elevationGain
            : elevationGain // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }

  /// Create a copy of SimulationEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RoutePointCopyWith<$Res> get point {
    return $RoutePointCopyWith<$Res>(_value.point, (value) {
      return _then(_value.copyWith(point: value));
    });
  }

  /// Create a copy of SimulationEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SpeedCopyWith<$Res> get speed {
    return $SpeedCopyWith<$Res>(_value.speed, (value) {
      return _then(_value.copyWith(speed: value));
    });
  }
}

/// @nodoc

class _$SimulationPositionChangedImpl implements SimulationPositionChanged {
  const _$SimulationPositionChangedImpl(
    this.point,
    this.speed,
    this.distanceCovered,
    this.elevationGain,
  );

  @override
  final RoutePoint point;
  @override
  final Speed speed;
  @override
  final double distanceCovered;
  @override
  final double elevationGain;

  @override
  String toString() {
    return 'SimulationEvent.positionChanged(point: $point, speed: $speed, distanceCovered: $distanceCovered, elevationGain: $elevationGain)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimulationPositionChangedImpl &&
            (identical(other.point, point) || other.point == point) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.distanceCovered, distanceCovered) ||
                other.distanceCovered == distanceCovered) &&
            (identical(other.elevationGain, elevationGain) ||
                other.elevationGain == elevationGain));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, point, speed, distanceCovered, elevationGain);

  /// Create a copy of SimulationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimulationPositionChangedImplCopyWith<_$SimulationPositionChangedImpl>
  get copyWith =>
      __$$SimulationPositionChangedImplCopyWithImpl<
        _$SimulationPositionChangedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Route route) started,
    required TResult Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )
    positionChanged,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() completed,
    required TResult Function() stopped,
  }) {
    return positionChanged(point, speed, distanceCovered, elevationGain);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Route route)? started,
    TResult? Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )?
    positionChanged,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? completed,
    TResult? Function()? stopped,
  }) {
    return positionChanged?.call(point, speed, distanceCovered, elevationGain);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Route route)? started,
    TResult Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )?
    positionChanged,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? completed,
    TResult Function()? stopped,
    required TResult orElse(),
  }) {
    if (positionChanged != null) {
      return positionChanged(point, speed, distanceCovered, elevationGain);
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
    required TResult Function(SimulationStopped value) stopped,
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
    TResult? Function(SimulationStopped value)? stopped,
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
    TResult Function(SimulationStopped value)? stopped,
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
    final RoutePoint point,
    final Speed speed,
    final double distanceCovered,
    final double elevationGain,
  ) = _$SimulationPositionChangedImpl;

  RoutePoint get point;
  Speed get speed;
  double get distanceCovered;
  double get elevationGain;

  /// Create a copy of SimulationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimulationPositionChangedImplCopyWith<_$SimulationPositionChangedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SimulationPausedImplCopyWith<$Res> {
  factory _$$SimulationPausedImplCopyWith(
    _$SimulationPausedImpl value,
    $Res Function(_$SimulationPausedImpl) then,
  ) = __$$SimulationPausedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SimulationPausedImplCopyWithImpl<$Res>
    extends _$SimulationEventCopyWithImpl<$Res, _$SimulationPausedImpl>
    implements _$$SimulationPausedImplCopyWith<$Res> {
  __$$SimulationPausedImplCopyWithImpl(
    _$SimulationPausedImpl _value,
    $Res Function(_$SimulationPausedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SimulationEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SimulationPausedImpl implements SimulationPaused {
  const _$SimulationPausedImpl();

  @override
  String toString() {
    return 'SimulationEvent.paused()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SimulationPausedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Route route) started,
    required TResult Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )
    positionChanged,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() completed,
    required TResult Function() stopped,
  }) {
    return paused();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Route route)? started,
    TResult? Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )?
    positionChanged,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? completed,
    TResult? Function()? stopped,
  }) {
    return paused?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Route route)? started,
    TResult Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )?
    positionChanged,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? completed,
    TResult Function()? stopped,
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
    required TResult Function(SimulationStopped value) stopped,
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
    TResult? Function(SimulationStopped value)? stopped,
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
    TResult Function(SimulationStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (paused != null) {
      return paused(this);
    }
    return orElse();
  }
}

abstract class SimulationPaused implements SimulationEvent {
  const factory SimulationPaused() = _$SimulationPausedImpl;
}

/// @nodoc
abstract class _$$SimulationResumedImplCopyWith<$Res> {
  factory _$$SimulationResumedImplCopyWith(
    _$SimulationResumedImpl value,
    $Res Function(_$SimulationResumedImpl) then,
  ) = __$$SimulationResumedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SimulationResumedImplCopyWithImpl<$Res>
    extends _$SimulationEventCopyWithImpl<$Res, _$SimulationResumedImpl>
    implements _$$SimulationResumedImplCopyWith<$Res> {
  __$$SimulationResumedImplCopyWithImpl(
    _$SimulationResumedImpl _value,
    $Res Function(_$SimulationResumedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SimulationEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SimulationResumedImpl implements SimulationResumed {
  const _$SimulationResumedImpl();

  @override
  String toString() {
    return 'SimulationEvent.resumed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SimulationResumedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Route route) started,
    required TResult Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )
    positionChanged,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() completed,
    required TResult Function() stopped,
  }) {
    return resumed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Route route)? started,
    TResult? Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )?
    positionChanged,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? completed,
    TResult? Function()? stopped,
  }) {
    return resumed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Route route)? started,
    TResult Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )?
    positionChanged,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? completed,
    TResult Function()? stopped,
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
    required TResult Function(SimulationStopped value) stopped,
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
    TResult? Function(SimulationStopped value)? stopped,
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
    TResult Function(SimulationStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (resumed != null) {
      return resumed(this);
    }
    return orElse();
  }
}

abstract class SimulationResumed implements SimulationEvent {
  const factory SimulationResumed() = _$SimulationResumedImpl;
}

/// @nodoc
abstract class _$$SimulationCompletedImplCopyWith<$Res> {
  factory _$$SimulationCompletedImplCopyWith(
    _$SimulationCompletedImpl value,
    $Res Function(_$SimulationCompletedImpl) then,
  ) = __$$SimulationCompletedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SimulationCompletedImplCopyWithImpl<$Res>
    extends _$SimulationEventCopyWithImpl<$Res, _$SimulationCompletedImpl>
    implements _$$SimulationCompletedImplCopyWith<$Res> {
  __$$SimulationCompletedImplCopyWithImpl(
    _$SimulationCompletedImpl _value,
    $Res Function(_$SimulationCompletedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SimulationEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SimulationCompletedImpl implements SimulationCompleted {
  const _$SimulationCompletedImpl();

  @override
  String toString() {
    return 'SimulationEvent.completed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimulationCompletedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Route route) started,
    required TResult Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )
    positionChanged,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() completed,
    required TResult Function() stopped,
  }) {
    return completed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Route route)? started,
    TResult? Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )?
    positionChanged,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? completed,
    TResult? Function()? stopped,
  }) {
    return completed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Route route)? started,
    TResult Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )?
    positionChanged,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? completed,
    TResult Function()? stopped,
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
    required TResult Function(SimulationStopped value) stopped,
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
    TResult? Function(SimulationStopped value)? stopped,
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
    TResult Function(SimulationStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class SimulationCompleted implements SimulationEvent {
  const factory SimulationCompleted() = _$SimulationCompletedImpl;
}

/// @nodoc
abstract class _$$SimulationStoppedImplCopyWith<$Res> {
  factory _$$SimulationStoppedImplCopyWith(
    _$SimulationStoppedImpl value,
    $Res Function(_$SimulationStoppedImpl) then,
  ) = __$$SimulationStoppedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SimulationStoppedImplCopyWithImpl<$Res>
    extends _$SimulationEventCopyWithImpl<$Res, _$SimulationStoppedImpl>
    implements _$$SimulationStoppedImplCopyWith<$Res> {
  __$$SimulationStoppedImplCopyWithImpl(
    _$SimulationStoppedImpl _value,
    $Res Function(_$SimulationStoppedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SimulationEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SimulationStoppedImpl implements SimulationStopped {
  const _$SimulationStoppedImpl();

  @override
  String toString() {
    return 'SimulationEvent.stopped()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SimulationStoppedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Route route) started,
    required TResult Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )
    positionChanged,
    required TResult Function() paused,
    required TResult Function() resumed,
    required TResult Function() completed,
    required TResult Function() stopped,
  }) {
    return stopped();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Route route)? started,
    TResult? Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )?
    positionChanged,
    TResult? Function()? paused,
    TResult? Function()? resumed,
    TResult? Function()? completed,
    TResult? Function()? stopped,
  }) {
    return stopped?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Route route)? started,
    TResult Function(
      RoutePoint point,
      Speed speed,
      double distanceCovered,
      double elevationGain,
    )?
    positionChanged,
    TResult Function()? paused,
    TResult Function()? resumed,
    TResult Function()? completed,
    TResult Function()? stopped,
    required TResult orElse(),
  }) {
    if (stopped != null) {
      return stopped();
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
    required TResult Function(SimulationStopped value) stopped,
  }) {
    return stopped(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SimulationStarted value)? started,
    TResult? Function(SimulationPositionChanged value)? positionChanged,
    TResult? Function(SimulationPaused value)? paused,
    TResult? Function(SimulationResumed value)? resumed,
    TResult? Function(SimulationCompleted value)? completed,
    TResult? Function(SimulationStopped value)? stopped,
  }) {
    return stopped?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SimulationStarted value)? started,
    TResult Function(SimulationPositionChanged value)? positionChanged,
    TResult Function(SimulationPaused value)? paused,
    TResult Function(SimulationResumed value)? resumed,
    TResult Function(SimulationCompleted value)? completed,
    TResult Function(SimulationStopped value)? stopped,
    required TResult orElse(),
  }) {
    if (stopped != null) {
      return stopped(this);
    }
    return orElse();
  }
}

abstract class SimulationStopped implements SimulationEvent {
  const factory SimulationStopped() = _$SimulationStoppedImpl;
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
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String rideId, String target)? queued,
    TResult? Function(String rideId, String target)? uploading,
    TResult? Function(String rideId, String target)? success,
    TResult? Function(String rideId, String target, String error)? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String rideId, String target)? queued,
    TResult Function(String rideId, String target)? uploading,
    TResult Function(String rideId, String target)? success,
    TResult Function(String rideId, String target, String error)? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExportQueued value) queued,
    required TResult Function(ExportUploading value) uploading,
    required TResult Function(ExportSuccess value) success,
    required TResult Function(ExportFailed value) failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExportQueued value)? queued,
    TResult? Function(ExportUploading value)? uploading,
    TResult? Function(ExportSuccess value)? success,
    TResult? Function(ExportFailed value)? failed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExportQueued value)? queued,
    TResult Function(ExportUploading value)? uploading,
    TResult Function(ExportSuccess value)? success,
    TResult Function(ExportFailed value)? failed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of ExportEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExportEventCopyWith<ExportEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExportEventCopyWith<$Res> {
  factory $ExportEventCopyWith(
    ExportEvent value,
    $Res Function(ExportEvent) then,
  ) = _$ExportEventCopyWithImpl<$Res, ExportEvent>;
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

  /// Create a copy of ExportEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rideId = null, Object? target = null}) {
    return _then(
      _value.copyWith(
            rideId: null == rideId
                ? _value.rideId
                : rideId // ignore: cast_nullable_to_non_nullable
                      as String,
            target: null == target
                ? _value.target
                : target // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExportQueuedImplCopyWith<$Res>
    implements $ExportEventCopyWith<$Res> {
  factory _$$ExportQueuedImplCopyWith(
    _$ExportQueuedImpl value,
    $Res Function(_$ExportQueuedImpl) then,
  ) = __$$ExportQueuedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rideId, String target});
}

/// @nodoc
class __$$ExportQueuedImplCopyWithImpl<$Res>
    extends _$ExportEventCopyWithImpl<$Res, _$ExportQueuedImpl>
    implements _$$ExportQueuedImplCopyWith<$Res> {
  __$$ExportQueuedImplCopyWithImpl(
    _$ExportQueuedImpl _value,
    $Res Function(_$ExportQueuedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExportEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rideId = null, Object? target = null}) {
    return _then(
      _$ExportQueuedImpl(
        null == rideId
            ? _value.rideId
            : rideId // ignore: cast_nullable_to_non_nullable
                  as String,
        null == target
            ? _value.target
            : target // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ExportQueuedImpl implements ExportQueued {
  const _$ExportQueuedImpl(this.rideId, this.target);

  @override
  final String rideId;
  @override
  final String target;

  @override
  String toString() {
    return 'ExportEvent.queued(rideId: $rideId, target: $target)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportQueuedImpl &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.target, target) || other.target == target));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId, target);

  /// Create a copy of ExportEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportQueuedImplCopyWith<_$ExportQueuedImpl> get copyWith =>
      __$$ExportQueuedImplCopyWithImpl<_$ExportQueuedImpl>(this, _$identity);

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
      _$ExportQueuedImpl;

  @override
  String get rideId;
  @override
  String get target;

  /// Create a copy of ExportEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExportQueuedImplCopyWith<_$ExportQueuedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ExportUploadingImplCopyWith<$Res>
    implements $ExportEventCopyWith<$Res> {
  factory _$$ExportUploadingImplCopyWith(
    _$ExportUploadingImpl value,
    $Res Function(_$ExportUploadingImpl) then,
  ) = __$$ExportUploadingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rideId, String target});
}

/// @nodoc
class __$$ExportUploadingImplCopyWithImpl<$Res>
    extends _$ExportEventCopyWithImpl<$Res, _$ExportUploadingImpl>
    implements _$$ExportUploadingImplCopyWith<$Res> {
  __$$ExportUploadingImplCopyWithImpl(
    _$ExportUploadingImpl _value,
    $Res Function(_$ExportUploadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExportEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rideId = null, Object? target = null}) {
    return _then(
      _$ExportUploadingImpl(
        null == rideId
            ? _value.rideId
            : rideId // ignore: cast_nullable_to_non_nullable
                  as String,
        null == target
            ? _value.target
            : target // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ExportUploadingImpl implements ExportUploading {
  const _$ExportUploadingImpl(this.rideId, this.target);

  @override
  final String rideId;
  @override
  final String target;

  @override
  String toString() {
    return 'ExportEvent.uploading(rideId: $rideId, target: $target)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportUploadingImpl &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.target, target) || other.target == target));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId, target);

  /// Create a copy of ExportEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportUploadingImplCopyWith<_$ExportUploadingImpl> get copyWith =>
      __$$ExportUploadingImplCopyWithImpl<_$ExportUploadingImpl>(
        this,
        _$identity,
      );

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
      _$ExportUploadingImpl;

  @override
  String get rideId;
  @override
  String get target;

  /// Create a copy of ExportEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExportUploadingImplCopyWith<_$ExportUploadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ExportSuccessImplCopyWith<$Res>
    implements $ExportEventCopyWith<$Res> {
  factory _$$ExportSuccessImplCopyWith(
    _$ExportSuccessImpl value,
    $Res Function(_$ExportSuccessImpl) then,
  ) = __$$ExportSuccessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rideId, String target});
}

/// @nodoc
class __$$ExportSuccessImplCopyWithImpl<$Res>
    extends _$ExportEventCopyWithImpl<$Res, _$ExportSuccessImpl>
    implements _$$ExportSuccessImplCopyWith<$Res> {
  __$$ExportSuccessImplCopyWithImpl(
    _$ExportSuccessImpl _value,
    $Res Function(_$ExportSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExportEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rideId = null, Object? target = null}) {
    return _then(
      _$ExportSuccessImpl(
        null == rideId
            ? _value.rideId
            : rideId // ignore: cast_nullable_to_non_nullable
                  as String,
        null == target
            ? _value.target
            : target // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ExportSuccessImpl implements ExportSuccess {
  const _$ExportSuccessImpl(this.rideId, this.target);

  @override
  final String rideId;
  @override
  final String target;

  @override
  String toString() {
    return 'ExportEvent.success(rideId: $rideId, target: $target)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportSuccessImpl &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.target, target) || other.target == target));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId, target);

  /// Create a copy of ExportEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportSuccessImplCopyWith<_$ExportSuccessImpl> get copyWith =>
      __$$ExportSuccessImplCopyWithImpl<_$ExportSuccessImpl>(this, _$identity);

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
      _$ExportSuccessImpl;

  @override
  String get rideId;
  @override
  String get target;

  /// Create a copy of ExportEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExportSuccessImplCopyWith<_$ExportSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ExportFailedImplCopyWith<$Res>
    implements $ExportEventCopyWith<$Res> {
  factory _$$ExportFailedImplCopyWith(
    _$ExportFailedImpl value,
    $Res Function(_$ExportFailedImpl) then,
  ) = __$$ExportFailedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rideId, String target, String error});
}

/// @nodoc
class __$$ExportFailedImplCopyWithImpl<$Res>
    extends _$ExportEventCopyWithImpl<$Res, _$ExportFailedImpl>
    implements _$$ExportFailedImplCopyWith<$Res> {
  __$$ExportFailedImplCopyWithImpl(
    _$ExportFailedImpl _value,
    $Res Function(_$ExportFailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExportEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? target = null,
    Object? error = null,
  }) {
    return _then(
      _$ExportFailedImpl(
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
      ),
    );
  }
}

/// @nodoc

class _$ExportFailedImpl implements ExportFailed {
  const _$ExportFailedImpl(this.rideId, this.target, this.error);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportFailedImpl &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rideId, target, error);

  /// Create a copy of ExportEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportFailedImplCopyWith<_$ExportFailedImpl> get copyWith =>
      __$$ExportFailedImplCopyWithImpl<_$ExportFailedImpl>(this, _$identity);

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
    final String rideId,
    final String target,
    final String error,
  ) = _$ExportFailedImpl;

  @override
  String get rideId;
  @override
  String get target;
  String get error;

  /// Create a copy of ExportEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExportFailedImplCopyWith<_$ExportFailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
