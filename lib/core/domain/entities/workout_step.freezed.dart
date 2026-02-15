// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$WorkoutStep {
  StepType get type => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  double get powerTargetPercent => throw _privateConstructorUsedError;
  double? get powerLowPercent => throw _privateConstructorUsedError;
  double? get powerHighPercent => throw _privateConstructorUsedError;
  int? get cadenceTarget => throw _privateConstructorUsedError;
  int? get repeat => throw _privateConstructorUsedError;

  /// Duration of the "off" / rest phase for interval steps (seconds).
  int? get offDurationSeconds => throw _privateConstructorUsedError;

  /// Cadence target during the rest phase of interval steps.
  int? get cadenceResting => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WorkoutStepCopyWith<WorkoutStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutStepCopyWith<$Res> {
  factory $WorkoutStepCopyWith(
          WorkoutStep value, $Res Function(WorkoutStep) then) =
      _$WorkoutStepCopyWithImpl<$Res, WorkoutStep>;
  @useResult
  $Res call(
      {StepType type,
      int durationSeconds,
      double powerTargetPercent,
      double? powerLowPercent,
      double? powerHighPercent,
      int? cadenceTarget,
      int? repeat,
      int? offDurationSeconds,
      int? cadenceResting});
}

/// @nodoc
class _$WorkoutStepCopyWithImpl<$Res, $Val extends WorkoutStep>
    implements $WorkoutStepCopyWith<$Res> {
  _$WorkoutStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? durationSeconds = null,
    Object? powerTargetPercent = null,
    Object? powerLowPercent = freezed,
    Object? powerHighPercent = freezed,
    Object? cadenceTarget = freezed,
    Object? repeat = freezed,
    Object? offDurationSeconds = freezed,
    Object? cadenceResting = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as StepType,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      powerTargetPercent: null == powerTargetPercent
          ? _value.powerTargetPercent
          : powerTargetPercent // ignore: cast_nullable_to_non_nullable
              as double,
      powerLowPercent: freezed == powerLowPercent
          ? _value.powerLowPercent
          : powerLowPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      powerHighPercent: freezed == powerHighPercent
          ? _value.powerHighPercent
          : powerHighPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      cadenceTarget: freezed == cadenceTarget
          ? _value.cadenceTarget
          : cadenceTarget // ignore: cast_nullable_to_non_nullable
              as int?,
      repeat: freezed == repeat
          ? _value.repeat
          : repeat // ignore: cast_nullable_to_non_nullable
              as int?,
      offDurationSeconds: freezed == offDurationSeconds
          ? _value.offDurationSeconds
          : offDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      cadenceResting: freezed == cadenceResting
          ? _value.cadenceResting
          : cadenceResting // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_WorkoutStepCopyWith<$Res>
    implements $WorkoutStepCopyWith<$Res> {
  factory _$$_WorkoutStepCopyWith(
          _$_WorkoutStep value, $Res Function(_$_WorkoutStep) then) =
      __$$_WorkoutStepCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {StepType type,
      int durationSeconds,
      double powerTargetPercent,
      double? powerLowPercent,
      double? powerHighPercent,
      int? cadenceTarget,
      int? repeat,
      int? offDurationSeconds,
      int? cadenceResting});
}

