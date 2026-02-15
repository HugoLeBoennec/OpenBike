// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$UserProfile {
  Watts get ftp => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  double get height => throw _privateConstructorUsedError;
  HeartRate get restingHr => throw _privateConstructorUsedError;
  HeartRate get maxHr => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {Watts ftp,
      double weight,
      double height,
      HeartRate restingHr,
      HeartRate maxHr,
      String name});

  $WattsCopyWith<$Res> get ftp;
  $HeartRateCopyWith<$Res> get restingHr;
  $HeartRateCopyWith<$Res> get maxHr;
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ftp = null,
    Object? weight = null,
    Object? height = null,
    Object? restingHr = null,
    Object? maxHr = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      ftp: null == ftp
          ? _value.ftp
          : ftp // ignore: cast_nullable_to_non_nullable
              as Watts,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
      restingHr: null == restingHr
          ? _value.restingHr
          : restingHr // ignore: cast_nullable_to_non_nullable
              as HeartRate,
      maxHr: null == maxHr
          ? _value.maxHr
          : maxHr // ignore: cast_nullable_to_non_nullable
              as HeartRate,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WattsCopyWith<$Res> get ftp {
    return $WattsCopyWith<$Res>(_value.ftp, (value) {
      return _then(_value.copyWith(ftp: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $HeartRateCopyWith<$Res> get restingHr {
    return $HeartRateCopyWith<$Res>(_value.restingHr, (value) {
      return _then(_value.copyWith(restingHr: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $HeartRateCopyWith<$Res> get maxHr {
    return $HeartRateCopyWith<$Res>(_value.maxHr, (value) {
      return _then(_value.copyWith(maxHr: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_UserProfileCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$_UserProfileCopyWith(
          _$_UserProfile value, $Res Function(_$_UserProfile) then) =
      __$$_UserProfileCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Watts ftp,
      double weight,
      double height,
      HeartRate restingHr,
      HeartRate maxHr,
      String name});

  @override
  $WattsCopyWith<$Res> get ftp;
  @override
  $HeartRateCopyWith<$Res> get restingHr;
  @override
  $HeartRateCopyWith<$Res> get maxHr;
}

/// @nodoc
class __$$_UserProfileCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$_UserProfile>
    implements _$$_UserProfileCopyWith<$Res> {
  __$$_UserProfileCopyWithImpl(
      _$_UserProfile _value, $Res Function(_$_UserProfile) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ftp = null,
    Object? weight = null,
    Object? height = null,
    Object? restingHr = null,
    Object? maxHr = null,
    Object? name = null,
  }) {
    return _then(_$_UserProfile(
      ftp: null == ftp
          ? _value.ftp
          : ftp // ignore: cast_nullable_to_non_nullable
              as Watts,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
      restingHr: null == restingHr
          ? _value.restingHr
          : restingHr // ignore: cast_nullable_to_non_nullable
              as HeartRate,
      maxHr: null == maxHr
          ? _value.maxHr
          : maxHr // ignore: cast_nullable_to_non_nullable
              as HeartRate,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_UserProfile implements _UserProfile {
  const _$_UserProfile(
      {required this.ftp,
      required this.weight,
      required this.height,
      required this.restingHr,
      required this.maxHr,
      required this.name});

  @override
  final Watts ftp;
  @override
  final double weight;
  @override
  final double height;
  @override
  final HeartRate restingHr;
  @override
  final HeartRate maxHr;
  @override
  final String name;

  @override
  String toString() {
    return 'UserProfile(ftp: $ftp, weight: $weight, height: $height, restingHr: $restingHr, maxHr: $maxHr, name: $name)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UserProfile &&
            (identical(other.ftp, ftp) || other.ftp == ftp) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.restingHr, restingHr) ||
                other.restingHr == restingHr) &&
            (identical(other.maxHr, maxHr) || other.maxHr == maxHr) &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, ftp, weight, height, restingHr, maxHr, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UserProfileCopyWith<_$_UserProfile> get copyWith =>
      __$$_UserProfileCopyWithImpl<_$_UserProfile>(this, _$identity);
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {required final Watts ftp,
      required final double weight,
      required final double height,
      required final HeartRate restingHr,
      required final HeartRate maxHr,
      required final String name}) = _$_UserProfile;

  @override
  Watts get ftp;
  @override
  double get weight;
  @override
  double get height;
  @override
  HeartRate get restingHr;
  @override
  HeartRate get maxHr;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$_UserProfileCopyWith<_$_UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}
