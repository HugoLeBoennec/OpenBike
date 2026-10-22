import 'dart:async';

import 'package:logging/logging.dart';

import '../../domain/entities/sensor_reading.dart';
import '../../domain/ports/trainer_port.dart';
import '../../domain/value_objects/value_objects.dart';
import '../../events/app_event.dart';
import '../../events/event_bus.dart';

final _log = Logger('ErgCadenceGuard');

/// Eases ERG when the rider's cadence collapses, and gives the target back
/// once they spin up again.
///
/// In ERG the trainer holds the watts whatever the cadence, and power is
/// force times pedal speed: as cadence falls, each stroke needs more force,
/// which slows the pedals further — until they barely turn. Below
/// [easeBelowRpm] for [easeAfter], the guard sends [easedFraction] of the
/// target instead; from [resumeAtRpm] for [resumeAfter], the full target
/// again. The gap between the two keeps it from flapping around one cadence.
/// It also makes restarting from a standstill in ERG bearable.
///
/// Sits between the trainer and whatever sets ERG targets — the workout
/// engine every second, manual ERG once per change — so it remembers the
/// target asked for (the workout's own target never changes) and re-sends
/// by itself when easing starts or ends. Resistance and SIM commands pass
/// straight through and stand it down.
class ErgCadenceGuard implements TrainerPort {
  ErgCadenceGuard({
    required TrainerPort trainer,
    required EventBus eventBus,
    DateTime Function() clock = DateTime.now,
  })  : _trainer = trainer,
        _clock = clock {
    _sensorSub = eventBus
        .on<SensorEvent>()
        .listen((event) => _onCadence(event.reading.cadence));
  }

  static const easeBelowRpm = 50.0;
  static const resumeAtRpm = 60.0;
  static const easeAfter = Duration(seconds: 3);
  static const resumeAfter = Duration(seconds: 3);
  static const easedFraction = 0.5;

  final TrainerPort _trainer;
  final DateTime Function() _clock;
  StreamSubscription<SensorEvent>? _sensorSub;

  /// The ERG target last asked for; null outside ERG.
  Watts? _target;
  bool _easing = false;

  /// When cadence first crossed the line being watched — [easeBelowRpm]
  /// while riding normally, [resumeAtRpm] while eased.
  DateTime? _crossedAt;

  final _easingController = StreamController<bool>.broadcast();

  /// Whether ERG is eased right now, so the ride screen can say why the
  /// trainer gives less than the target.
  bool get isEasing => _easing;
  Stream<bool> get easingStream => _easingController.stream;

  @override
  Stream<SensorReading> get dataStream => _trainer.dataStream;

  @override
  Future<void> setTargetPower(Watts watts) {
    _target = watts;
    return _trainer.setTargetPower(_easing ? _eased(watts) : watts);
  }

  @override
  Future<void> setSimulationParams(
    double windSpeed,
    Grade grade,
    double crr,
    double cda,
  ) {
    _standDown();
    return _trainer.setSimulationParams(windSpeed, grade, crr, cda);
  }

  @override
  Future<void> setResistance(double percent) {
    _standDown();
    return _trainer.setResistance(percent);
  }

  @override
  Future<void> disconnect() => _trainer.disconnect();

  void dispose() {
    _sensorSub?.cancel();
    _easingController.close();
  }

  void _onCadence(Cadence? cadence) {
    final target = _target;
    if (cadence == null || target == null) return;

    final crossed =
        _easing ? cadence.rpm >= resumeAtRpm : cadence.rpm < easeBelowRpm;
    if (!crossed) {
      _crossedAt = null;
      return;
    }
    final now = _clock();
    final since = _crossedAt ??= now;
    if (now.difference(since) < (_easing ? resumeAfter : easeAfter)) return;

    _crossedAt = null;
    _setEasing(!_easing);
    _trainer
        .setTargetPower(_easing ? _eased(target) : target)
        .catchError((Object e) => _log.warning('Failed to set target: $e'));
  }

  Watts _eased(Watts target) =>
      Watts((target.value * easedFraction).roundToDouble());

  void _standDown() {
    _target = null;
    _crossedAt = null;
    _setEasing(false);
  }

  void _setEasing(bool easing) {
    if (_easing == easing) return;
    _easing = easing;
    _log.info(easing ? 'Cadence low — easing ERG' : 'Cadence back — full ERG');
    if (!_easingController.isClosed) _easingController.add(easing);
  }
}
