import '../entities/sensor_reading.dart';

abstract class SensorPort {
  Stream<SensorReading> get dataStream;
  Future<void> disconnect();
}
