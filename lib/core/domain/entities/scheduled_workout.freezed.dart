// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduled_workout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ScheduledWorkout {
  String get id => throw _privateConstructorUsedError;
  String get workoutId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String? get completedRideId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Create a copy of ScheduledWorkout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduledWorkoutCopyWith<ScheduledWorkout> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduledWorkoutCopyWith<$Res> {
  factory $ScheduledWorkoutCopyWith(
    ScheduledWorkout value,
    $Res Function(ScheduledWorkout) then,
  ) = _$ScheduledWorkoutCopyWithImpl<$Res, ScheduledWorkout>;
  @useResult
  $Res call({
    String id,
    String workoutId,
    DateTime date,
    String? completedRideId,
    String? notes,
  });
}

/// @nodoc
class _$ScheduledWorkoutCopyWithImpl<$Res, $Val extends ScheduledWorkout>
    implements $ScheduledWorkoutCopyWith<$Res> {
  _$ScheduledWorkoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduledWorkout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workoutId = null,
    Object? date = null,
    Object? completedRideId = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            workoutId: null == workoutId
                ? _value.workoutId
                : workoutId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            completedRideId: freezed == completedRideId
                ? _value.completedRideId
                : completedRideId // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScheduledWorkoutImplCopyWith<$Res>
    implements $ScheduledWorkoutCopyWith<$Res> {
  factory _$$ScheduledWorkoutImplCopyWith(
    _$ScheduledWorkoutImpl value,
    $Res Function(_$ScheduledWorkoutImpl) then,
  ) = __$$ScheduledWorkoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String workoutId,
    DateTime date,
    String? completedRideId,
    String? notes,
  });
}

/// @nodoc
class __$$ScheduledWorkoutImplCopyWithImpl<$Res>
    extends _$ScheduledWorkoutCopyWithImpl<$Res, _$ScheduledWorkoutImpl>
    implements _$$ScheduledWorkoutImplCopyWith<$Res> {
  __$$ScheduledWorkoutImplCopyWithImpl(
    _$ScheduledWorkoutImpl _value,
    $Res Function(_$ScheduledWorkoutImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScheduledWorkout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workoutId = null,
    Object? date = null,
    Object? completedRideId = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$ScheduledWorkoutImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        workoutId: null == workoutId
            ? _value.workoutId
            : workoutId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        completedRideId: freezed == completedRideId
            ? _value.completedRideId
            : completedRideId // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ScheduledWorkoutImpl implements _ScheduledWorkout {
  const _$ScheduledWorkoutImpl({
    required this.id,
    required this.workoutId,
    required this.date,
    this.completedRideId,
    this.notes,
  });

  @override
  final String id;
  @override
  final String workoutId;
  @override
  final DateTime date;
  @override
  final String? completedRideId;
  @override
  final String? notes;

  @override
  String toString() {
    return 'ScheduledWorkout(id: $id, workoutId: $workoutId, date: $date, completedRideId: $completedRideId, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduledWorkoutImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workoutId, workoutId) ||
                other.workoutId == workoutId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.completedRideId, completedRideId) ||
                other.completedRideId == completedRideId) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, workoutId, date, completedRideId, notes);

  /// Create a copy of ScheduledWorkout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduledWorkoutImplCopyWith<_$ScheduledWorkoutImpl> get copyWith =>
      __$$ScheduledWorkoutImplCopyWithImpl<_$ScheduledWorkoutImpl>(
        this,
        _$identity,
      );
}

abstract class _ScheduledWorkout implements ScheduledWorkout {
  const factory _ScheduledWorkout({
    required final String id,
    required final String workoutId,
    required final DateTime date,
    final String? completedRideId,
    final String? notes,
  }) = _$ScheduledWorkoutImpl;

  @override
  String get id;
  @override
  String get workoutId;
  @override
  DateTime get date;
  @override
  String? get completedRideId;
  @override
  String? get notes;

  /// Create a copy of ScheduledWorkout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduledWorkoutImplCopyWith<_$ScheduledWorkoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
