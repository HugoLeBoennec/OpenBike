import 'dart:async';
import 'dart:math';

import 'package:logging/logging.dart';

import '../../core/application/services/physics_engine.dart';
import '../../core/domain/entities/entities.dart';
import '../../core/domain/ports/trainer_port.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../core/events/app_event.dart';
import '../../core/events/event_bus.dart';

final _log = Logger('FakeTrainer');

/// Simulated indoor trainer implementing [TrainerPort].
///
/// Generates realistic [SensorReading] at 1 Hz with physics-based modeling:
/// - ERG mode: exponential convergence toward target power (~3s time constant)
/// - Simulation mode: power derived from grade via [CyclingPhysicsEngine]
/// - Resistance mode: power proportional to resistance percentage
///
/// Also models cadence (correlated to power), heart rate (with 30s lag),
/// speed (from physics), and cumulative distance.
class FakeTrainer implements TrainerPort {
  FakeTrainer({
    required EventBus eventBus,
    required CyclingPhysicsEngine physics,
    String deviceId = 'simulator-0',
    double baselinePower = 150,
    double ftp = 200,
    double riderMass = 80,
  })  : _eventBus = eventBus,
        _physics = physics,
        _deviceId = deviceId,
        _baselinePower = baselinePower,
        _ftp = ftp,
        _riderMass = riderMass;

  final EventBus _eventBus;
  final CyclingPhysicsEngine _physics;
  final String _deviceId;
  final double _baselinePower;
  final double _ftp;
  final double _riderMass;

  final _dataController = StreamController<SensorReading>.broadcast();
  final _rng = Random();
  Timer? _ticker;

  // ---------------------------------------------------------------------------
  // Internal state
  // ---------------------------------------------------------------------------

  ControlMode _mode = ControlMode.erg;
  double _targetPower = 150;
  Grade _grade = Grade.flat;
  double _crr = 0.004;
  double _cda = 0.32;
  double _resistance = 0.5; // 0..1 fraction
  double _currentPower = 150;
  double _currentHr = 70;
  double _accumulatedDistance = 0;
  Speed _lastSpeed = Speed.zero;

  // Manual overrides (for dev tools).
  double? _manualPowerOverride;
  double? _manualCadenceOverride;
  int? _manualHrOverride;

  late final TrainerDevice _device = TrainerDevice(
    id: _deviceId,
    name: 'OpenBike Virtual Trainer',
    manufacturer: 'OpenBike',
    protocol: DeviceProtocol.simulator,
    isControllable: true,
    supportedModes: const [
      ControlMode.erg,
      ControlMode.simulation,
      ControlMode.resistance,
    ],
  );

  @override
  Stream<SensorReading> get dataStream => _dataController.stream;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Starts the 1 Hz data generation loop and fires connected events.
  Future<void> initialize() async {
    _log.info('Initializing FakeTrainer ($_deviceId)');
    _currentPower = _baselinePower;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _eventBus.fire(TrainerEvent.connected(_device));
    _eventBus.fire(TrainerEvent.controlAcquired(_deviceId));
  }

  // ---------------------------------------------------------------------------
  // Data generation (1 Hz tick)
  // ---------------------------------------------------------------------------

