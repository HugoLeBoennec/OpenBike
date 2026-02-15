// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lap.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Lap {
  int get startIndex => throw _privateConstructorUsedError;
  int get endIndex => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LapCopyWith<Lap> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LapCopyWith<$Res> {
  factory $LapCopyWith(Lap value, $Res Function(Lap) then) =
      _$LapCopyWithImpl<$Res, Lap>;
  @useResult
  $Res call(
      {int startIndex, int endIndex, DateTime startTime, Duration duration});
}

/// @nodoc
class _$LapCopyWithImpl<$Res, $Val extends Lap> implements $LapCopyWith<$Res> {
  _$LapCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startIndex = null,
    Object? endIndex = null,
    Object? startTime = null,
    Object? duration = null,
  }) {
    return _then(_value.copyWith(
      startIndex: null == startIndex
          ? _value.startIndex
          : startIndex // ignore: cast_nullable_to_non_nullable
              as int,
      endIndex: null == endIndex
          ? _value.endIndex
          : endIndex // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LapCopyWith<$Res> implements $LapCopyWith<$Res> {
  factory _$$_LapCopyWith(_$_Lap value, $Res Function(_$_Lap) then) =
      __$$_LapCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int startIndex, int endIndex, DateTime startTime, Duration duration});
}

/// @nodoc
class __$$_LapCopyWithImpl<$Res> extends _$LapCopyWithImpl<$Res, _$_Lap>
    implements _$$_LapCopyWith<$Res> {
  __$$_LapCopyWithImpl(_$_Lap _value, $Res Function(_$_Lap) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startIndex = null,
    Object? endIndex = null,
    Object? startTime = null,
    Object? duration = null,
  }) {
    return _then(_$_Lap(
      startIndex: null == startIndex
          ? _value.startIndex
          : startIndex // ignore: cast_nullable_to_non_nullable
              as int,
      endIndex: null == endIndex
          ? _value.endIndex
          : endIndex // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc

class _$_Lap implements _Lap {
  const _$_Lap(
      {required this.startIndex,
      required this.endIndex,
      required this.startTime,
      required this.duration});

  @override
  final int startIndex;
  @override
  final int endIndex;
  @override
  final DateTime startTime;
  @override
  final Duration duration;

  @override
  String toString() {
    return 'Lap(startIndex: $startIndex, endIndex: $endIndex, startTime: $startTime, duration: $duration)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Lap &&
            (identical(other.startIndex, startIndex) ||
                other.startIndex == startIndex) &&
            (identical(other.endIndex, endIndex) ||
                other.endIndex == endIndex) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, startIndex, endIndex, startTime, duration);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LapCopyWith<_$_Lap> get copyWith =>
      __$$_LapCopyWithImpl<_$_Lap>(this, _$identity);
}

abstract class _Lap implements Lap {
  const factory _Lap(
      {required final int startIndex,
      required final int endIndex,
      required final DateTime startTime,
      required final Duration duration}) = _$_Lap;

  @override
  int get startIndex;
  @override
  int get endIndex;
  @override
  DateTime get startTime;
  @override
  Duration get duration;
  @override
  @JsonKey(ignore: true)
  _$$_LapCopyWith<_$_Lap> get copyWith => throw _privateConstructorUsedError;
}
