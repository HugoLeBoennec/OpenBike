// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'distance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Distance {
  double get meters => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DistanceCopyWith<Distance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DistanceCopyWith<$Res> {
  factory $DistanceCopyWith(Distance value, $Res Function(Distance) then) =
      _$DistanceCopyWithImpl<$Res, Distance>;
  @useResult
  $Res call({double meters});
}

/// @nodoc
class _$DistanceCopyWithImpl<$Res, $Val extends Distance>
    implements $DistanceCopyWith<$Res> {
  _$DistanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meters = null,
  }) {
    return _then(_value.copyWith(
      meters: null == meters
          ? _value.meters
          : meters // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DistanceCopyWith<$Res> implements $DistanceCopyWith<$Res> {
  factory _$$_DistanceCopyWith(
          _$_Distance value, $Res Function(_$_Distance) then) =
      __$$_DistanceCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double meters});
}

/// @nodoc
class __$$_DistanceCopyWithImpl<$Res>
    extends _$DistanceCopyWithImpl<$Res, _$_Distance>
    implements _$$_DistanceCopyWith<$Res> {
  __$$_DistanceCopyWithImpl(
      _$_Distance _value, $Res Function(_$_Distance) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meters = null,
  }) {
    return _then(_$_Distance(
      null == meters
          ? _value.meters
          : meters // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$_Distance extends _Distance {
  const _$_Distance(this.meters) : super._();

  @override
  final double meters;

  @override
  String toString() {
    return 'Distance(meters: $meters)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Distance &&
            (identical(other.meters, meters) || other.meters == meters));
  }

  @override
  int get hashCode => Object.hash(runtimeType, meters);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DistanceCopyWith<_$_Distance> get copyWith =>
      __$$_DistanceCopyWithImpl<_$_Distance>(this, _$identity);
}

abstract class _Distance extends Distance {
  const factory _Distance(final double meters) = _$_Distance;
  const _Distance._() : super._();

  @override
  double get meters;
  @override
  @JsonKey(ignore: true)
  _$$_DistanceCopyWith<_$_Distance> get copyWith =>
      throw _privateConstructorUsedError;
}
