// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'speed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Speed {
  double get kmh => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SpeedCopyWith<Speed> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpeedCopyWith<$Res> {
  factory $SpeedCopyWith(Speed value, $Res Function(Speed) then) =
      _$SpeedCopyWithImpl<$Res, Speed>;
  @useResult
  $Res call({double kmh});
}

/// @nodoc
class _$SpeedCopyWithImpl<$Res, $Val extends Speed>
    implements $SpeedCopyWith<$Res> {
  _$SpeedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kmh = null,
  }) {
    return _then(_value.copyWith(
      kmh: null == kmh
          ? _value.kmh
          : kmh // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SpeedCopyWith<$Res> implements $SpeedCopyWith<$Res> {
  factory _$$_SpeedCopyWith(_$_Speed value, $Res Function(_$_Speed) then) =
      __$$_SpeedCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double kmh});
}

/// @nodoc
class __$$_SpeedCopyWithImpl<$Res> extends _$SpeedCopyWithImpl<$Res, _$_Speed>
    implements _$$_SpeedCopyWith<$Res> {
  __$$_SpeedCopyWithImpl(_$_Speed _value, $Res Function(_$_Speed) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kmh = null,
  }) {
    return _then(_$_Speed(
      null == kmh
          ? _value.kmh
          : kmh // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$_Speed extends _Speed {
  const _$_Speed(this.kmh) : super._();

  @override
  final double kmh;

  @override
  String toString() {
    return 'Speed(kmh: $kmh)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Speed &&
            (identical(other.kmh, kmh) || other.kmh == kmh));
  }

  @override
  int get hashCode => Object.hash(runtimeType, kmh);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SpeedCopyWith<_$_Speed> get copyWith =>
      __$$_SpeedCopyWithImpl<_$_Speed>(this, _$identity);
}

abstract class _Speed extends Speed {
  const factory _Speed(final double kmh) = _$_Speed;
  const _Speed._() : super._();

  @override
  double get kmh;
  @override
  @JsonKey(ignore: true)
  _$$_SpeedCopyWith<_$_Speed> get copyWith =>
      throw _privateConstructorUsedError;
}
