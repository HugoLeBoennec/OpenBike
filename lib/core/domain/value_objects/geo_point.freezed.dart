// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'geo_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$GeoPoint {
  double get lat => throw _privateConstructorUsedError;
  double get lon => throw _privateConstructorUsedError;
  double? get elevation => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GeoPointCopyWith<GeoPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeoPointCopyWith<$Res> {
  factory $GeoPointCopyWith(GeoPoint value, $Res Function(GeoPoint) then) =
      _$GeoPointCopyWithImpl<$Res, GeoPoint>;
  @useResult
  $Res call({double lat, double lon, double? elevation});
}

/// @nodoc
class _$GeoPointCopyWithImpl<$Res, $Val extends GeoPoint>
    implements $GeoPointCopyWith<$Res> {
  _$GeoPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lon = null,
    Object? elevation = freezed,
  }) {
    return _then(_value.copyWith(
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lon: null == lon
          ? _value.lon
          : lon // ignore: cast_nullable_to_non_nullable
              as double,
      elevation: freezed == elevation
          ? _value.elevation
          : elevation // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GeoPointCopyWith<$Res> implements $GeoPointCopyWith<$Res> {
  factory _$$_GeoPointCopyWith(
          _$_GeoPoint value, $Res Function(_$_GeoPoint) then) =
      __$$_GeoPointCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double lat, double lon, double? elevation});
}

/// @nodoc
class __$$_GeoPointCopyWithImpl<$Res>
    extends _$GeoPointCopyWithImpl<$Res, _$_GeoPoint>
    implements _$$_GeoPointCopyWith<$Res> {
  __$$_GeoPointCopyWithImpl(
      _$_GeoPoint _value, $Res Function(_$_GeoPoint) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lon = null,
    Object? elevation = freezed,
  }) {
    return _then(_$_GeoPoint(
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lon: null == lon
          ? _value.lon
          : lon // ignore: cast_nullable_to_non_nullable
              as double,
      elevation: freezed == elevation
          ? _value.elevation
          : elevation // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$_GeoPoint extends _GeoPoint {
  const _$_GeoPoint({required this.lat, required this.lon, this.elevation})
      : super._();

  @override
  final double lat;
  @override
  final double lon;
  @override
  final double? elevation;

  @override
  String toString() {
    return 'GeoPoint(lat: $lat, lon: $lon, elevation: $elevation)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GeoPoint &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lon, lon) || other.lon == lon) &&
            (identical(other.elevation, elevation) ||
                other.elevation == elevation));
  }

  @override
  int get hashCode => Object.hash(runtimeType, lat, lon, elevation);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GeoPointCopyWith<_$_GeoPoint> get copyWith =>
      __$$_GeoPointCopyWithImpl<_$_GeoPoint>(this, _$identity);
}

abstract class _GeoPoint extends GeoPoint {
  const factory _GeoPoint(
      {required final double lat,
      required final double lon,
      final double? elevation}) = _$_GeoPoint;
  const _GeoPoint._() : super._();

  @override
  double get lat;
  @override
  double get lon;
  @override
  double? get elevation;
  @override
  @JsonKey(ignore: true)
  _$$_GeoPointCopyWith<_$_GeoPoint> get copyWith =>
      throw _privateConstructorUsedError;
}
