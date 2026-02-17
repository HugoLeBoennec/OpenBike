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
  Watts? get cachedAvgPower => throw _privateConstructorUsedError;
  Watts? get cachedNormalizedPower => throw _privateConstructorUsedError;
  Watts? get cachedMaxPower => throw _privateConstructorUsedError;
  Cadence? get cachedAvgCadence => throw _privateConstructorUsedError;
  HeartRate? get cachedAvgHr => throw _privateConstructorUsedError;
  HeartRate? get cachedMaxHr => throw _privateConstructorUsedError;
  Distance? get cachedTotalDistance => throw _privateConstructorUsedError;
  double? get cachedTss => throw _privateConstructorUsedError;
  double? get cachedIntensityFactor => throw _privateConstructorUsedError;

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
      Duration pauseDuration,
      Watts? cachedAvgPower,
      Watts? cachedNormalizedPower,
      Watts? cachedMaxPower,
      Cadence? cachedAvgCadence,
      HeartRate? cachedAvgHr,
      HeartRate? cachedMaxHr,
      Distance? cachedTotalDistance,
      double? cachedTss,
      double? cachedIntensityFactor});
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
    Object? cachedAvgPower = freezed,
    Object? cachedNormalizedPower = freezed,
    Object? cachedMaxPower = freezed,
    Object? cachedAvgCadence = freezed,
    Object? cachedAvgHr = freezed,
    Object? cachedMaxHr = freezed,
    Object? cachedTotalDistance = freezed,
    Object? cachedTss = freezed,
    Object? cachedIntensityFactor = freezed,
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
      cachedAvgPower: freezed == cachedAvgPower
          ? _value.cachedAvgPower
          : cachedAvgPower // ignore: cast_nullable_to_non_nullable
              as Watts?,
      cachedNormalizedPower: freezed == cachedNormalizedPower
          ? _value.cachedNormalizedPower
          : cachedNormalizedPower // ignore: cast_nullable_to_non_nullable
              as Watts?,
      cachedMaxPower: freezed == cachedMaxPower
          ? _value.cachedMaxPower
          : cachedMaxPower // ignore: cast_nullable_to_non_nullable
              as Watts?,
      cachedAvgCadence: freezed == cachedAvgCadence
          ? _value.cachedAvgCadence
          : cachedAvgCadence // ignore: cast_nullable_to_non_nullable
              as Cadence?,
      cachedAvgHr: freezed == cachedAvgHr
          ? _value.cachedAvgHr
          : cachedAvgHr // ignore: cast_nullable_to_non_nullable
              as HeartRate?,
      cachedMaxHr: freezed == cachedMaxHr
          ? _value.cachedMaxHr
          : cachedMaxHr // ignore: cast_nullable_to_non_nullable
              as HeartRate?,
      cachedTotalDistance: freezed == cachedTotalDistance
          ? _value.cachedTotalDistance
          : cachedTotalDistance // ignore: cast_nullable_to_non_nullable
              as Distance?,
      cachedTss: freezed == cachedTss
          ? _value.cachedTss
          : cachedTss // ignore: cast_nullable_to_non_nullable
              as double?,
      cachedIntensityFactor: freezed == cachedIntensityFactor
          ? _value.cachedIntensityFactor
          : cachedIntensityFactor // ignore: cast_nullable_to_non_nullable
              as double?,
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
      Duration pauseDuration,
      Watts? cachedAvgPower,
      Watts? cachedNormalizedPower,
      Watts? cachedMaxPower,
      Cadence? cachedAvgCadence,
      HeartRate? cachedAvgHr,
      HeartRate? cachedMaxHr,
      Distance? cachedTotalDistance,
      double? cachedTss,
      double? cachedIntensityFactor});
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
    Object? cachedAvgPower = freezed,
    Object? cachedNormalizedPower = freezed,
    Object? cachedMaxPower = freezed,
    Object? cachedAvgCadence = freezed,
    Object? cachedAvgHr = freezed,
    Object? cachedMaxHr = freezed,
    Object? cachedTotalDistance = freezed,
    Object? cachedTss = freezed,
    Object? cachedIntensityFactor = freezed,
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
      cachedAvgPower: freezed == cachedAvgPower
          ? _value.cachedAvgPower
          : cachedAvgPower // ignore: cast_nullable_to_non_nullable
              as Watts?,
      cachedNormalizedPower: freezed == cachedNormalizedPower
          ? _value.cachedNormalizedPower
          : cachedNormalizedPower // ignore: cast_nullable_to_non_nullable
              as Watts?,
      cachedMaxPower: freezed == cachedMaxPower
          ? _value.cachedMaxPower
          : cachedMaxPower // ignore: cast_nullable_to_non_nullable
              as Watts?,
      cachedAvgCadence: freezed == cachedAvgCadence
          ? _value.cachedAvgCadence
          : cachedAvgCadence // ignore: cast_nullable_to_non_nullable
              as Cadence?,
      cachedAvgHr: freezed == cachedAvgHr
          ? _value.cachedAvgHr
          : cachedAvgHr // ignore: cast_nullable_to_non_nullable
              as HeartRate?,
      cachedMaxHr: freezed == cachedMaxHr
          ? _value.cachedMaxHr
          : cachedMaxHr // ignore: cast_nullable_to_non_nullable
              as HeartRate?,
      cachedTotalDistance: freezed == cachedTotalDistance
          ? _value.cachedTotalDistance
          : cachedTotalDistance // ignore: cast_nullable_to_non_nullable
              as Distance?,
      cachedTss: freezed == cachedTss
          ? _value.cachedTss
          : cachedTss // ignore: cast_nullable_to_non_nullable
              as double?,
      cachedIntensityFactor: freezed == cachedIntensityFactor
          ? _value.cachedIntensityFactor
          : cachedIntensityFactor // ignore: cast_nullable_to_non_nullable
              as double?,
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
      this.pauseDuration = Duration.zero,
      this.cachedAvgPower,
      this.cachedNormalizedPower,
      this.cachedMaxPower,
      this.cachedAvgCadence,
      this.cachedAvgHr,
      this.cachedMaxHr,
      this.cachedTotalDistance,
      this.cachedTss,
      this.cachedIntensityFactor})
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
  final Watts? cachedAvgPower;
  @override
  final Watts? cachedNormalizedPower;
  @override
  final Watts? cachedMaxPower;
  @override
  final Cadence? cachedAvgCadence;
  @override
  final HeartRate? cachedAvgHr;
  @override
  final HeartRate? cachedMaxHr;
  @override
  final Distance? cachedTotalDistance;
  @override
  final double? cachedTss;
  @override
  final double? cachedIntensityFactor;

  @override
  String toString() {
    return 'Ride(id: $id, startTime: $startTime, endTime: $endTime, status: $status, readings: $readings, laps: $laps, pauseDuration: $pauseDuration, cachedAvgPower: $cachedAvgPower, cachedNormalizedPower: $cachedNormalizedPower, cachedMaxPower: $cachedMaxPower, cachedAvgCadence: $cachedAvgCadence, cachedAvgHr: $cachedAvgHr, cachedMaxHr: $cachedMaxHr, cachedTotalDistance: $cachedTotalDistance, cachedTss: $cachedTss, cachedIntensityFactor: $cachedIntensityFactor)';
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
                other.pauseDuration == pauseDuration) &&
            (identical(other.cachedAvgPower, cachedAvgPower) ||
                other.cachedAvgPower == cachedAvgPower) &&
            (identical(other.cachedNormalizedPower, cachedNormalizedPower) ||
                other.cachedNormalizedPower == cachedNormalizedPower) &&
            (identical(other.cachedMaxPower, cachedMaxPower) ||
                other.cachedMaxPower == cachedMaxPower) &&
            (identical(other.cachedAvgCadence, cachedAvgCadence) ||
                other.cachedAvgCadence == cachedAvgCadence) &&
            (identical(other.cachedAvgHr, cachedAvgHr) ||
                other.cachedAvgHr == cachedAvgHr) &&
            (identical(other.cachedMaxHr, cachedMaxHr) ||
                other.cachedMaxHr == cachedMaxHr) &&
            (identical(other.cachedTotalDistance, cachedTotalDistance) ||
                other.cachedTotalDistance == cachedTotalDistance) &&
            (identical(other.cachedTss, cachedTss) ||
                other.cachedTss == cachedTss) &&
            (identical(other.cachedIntensityFactor, cachedIntensityFactor) ||
                other.cachedIntensityFactor == cachedIntensityFactor));
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
      pauseDuration,
      cachedAvgPower,
      cachedNormalizedPower,
      cachedMaxPower,
      cachedAvgCadence,
      cachedAvgHr,
      cachedMaxHr,
      cachedTotalDistance,
      cachedTss,
      cachedIntensityFactor);

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
      final Duration pauseDuration,
      final Watts? cachedAvgPower,
      final Watts? cachedNormalizedPower,
      final Watts? cachedMaxPower,
      final Cadence? cachedAvgCadence,
      final HeartRate? cachedAvgHr,
      final HeartRate? cachedMaxHr,
      final Distance? cachedTotalDistance,
      final double? cachedTss,
      final double? cachedIntensityFactor}) = _$_Ride;
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
  Watts? get cachedAvgPower;
  @override
  Watts? get cachedNormalizedPower;
  @override
  Watts? get cachedMaxPower;
  @override
  Cadence? get cachedAvgCadence;
  @override
  HeartRate? get cachedAvgHr;
  @override
  HeartRate? get cachedMaxHr;
  @override
  Distance? get cachedTotalDistance;
  @override
  double? get cachedTss;
  @override
  double? get cachedIntensityFactor;
  @override
  @JsonKey(ignore: true)
  _$$_RideCopyWith<_$_Ride> get copyWith => throw _privateConstructorUsedError;
}
