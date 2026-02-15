// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sensor_reading.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$SensorReading {
  DateTime get timestamp => throw _privateConstructorUsedError;
  Watts? get power => throw _privateConstructorUsedError;
  Cadence? get cadence => throw _privateConstructorUsedError;
  HeartRate? get heartRate => throw _privateConstructorUsedError;
  Speed? get speed => throw _privateConstructorUsedError;
  Distance? get distance => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SensorReadingCopyWith<SensorReading> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SensorReadingCopyWith<$Res> {
  factory $SensorReadingCopyWith(
          SensorReading value, $Res Function(SensorReading) then) =
      _$SensorReadingCopyWithImpl<$Res, SensorReading>;
  @useResult
  $Res call(
      {DateTime timestamp,
      Watts? power,
      Cadence? cadence,
      HeartRate? heartRate,
      Speed? speed,
      Distance? distance});

  $WattsCopyWith<$Res>? get power;
  $CadenceCopyWith<$Res>? get cadence;
  $HeartRateCopyWith<$Res>? get heartRate;
  $SpeedCopyWith<$Res>? get speed;
  $DistanceCopyWith<$Res>? get distance;
}

/// @nodoc
class _$SensorReadingCopyWithImpl<$Res, $Val extends SensorReading>
    implements $SensorReadingCopyWith<$Res> {
  _$SensorReadingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? power = freezed,
    Object? cadence = freezed,
    Object? heartRate = freezed,
    Object? speed = freezed,
    Object? distance = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      power: freezed == power
          ? _value.power
          : power // ignore: cast_nullable_to_non_nullable
              as Watts?,
      cadence: freezed == cadence
          ? _value.cadence
          : cadence // ignore: cast_nullable_to_non_nullable
              as Cadence?,
      heartRate: freezed == heartRate
          ? _value.heartRate
          : heartRate // ignore: cast_nullable_to_non_nullable
              as HeartRate?,
      speed: freezed == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as Speed?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as Distance?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WattsCopyWith<$Res>? get power {
    if (_value.power == null) {
      return null;
    }

    return $WattsCopyWith<$Res>(_value.power!, (value) {
      return _then(_value.copyWith(power: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CadenceCopyWith<$Res>? get cadence {
    if (_value.cadence == null) {
      return null;
    }

    return $CadenceCopyWith<$Res>(_value.cadence!, (value) {
      return _then(_value.copyWith(cadence: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $HeartRateCopyWith<$Res>? get heartRate {
    if (_value.heartRate == null) {
      return null;
    }

    return $HeartRateCopyWith<$Res>(_value.heartRate!, (value) {
      return _then(_value.copyWith(heartRate: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SpeedCopyWith<$Res>? get speed {
    if (_value.speed == null) {
      return null;
    }

    return $SpeedCopyWith<$Res>(_value.speed!, (value) {
      return _then(_value.copyWith(speed: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DistanceCopyWith<$Res>? get distance {
    if (_value.distance == null) {
      return null;
    }

    return $DistanceCopyWith<$Res>(_value.distance!, (value) {
      return _then(_value.copyWith(distance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_SensorReadingCopyWith<$Res>
    implements $SensorReadingCopyWith<$Res> {
  factory _$$_SensorReadingCopyWith(
          _$_SensorReading value, $Res Function(_$_SensorReading) then) =
      __$$_SensorReadingCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      Watts? power,
      Cadence? cadence,
      HeartRate? heartRate,
      Speed? speed,
      Distance? distance});

  @override
  $WattsCopyWith<$Res>? get power;
  @override
  $CadenceCopyWith<$Res>? get cadence;
  @override
  $HeartRateCopyWith<$Res>? get heartRate;
  @override
  $SpeedCopyWith<$Res>? get speed;
  @override
  $DistanceCopyWith<$Res>? get distance;
}

/// @nodoc
class __$$_SensorReadingCopyWithImpl<$Res>
    extends _$SensorReadingCopyWithImpl<$Res, _$_SensorReading>
    implements _$$_SensorReadingCopyWith<$Res> {
  __$$_SensorReadingCopyWithImpl(
      _$_SensorReading _value, $Res Function(_$_SensorReading) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? power = freezed,
    Object? cadence = freezed,
    Object? heartRate = freezed,
    Object? speed = freezed,
    Object? distance = freezed,
  }) {
    return _then(_$_SensorReading(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      power: freezed == power
          ? _value.power
          : power // ignore: cast_nullable_to_non_nullable
              as Watts?,
      cadence: freezed == cadence
          ? _value.cadence
          : cadence // ignore: cast_nullable_to_non_nullable
              as Cadence?,
      heartRate: freezed == heartRate
          ? _value.heartRate
          : heartRate // ignore: cast_nullable_to_non_nullable
              as HeartRate?,
      speed: freezed == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as Speed?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as Distance?,
    ));
  }
}

/// @nodoc

class _$_SensorReading implements _SensorReading {
  const _$_SensorReading(
      {required this.timestamp,
      this.power,
      this.cadence,
      this.heartRate,
      this.speed,
      this.distance});

  @override
  final DateTime timestamp;
  @override
  final Watts? power;
  @override
  final Cadence? cadence;
  @override
  final HeartRate? heartRate;
  @override
  final Speed? speed;
  @override
  final Distance? distance;

  @override
  String toString() {
    return 'SensorReading(timestamp: $timestamp, power: $power, cadence: $cadence, heartRate: $heartRate, speed: $speed, distance: $distance)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SensorReading &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.power, power) || other.power == power) &&
            (identical(other.cadence, cadence) || other.cadence == cadence) &&
            (identical(other.heartRate, heartRate) ||
                other.heartRate == heartRate) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.distance, distance) ||
                other.distance == distance));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, timestamp, power, cadence, heartRate, speed, distance);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SensorReadingCopyWith<_$_SensorReading> get copyWith =>
      __$$_SensorReadingCopyWithImpl<_$_SensorReading>(this, _$identity);
}

abstract class _SensorReading implements SensorReading {
  const factory _SensorReading(
      {required final DateTime timestamp,
      final Watts? power,
      final Cadence? cadence,
      final HeartRate? heartRate,
      final Speed? speed,
      final Distance? distance}) = _$_SensorReading;

  @override
  DateTime get timestamp;
  @override
  Watts? get power;
  @override
  Cadence? get cadence;
  @override
  HeartRate? get heartRate;
  @override
  Speed? get speed;
  @override
  Distance? get distance;
  @override
  @JsonKey(ignore: true)
  _$$_SensorReadingCopyWith<_$_SensorReading> get copyWith =>
      throw _privateConstructorUsedError;
}
