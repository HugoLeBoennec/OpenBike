import '../entities/sensor_reading.dart';
import '../value_objects/value_objects.dart';

abstract class TrainerPort {
  Stream<SensorReading> get dataStream;

  Future<void> setTargetPower(Watts watts);
  Future<void> setSimulationParams(
    double windSpeed,
    Grade grade,
    double crr,
    double cda,
  );
  Future<void> setResistance(double percent);
  Future<void> disconnect();
}
