// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cadence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Cadence {
  double get rpm => throw _privateConstructorUsedError;

  /// Create a copy of Cadence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CadenceCopyWith<Cadence> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceCopyWith<$Res> {
  factory $CadenceCopyWith(Cadence value, $Res Function(Cadence) then) =
      _$CadenceCopyWithImpl<$Res, Cadence>;
  @useResult
  $Res call({double rpm});
}

/// @nodoc
class _$CadenceCopyWithImpl<$Res, $Val extends Cadence>
    implements $CadenceCopyWith<$Res> {
  _$CadenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Cadence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rpm = null}) {
    return _then(
      _value.copyWith(
            rpm: null == rpm
                ? _value.rpm
                : rpm // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CadenceImplCopyWith<$Res> implements $CadenceCopyWith<$Res> {
  factory _$$CadenceImplCopyWith(
    _$CadenceImpl value,
    $Res Function(_$CadenceImpl) then,
  ) = __$$CadenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double rpm});
}

/// @nodoc
class __$$CadenceImplCopyWithImpl<$Res>
    extends _$CadenceCopyWithImpl<$Res, _$CadenceImpl>
    implements _$$CadenceImplCopyWith<$Res> {
  __$$CadenceImplCopyWithImpl(
    _$CadenceImpl _value,
    $Res Function(_$CadenceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Cadence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rpm = null}) {
    return _then(
      _$CadenceImpl(
        null == rpm
            ? _value.rpm
            : rpm // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$CadenceImpl extends _Cadence {
  const _$CadenceImpl(this.rpm) : super._();

  @override
  final double rpm;

  @override
  String toString() {
    return 'Cadence(rpm: $rpm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CadenceImpl &&
            (identical(other.rpm, rpm) || other.rpm == rpm));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rpm);

  /// Create a copy of Cadence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CadenceImplCopyWith<_$CadenceImpl> get copyWith =>
      __$$CadenceImplCopyWithImpl<_$CadenceImpl>(this, _$identity);
}

abstract class _Cadence extends Cadence {
  const factory _Cadence(final double rpm) = _$CadenceImpl;
  const _Cadence._() : super._();

  @override
  double get rpm;

  /// Create a copy of Cadence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CadenceImplCopyWith<_$CadenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
