import 'dart:async';
import 'dart:collection';

import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/lap.dart';
import '../../domain/entities/ride.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../domain/ports/storage_port.dart';
import '../../domain/value_objects/value_objects.dart';
import '../../events/app_event.dart';
import '../../events/event_bus.dart';
import 'personal_records_calculator.dart';

final _log = Logger('RecordingEngine');

enum RecordingState { idle, recording, paused }

/// Captures ride data from sensor events at 1 Hz, manages recording lifecycle
/// (start/pause/resume/stop/laps), auto-saves every 30 seconds, and computes
/// post-ride metrics on stop.
class RecordingEngine {
  RecordingEngine({
    required EventBus eventBus,
    required StoragePort storage,
    Uuid? uuid,
    PersonalRecordsCalculator? personalRecordsCalculator,
    Duration autoSaveInterval = const Duration(seconds: 30),
  })  : _eventBus = eventBus,
        _storage = storage,
        _uuid = uuid ?? Uuid(),
        _personalRecords = personalRecordsCalculator ?? PersonalRecordsCalculator(),
        _autoSaveIntervalTicks = autoSaveInterval.inSeconds;

  final EventBus _eventBus;
  final StoragePort _storage;
  final Uuid _uuid;
  final PersonalRecordsCalculator _personalRecords;

  // ---------------------------------------------------------------------------
  // Public state
  // ---------------------------------------------------------------------------

  RecordingState _state = RecordingState.idle;
  RecordingState get state => _state;

  final _stateController = StreamController<RecordingState>.broadcast();
  Stream<RecordingState> get stateStream => _stateController.stream;

  /// Every reading as it is recorded, once a second while recording. Driven
  /// by the sample timer, so it keeps flowing while the app draws no frames
  /// (window hidden, screen off) — unlike anything recomputed by the UI.
  final _sampleController = StreamController<SensorReading>.broadcast();
  Stream<SensorReading> get sampleStream => _sampleController.stream;

  Ride? _currentRide;
  Ride? get currentRide => _currentRide;

  /// Snapshot of the ride in progress for live metrics. [currentRide] is the
  /// ride as created at start (no readings, no pause time); this one carries
  /// the samples and laps recorded so far and the pause time including a
  /// pause that is still running, so `activeDuration` freezes while paused.
  /// The lists are views, not copies — a snapshot is cheap once a second.
  Ride? get liveRide {
    final ride = _currentRide;
    if (ride == null) return null;
    var pause = _totalPauseDuration;
    if (_state == RecordingState.paused && _pauseStartTime != null) {
      pause += DateTime.now().difference(_pauseStartTime!);
    }
    return ride.copyWith(
      readings: UnmodifiableListView(_readings),
      laps: UnmodifiableListView(_laps),
      pauseDuration: pause,
    );
  }

  SensorReading? _latestReading;
  SensorReading? get latestReading => _latestReading;

  Grade? _latestGrade;

  // Fallback distance/elevation-gain for route-simulated rides — many
  // trainers don't report cumulative distance over BLE/ANT+, and none have
  // an altimeter, so RouteSimulator's own physics-driven totals are the
  // only source for either. Null whenever no route is active.
  double? _latestSimDistance;
  double? _latestSimElevationGain;

  /// Number of laps recorded so far (including the auto-closed final lap on stop).
  int get lapCount => _laps.length;

  // ---------------------------------------------------------------------------
  // Internal state
  // ---------------------------------------------------------------------------

  final _readings = <SensorReading>[];
  final _laps = <Lap>[];

  StreamSubscription<SensorEvent>? _sensorSubscription;
  StreamSubscription<SimulationEvent>? _simulationSubscription;
  Timer? _sampleTimer;

  // Pause tracking.
  DateTime? _pauseStartTime;
  Duration _totalPauseDuration = Duration.zero;

  // Auto-save counter (ticks at 1 Hz, saves every 30 ticks by default).
  int _ticksSinceLastSave = 0;
  final int _autoSaveIntervalTicks;

