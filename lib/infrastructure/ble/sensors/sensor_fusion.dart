import 'dart:async';

import 'package:logging/logging.dart';

import '../../../core/domain/entities/sensor_reading.dart';
import '../../../core/domain/value_objects/value_objects.dart';
import '../../../core/events/app_event.dart';
import '../../../core/events/event_bus.dart';

final _log = Logger('SensorFusion');

/// Priority level for a sensor data source.
///
/// When two sources provide the same field (e.g. power from both the trainer
/// and an external power meter), the source with higher priority wins.
enum SensorPriority { low, normal, high }

/// A named sensor data source with priority.
class SensorSource {
  const SensorSource({
    required this.id,
    required this.stream,
    this.priority = SensorPriority.normal,
  });

  final String id;
  final Stream<SensorReading> stream;
  final SensorPriority priority;
}

/// Merges readings from multiple BLE sensor streams into a single unified
/// [SensorReading] emitted at a maximum rate of 1 Hz.
///
/// When two sources provide the same field, the source with higher
/// [SensorPriority] wins.  If priorities are equal, the most recent value
/// is used.
///
/// Emits fused readings on the [EventBus] as [SensorEvent]s.
class SensorFusion {
  SensorFusion({
    required EventBus eventBus,
    String deviceId = 'fusion',
  })  : _eventBus = eventBus,
        _deviceId = deviceId;

  final EventBus _eventBus;
  final String _deviceId;

  final _subscriptions = <String, StreamSubscription>{};
  final _latestBySource = <String, SensorReading>{};
  final _priorities = <String, SensorPriority>{};

  Timer? _throttleTimer;
  bool _dirty = false;

  final _outputController = StreamController<SensorReading>.broadcast();

  /// Stream of fused sensor readings (max 1 Hz).
  Stream<SensorReading> get stream => _outputController.stream;

  // ---------------------------------------------------------------------------
  // Source management
  // ---------------------------------------------------------------------------

  /// Adds a sensor source.  If a source with the same [id] already exists,
  /// it is replaced.
  void addSource(SensorSource source) {
    removeSource(source.id);

    _priorities[source.id] = source.priority;
    _subscriptions[source.id] = source.stream.listen((reading) {
      _latestBySource[source.id] = reading;
      _dirty = true;
    });

    _log.info('Added source "${source.id}" (priority=${source.priority})');
    _ensureTimer();
  }

  /// Removes a sensor source by id.
  void removeSource(String id) {
    _subscriptions[id]?.cancel();
    _subscriptions.remove(id);
    _latestBySource.remove(id);
    _priorities.remove(id);
  }

  // ---------------------------------------------------------------------------
  // 1 Hz throttled emission
  // ---------------------------------------------------------------------------

  void _ensureTimer() {
    _throttleTimer ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => _emitFused(),
    );
  }

  void _emitFused() {
    if (!_dirty || _latestBySource.isEmpty) return;
    _dirty = false;

    final fused = _fuse();
    _outputController.add(fused);
    _eventBus.fire(SensorEvent(reading: fused, deviceId: _deviceId));
  }

  // ---------------------------------------------------------------------------
  // Fusion logic
  // ---------------------------------------------------------------------------

  SensorReading _fuse() {
    Watts? power;
    SensorPriority powerPrio = SensorPriority.low;

    Cadence? cadence;
    SensorPriority cadencePrio = SensorPriority.low;

    HeartRate? heartRate;
    SensorPriority hrPrio = SensorPriority.low;

    Speed? speed;
    SensorPriority speedPrio = SensorPriority.low;

    Distance? distance;
    SensorPriority distancePrio = SensorPriority.low;

    for (final entry in _latestBySource.entries) {
      final id = entry.key;
      final reading = entry.value;
      final prio = _priorities[id] ?? SensorPriority.normal;

      if (reading.power != null && prio.index >= powerPrio.index) {
        power = reading.power;
        powerPrio = prio;
      }
      if (reading.cadence != null && prio.index >= cadencePrio.index) {
        cadence = reading.cadence;
        cadencePrio = prio;
      }
      if (reading.heartRate != null && prio.index >= hrPrio.index) {
        heartRate = reading.heartRate;
        hrPrio = prio;
      }
      if (reading.speed != null && prio.index >= speedPrio.index) {
        speed = reading.speed;
        speedPrio = prio;
      }
      if (reading.distance != null && prio.index >= distancePrio.index) {
        distance = reading.distance;
        distancePrio = prio;
      }
    }

    return SensorReading(
      timestamp: DateTime.now(),
      power: power,
      cadence: cadence,
      heartRate: heartRate,
      speed: speed,
      distance: distance,
    );
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Releases all resources.
  Future<void> dispose() async {
    _throttleTimer?.cancel();
    _throttleTimer = null;

    for (final sub in _subscriptions.values) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _latestBySource.clear();
    _priorities.clear();

    await _outputController.close();
  }
}
