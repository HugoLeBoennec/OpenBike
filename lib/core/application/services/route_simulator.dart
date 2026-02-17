import 'dart:async';

import '../../domain/entities/route.dart';
import '../../domain/entities/route_point.dart';
import '../../domain/ports/trainer_port.dart';
import '../../domain/value_objects/value_objects.dart';
import '../../events/app_event.dart';
import '../../events/event_bus.dart';
import 'physics_engine.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum SimulationState { idle, running, paused, completed }

// ---------------------------------------------------------------------------
// Progress snapshot emitted at 1 Hz
// ---------------------------------------------------------------------------

class SimulationProgress {
  const SimulationProgress({
    required this.currentPoint,
    required this.pointIndex,
    required this.speed,
    required this.grade,
    required this.distanceCovered,
    required this.distanceRemaining,
    required this.elevationGain,
    required this.elapsed,
  });

  final RoutePoint currentPoint;
  final int pointIndex;
  final Speed speed;
  final Grade grade;
  final Distance distanceCovered;
  final Distance distanceRemaining;
  final double elevationGain;
  final Duration elapsed;
}

// ---------------------------------------------------------------------------
// RouteSimulator
// ---------------------------------------------------------------------------

class RouteSimulator {
  RouteSimulator({
    required TrainerPort trainerPort,
    required EventBus eventBus,
    required CyclingPhysicsEngine physics,
  })  : _trainerPort = trainerPort,
        _eventBus = eventBus,
        _physics = physics;

  final TrainerPort _trainerPort;
  final EventBus _eventBus;
  final CyclingPhysicsEngine _physics;

  // -- public getters --------------------------------------------------------

  SimulationState get state => _state;
  Route? get currentRoute => _route;
  RoutePoint? get currentPoint =>
      _route != null && _pointIndex < _route!.points.length
          ? _route!.points[_pointIndex]
          : null;
  Speed get currentSpeed => _speed;
  double get distanceCovered => _distanceCovered;

  Stream<SimulationState> get stateStream => _stateController.stream;
  Stream<SimulationProgress> get progressStream => _progressController.stream;

  // -- internal state --------------------------------------------------------

  SimulationState _state = SimulationState.idle;
  Route? _route;
  int _pointIndex = 0;
  double _distanceCovered = 0; // meters
  Speed _speed = Speed.zero;
  double _elevationGain = 0;
  int _elapsedSeconds = 0;

  double _mass = 80;
  double _crr = 0.004;
  double _cda = 0.32;

  Timer? _ticker;
  StreamSubscription<SensorEvent>? _sensorSub;
  Watts _latestPower = Watts.zero;

  DateTime? _pauseStart;
  // ignore: unused_field
  Duration _totalPauseDuration = Duration.zero;

  final _stateController = StreamController<SimulationState>.broadcast();
  final _progressController = StreamController<SimulationProgress>.broadcast();

  // -- public API ------------------------------------------------------------

  void start(
    Route route, {
    double mass = 80,
    double crr = 0.004,
    double cda = 0.32,
  }) {
    if (_state != SimulationState.idle) {
      throw StateError('Cannot start: state is $_state');
    }

    _route = route;
    _mass = mass;
    _crr = crr;
    _cda = cda;
    _pointIndex = 0;
    _distanceCovered = 0;
    _speed = Speed.zero;
    _elevationGain = 0;
    _elapsedSeconds = 0;
    _latestPower = Watts.zero;
    _totalPauseDuration = Duration.zero;

    _setState(SimulationState.running);
    _eventBus.fire(SimulationEvent.started(route));

    // Listen for sensor power updates.
    _sensorSub = _eventBus.on<SensorEvent>().listen((e) {
      if (e.reading.power != null) {
        _latestPower = e.reading.power!;
      }
    });

    // Send initial simulation params to trainer.
    _sendSimParams(_route!.points.first.grade);

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    if (_state != SimulationState.running) {
      throw StateError('Cannot pause: state is $_state');
    }
    _ticker?.cancel();
    _ticker = null;
    _pauseStart = DateTime.now();
    _setState(SimulationState.paused);
    _eventBus.fire(const SimulationEvent.paused());
  }