  // Readings already written to storage — each save appends only the ones
  // after them. Writing the whole list on every auto-save stored the start of
  // a ride once per save, 35 times over by the end of a 17-minute ride.
  int _savedReadingCount = 0;
  Future<void>? _pendingAutoSave;

  // Lap tracking.
  int _lastLapStartIndex = 0;
  DateTime? _lastLapStartTime;

  // Distance ridden since start. Trainers report a running counter that
  // started when they powered on or connected, not when the ride did, so
  // readings carry the sum of its increments instead of the raw value.
  double _distanceRidden = 0;
  double? _lastTrainerDistance;

  // ---------------------------------------------------------------------------
  // start
  // ---------------------------------------------------------------------------

  /// Creates a new [Ride] and begins collecting [SensorReading]s at 1 Hz.
  Future<Ride> start() async {
    if (_state != RecordingState.idle) {
      throw StateError('Cannot start: engine is $_state');
    }

    final rideId = _uuid.v4();
    final now = DateTime.now();

    _currentRide = Ride(
      id: rideId,
      startTime: now,
      status: RideStatus.active,
    );

    _readings.clear();
    _laps.clear();
    _totalPauseDuration = Duration.zero;
    _ticksSinceLastSave = 0;
    _savedReadingCount = 0;
    _lastLapStartIndex = 0;
    _lastLapStartTime = now;
    _latestReading = null;
    _distanceRidden = 0;
    _lastTrainerDistance = null;

    // Listen to sensor events — buffer the latest reading.
    _latestGrade = null;
    _latestSimDistance = null;
    _latestSimElevationGain = null;
    _sensorSubscription = _eventBus.on<SensorEvent>().listen((event) {
      _latestReading = event.reading;
    });

    // Listen to route simulation events — buffer the latest grade/distance/
    // elevation-gain so SIM rides carry them in their recorded readings even
    // when the trainer itself doesn't report distance (and never reports
    // elevation — it has no altimeter).
    _simulationSubscription = _eventBus.on<SimulationEvent>().listen((event) {
      if (event is SimulationPositionChanged) {
        _latestGrade = event.point.grade;
        _latestSimDistance = event.distanceCovered;
        _latestSimElevationGain = event.elevationGain;
      }
    });

    // 1 Hz sample timer.
    _sampleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _onTick();
    });

    _setState(RecordingState.recording);

    _eventBus.fire(RideEvent.started(rideId));
    _log.info('Recording started: $rideId');

    // Persist initial ride.
    await _storage.saveRide(_currentRide!);

    return _currentRide!;
  }

  // ---------------------------------------------------------------------------
  // pause / resume
  // ---------------------------------------------------------------------------

  void pause() {
    if (_state != RecordingState.recording) {
      throw StateError('Cannot pause: engine is $_state');
    }

    _pauseStartTime = DateTime.now();
    // Distance pedalled while paused isn't part of the ride: the first
    // reading after resuming becomes the new baseline.
    _lastTrainerDistance = null;
    _setState(RecordingState.paused);
    _eventBus.fire(RideEvent.paused(_currentRide!.id));
    _log.info('Recording paused');
  }

  void resume() {
    if (_state != RecordingState.paused) {
      throw StateError('Cannot resume: engine is $_state');
    }

    if (_pauseStartTime != null) {
      _totalPauseDuration += DateTime.now().difference(_pauseStartTime!);
      _pauseStartTime = null;
    }

    _setState(RecordingState.recording);
    _eventBus.fire(RideEvent.resumed(_currentRide!.id));
    _log.info('Recording resumed');
  }

  // ---------------------------------------------------------------------------
  // markLap
  // ---------------------------------------------------------------------------

  Lap markLap() {
    if (_state == RecordingState.idle) {
      throw StateError('Cannot mark lap: engine is idle');
    }

    final now = DateTime.now();
    final endIndex = _readings.isEmpty ? 0 : _readings.length - 1;
    final lapStart = _lastLapStartTime ?? _currentRide!.startTime;

    final lap = Lap(
      startIndex: _lastLapStartIndex,
      endIndex: endIndex,
      startTime: lapStart,
      duration: now.difference(lapStart),
    );

    _laps.add(lap);
    _lastLapStartIndex = endIndex + 1;
    _lastLapStartTime = now;

    _eventBus.fire(RideEvent.lapMarked(_currentRide!.id, lap));
    _log.info('Lap ${_laps.length} marked (readings $_lastLapStartIndex..$endIndex)');

    return lap;
  }

  // ---------------------------------------------------------------------------
  // Lap stats
  // ---------------------------------------------------------------------------

  /// Average power over [lap]'s reading range, for the last-lap summary.
  Watts avgPowerForLap(Lap lap) {
    if (_readings.isEmpty) return Watts.zero;
    final start = lap.startIndex.clamp(0, _readings.length - 1);
    final end = lap.endIndex.clamp(0, _readings.length - 1);
    if (start > end) return Watts.zero;

    final powers = [
      for (var i = start; i <= end; i++) _readings[i].power?.value ?? 0,
    ];
    if (powers.isEmpty) return Watts.zero;
    return Watts(powers.reduce((a, b) => a + b) / powers.length);
  }

  // ---------------------------------------------------------------------------
  // stop
  // ---------------------------------------------------------------------------

  /// Finalises the ride, computes metrics, persists everything, and returns
  /// the completed [Ride].
  ///
  /// Pass [ftp] to compute and persist TSS, IF, and the FTP-at-time snapshot.
  /// If null, those metrics are skipped. Mean-max power personal-record
  /// candidates are always computed and cached, independent of [ftp].
  Future<Ride> stop({Watts? ftp}) async {
    if (_state == RecordingState.idle) {
      throw StateError('Cannot stop: engine is idle');
    }

    // If paused, close the current pause interval.
    if (_state == RecordingState.paused && _pauseStartTime != null) {
      _totalPauseDuration += DateTime.now().difference(_pauseStartTime!);
      _pauseStartTime = null;
    }

    _sampleTimer?.cancel();
    _sampleTimer = null;
    await _sensorSubscription?.cancel();
    _sensorSubscription = null;
    await _simulationSubscription?.cancel();
    _simulationSubscription = null;
    // Let an auto-save still writing finish first, so the final save starts
    // after the readings it stored.
    await _pendingAutoSave;
    _pendingAutoSave = null;

    final now = DateTime.now();

    // Auto-close the last lap.
    if (_readings.isNotEmpty && _lastLapStartIndex < _readings.length) {
      _laps.add(Lap(
        startIndex: _lastLapStartIndex,
        endIndex: _readings.length - 1,
        startTime: _lastLapStartTime ?? _currentRide!.startTime,
        duration: now.difference(_lastLapStartTime ?? _currentRide!.startTime),
      ));
    }

    final finalRide = _currentRide!.copyWith(
      endTime: now,
      status: RideStatus.finished,
      readings: List.unmodifiable(_readings),
      laps: List.unmodifiable(_laps),
      pauseDuration: _totalPauseDuration,
      cachedElevationGain: _latestSimElevationGain != null
          ? Distance(_latestSimElevationGain!)
          : null,
    );

    // Persist.
    if (ftp != null) {
      await _storage.saveRide(finalRide, ftp: ftp);
    } else {
      await _storage.saveRide(finalRide);
    }
    await _saveNewReadings(finalRide.id);
    if (_laps.isNotEmpty) {
      await _storage.saveLaps(finalRide.id, _laps);
    }

    final records = _personalRecords.computeRecords(
      rideId: finalRide.id,
      achievedAt: finalRide.startTime,
      readings: _readings,
    );
    if (records.isNotEmpty) {
      await _storage.savePersonalRecords(records);
    }

    _eventBus.fire(RideEvent.stopped(finalRide));
    _log.info(
      'Recording stopped: ${finalRide.id} — '
      '${_readings.length} readings, ${_laps.length} laps, '
      'active ${finalRide.activeDuration.inSeconds}s',
    );

    _setState(RecordingState.idle);
    _currentRide = null;
    _latestReading = null;

    return finalRide;
  }

  // ---------------------------------------------------------------------------
  // discard
  // ---------------------------------------------------------------------------

  /// Abandons the ride in progress: cancels sampling, deletes the partially
  /// auto-saved ride and returns to idle. Unlike [stop] it fires no
  /// [RideStopped], so auto-upload and calendar linking don't run.
  Future<void> discard() async {
    if (_state == RecordingState.idle) {
      throw StateError('Cannot discard: engine is idle');
    }

    _sampleTimer?.cancel();
    _sampleTimer = null;
    await _sensorSubscription?.cancel();
    _sensorSubscription = null;
    await _simulationSubscription?.cancel();
    _simulationSubscription = null;
    // An auto-save finishing after the delete would leave orphan readings.
    await _pendingAutoSave;
    _pendingAutoSave = null;

    final rideId = _currentRide!.id;
    _pauseStartTime = null;
    _currentRide = null;
    _latestReading = null;
    _readings.clear();
    _laps.clear();
    _setState(RecordingState.idle);

    await _storage.deleteRide(rideId);
    _log.info('Recording discarded: $rideId');
  }

  // ---------------------------------------------------------------------------
  // dispose
  // ---------------------------------------------------------------------------

  Future<void> dispose() async {
    _sampleTimer?.cancel();
    await _sensorSubscription?.cancel();
    await _simulationSubscription?.cancel();
    await _stateController.close();
    await _sampleController.close();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _onTick() {
    if (_state != RecordingState.recording) return;

    // Sample the latest buffered reading.
    final reading = _latestReading;
    if (reading != null) {
      // Stamp with our own wall-clock so readings are exactly 1 Hz.
      final stamped = SensorReading(
        timestamp: DateTime.now(),
        power: reading.power,
        cadence: reading.cadence,
        heartRate: reading.heartRate,
        speed: reading.speed,
        distance: reading.distance != null
            ? Distance(_addTrainerDistance(reading.distance!.meters))
            : (_latestSimDistance != null
                ? Distance(_latestSimDistance!)
                : null),
        grade: _latestGrade,
      );
      _readings.add(stamped);
      _sampleController.add(stamped);
    }

    // Auto-save every 30 seconds.
    _ticksSinceLastSave++;
    if (_ticksSinceLastSave >= _autoSaveIntervalTicks) {
      _ticksSinceLastSave = 0;
      _pendingAutoSave = _autoSave();
    }
  }

  /// Adds the trainer counter's increase since the last sample and returns
  /// the distance ridden so far. A counter that went backwards was reset (the
  /// trainer reconnected), so everything it reports counts as new distance.
  double _addTrainerDistance(double counter) {
    final last = _lastTrainerDistance;
    if (last != null) {
      _distanceRidden += counter >= last ? counter - last : counter;
    }
    _lastTrainerDistance = counter;
    return _distanceRidden;
  }

  Future<void> _autoSave() async {
    if (_currentRide == null) return;
    try {
      final snapshot = _currentRide!.copyWith(
        readings: List.unmodifiable(_readings),
        laps: List.unmodifiable(_laps),
        pauseDuration: _totalPauseDuration,
      );
      await _storage.saveRide(snapshot);
      await _saveNewReadings(snapshot.id);
      _log.fine('Auto-saved $_savedReadingCount readings');
    } catch (e) {
      _log.warning('Auto-save failed: $e');
    }
  }

  /// Appends the readings recorded since the last successful save. A failed
  /// save leaves the count alone, so the next one retries those readings.
  Future<void> _saveNewReadings(String rideId) async {
    final end = _readings.length;
    if (end == _savedReadingCount) return;
    await _storage.saveSensorReadings(
      rideId,
      _readings.sublist(_savedReadingCount, end),
    );
    _savedReadingCount = end;
  }

  void _setState(RecordingState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }
}
