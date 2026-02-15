import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/value_objects.dart';

part 'sensor_reading.freezed.dart';

@freezed
class SensorReading with _$SensorReading {
  const factory SensorReading({
    required DateTime timestamp,
    Watts? power,
    Cadence? cadence,
    HeartRate? heartRate,
    Speed? speed,
    Distance? distance,
  }) = _SensorReading;
}