  void resume() {
    if (_state != SimulationState.paused) {
      throw StateError('Cannot resume: state is $_state');
    }
    if (_pauseStart != null) {
      _totalPauseDuration += DateTime.now().difference(_pauseStart!);
      _pauseStart = null;
    }
    _setState(SimulationState.running);
    _eventBus.fire(const SimulationEvent.resumed());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void stop() {
    if (_state == SimulationState.idle) {
      throw StateError('Cannot stop: state is idle');
    }
    _cleanup();
    _setState(SimulationState.idle);
  }

  void dispose() {
    _cleanup();
    _stateController.close();
    _progressController.close();
  }

  // -- private ---------------------------------------------------------------

  void _tick() {
    if (_state != SimulationState.running || _route == null) return;

    final route = _route!;
    final totalDist = route.totalDistance.meters;
    if (totalDist <= 0) {
      _complete();
      return;
    }

    // Interpolate grade at current distance.
    final grade = _gradeAtDistance(_distanceCovered);

    // Calculate virtual speed from rider power and grade.
    _speed = _physics.calculateSpeed(
      power: _latestPower,
      grade: grade,
      mass: _mass,
      crr: _crr,
      cda: _cda,
    );

    // Advance position.
    _distanceCovered += _speed.mps;
    _elapsedSeconds++;

    // Find current point index via binary search.
    _pointIndex = _findPointIndex(_distanceCovered);

    // Track elevation gain.
    if (_pointIndex > 0 && _pointIndex < route.points.length) {
      final dElev = route.points[_pointIndex].smoothedElevation -
          route.points[_pointIndex - 1].smoothedElevation;
      if (dElev > 0) _elevationGain += dElev;
    }

    // Send simulation params to trainer.
    _sendSimParams(grade);

    // Emit progress.
    final point = route.points[_pointIndex.clamp(0, route.points.length - 1)];
    _progressController.add(SimulationProgress(
      currentPoint: point,
      pointIndex: _pointIndex,
      speed: _speed,
      grade: grade,
      distanceCovered: Distance(_distanceCovered),
      distanceRemaining: Distance((totalDist - _distanceCovered).clamp(0, totalDist)),
      elevationGain: _elevationGain,
      elapsed: Duration(seconds: _elapsedSeconds),
    ));

    _eventBus.fire(SimulationEvent.positionChanged(point, _speed));

    // Check completion.
    if (_distanceCovered >= totalDist) {
      _complete();
    }
  }

  /// Interpolates grade between route points at [distance] meters.
  Grade _gradeAtDistance(double distance) {
    final points = _route!.points;
    if (points.isEmpty) return Grade.flat;
    if (points.length == 1) return points.first.grade;

    // Binary search for surrounding points.
    var lo = 0;
    var hi = points.length - 1;
    while (lo < hi - 1) {
      final mid = (lo + hi) ~/ 2;
      if (points[mid].distanceFromStart <= distance) {
        lo = mid;
      } else {
        hi = mid;
      }
    }

    if (lo == hi) return points[lo].grade;

    final pA = points[lo];
    final pB = points[hi];
    final segLen = pB.distanceFromStart - pA.distanceFromStart;
    if (segLen < 0.1) return pA.grade;

    // Linear interpolation of grade between the two points.
    final t = ((distance - pA.distanceFromStart) / segLen).clamp(0.0, 1.0);
    final gradePct =
        pA.grade.percent + (pB.grade.percent - pA.grade.percent) * t;
    return Grade(gradePct.clamp(-30.0, 30.0));
  }

  /// Binary search for the route point index closest to [distance].
  int _findPointIndex(double distance) {
    final points = _route!.points;
    if (points.isEmpty) return 0;

    var lo = 0;
    var hi = points.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      if (points[mid].distanceFromStart <= distance) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo;
  }

  void _sendSimParams(Grade grade) {
    _trainerPort.setSimulationParams(0, grade, _crr, _cda);
  }

  void _complete() {
    _cleanup();
    _setState(SimulationState.completed);
    _eventBus.fire(const SimulationEvent.completed());
  }

  void _cleanup() {
    _ticker?.cancel();
    _ticker = null;
    _sensorSub?.cancel();
    _sensorSub = null;
  }

  void _setState(SimulationState newState) {
    _state = newState;
    _stateController.add(newState);
  }
}
