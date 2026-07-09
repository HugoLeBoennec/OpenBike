import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../core/domain/entities/trainer_device.dart';
import '../../infrastructure/ble/ble_transport.dart';
import '../../infrastructure/simulator/simulator.dart';
import '../state/providers.dart';

final _log = Logger('DeviceScanScreen');

/// BLE device scanning and connection screen.
///
/// When `DEV_MODE=true`, shows a "Simulator Mode" toggle that replaces BLE
/// scanning with fake devices from [SimulatorDevicePlugin].
class DeviceScanScreen extends ConsumerStatefulWidget {
  const DeviceScanScreen({super.key});

  @override
  ConsumerState<DeviceScanScreen> createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends ConsumerState<DeviceScanScreen> {
  bool _simulatorMode = false;
  List<TrainerDevice> _simulatorDevices = [];
  bool _scanningSimulator = false;
  String? _bleError;

  @override
  void initState() {
    super.initState();
    // Auto-enable simulator mode in DEV_MODE.
    final devMode = const bool.fromEnvironment('DEV_MODE');
    if (devMode) {
      _simulatorMode = true;
      _loadSimulatorDevices();
    }
  }

  Future<void> _loadSimulatorDevices() async {
    setState(() => _scanningSimulator = true);
    final simPlugin = ref.read(simulatorPluginProvider);
    if (simPlugin != null) {
      final devices = await simPlugin.scan(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          _simulatorDevices = devices;
          _scanningSimulator = false;
        });
      }
    } else {
      if (mounted) setState(() => _scanningSimulator = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectedDevice = ref.watch(trainerDeviceProvider);
    final scanState = ref.watch(bleScanStateProvider);
    final scanResults = ref.watch(bleScanResultsProvider);
    final isScanning =
        scanState.valueOrNull == BleTransportState.scanning;
    final devMode = ref.watch(devModeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Devices'),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ----- DEV_MODE: Simulator toggle -----
          if (devMode)
            _SimulatorToggle(
              value: _simulatorMode,
              onChanged: (v) {
                setState(() => _simulatorMode = v);
                if (v) _loadSimulatorDevices();
              },
            ),

          // ----- BLE error banner -----
          if (_bleError != null && !_simulatorMode)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bluetooth_disabled,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _bleError!,
                      style: const TextStyle(
                          color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // ----- Connected device section -----
          if (connectedDevice != null) ...[
            _SectionHeader('CONNECTED'),
            _ConnectedDeviceTile(
              device: connectedDevice,
              onDisconnect: () async {
                final port = ref.read(activeTrainerPortProvider);
                if (port != null) {
                  await port.disconnect();
                  ref.read(activeTrainerPortProvider.notifier).state = null;
                } else {
                  await ref.read(bleTransportProvider).disconnectDevice();
                }
                ref.read(trainerDeviceProvider.notifier).state = null;
              },
            ),
            const SizedBox(height: 16),
          ],

          // ----- Simulator devices -----
          if (_simulatorMode) ...[
            _SectionHeader(
                _scanningSimulator ? 'SCANNING…' : 'SIMULATOR DEVICES'),
            if (_simulatorDevices.isEmpty && !_scanningSimulator)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No simulator plugin registered.\nEnsure DEV_MODE=true.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),
              ),
            for (final device in _simulatorDevices)
              _SimulatorDeviceTile(
                device: device,
                onTap: () => _connectSimulator(device),
              ),
            if (_scanningSimulator)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white30,
                    ),
                  ),
                ),
              ),
          ],

          // ----- Discovered BLE devices section -----
          if (!_simulatorMode) ...[
            _SectionHeader(isScanning ? 'SCANNING…' : 'NEARBY DEVICES'),
            scanResults.when(
              data: (devices) {
                if (devices.isEmpty && !isScanning) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Tap the scan button to search\nfor nearby cycling devices.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final scanned in devices)
                      _ScannedDeviceTile(
                        scanned: scanned,
                        isConnecting: scanState.valueOrNull ==
                            BleTransportState.connecting,
                        onTap: () => _connect(scanned),
                      ),
                    if (isScanning)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white30,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: (isScanning || _scanningSimulator)
            ? Colors.white24
            : Colors.blue,
        onPressed: (isScanning || _scanningSimulator) ? null : _startScan,
        child: Icon(
          (isScanning || _scanningSimulator)
              ? Icons.bluetooth_searching
              : Icons.search,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _startScan() async {
    if (_simulatorMode) {
      _loadSimulatorDevices();
      return;
    }
    final transport = ref.read(bleTransportProvider);
    await transport.startScan(timeout: const Duration(seconds: 10));
    if (mounted && transport.lastScanError != null) {
      setState(() => _bleError = transport.lastScanError);
    }
  }

  Future<void> _connect(BleScannedDevice scanned) async {
    _log.info('[BLE-DEBUG] Connecting to ${scanned.device.name} '
        '(${scanned.device.id}, protocol=${scanned.device.protocol})');

    // Look up the correct plugin for this device.
    final registry = ref.read(pluginRegistryProvider);
    final plugin = registry.getPluginForDevice(scanned.device);

    if (plugin == null) {
      _log.warning('[BLE-DEBUG] No plugin found for ${scanned.device.protocol}');
      if (mounted) {
        setState(() => _bleError =
            'No plugin available for ${scanned.device.name}');
      }
      return;
    }

    _log.info('[BLE-DEBUG] Using plugin ${plugin.manifest.name}');

    try {
      // plugin.connect() handles: raw BLE connect → service discovery →
      // FTMS subscribe → control handshake → fires TrainerEvents on EventBus.
      final trainerPort = await plugin.connect(scanned.device);
      if (!mounted) return;

      _log.info('[BLE-DEBUG] Plugin connect complete — TrainerPort ready');

      ref.read(trainerDeviceProvider.notifier).state = scanned.device;
      ref.read(activeTrainerPortProvider.notifier).state = trainerPort;

      final saved = ref.read(savedDeviceIdsProvider);
      if (!saved.contains(scanned.device.id)) {
        final updated = [...saved, scanned.device.id];
        ref.read(savedDeviceIdsProvider.notifier).state = updated;
        ref.read(appPreferencesProvider).setSavedDeviceIds(updated);
      }
    } catch (e, st) {
      _log.severe('[BLE-DEBUG] Plugin connect failed: $e', e, st);
      if (mounted) {
        setState(() => _bleError = 'Connection failed: $e');
      }
    }
  }

  Future<void> _connectSimulator(TrainerDevice device) async {
    final simPlugin = ref.read(simulatorPluginProvider);
    if (simPlugin == null) return;

    await simPlugin.connect(device);
    if (!mounted) return;

    ref.read(trainerDeviceProvider.notifier).state = device;
  }
}

// ---------------------------------------------------------------------------
// Simulator toggle
// ---------------------------------------------------------------------------

class _SimulatorToggle extends StatelessWidget {
  const _SimulatorToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: value
            ? Colors.deepPurple.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: value
            ? Border.all(color: Colors.deepPurple.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Icon(Icons.computer,
              color: value ? Colors.deepPurple : Colors.white38, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Simulator Mode',
              style: TextStyle(
                color: value ? Colors.deepPurple.shade200 : Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Simulator device tile
// ---------------------------------------------------------------------------

class _SimulatorDeviceTile extends StatelessWidget {
  const _SimulatorDeviceTile({
    required this.device,
    required this.onTap,
  });

  final TrainerDevice device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.computer, color: Colors.deepPurple),
        title: Text(
          device.name,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Row(
          children: [
            _ProtocolBadge(device.protocol.name),
            const SizedBox(width: 8),
            if (device.isControllable)
              const Text('Controllable',
                  style: TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
        onTap: onTap,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
// Connected device tile
// ---------------------------------------------------------------------------

class _ConnectedDeviceTile extends StatelessWidget {
  const _ConnectedDeviceTile({
    required this.device,
    required this.onDisconnect,
  });

  final TrainerDevice device;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: const Icon(Icons.bluetooth_connected, color: Colors.green),
        title: Text(
          device.name,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _protocolLabel(device.protocol.name),
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.link_off, color: Colors.white54),
          onPressed: onDisconnect,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scanned device tile
// ---------------------------------------------------------------------------

class _ScannedDeviceTile extends StatelessWidget {
  const _ScannedDeviceTile({
    required this.scanned,
    required this.isConnecting,
    required this.onTap,
  });

  final BleScannedDevice scanned;
  final bool isConnecting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = scanned.device.name.isNotEmpty
        ? scanned.device.name
        : 'Unknown Device';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          _deviceIcon(scanned.device.protocol.name),
          color: Colors.white70,
        ),
        title: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Row(
          children: [
            _ProtocolBadge(scanned.device.protocol.name),
            const SizedBox(width: 8),
            _RssiIndicator(rssi: scanned.rssi),
          ],
        ),
        trailing: isConnecting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right, color: Colors.white30),
        onTap: isConnecting ? null : onTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Protocol badge
// ---------------------------------------------------------------------------

class _ProtocolBadge extends StatelessWidget {
  const _ProtocolBadge(this.protocol);
  final String protocol;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _protocolLabel(protocol),
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RSSI signal bars
// ---------------------------------------------------------------------------

class _RssiIndicator extends StatelessWidget {
  const _RssiIndicator({required this.rssi});
  final int rssi;

  @override
  Widget build(BuildContext context) {
    // Map RSSI (-100 to -30) to 0–4 bars
    final bars = rssi > -50
        ? 4
        : rssi > -65
            ? 3
            : rssi > -80
                ? 2
                : rssi > -90
                    ? 1
                    : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        final active = i < bars;
        return Container(
          width: 3,
          height: 6.0 + i * 3,
          margin: const EdgeInsets.only(right: 1),
          decoration: BoxDecoration(
            color: active ? Colors.green : Colors.white12,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _protocolLabel(String protocol) {
  switch (protocol) {
    case 'bleFtms':
      return 'FTMS';
    case 'blePower':
      return 'CPS';
    case 'bleCsc':
      return 'CSC';
    case 'bleHr':
      return 'HR';
    case 'antFec':
      return 'ANT+';
    case 'simulator':
      return 'SIM';
    default:
      return protocol.toUpperCase();
  }
}

IconData _deviceIcon(String protocol) {
  switch (protocol) {
    case 'bleFtms':
      return Icons.pedal_bike;
    case 'blePower':
      return Icons.bolt;
    case 'bleCsc':
      return Icons.rotate_right;
    case 'bleHr':
      return Icons.favorite;
    case 'simulator':
      return Icons.computer;
    default:
      return Icons.bluetooth;
  }
}
