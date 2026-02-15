// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cadence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Cadence {
  double get rpm => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CadenceCopyWith<Cadence> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceCopyWith<$Res> {
  factory $CadenceCopyWith(Cadence value, $Res Function(Cadence) then) =
      _$CadenceCopyWithImpl<$Res, Cadence>;
  @useResult
  $Res call({double rpm});
}

/// @nodoc
class _$CadenceCopyWithImpl<$Res, $Val extends Cadence>
    implements $CadenceCopyWith<$Res> {
  _$CadenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rpm = null,
  }) {
    return _then(_value.copyWith(
      rpm: null == rpm
          ? _value.rpm
          : rpm // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CadenceCopyWith<$Res> implements $CadenceCopyWith<$Res> {
  factory _$$_CadenceCopyWith(
          _$_Cadence value, $Res Function(_$_Cadence) then) =
      __$$_CadenceCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double rpm});
}

/// @nodoc
class __$$_CadenceCopyWithImpl<$Res>
    extends _$CadenceCopyWithImpl<$Res, _$_Cadence>
    implements _$$_CadenceCopyWith<$Res> {
  __$$_CadenceCopyWithImpl(_$_Cadence _value, $Res Function(_$_Cadence) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rpm = null,
  }) {
    return _then(_$_Cadence(
      null == rpm
          ? _value.rpm
          : rpm // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$_Cadence extends _Cadence {
  const _$_Cadence(this.rpm) : super._();

  @override
  final double rpm;

  @override
  String toString() {
    return 'Cadence(rpm: $rpm)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Cadence &&
            (identical(other.rpm, rpm) || other.rpm == rpm));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rpm);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CadenceCopyWith<_$_Cadence> get copyWith =>
      __$$_CadenceCopyWithImpl<_$_Cadence>(this, _$identity);
}

abstract class _Cadence extends Cadence {
  const factory _Cadence(final double rpm) = _$_Cadence;
  const _Cadence._() : super._();

  @override
  double get rpm;
  @override
  @JsonKey(ignore: true)
  _$$_CadenceCopyWith<_$_Cadence> get copyWith =>
      throw _privateConstructorUsedError;
}
