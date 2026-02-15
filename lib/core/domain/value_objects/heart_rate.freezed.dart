// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'heart_rate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$HeartRate {
  int get bpm => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HeartRateCopyWith<HeartRate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeartRateCopyWith<$Res> {
  factory $HeartRateCopyWith(HeartRate value, $Res Function(HeartRate) then) =
      _$HeartRateCopyWithImpl<$Res, HeartRate>;
  @useResult
  $Res call({int bpm});
}

/// @nodoc
class _$HeartRateCopyWithImpl<$Res, $Val extends HeartRate>
    implements $HeartRateCopyWith<$Res> {
  _$HeartRateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bpm = null,
  }) {
    return _then(_value.copyWith(
      bpm: null == bpm
          ? _value.bpm
          : bpm // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_HeartRateCopyWith<$Res> implements $HeartRateCopyWith<$Res> {
  factory _$$_HeartRateCopyWith(
          _$_HeartRate value, $Res Function(_$_HeartRate) then) =
      __$$_HeartRateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int bpm});
}

/// @nodoc
class __$$_HeartRateCopyWithImpl<$Res>
    extends _$HeartRateCopyWithImpl<$Res, _$_HeartRate>
    implements _$$_HeartRateCopyWith<$Res> {
  __$$_HeartRateCopyWithImpl(
      _$_HeartRate _value, $Res Function(_$_HeartRate) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bpm = null,
  }) {
    return _then(_$_HeartRate(
      null == bpm
          ? _value.bpm
          : bpm // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_HeartRate extends _HeartRate {
  const _$_HeartRate(this.bpm) : super._();

  @override
  final int bpm;

  @override
  String toString() {
    return 'HeartRate(bpm: $bpm)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_HeartRate &&
            (identical(other.bpm, bpm) || other.bpm == bpm));
  }

  @override
  int get hashCode => Object.hash(runtimeType, bpm);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_HeartRateCopyWith<_$_HeartRate> get copyWith =>
      __$$_HeartRateCopyWithImpl<_$_HeartRate>(this, _$identity);
}

abstract class _HeartRate extends HeartRate {
  const factory _HeartRate(final int bpm) = _$_HeartRate;
  const _HeartRate._() : super._();

  @override
  int get bpm;
  @override
  @JsonKey(ignore: true)
  _$$_HeartRateCopyWith<_$_HeartRate> get copyWith =>
      throw _privateConstructorUsedError;
}
