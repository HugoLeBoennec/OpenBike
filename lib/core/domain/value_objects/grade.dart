import 'package:freezed_annotation/freezed_annotation.dart';

part 'grade.freezed.dart';

/// Road grade as a percentage (e.g. 5.0 = 5%), clamped to [-45, +45].
@freezed
class Grade with _$Grade {
  const Grade._();

  const factory Grade(double percent) = _Grade;

  /// Creates a [Grade] with the value clamped between -45% and +45%.
  static Grade clamped(double percent) => Grade(percent.clamp(-45.0, 45.0));

  double get ratio => percent / 100;

  static const flat = Grade(0);
}
