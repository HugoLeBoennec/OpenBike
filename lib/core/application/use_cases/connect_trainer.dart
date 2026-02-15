import '../../domain/entities/sensor_reading.dart';
import '../../domain/ports/trainer_port.dart';

class ConnectTrainer {
  final TrainerPort _trainerPort;

  ConnectTrainer(this._trainerPort);

  Stream<SensorReading> get dataStream => _trainerPort.dataStream;

  Future<void> disconnect() => _trainerPort.disconnect();
}