  void _tick() {
    // 1. Compute raw power based on mode.
    double rawPower;
    switch (_mode) {
      case ControlMode.erg:
        // Exponential convergence: time constant ~3s.
        _currentPower +=
            (_targetPower - _currentPower) * (1 - exp(-1.0 / 3.0));
        rawPower = _currentPower + _gaussian(10);
        break;
      case ControlMode.simulation:
        // Power required for current grade at last speed.
        final requiredPower = _physics.calculateRequiredPower(
          speed: _lastSpeed.kmh > 0 ? _lastSpeed : const Speed(25),
          grade: _grade,
          mass: _riderMass,
          crr: _crr,
          cda: _cda,
        );
        _currentPower +=
            (requiredPower.value - _currentPower) * (1 - exp(-1.0 / 3.0));
        rawPower = _currentPower + _gaussian(5);
        break;
      case ControlMode.resistance:
        final target = _baselinePower * _resistance * 2;
        _currentPower += (target - _currentPower) * (1 - exp(-1.0 / 3.0));
        rawPower = _currentPower + _gaussian(10);
        break;
    }

    // Apply manual override if set.
    final power = _manualPowerOverride ?? max(0, rawPower);

    // 2. Cadence: correlated to power.
    final rawCadence = 85.0 + (power - 150) * 0.05 + _gaussian(3);
    final cadence =
        _manualCadenceOverride ?? rawCadence.clamp(50.0, 120.0);

    // 3. Heart rate: exponential lag model (~30s time constant).
    final targetHr = 60.0 + 130.0 * (power / _ftp).clamp(0.0, 1.5);
    _currentHr += (targetHr - _currentHr) * (1 - exp(-1.0 / 30.0));
    final hr = _manualHrOverride ?? _currentHr.round().clamp(50, 200);

    // 4. Speed from physics.
    final speed = _physics.calculateSpeed(
      power: Watts(power),
      grade: _grade,
      mass: _riderMass,
      crr: _crr,
      cda: _cda,
    );
    _lastSpeed = speed;

    // 5. Accumulate distance.
    _accumulatedDistance += speed.mps;

    // 6. Emit reading.
    final reading = SensorReading(
      timestamp: DateTime.now(),
      power: Watts(power),
      cadence: Cadence(cadence),
      heartRate: HeartRate(hr),
      speed: speed,
      distance: Distance(_accumulatedDistance),
    );

    _dataController.add(reading);
    _eventBus.fire(SensorEvent(reading: reading, deviceId: _deviceId));
  }

  // ---------------------------------------------------------------------------
  // Gaussian noise (Box-Muller transform)
  // ---------------------------------------------------------------------------

  double _gaussian(double sigma) {
    final u1 = _rng.nextDouble();
    final u2 = _rng.nextDouble();
    return sigma * sqrt(-2 * log(u1 + 1e-10)) * cos(2 * pi * u2);
  }

  // ---------------------------------------------------------------------------
  // TrainerPort — control commands
  // ---------------------------------------------------------------------------

  @override
  Future<void> setTargetPower(Watts watts) async {
    _mode = ControlMode.erg;
    _targetPower = watts.value;
    _eventBus.fire(TrainerEvent.modeChanged(_deviceId, ControlMode.erg));
  }

  @override
  Future<void> setSimulationParams(
    double windSpeed,
    Grade grade,
    double crr,
    double cda,
  ) async {
    _mode = ControlMode.simulation;
    _grade = grade;
    _crr = crr;
    _cda = cda;
    _eventBus
        .fire(TrainerEvent.modeChanged(_deviceId, ControlMode.simulation));
  }

  @override
  Future<void> setResistance(double percent) async {
    _mode = ControlMode.resistance;
    _resistance = (percent / 100).clamp(0.0, 1.0);
    _eventBus
        .fire(TrainerEvent.modeChanged(_deviceId, ControlMode.resistance));
  }

  @override
  Future<void> disconnect() async {
    _log.info('Disconnecting FakeTrainer');
    _ticker?.cancel();
    _ticker = null;
    await _dataController.close();
    _eventBus.fire(TrainerEvent.disconnected(_deviceId));
  }

  // ---------------------------------------------------------------------------
  // Manual overrides (dev tools)
  // ---------------------------------------------------------------------------

  /// Override the emitted power value. Set to `null` to clear.
  void overridePower(double? watts) => _manualPowerOverride = watts;

  /// Override the emitted cadence value. Set to `null` to clear.
  void overrideCadence(double? rpm) => _manualCadenceOverride = rpm;

  /// Override the emitted heart rate value. Set to `null` to clear.
  void overrideHeartRate(int? bpm) => _manualHrOverride = bpm;

  /// Clear all manual overrides.
  void clearOverrides() {
    _manualPowerOverride = null;
    _manualCadenceOverride = null;
    _manualHrOverride = null;
  }
}
