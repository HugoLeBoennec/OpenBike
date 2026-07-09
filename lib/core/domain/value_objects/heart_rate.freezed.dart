// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'heart_rate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HeartRate {
  int get bpm => throw _privateConstructorUsedError;

  /// Create a copy of HeartRate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HeartRateCopyWith<HeartRate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeartRateCopyWith<$Res> {
  factory $HeartRateCopyWith(HeartRate value, $Res Function(HeartRate) then) =
      _$HeartRateCopyWithImpl<$Res, HeartRate>;
  @useResult
  $Res call({int bpm});
}

/// @nodoc
class _$HeartRateCopyWithImpl<$Res, $Val extends HeartRate>
    implements $HeartRateCopyWith<$Res> {
  _$HeartRateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HeartRate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? bpm = null}) {
    return _then(
      _value.copyWith(
            bpm: null == bpm
                ? _value.bpm
                : bpm // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HeartRateImplCopyWith<$Res>
    implements $HeartRateCopyWith<$Res> {
  factory _$$HeartRateImplCopyWith(
    _$HeartRateImpl value,
    $Res Function(_$HeartRateImpl) then,
  ) = __$$HeartRateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int bpm});
}

/// @nodoc
class __$$HeartRateImplCopyWithImpl<$Res>
    extends _$HeartRateCopyWithImpl<$Res, _$HeartRateImpl>
    implements _$$HeartRateImplCopyWith<$Res> {
  __$$HeartRateImplCopyWithImpl(
    _$HeartRateImpl _value,
    $Res Function(_$HeartRateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HeartRate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? bpm = null}) {
    return _then(
      _$HeartRateImpl(
        null == bpm
            ? _value.bpm
            : bpm // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$HeartRateImpl extends _HeartRate {
  const _$HeartRateImpl(this.bpm) : super._();

  @override
  final int bpm;

  @override
  String toString() {
    return 'HeartRate(bpm: $bpm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeartRateImpl &&
            (identical(other.bpm, bpm) || other.bpm == bpm));
  }

  @override
  int get hashCode => Object.hash(runtimeType, bpm);

  /// Create a copy of HeartRate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HeartRateImplCopyWith<_$HeartRateImpl> get copyWith =>
      __$$HeartRateImplCopyWithImpl<_$HeartRateImpl>(this, _$identity);
}

abstract class _HeartRate extends HeartRate {
  const factory _HeartRate(final int bpm) = _$HeartRateImpl;
  const _HeartRate._() : super._();

  @override
  int get bpm;

  /// Create a copy of HeartRate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HeartRateImplCopyWith<_$HeartRateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
