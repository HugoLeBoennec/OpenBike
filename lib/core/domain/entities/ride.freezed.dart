// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Ride {
  String get id => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  RideStatus get status => throw _privateConstructorUsedError;
  List<SensorReading> get readings => throw _privateConstructorUsedError;
  List<Lap> get laps => throw _privateConstructorUsedError;
  Duration get pauseDuration => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RideCopyWith<Ride> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RideCopyWith<$Res> {
  factory $RideCopyWith(Ride value, $Res Function(Ride) then) =
      _$RideCopyWithImpl<$Res, Ride>;
  @useResult
  $Res call(
      {String id,
      DateTime startTime,
      DateTime? endTime,
      RideStatus status,
      List<SensorReading> readings,
      List<Lap> laps,
      Duration pauseDuration});
}

/// @nodoc
class _$RideCopyWithImpl<$Res, $Val extends Ride>
    implements $RideCopyWith<$Res> {
  _$RideCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? status = null,
    Object? readings = null,
    Object? laps = null,
    Object? pauseDuration = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RideStatus,
      readings: null == readings
          ? _value.readings
          : readings // ignore: cast_nullable_to_non_nullable
              as List<SensorReading>,
      laps: null == laps
          ? _value.laps
          : laps // ignore: cast_nullable_to_non_nullable
              as List<Lap>,
      pauseDuration: null == pauseDuration
          ? _value.pauseDuration
          : pauseDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_RideCopyWith<$Res> implements $RideCopyWith<$Res> {
  factory _$$_RideCopyWith(_$_Ride value, $Res Function(_$_Ride) then) =
      __$$_RideCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime startTime,
      DateTime? endTime,
      RideStatus status,
      List<SensorReading> readings,
      List<Lap> laps,
      Duration pauseDuration});
}

/// @nodoc
class __$$_RideCopyWithImpl<$Res> extends _$RideCopyWithImpl<$Res, _$_Ride>
    implements _$$_RideCopyWith<$Res> {
  __$$_RideCopyWithImpl(_$_Ride _value, $Res Function(_$_Ride) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? status = null,
    Object? readings = null,
    Object? laps = null,
    Object? pauseDuration = null,
  }) {
    return _then(_$_Ride(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RideStatus,
      readings: null == readings
          ? _value._readings
          : readings // ignore: cast_nullable_to_non_nullable
              as List<SensorReading>,
      laps: null == laps
          ? _value._laps
          : laps // ignore: cast_nullable_to_non_nullable
              as List<Lap>,
      pauseDuration: null == pauseDuration
          ? _value.pauseDuration
          : pauseDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc

class _$_Ride extends _Ride {
  const _$_Ride(
      {required this.id,
      required this.startTime,
      this.endTime,
      this.status = RideStatus.idle,
      final List<SensorReading> readings = const [],
      final List<Lap> laps = const [],
      this.pauseDuration = Duration.zero})
      : _readings = readings,
        _laps = laps,
        super._();

  @override
  final String id;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  @JsonKey()
  final RideStatus status;
  final List<SensorReading> _readings;
  @override
  @JsonKey()
  List<SensorReading> get readings {
    if (_readings is EqualUnmodifiableListView) return _readings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_readings);
  }

  final List<Lap> _laps;
  @override
  @JsonKey()
  List<Lap> get laps {
    if (_laps is EqualUnmodifiableListView) return _laps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_laps);
  }

  @override
  @JsonKey()
  final Duration pauseDuration;

  @override
  String toString() {
    return 'Ride(id: $id, startTime: $startTime, endTime: $endTime, status: $status, readings: $readings, laps: $laps, pauseDuration: $pauseDuration)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Ride &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._readings, _readings) &&
            const DeepCollectionEquality().equals(other._laps, _laps) &&
            (identical(other.pauseDuration, pauseDuration) ||
                other.pauseDuration == pauseDuration));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      startTime,
      endTime,
      status,
      const DeepCollectionEquality().hash(_readings),
      const DeepCollectionEquality().hash(_laps),
      pauseDuration);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_RideCopyWith<_$_Ride> get copyWith =>
      __$$_RideCopyWithImpl<_$_Ride>(this, _$identity);
}

abstract class _Ride extends Ride {
  const factory _Ride(
      {required final String id,
      required final DateTime startTime,
      final DateTime? endTime,
      final RideStatus status,
      final List<SensorReading> readings,
      final List<Lap> laps,
      final Duration pauseDuration}) = _$_Ride;
  const _Ride._() : super._();

  @override
  String get id;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  RideStatus get status;
  @override
  List<SensorReading> get readings;
  @override
  List<Lap> get laps;
  @override
  Duration get pauseDuration;
  @override
  @JsonKey(ignore: true)
  _$$_RideCopyWith<_$_Ride> get copyWith => throw _privateConstructorUsedError;
}
