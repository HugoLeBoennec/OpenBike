import 'package:freezed_annotation/freezed_annotation.dart';

part 'lap.freezed.dart';

@freezed
class Lap with _$Lap {
  const factory Lap({
    required int startIndex,
    required int endIndex,
    required DateTime startTime,
    required Duration duration,
  }) = _Lap;
}
