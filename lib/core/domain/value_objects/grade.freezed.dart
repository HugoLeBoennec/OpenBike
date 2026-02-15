// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grade.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Grade {
  double get percent => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GradeCopyWith<Grade> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GradeCopyWith<$Res> {
  factory $GradeCopyWith(Grade value, $Res Function(Grade) then) =
      _$GradeCopyWithImpl<$Res, Grade>;
  @useResult
  $Res call({double percent});
}

/// @nodoc
class _$GradeCopyWithImpl<$Res, $Val extends Grade>
    implements $GradeCopyWith<$Res> {
  _$GradeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percent = null,
  }) {
    return _then(_value.copyWith(
      percent: null == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GradeCopyWith<$Res> implements $GradeCopyWith<$Res> {
  factory _$$_GradeCopyWith(_$_Grade value, $Res Function(_$_Grade) then) =
      __$$_GradeCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double percent});
}

/// @nodoc
class __$$_GradeCopyWithImpl<$Res> extends _$GradeCopyWithImpl<$Res, _$_Grade>
    implements _$$_GradeCopyWith<$Res> {
  __$$_GradeCopyWithImpl(_$_Grade _value, $Res Function(_$_Grade) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percent = null,
  }) {
    return _then(_$_Grade(
      null == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$_Grade extends _Grade {
  const _$_Grade(this.percent) : super._();

  @override
  final double percent;

  @override
  String toString() {
    return 'Grade(percent: $percent)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Grade &&
            (identical(other.percent, percent) || other.percent == percent));
  }

  @override
  int get hashCode => Object.hash(runtimeType, percent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GradeCopyWith<_$_Grade> get copyWith =>
      __$$_GradeCopyWithImpl<_$_Grade>(this, _$identity);
}

abstract class _Grade extends Grade {
  const factory _Grade(final double percent) = _$_Grade;
  const _Grade._() : super._();

  @override
  double get percent;
  @override
  @JsonKey(ignore: true)
  _$$_GradeCopyWith<_$_Grade> get copyWith =>
      throw _privateConstructorUsedError;
}
