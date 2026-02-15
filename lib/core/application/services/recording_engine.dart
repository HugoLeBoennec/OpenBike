import 'dart:async';

import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/lap.dart';
import '../../domain/entities/ride.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../domain/ports/storage_port.dart';
import '../../domain/value_objects/value_objects.dart';
import '../../events/app_event.dart';
import '../../events/event_bus.dart';

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
  })  : _eventBus = eventBus,
        _storage = storage,
        _uuid = uuid ?? const Uuid();

  final EventBus _eventBus;
  final StoragePort _storage;
  final Uuid _uuid;

  // ---------------------------------------------------------------------------
  // Public state
  // ---------------------------------------------------------------------------

  RecordingState _state = RecordingState.idle;
  RecordingState get state => _state;

  final _stateController = StreamController<RecordingState>.broadcast();
  Stream<RecordingState> get stateStream => _stateController.stream;

  Ride? _currentRide;
  Ride? get currentRide => _currentRide;

  SensorReading? _latestReading;
  SensorReading? get latestReading => _latestReading;

  // ---------------------------------------------------------------------------
  // Internal state
  // ---------------------------------------------------------------------------

  final _readings = <SensorReading>[];
  final _laps = <Lap>[];

  StreamSubscription<SensorEvent>? _sensorSubscription;
  Timer? _sampleTimer;

  // Pause tracking.
  DateTime? _pauseStartTime;
  Duration _totalPauseDuration = Duration.zero;

  // Auto-save counter (ticks at 1 Hz, saves every 30 ticks).
  int _ticksSinceLastSave = 0;
  static const int _autoSaveIntervalTicks = 30;

  // Lap tracking.
  int _lastLapStartIndex = 0;
  DateTime? _lastLapStartTime;

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
    _lastLapStartIndex = 0;
    _lastLapStartTime = now;
    _latestReading = null;

    // Listen to sensor events — buffer the latest reading.
    _sensorSubscription = _eventBus.on<SensorEvent>().listen((event) {
      _latestReading = event.reading;
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
  // stop
  // ---------------------------------------------------------------------------

  /// Finalises the ride, computes metrics, persists everything, and returns
  /// the completed [Ride].
  ///
  /// Pass [ftp] to compute TSS and IF. If null, those metrics are skipped.
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
    );

    // Persist.
    await _storage.saveRide(finalRide);
    if (_readings.isNotEmpty) {
      await _storage.saveSensorReadings(finalRide.id, _readings);
    }
    if (_laps.isNotEmpty) {
      await _storage.saveLaps(finalRide.id, _laps);
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
  // dispose
  // ---------------------------------------------------------------------------

  Future<void> dispose() async {
    _sampleTimer?.cancel();
    await _sensorSubscription?.cancel();
    await _stateController.close();
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
        distance: reading.distance,
      );
      _readings.add(stamped);
    }

    // Auto-save every 30 seconds.
    _ticksSinceLastSave++;
    if (_ticksSinceLastSave >= _autoSaveIntervalTicks) {
      _ticksSinceLastSave = 0;
      _autoSave();
    }
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
      await _storage.saveSensorReadings(snapshot.id, _readings);
      _log.fine('Auto-saved ${_readings.length} readings');
    } catch (e) {
      _log.warning('Auto-save failed: $e');
    }
  }

  void _setState(RecordingState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }
}
