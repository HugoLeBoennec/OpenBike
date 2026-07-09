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
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PowerZone {
  String get name => throw _privateConstructorUsedError;
  double get minPercent => throw _privateConstructorUsedError;
  double get maxPercent => throw _privateConstructorUsedError;
  Color get color => throw _privateConstructorUsedError;

  /// Create a copy of PowerZone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of PowerZone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? minPercent = null,
    Object? maxPercent = null,
    Object? color = null,
  }) {
    return _then(
      _value.copyWith(
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PowerZoneImplCopyWith<$Res>
    implements $PowerZoneCopyWith<$Res> {
  factory _$$PowerZoneImplCopyWith(
    _$PowerZoneImpl value,
    $Res Function(_$PowerZoneImpl) then,
  ) = __$$PowerZoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, double minPercent, double maxPercent, Color color});
}

/// @nodoc
class __$$PowerZoneImplCopyWithImpl<$Res>
    extends _$PowerZoneCopyWithImpl<$Res, _$PowerZoneImpl>
    implements _$$PowerZoneImplCopyWith<$Res> {
  __$$PowerZoneImplCopyWithImpl(
    _$PowerZoneImpl _value,
    $Res Function(_$PowerZoneImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PowerZone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? minPercent = null,
    Object? maxPercent = null,
    Object? color = null,
  }) {
    return _then(
      _$PowerZoneImpl(
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
      ),
    );
  }
}

/// @nodoc

class _$PowerZoneImpl extends _PowerZone {
  const _$PowerZoneImpl({
    required this.name,
    required this.minPercent,
    required this.maxPercent,
    required this.color,
  }) : super._();

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PowerZoneImpl &&
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

  /// Create a copy of PowerZone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PowerZoneImplCopyWith<_$PowerZoneImpl> get copyWith =>
      __$$PowerZoneImplCopyWithImpl<_$PowerZoneImpl>(this, _$identity);
}

abstract class _PowerZone extends PowerZone {
  const factory _PowerZone({
    required final String name,
    required final double minPercent,
    required final double maxPercent,
    required final Color color,
  }) = _$PowerZoneImpl;
  const _PowerZone._() : super._();

  @override
  String get name;
  @override
  double get minPercent;
  @override
  double get maxPercent;
  @override
  Color get color;

  /// Create a copy of PowerZone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PowerZoneImplCopyWith<_$PowerZoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
