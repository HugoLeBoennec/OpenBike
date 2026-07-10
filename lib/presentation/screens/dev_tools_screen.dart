import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/application/services/personal_records_backfill.dart';
import '../../core/domain/entities/entities.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../core/events/app_event.dart';
import '../../infrastructure/simulator/simulator.dart';
import '../state/providers.dart';

/// Developer tools screen — simulator controls, manual overrides,
/// event log, and quick actions for testing.
///
/// Only accessible when the app is compiled with `--dart-define=DEV_MODE=true`.
class DevToolsScreen extends ConsumerStatefulWidget {
  const DevToolsScreen({super.key});

  @override
  ConsumerState<DevToolsScreen> createState() => _DevToolsScreenState();
}

class _DevToolsScreenState extends ConsumerState<DevToolsScreen> {
  final List<_EventEntry> _events = [];
  StreamSubscription<Object>? _eventSub;

  // Override slider values.
  double _powerSlider = 200;
  double _cadenceSlider = 85;
  double _hrSlider = 140;
  bool _powerOverrideActive = false;
  bool _cadenceOverrideActive = false;
  bool _hrOverrideActive = false;

  @override
  void initState() {
    super.initState();
    final bus = ref.read(eventBusProvider);
    _eventSub = bus.stream.listen((event) {
      if (!mounted) return;
      setState(() {
        _events.insert(0, _EventEntry(DateTime.now(), event));
        if (_events.length > 100) _events.removeLast();
      });
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final simPlugin = ref.watch(simulatorPluginProvider);
    final activeTrainer = simPlugin?.activeTrainer;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Dev Tools'),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ---- Simulator Controls ----
          _SectionHeader('SIMULATOR'),
          _SimulatorControls(
            plugin: simPlugin,
            isConnected: activeTrainer != null,
            onConnect: () => _connectSimulator(simPlugin!),
            onDisconnect: () => _disconnectSimulator(activeTrainer!),
          ),

          const SizedBox(height: 8),

          // ---- Manual Overrides ----
          _SectionHeader('MANUAL OVERRIDES'),
          if (activeTrainer == null)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Connect the simulator first.',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            )
          else ...[
            _OverrideSlider(
              label: 'Power',
              unit: 'W',
              value: _powerSlider,
              min: 0,
              max: 600,
              active: _powerOverrideActive,
              onChanged: (v) => setState(() => _powerSlider = v),
              onToggle: (active) {
                setState(() => _powerOverrideActive = active);
                activeTrainer
                    .overridePower(active ? _powerSlider : null);
              },
            ),
            _OverrideSlider(
              label: 'Cadence',
              unit: 'rpm',
              value: _cadenceSlider,
              min: 40,
              max: 130,
              active: _cadenceOverrideActive,
              onChanged: (v) => setState(() => _cadenceSlider = v),
              onToggle: (active) {
                setState(() => _cadenceOverrideActive = active);
                activeTrainer
                    .overrideCadence(active ? _cadenceSlider : null);
              },
            ),
            _OverrideSlider(
              label: 'Heart Rate',
              unit: 'bpm',
              value: _hrSlider,
              min: 50,
              max: 200,
              active: _hrOverrideActive,
              onChanged: (v) => setState(() => _hrSlider = v),
              onToggle: (active) {
                setState(() => _hrOverrideActive = active);
                activeTrainer
                    .overrideHeartRate(active ? _hrSlider.round() : null);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: OutlinedButton(
                onPressed: () {
                  activeTrainer.clearOverrides();
                  setState(() {
                    _powerOverrideActive = false;
                    _cadenceOverrideActive = false;
                    _hrOverrideActive = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white54,
                  side: const BorderSide(color: Colors.white24),
                ),
                child: const Text('Clear All Overrides'),
              ),
            ),
          ],

          const SizedBox(height: 8),

          // ---- Quick Actions ----
          _SectionHeader('QUICK ACTIONS'),
          _ActionTile(
            icon: Icons.directions_bike,
            title: 'Generate 1h Ride',
            subtitle: '3600 synthetic readings (~180W avg)',
            onTap: () => _generateFakeRide(context),
          ),
          _ActionTile(
            icon: Icons.emoji_events_outlined,
            title: 'Backfill Personal Records',
            subtitle: 'Recompute mean-max power for every ride with readings',
            onTap: () => _backfillPersonalRecords(context),
          ),

          const SizedBox(height: 8),

          // ---- Event Log ----
          _SectionHeader('EVENT LOG (${_events.length})'),
          if (_events.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No events yet.',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            )
          else
            ..._events.take(50).map((e) => _EventTile(entry: e)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _connectSimulator(SimulatorDevicePlugin plugin) async {
    final devices = await plugin.scan(const Duration(seconds: 1));
    if (devices.isEmpty) return;
    final trainer = await plugin.connect(devices.first);
    ref.read(trainerDeviceProvider.notifier).state = devices.first;
    // Start listening to data to push to live providers.
    trainer.dataStream.listen((reading) {
      ref.read(livePowerProvider.notifier).state =
          reading.power ?? Watts.zero;
      ref.read(liveCadenceProvider.notifier).state =
          reading.cadence ?? Cadence.zero;
      ref.read(liveHeartRateProvider.notifier).state =
          reading.heartRate ?? HeartRate.zero;
      ref.read(liveSpeedProvider.notifier).state =
          reading.speed ?? Speed.zero;
    });
    if (mounted) setState(() {});
  }

  Future<void> _disconnectSimulator(FakeTrainer trainer) async {
    await trainer.disconnect();
    ref.read(trainerDeviceProvider.notifier).state = null;
    if (mounted) setState(() {});
  }

  Future<void> _generateFakeRide(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final rng = Random();
    final rideId = 'fake-${DateTime.now().millisecondsSinceEpoch}';
    final start = DateTime.now().subtract(const Duration(hours: 1));
    final readings = <SensorReading>[];
    double distance = 0;

    for (int i = 0; i < 3600; i++) {
      final power = 180.0 + rng.nextDouble() * 40 - 20; // 160-200W
      final cadence = 85.0 + rng.nextDouble() * 10 - 5; // 80-90 rpm
      final hr = 145 + rng.nextInt(11) - 5; // 140-150 bpm
      final speed = 28.0 + rng.nextDouble() * 4 - 2; // 26-30 km/h
      distance += (speed / 3.6); // m/s * 1s

      readings.add(SensorReading(
        timestamp: start.add(Duration(seconds: i)),
        power: Watts(power),
        cadence: Cadence(cadence),
        heartRate: HeartRate(hr),
        speed: Speed(speed),
        distance: Distance(distance),
      ));
    }

    final ride = Ride(
      id: rideId,
      startTime: start,
      endTime: DateTime.now(),
      status: RideStatus.finished,
      readings: readings,
    );

    final storage = ref.read(storageProvider);
    await storage.saveRide(ride);
    await storage.saveSensorReadings(rideId, readings);

    // Invalidate history so it refreshes.
    ref.invalidate(rideHistoryProvider);

    messenger.showSnackBar(
      SnackBar(
        content: Text('Created ride $rideId with ${readings.length} readings'),
        backgroundColor: Colors.green.shade800,
      ),
    );
  }

  Future<void> _backfillPersonalRecords(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final storage = ref.read(storageProvider);
    final count = await backfillPersonalRecords(storage);

    ref.invalidate(personalRecordsProvider);

    messenger.showSnackBar(
      SnackBar(
        content: Text('Backfilled records from $count ride(s)'),
        backgroundColor: Colors.green.shade800,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Simulator controls
// ---------------------------------------------------------------------------

class _SimulatorControls extends StatelessWidget {
  const _SimulatorControls({
    required this.plugin,
    required this.isConnected,
    required this.onConnect,
    required this.onDisconnect,
  });

  final SimulatorDevicePlugin? plugin;
  final bool isConnected;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    if (plugin == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Simulator plugin not registered.\nMake sure DEV_MODE=true.',
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.link : Icons.link_off,
            color: isConnected ? Colors.green : Colors.white38,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            isConnected ? 'Virtual Trainer Connected' : 'Not Connected',
            style: TextStyle(
              color: isConnected ? Colors.white : Colors.white54,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: isConnected ? onDisconnect : onConnect,
            style: FilledButton.styleFrom(
              backgroundColor:
                  isConnected ? Colors.red.shade800 : Colors.blue.shade700,
              minimumSize: const Size(100, 36),
            ),
            child: Text(isConnected ? 'Disconnect' : 'Connect'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Override slider
// ---------------------------------------------------------------------------

class _OverrideSlider extends StatelessWidget {
  const _OverrideSlider({
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.active,
    required this.onChanged,
    required this.onToggle,
  });

  final String label;
  final String unit;
  final double value;
  final double min;
  final double max;
  final bool active;
  final ValueChanged<double> onChanged;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Switch(
              value: active,
              onChanged: onToggle,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              '$label: ${value.round()} $unit',
              style: TextStyle(
                color: active ? Colors.white : Colors.white38,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: active ? onChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action tile
// ---------------------------------------------------------------------------

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white54, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing: const Icon(Icons.play_arrow, color: Colors.white24),
      onTap: onTap,
    );
  }
}

// ---------------------------------------------------------------------------
// Event log
// ---------------------------------------------------------------------------

class _EventEntry {
  _EventEntry(this.time, this.event);
  final DateTime time;
  final Object event;
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.entry});
  final _EventEntry entry;

  @override
  Widget build(BuildContext context) {
    final time =
        '${entry.time.hour.toString().padLeft(2, '0')}:'
        '${entry.time.minute.toString().padLeft(2, '0')}:'
        '${entry.time.second.toString().padLeft(2, '0')}';

    final label = _classifyLabel(entry.event);
    final color = _classifyColor(entry.event);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(
              color: Colors.white24,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _classifyLabel(Object event) {
    if (event is SensorEvent) {
      final r = event.reading;
      return 'Sensor  P:${r.power?.value.round() ?? '-'}W  '
          'C:${r.cadence?.rpm.round() ?? '-'}  '
          'HR:${r.heartRate?.bpm ?? '-'}';
    }
    if (event is TrainerEvent) return 'Trainer  ${event.runtimeType}';
    if (event is RideEvent) return 'Ride  ${event.runtimeType}';
    if (event is WorkoutEvent) return 'Workout  ${event.runtimeType}';
    if (event is ExportEvent) return 'Export  ${event.runtimeType}';
    return event.runtimeType.toString();
  }

  Color _classifyColor(Object event) {
    if (event is SensorEvent) return Colors.blue;
    if (event is TrainerEvent) return Colors.orange;
    if (event is RideEvent) return Colors.green;
    if (event is WorkoutEvent) return Colors.purple;
    if (event is ExportEvent) return Colors.teal;
    return Colors.grey;
  }
}
