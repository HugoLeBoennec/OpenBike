// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'power_zone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$PowerZone {
  String get name => throw _privateConstructorUsedError;
  double get minPercent => throw _privateConstructorUsedError;
  double get maxPercent => throw _privateConstructorUsedError;
  Color get color => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PowerZoneCopyWith<PowerZone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PowerZoneCopyWith<$Res> {
  factory $PowerZoneCopyWith(PowerZone value, $Res Function(PowerZone) then) =
      _$PowerZoneCopyWithImpl<$Res, PowerZone>;
  @useResult
  $Res call({String name, double minPercent, double maxPercent, Color color});
}

/// @nodoc
class _$PowerZoneCopyWithImpl<$Res, $Val extends PowerZone>
    implements $PowerZoneCopyWith<$Res> {
  _$PowerZoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? minPercent = null,
    Object? maxPercent = null,
    Object? color = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      minPercent: null == minPercent
          ? _value.minPercent
          : minPercent // ignore: cast_nullable_to_non_nullable
              as double,
      maxPercent: null == maxPercent
          ? _value.maxPercent
          : maxPercent // ignore: cast_nullable_to_non_nullable
              as double,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PowerZoneCopyWith<$Res> implements $PowerZoneCopyWith<$Res> {
  factory _$$_PowerZoneCopyWith(
          _$_PowerZone value, $Res Function(_$_PowerZone) then) =
      __$$_PowerZoneCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, double minPercent, double maxPercent, Color color});
}

/// @nodoc
class __$$_PowerZoneCopyWithImpl<$Res>
    extends _$PowerZoneCopyWithImpl<$Res, _$_PowerZone>
    implements _$$_PowerZoneCopyWith<$Res> {
  __$$_PowerZoneCopyWithImpl(
      _$_PowerZone _value, $Res Function(_$_PowerZone) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? minPercent = null,
    Object? maxPercent = null,
    Object? color = null,
  }) {
    return _then(_$_PowerZone(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      minPercent: null == minPercent
          ? _value.minPercent
          : minPercent // ignore: cast_nullable_to_non_nullable
              as double,
      maxPercent: null == maxPercent
          ? _value.maxPercent
          : maxPercent // ignore: cast_nullable_to_non_nullable
              as double,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color,
    ));
  }
}

/// @nodoc

class _$_PowerZone extends _PowerZone {
  const _$_PowerZone(
      {required this.name,
      required this.minPercent,
      required this.maxPercent,
      required this.color})
      : super._();

  @override
  final String name;
  @override
  final double minPercent;
  @override
  final double maxPercent;
  @override
  final Color color;

  @override
  String toString() {
    return 'PowerZone(name: $name, minPercent: $minPercent, maxPercent: $maxPercent, color: $color)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PowerZone &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.minPercent, minPercent) ||
                other.minPercent == minPercent) &&
            (identical(other.maxPercent, maxPercent) ||
                other.maxPercent == maxPercent) &&
            (identical(other.color, color) || other.color == color));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, name, minPercent, maxPercent, color);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PowerZoneCopyWith<_$_PowerZone> get copyWith =>
      __$$_PowerZoneCopyWithImpl<_$_PowerZone>(this, _$identity);
}

abstract class _PowerZone extends PowerZone {
  const factory _PowerZone(
      {required final String name,
      required final double minPercent,
      required final double maxPercent,
      required final Color color}) = _$_PowerZone;
  const _PowerZone._() : super._();

  @override
  String get name;
  @override
  double get minPercent;
  @override
  double get maxPercent;
  @override
  Color get color;
  @override
  @JsonKey(ignore: true)
  _$$_PowerZoneCopyWith<_$_PowerZone> get copyWith =>
      throw _privateConstructorUsedError;
}