/// @nodoc
class __$$_WorkoutStepCopyWithImpl<$Res>
    extends _$WorkoutStepCopyWithImpl<$Res, _$_WorkoutStep>
    implements _$$_WorkoutStepCopyWith<$Res> {
  __$$_WorkoutStepCopyWithImpl(
      _$_WorkoutStep _value, $Res Function(_$_WorkoutStep) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? durationSeconds = null,
    Object? powerTargetPercent = null,
    Object? powerLowPercent = freezed,
    Object? powerHighPercent = freezed,
    Object? cadenceTarget = freezed,
    Object? repeat = freezed,
    Object? offDurationSeconds = freezed,
    Object? cadenceResting = freezed,
  }) {
    return _then(_$_WorkoutStep(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as StepType,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      powerTargetPercent: null == powerTargetPercent
          ? _value.powerTargetPercent
          : powerTargetPercent // ignore: cast_nullable_to_non_nullable
              as double,
      powerLowPercent: freezed == powerLowPercent
          ? _value.powerLowPercent
          : powerLowPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      powerHighPercent: freezed == powerHighPercent
          ? _value.powerHighPercent
          : powerHighPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      cadenceTarget: freezed == cadenceTarget
          ? _value.cadenceTarget
          : cadenceTarget // ignore: cast_nullable_to_non_nullable
              as int?,
      repeat: freezed == repeat
          ? _value.repeat
          : repeat // ignore: cast_nullable_to_non_nullable
              as int?,
      offDurationSeconds: freezed == offDurationSeconds
          ? _value.offDurationSeconds
          : offDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      cadenceResting: freezed == cadenceResting
          ? _value.cadenceResting
          : cadenceResting // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$_WorkoutStep extends _WorkoutStep {
  const _$_WorkoutStep(
      {required this.type,
      required this.durationSeconds,
      required this.powerTargetPercent,
      this.powerLowPercent,
      this.powerHighPercent,
      this.cadenceTarget,
      this.repeat,
      this.offDurationSeconds,
      this.cadenceResting})
      : super._();

  @override
  final StepType type;
  @override
  final int durationSeconds;
  @override
  final double powerTargetPercent;
  @override
  final double? powerLowPercent;
  @override
  final double? powerHighPercent;
  @override
  final int? cadenceTarget;
  @override
  final int? repeat;

  /// Duration of the "off" / rest phase for interval steps (seconds).
  @override
  final int? offDurationSeconds;

  /// Cadence target during the rest phase of interval steps.
  @override
  final int? cadenceResting;

  @override
  String toString() {
    return 'WorkoutStep(type: $type, durationSeconds: $durationSeconds, powerTargetPercent: $powerTargetPercent, powerLowPercent: $powerLowPercent, powerHighPercent: $powerHighPercent, cadenceTarget: $cadenceTarget, repeat: $repeat, offDurationSeconds: $offDurationSeconds, cadenceResting: $cadenceResting)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_WorkoutStep &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.powerTargetPercent, powerTargetPercent) ||
                other.powerTargetPercent == powerTargetPercent) &&
            (identical(other.powerLowPercent, powerLowPercent) ||
                other.powerLowPercent == powerLowPercent) &&
            (identical(other.powerHighPercent, powerHighPercent) ||
                other.powerHighPercent == powerHighPercent) &&
            (identical(other.cadenceTarget, cadenceTarget) ||
                other.cadenceTarget == cadenceTarget) &&
            (identical(other.repeat, repeat) || other.repeat == repeat) &&
            (identical(other.offDurationSeconds, offDurationSeconds) ||
                other.offDurationSeconds == offDurationSeconds) &&
            (identical(other.cadenceResting, cadenceResting) ||
                other.cadenceResting == cadenceResting));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      durationSeconds,
      powerTargetPercent,
      powerLowPercent,
      powerHighPercent,
      cadenceTarget,
      repeat,
      offDurationSeconds,
      cadenceResting);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_WorkoutStepCopyWith<_$_WorkoutStep> get copyWith =>
      __$$_WorkoutStepCopyWithImpl<_$_WorkoutStep>(this, _$identity);
}

abstract class _WorkoutStep extends WorkoutStep {
  const factory _WorkoutStep(
      {required final StepType type,
      required final int durationSeconds,
      required final double powerTargetPercent,
      final double? powerLowPercent,
      final double? powerHighPercent,
      final int? cadenceTarget,
      final int? repeat,
      final int? offDurationSeconds,
      final int? cadenceResting}) = _$_WorkoutStep;
  const _WorkoutStep._() : super._();

  @override
  StepType get type;
  @override
  int get durationSeconds;
  @override
  double get powerTargetPercent;
  @override
  double? get powerLowPercent;
  @override
  double? get powerHighPercent;
  @override
  int? get cadenceTarget;
  @override
  int? get repeat;
  @override

  /// Duration of the "off" / rest phase for interval steps (seconds).
  int? get offDurationSeconds;
  @override

  /// Cadence target during the rest phase of interval steps.
  int? get cadenceResting;
  @override
  @JsonKey(ignore: true)
  _$$_WorkoutStepCopyWith<_$_WorkoutStep> get copyWith =>
      throw _privateConstructorUsedError;
}
