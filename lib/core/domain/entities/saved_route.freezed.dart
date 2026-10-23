// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_route.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SavedRoute {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// [importSource] for a file the rider picked; otherwise the id of the
  /// route source that provided it, with [externalRef] its id there.
  String get source => throw _privateConstructorUsedError;
  String? get externalRef => throw _privateConstructorUsedError;

  /// Encoded [RouteShape] — what duplicate detection compares.
  String get fingerprint => throw _privateConstructorUsedError;
  Distance get distance => throw _privateConstructorUsedError;

  /// Metres climbed, from the smoothed elevations.
  double get ascent => throw _privateConstructorUsedError;

  /// Elevation samples spread evenly along the route, for thumbnails.
  List<double> get profile => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get rideCount => throw _privateConstructorUsedError;
  DateTime? get lastRiddenAt => throw _privateConstructorUsedError;

  /// Create a copy of SavedRoute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavedRouteCopyWith<SavedRoute> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavedRouteCopyWith<$Res> {
  factory $SavedRouteCopyWith(
    SavedRoute value,
    $Res Function(SavedRoute) then,
  ) = _$SavedRouteCopyWithImpl<$Res, SavedRoute>;
  @useResult
  $Res call({
    String id,
    String name,
    String source,
    String? externalRef,
    String fingerprint,
    Distance distance,
    double ascent,
    List<double> profile,
    DateTime createdAt,
    int rideCount,
    DateTime? lastRiddenAt,
  });

  $DistanceCopyWith<$Res> get distance;
}

