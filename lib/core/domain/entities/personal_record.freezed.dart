// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'personal_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PersonalRecord {
  String get rideId => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  Watts get watts => throw _privateConstructorUsedError;
  DateTime get achievedAt => throw _privateConstructorUsedError;

  /// Create a copy of PersonalRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonalRecordCopyWith<PersonalRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonalRecordCopyWith<$Res> {
  factory $PersonalRecordCopyWith(
    PersonalRecord value,
    $Res Function(PersonalRecord) then,
  ) = _$PersonalRecordCopyWithImpl<$Res, PersonalRecord>;
  @useResult
  $Res call({
    String rideId,
    int durationSeconds,
    Watts watts,
    DateTime achievedAt,
  });

  $WattsCopyWith<$Res> get watts;
}

/// @nodoc
class _$PersonalRecordCopyWithImpl<$Res, $Val extends PersonalRecord>
    implements $PersonalRecordCopyWith<$Res> {
  _$PersonalRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PersonalRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? durationSeconds = null,
    Object? watts = null,
    Object? achievedAt = null,
  }) {
    return _then(
      _value.copyWith(
            rideId: null == rideId
                ? _value.rideId
                : rideId // ignore: cast_nullable_to_non_nullable
                      as String,
            durationSeconds: null == durationSeconds
                ? _value.durationSeconds
                : durationSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            watts: null == watts
                ? _value.watts
                : watts // ignore: cast_nullable_to_non_nullable
                      as Watts,
            achievedAt: null == achievedAt
                ? _value.achievedAt
                : achievedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of PersonalRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WattsCopyWith<$Res> get watts {
    return $WattsCopyWith<$Res>(_value.watts, (value) {
      return _then(_value.copyWith(watts: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PersonalRecordImplCopyWith<$Res>
    implements $PersonalRecordCopyWith<$Res> {
  factory _$$PersonalRecordImplCopyWith(
    _$PersonalRecordImpl value,
    $Res Function(_$PersonalRecordImpl) then,
  ) = __$$PersonalRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String rideId,
    int durationSeconds,
    Watts watts,
    DateTime achievedAt,
  });

  @override
  $WattsCopyWith<$Res> get watts;
}

/// @nodoc
class __$$PersonalRecordImplCopyWithImpl<$Res>
    extends _$PersonalRecordCopyWithImpl<$Res, _$PersonalRecordImpl>
    implements _$$PersonalRecordImplCopyWith<$Res> {
  __$$PersonalRecordImplCopyWithImpl(
    _$PersonalRecordImpl _value,
    $Res Function(_$PersonalRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PersonalRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rideId = null,
    Object? durationSeconds = null,
    Object? watts = null,
    Object? achievedAt = null,
  }) {
    return _then(
      _$PersonalRecordImpl(
        rideId: null == rideId
            ? _value.rideId
            : rideId // ignore: cast_nullable_to_non_nullable
                  as String,
        durationSeconds: null == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        watts: null == watts
            ? _value.watts
            : watts // ignore: cast_nullable_to_non_nullable
                  as Watts,
        achievedAt: null == achievedAt
            ? _value.achievedAt
            : achievedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$PersonalRecordImpl implements _PersonalRecord {
  const _$PersonalRecordImpl({
    required this.rideId,
    required this.durationSeconds,
    required this.watts,
    required this.achievedAt,
  });

  @override
  final String rideId;
  @override
  final int durationSeconds;
  @override
  final Watts watts;
  @override
  final DateTime achievedAt;

  @override
  String toString() {
    return 'PersonalRecord(rideId: $rideId, durationSeconds: $durationSeconds, watts: $watts, achievedAt: $achievedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonalRecordImpl &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.watts, watts) || other.watts == watts) &&
            (identical(other.achievedAt, achievedAt) ||
                other.achievedAt == achievedAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, rideId, durationSeconds, watts, achievedAt);

  /// Create a copy of PersonalRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonalRecordImplCopyWith<_$PersonalRecordImpl> get copyWith =>
      __$$PersonalRecordImplCopyWithImpl<_$PersonalRecordImpl>(
        this,
        _$identity,
      );
}

abstract class _PersonalRecord implements PersonalRecord {
  const factory _PersonalRecord({
    required final String rideId,
    required final int durationSeconds,
    required final Watts watts,
    required final DateTime achievedAt,
  }) = _$PersonalRecordImpl;

  @override
  String get rideId;
  @override
  int get durationSeconds;
  @override
  Watts get watts;
  @override
  DateTime get achievedAt;

  /// Create a copy of PersonalRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonalRecordImplCopyWith<_$PersonalRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
