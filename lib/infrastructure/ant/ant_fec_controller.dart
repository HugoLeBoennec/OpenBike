import 'dart:async';
import '../../core/domain/entities/trainer.dart';
import '../../core/domain/ports/trainer_port.dart';
import '../../core/domain/value_objects/value_objects.dart';

/// ANT+ FE-C (Fitness Equipment Control) profile.
///
/// Placeholder for USB-based ANT+ communication on desktop platforms.
class AntFecController implements TrainerPort {
  final _trainerController = StreamController<Trainer>.broadcast();

  @override
  Future<List<Trainer>> scan() async {
    // TODO: Implement ANT+ USB stick discovery
    return [];
  }

  @override
  Future<void> connect(String trainerId) async {
    // TODO: Implement ANT+ channel open
  }

  @override
  Future<void> disconnect() async {
    // TODO: Implement ANT+ channel close
  }

  @override
  Stream<Trainer> get trainerState => _trainerController.stream;

  @override
  Future<void> setTargetPower(Watts watts) async {
    // TODO: Send FE-C page 49 (Set Target Power)
  }

  @override
  Future<void> setSimulationParams({
    required Grade grade,
    double crr = 0.004,
    double cw = 0.51,
  }) async {
    // TODO: Send FE-C page 51 (Track Resistance)
  }

  @override
  Future<void> setResistance(double level) async {
    // TODO: Send FE-C page 48 (Basic Resistance)
  }
}