/// @nodoc
class _$SavedRouteCopyWithImpl<$Res, $Val extends SavedRoute>
    implements $SavedRouteCopyWith<$Res> {
  _$SavedRouteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavedRoute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? source = null,
    Object? externalRef = freezed,
    Object? fingerprint = null,
    Object? distance = null,
    Object? ascent = null,
    Object? profile = null,
    Object? createdAt = null,
    Object? rideCount = null,
    Object? lastRiddenAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            externalRef: freezed == externalRef
                ? _value.externalRef
                : externalRef // ignore: cast_nullable_to_non_nullable
                      as String?,
            fingerprint: null == fingerprint
                ? _value.fingerprint
                : fingerprint // ignore: cast_nullable_to_non_nullable
                      as String,
            distance: null == distance
                ? _value.distance
                : distance // ignore: cast_nullable_to_non_nullable
                      as Distance,
            ascent: null == ascent
                ? _value.ascent
                : ascent // ignore: cast_nullable_to_non_nullable
                      as double,
            profile: null == profile
                ? _value.profile
                : profile // ignore: cast_nullable_to_non_nullable
                      as List<double>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            rideCount: null == rideCount
                ? _value.rideCount
                : rideCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastRiddenAt: freezed == lastRiddenAt
                ? _value.lastRiddenAt
                : lastRiddenAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of SavedRoute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DistanceCopyWith<$Res> get distance {
    return $DistanceCopyWith<$Res>(_value.distance, (value) {
      return _then(_value.copyWith(distance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SavedRouteImplCopyWith<$Res>
    implements $SavedRouteCopyWith<$Res> {
  factory _$$SavedRouteImplCopyWith(
    _$SavedRouteImpl value,
    $Res Function(_$SavedRouteImpl) then,
  ) = __$$SavedRouteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String source,
    String? externalRef,
    String fingerprint,
    Distance distance,
    double ascent,
    List<double> profile,
    DateTime createdAt,
    int rideCount,
    DateTime? lastRiddenAt,
  });

  @override
  $DistanceCopyWith<$Res> get distance;
}

/// @nodoc
class __$$SavedRouteImplCopyWithImpl<$Res>
    extends _$SavedRouteCopyWithImpl<$Res, _$SavedRouteImpl>
    implements _$$SavedRouteImplCopyWith<$Res> {
  __$$SavedRouteImplCopyWithImpl(
    _$SavedRouteImpl _value,
    $Res Function(_$SavedRouteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SavedRoute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? source = null,
    Object? externalRef = freezed,
    Object? fingerprint = null,
    Object? distance = null,
    Object? ascent = null,
    Object? profile = null,
    Object? createdAt = null,
    Object? rideCount = null,
    Object? lastRiddenAt = freezed,
  }) {
    return _then(
      _$SavedRouteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        externalRef: freezed == externalRef
            ? _value.externalRef
            : externalRef // ignore: cast_nullable_to_non_nullable
                  as String?,
        fingerprint: null == fingerprint
            ? _value.fingerprint
            : fingerprint // ignore: cast_nullable_to_non_nullable
                  as String,
        distance: null == distance
            ? _value.distance
            : distance // ignore: cast_nullable_to_non_nullable
                  as Distance,
        ascent: null == ascent
            ? _value.ascent
            : ascent // ignore: cast_nullable_to_non_nullable
                  as double,
        profile: null == profile
            ? _value._profile
            : profile // ignore: cast_nullable_to_non_nullable
                  as List<double>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        rideCount: null == rideCount
            ? _value.rideCount
            : rideCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastRiddenAt: freezed == lastRiddenAt
            ? _value.lastRiddenAt
            : lastRiddenAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$SavedRouteImpl extends _SavedRoute {
  const _$SavedRouteImpl({
    required this.id,
    required this.name,
    this.source = SavedRoute.importSource,
    this.externalRef,
    required this.fingerprint,
    required this.distance,
    required this.ascent,
    final List<double> profile = const [],
    required this.createdAt,
    this.rideCount = 0,
    this.lastRiddenAt,
  }) : _profile = profile,
       super._();

  @override
  final String id;
  @override
  final String name;

  /// [importSource] for a file the rider picked; otherwise the id of the
  /// route source that provided it, with [externalRef] its id there.
  @override
  @JsonKey()
  final String source;
  @override
  final String? externalRef;

  /// Encoded [RouteShape] — what duplicate detection compares.
  @override
  final String fingerprint;
  @override
  final Distance distance;

  /// Metres climbed, from the smoothed elevations.
  @override
  final double ascent;

  /// Elevation samples spread evenly along the route, for thumbnails.
  final List<double> _profile;

  /// Elevation samples spread evenly along the route, for thumbnails.
  @override
  @JsonKey()
  List<double> get profile {
    if (_profile is EqualUnmodifiableListView) return _profile;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_profile);
  }

  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int rideCount;
  @override
  final DateTime? lastRiddenAt;

  @override
  String toString() {
    return 'SavedRoute(id: $id, name: $name, source: $source, externalRef: $externalRef, fingerprint: $fingerprint, distance: $distance, ascent: $ascent, profile: $profile, createdAt: $createdAt, rideCount: $rideCount, lastRiddenAt: $lastRiddenAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavedRouteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.externalRef, externalRef) ||
                other.externalRef == externalRef) &&
            (identical(other.fingerprint, fingerprint) ||
                other.fingerprint == fingerprint) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.ascent, ascent) || other.ascent == ascent) &&
            const DeepCollectionEquality().equals(other._profile, _profile) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.rideCount, rideCount) ||
                other.rideCount == rideCount) &&
            (identical(other.lastRiddenAt, lastRiddenAt) ||
                other.lastRiddenAt == lastRiddenAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    source,
    externalRef,
    fingerprint,
    distance,
    ascent,
    const DeepCollectionEquality().hash(_profile),
    createdAt,
    rideCount,
    lastRiddenAt,
  );

  /// Create a copy of SavedRoute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavedRouteImplCopyWith<_$SavedRouteImpl> get copyWith =>
      __$$SavedRouteImplCopyWithImpl<_$SavedRouteImpl>(this, _$identity);
}

abstract class _SavedRoute extends SavedRoute {
  const factory _SavedRoute({
    required final String id,
    required final String name,
    final String source,
    final String? externalRef,
    required final String fingerprint,
    required final Distance distance,
    required final double ascent,
    final List<double> profile,
    required final DateTime createdAt,
    final int rideCount,
    final DateTime? lastRiddenAt,
  }) = _$SavedRouteImpl;
  const _SavedRoute._() : super._();

  @override
  String get id;
  @override
  String get name;

  /// [importSource] for a file the rider picked; otherwise the id of the
  /// route source that provided it, with [externalRef] its id there.
  @override
  String get source;
  @override
  String? get externalRef;

  /// Encoded [RouteShape] — what duplicate detection compares.
  @override
  String get fingerprint;
  @override
  Distance get distance;

  /// Metres climbed, from the smoothed elevations.
  @override
  double get ascent;

  /// Elevation samples spread evenly along the route, for thumbnails.
  @override
  List<double> get profile;
  @override
  DateTime get createdAt;
  @override
  int get rideCount;
  @override
  DateTime? get lastRiddenAt;

  /// Create a copy of SavedRoute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavedRouteImplCopyWith<_$SavedRouteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
