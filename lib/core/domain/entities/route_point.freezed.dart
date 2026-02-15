// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$RoutePoint {
  GeoPoint get position => throw _privateConstructorUsedError;
  double get distanceFromStart => throw _privateConstructorUsedError;
  double get smoothedElevation => throw _privateConstructorUsedError;
  Grade get grade => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RoutePointCopyWith<RoutePoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoutePointCopyWith<$Res> {
  factory $RoutePointCopyWith(
          RoutePoint value, $Res Function(RoutePoint) then) =
      _$RoutePointCopyWithImpl<$Res, RoutePoint>;
  @useResult
  $Res call(
      {GeoPoint position,
      double distanceFromStart,
      double smoothedElevation,
      Grade grade});

  $GeoPointCopyWith<$Res> get position;
  $GradeCopyWith<$Res> get grade;
}

/// @nodoc
class _$RoutePointCopyWithImpl<$Res, $Val extends RoutePoint>
    implements $RoutePointCopyWith<$Res> {
  _$RoutePointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? distanceFromStart = null,
    Object? smoothedElevation = null,
    Object? grade = null,
  }) {
    return _then(_value.copyWith(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as GeoPoint,
      distanceFromStart: null == distanceFromStart
          ? _value.distanceFromStart
          : distanceFromStart // ignore: cast_nullable_to_non_nullable
              as double,
      smoothedElevation: null == smoothedElevation
          ? _value.smoothedElevation
          : smoothedElevation // ignore: cast_nullable_to_non_nullable
              as double,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as Grade,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GeoPointCopyWith<$Res> get position {
    return $GeoPointCopyWith<$Res>(_value.position, (value) {
      return _then(_value.copyWith(position: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GradeCopyWith<$Res> get grade {
    return $GradeCopyWith<$Res>(_value.grade, (value) {
      return _then(_value.copyWith(grade: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_RoutePointCopyWith<$Res>
    implements $RoutePointCopyWith<$Res> {
  factory _$$_RoutePointCopyWith(
          _$_RoutePoint value, $Res Function(_$_RoutePoint) then) =
      __$$_RoutePointCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {GeoPoint position,
      double distanceFromStart,
      double smoothedElevation,
      Grade grade});

  @override
  $GeoPointCopyWith<$Res> get position;
  @override
  $GradeCopyWith<$Res> get grade;
}

/// @nodoc
class __$$_RoutePointCopyWithImpl<$Res>
    extends _$RoutePointCopyWithImpl<$Res, _$_RoutePoint>
    implements _$$_RoutePointCopyWith<$Res> {
  __$$_RoutePointCopyWithImpl(
      _$_RoutePoint _value, $Res Function(_$_RoutePoint) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? distanceFromStart = null,
    Object? smoothedElevation = null,
    Object? grade = null,
  }) {
    return _then(_$_RoutePoint(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as GeoPoint,
      distanceFromStart: null == distanceFromStart
          ? _value.distanceFromStart
          : distanceFromStart // ignore: cast_nullable_to_non_nullable
              as double,
      smoothedElevation: null == smoothedElevation
          ? _value.smoothedElevation
          : smoothedElevation // ignore: cast_nullable_to_non_nullable
              as double,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as Grade,
    ));
  }
}

/// @nodoc

class _$_RoutePoint extends _RoutePoint {
  const _$_RoutePoint(
      {required this.position,
      required this.distanceFromStart,
      required this.smoothedElevation,
      required this.grade})
      : super._();

  @override
  final GeoPoint position;
  @override
  final double distanceFromStart;
  @override
  final double smoothedElevation;
  @override
  final Grade grade;

  @override
  String toString() {
    return 'RoutePoint(position: $position, distanceFromStart: $distanceFromStart, smoothedElevation: $smoothedElevation, grade: $grade)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_RoutePoint &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.distanceFromStart, distanceFromStart) ||
                other.distanceFromStart == distanceFromStart) &&
            (identical(other.smoothedElevation, smoothedElevation) ||
                other.smoothedElevation == smoothedElevation) &&
            (identical(other.grade, grade) || other.grade == grade));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, position, distanceFromStart, smoothedElevation, grade);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_RoutePointCopyWith<_$_RoutePoint> get copyWith =>
      __$$_RoutePointCopyWithImpl<_$_RoutePoint>(this, _$identity);
}

abstract class _RoutePoint extends RoutePoint {
  const factory _RoutePoint(
      {required final GeoPoint position,
      required final double distanceFromStart,
      required final double smoothedElevation,
      required final Grade grade}) = _$_RoutePoint;
  const _RoutePoint._() : super._();

  @override
  GeoPoint get position;
  @override
  double get distanceFromStart;
  @override
  double get smoothedElevation;
  @override
  Grade get grade;
  @override
  @JsonKey(ignore: true)
  _$$_RoutePointCopyWith<_$_RoutePoint> get copyWith =>
      throw _privateConstructorUsedError;
}
