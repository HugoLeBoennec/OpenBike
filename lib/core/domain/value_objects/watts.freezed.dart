// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'watts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Watts {
  double get value => throw _privateConstructorUsedError;

  /// Create a copy of Watts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WattsCopyWith<Watts> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WattsCopyWith<$Res> {
  factory $WattsCopyWith(Watts value, $Res Function(Watts) then) =
      _$WattsCopyWithImpl<$Res, Watts>;
  @useResult
  $Res call({double value});
}

/// @nodoc
class _$WattsCopyWithImpl<$Res, $Val extends Watts>
    implements $WattsCopyWith<$Res> {
  _$WattsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Watts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? value = null}) {
    return _then(
      _value.copyWith(
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WattsImplCopyWith<$Res> implements $WattsCopyWith<$Res> {
  factory _$$WattsImplCopyWith(
    _$WattsImpl value,
    $Res Function(_$WattsImpl) then,
  ) = __$$WattsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double value});
}

/// @nodoc
class __$$WattsImplCopyWithImpl<$Res>
    extends _$WattsCopyWithImpl<$Res, _$WattsImpl>
    implements _$$WattsImplCopyWith<$Res> {
  __$$WattsImplCopyWithImpl(
    _$WattsImpl _value,
    $Res Function(_$WattsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Watts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? value = null}) {
    return _then(
      _$WattsImpl(
        null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$WattsImpl extends _Watts {
  const _$WattsImpl(this.value) : super._();

  @override
  final double value;

  @override
  String toString() {
    return 'Watts(value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WattsImpl &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  /// Create a copy of Watts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WattsImplCopyWith<_$WattsImpl> get copyWith =>
      __$$WattsImplCopyWithImpl<_$WattsImpl>(this, _$identity);
}

abstract class _Watts extends Watts {
  const factory _Watts(final double value) = _$WattsImpl;
  const _Watts._() : super._();

  @override
  double get value;

  /// Create a copy of Watts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WattsImplCopyWith<_$WattsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
