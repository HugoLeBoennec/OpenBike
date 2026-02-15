import 'package:freezed_annotation/freezed_annotation.dart';

part 'heart_rate.freezed.dart';

@freezed
class HeartRate with _$HeartRate {
  const HeartRate._();

  const factory HeartRate(int bpm) = _HeartRate;

  static const zero = HeartRate(0);
}
