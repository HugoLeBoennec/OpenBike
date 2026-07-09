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
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Speed {
  double get kmh => throw _privateConstructorUsedError;

  /// Create a copy of Speed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of Speed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? kmh = null}) {
    return _then(
      _value.copyWith(
            kmh: null == kmh
                ? _value.kmh
                : kmh // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SpeedImplCopyWith<$Res> implements $SpeedCopyWith<$Res> {
  factory _$$SpeedImplCopyWith(
    _$SpeedImpl value,
    $Res Function(_$SpeedImpl) then,
  ) = __$$SpeedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double kmh});
}

/// @nodoc
class __$$SpeedImplCopyWithImpl<$Res>
    extends _$SpeedCopyWithImpl<$Res, _$SpeedImpl>
    implements _$$SpeedImplCopyWith<$Res> {
  __$$SpeedImplCopyWithImpl(
    _$SpeedImpl _value,
    $Res Function(_$SpeedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Speed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? kmh = null}) {
    return _then(
      _$SpeedImpl(
        null == kmh
            ? _value.kmh
            : kmh // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$SpeedImpl extends _Speed {
  const _$SpeedImpl(this.kmh) : super._();

  @override
  final double kmh;

  @override
  String toString() {
    return 'Speed(kmh: $kmh)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpeedImpl &&
            (identical(other.kmh, kmh) || other.kmh == kmh));
  }

  @override
  int get hashCode => Object.hash(runtimeType, kmh);

  /// Create a copy of Speed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpeedImplCopyWith<_$SpeedImpl> get copyWith =>
      __$$SpeedImplCopyWithImpl<_$SpeedImpl>(this, _$identity);
}

abstract class _Speed extends Speed {
  const factory _Speed(final double kmh) = _$SpeedImpl;
  const _Speed._() : super._();

  @override
  double get kmh;

  /// Create a copy of Speed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpeedImplCopyWith<_$SpeedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
