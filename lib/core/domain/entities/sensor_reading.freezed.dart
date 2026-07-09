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
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SensorReading {
  DateTime get timestamp => throw _privateConstructorUsedError;
  Watts? get power => throw _privateConstructorUsedError;
  Cadence? get cadence => throw _privateConstructorUsedError;
  HeartRate? get heartRate => throw _privateConstructorUsedError;
  Speed? get speed => throw _privateConstructorUsedError;
  Distance? get distance => throw _privateConstructorUsedError;
  Grade? get grade => throw _privateConstructorUsedError;

  /// Create a copy of SensorReading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SensorReadingCopyWith<SensorReading> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SensorReadingCopyWith<$Res> {
  factory $SensorReadingCopyWith(
    SensorReading value,
    $Res Function(SensorReading) then,
  ) = _$SensorReadingCopyWithImpl<$Res, SensorReading>;
  @useResult
  $Res call({
    DateTime timestamp,
    Watts? power,
    Cadence? cadence,
    HeartRate? heartRate,
    Speed? speed,
    Distance? distance,
    Grade? grade,
  });

  $WattsCopyWith<$Res>? get power;
  $CadenceCopyWith<$Res>? get cadence;
  $HeartRateCopyWith<$Res>? get heartRate;
  $SpeedCopyWith<$Res>? get speed;
  $DistanceCopyWith<$Res>? get distance;
  $GradeCopyWith<$Res>? get grade;
}

/// @nodoc
class _$SensorReadingCopyWithImpl<$Res, $Val extends SensorReading>
    implements $SensorReadingCopyWith<$Res> {
  _$SensorReadingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SensorReading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? power = freezed,
    Object? cadence = freezed,
    Object? heartRate = freezed,
    Object? speed = freezed,
    Object? distance = freezed,
    Object? grade = freezed,
  }) {
    return _then(
      _value.copyWith(
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
            grade: freezed == grade
                ? _value.grade
                : grade // ignore: cast_nullable_to_non_nullable
                      as Grade?,
          )
          as $Val,
    );
  }

  /// Create a copy of SensorReading
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of SensorReading
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of SensorReading
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of SensorReading
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of SensorReading
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of SensorReading
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GradeCopyWith<$Res>? get grade {
    if (_value.grade == null) {
      return null;
    }

    return $GradeCopyWith<$Res>(_value.grade!, (value) {
      return _then(_value.copyWith(grade: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SensorReadingImplCopyWith<$Res>
    implements $SensorReadingCopyWith<$Res> {
  factory _$$SensorReadingImplCopyWith(
    _$SensorReadingImpl value,
    $Res Function(_$SensorReadingImpl) then,
  ) = __$$SensorReadingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime timestamp,
    Watts? power,
    Cadence? cadence,
    HeartRate? heartRate,
    Speed? speed,
    Distance? distance,
    Grade? grade,
  });

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
  @override
  $GradeCopyWith<$Res>? get grade;
}

/// @nodoc
class __$$SensorReadingImplCopyWithImpl<$Res>
    extends _$SensorReadingCopyWithImpl<$Res, _$SensorReadingImpl>
    implements _$$SensorReadingImplCopyWith<$Res> {
  __$$SensorReadingImplCopyWithImpl(
    _$SensorReadingImpl _value,
    $Res Function(_$SensorReadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SensorReading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? power = freezed,
    Object? cadence = freezed,
    Object? heartRate = freezed,
    Object? speed = freezed,
    Object? distance = freezed,
    Object? grade = freezed,
  }) {
    return _then(
      _$SensorReadingImpl(
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
        grade: freezed == grade
            ? _value.grade
            : grade // ignore: cast_nullable_to_non_nullable
                  as Grade?,
      ),
    );
  }
}

/// @nodoc

class _$SensorReadingImpl implements _SensorReading {
  const _$SensorReadingImpl({
    required this.timestamp,
    this.power,
    this.cadence,
    this.heartRate,
    this.speed,
    this.distance,
    this.grade,
  });

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
  final Grade? grade;

  @override
  String toString() {
    return 'SensorReading(timestamp: $timestamp, power: $power, cadence: $cadence, heartRate: $heartRate, speed: $speed, distance: $distance, grade: $grade)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SensorReadingImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.power, power) || other.power == power) &&
            (identical(other.cadence, cadence) || other.cadence == cadence) &&
            (identical(other.heartRate, heartRate) ||
                other.heartRate == heartRate) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.grade, grade) || other.grade == grade));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    timestamp,
    power,
    cadence,
    heartRate,
    speed,
    distance,
    grade,
  );

  /// Create a copy of SensorReading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SensorReadingImplCopyWith<_$SensorReadingImpl> get copyWith =>
      __$$SensorReadingImplCopyWithImpl<_$SensorReadingImpl>(this, _$identity);
}

abstract class _SensorReading implements SensorReading {
  const factory _SensorReading({
    required final DateTime timestamp,
    final Watts? power,
    final Cadence? cadence,
    final HeartRate? heartRate,
    final Speed? speed,
    final Distance? distance,
    final Grade? grade,
  }) = _$SensorReadingImpl;

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
  Grade? get grade;

  /// Create a copy of SensorReading
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SensorReadingImplCopyWith<_$SensorReadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
