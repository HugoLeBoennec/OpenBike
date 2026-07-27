import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../core/domain/entities/entities.dart';
import '../../infrastructure/ble/ble_transport.dart';
import '../../infrastructure/simulator/simulator.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/sensor_role_labels.dart';

final _log = Logger('DeviceScanScreen');

/// Device-management screen: per-role pairing slots (trainer, heart rate,
/// power, cadence/speed) plus a scan list to assign devices to those roles.
///
/// When `DEV_MODE=true`, shows a "Simulator Mode" toggle that replaces BLE
/// scanning with a fake trainer from [SimulatorDevicePlugin] — assigned to
/// the trainer role like any other device.
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

  /// Role currently awaiting a device assignment (set by tapping a role
  /// slot's "assign" affordance). `null` means the next tapped device is
  /// assigned to whichever role its protocol defaults to.
  SensorRole? _assigningRole;

  /// Roles with an assignment in flight (shows a spinner on that slot).
  final Set<SensorRole> _connectingRoles = {};

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
    final scanState = ref.watch(bleScanStateProvider);
    final scanResults = ref.watch(bleScanResultsProvider);
    final isScanning = scanState.valueOrNull == BleTransportState.scanning;
    final devMode = ref.watch(devModeProvider);
    final pairedDevices = ref.watch(pairedDevicesProvider);
    final roleConnection = ref.watch(roleConnectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ----- Role pairing slots -----
          _SectionHeader('PAIRED DEVICES'),
          for (final role in SensorRole.values)
            _RoleSlotTile(
              role: role,
              device: pairedDevices.forRole(role),
              isConnected: roleConnection[role] == RoleConnection.connected,
              isAssigning: _assigningRole == role,
              isConnecting: _connectingRoles.contains(role),
              onTapAssign: () => setState(() {
                _assigningRole = _assigningRole == role ? null : role;
              }),
              onReconnect: () => _reconnectRole(role),
              onForget: () => _forgetRole(role),
              onRename: (name) => _renameRole(role, name),
            ),
          if (_assigningRole != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Tap a device below to assign it to '
                '${roleLabel(_assigningRole!)}.',
                style: const TextStyle(color: Colors.amber, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),

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

          // ----- Simulator devices -----
          if (_simulatorMode) ...[
            _SectionHeader(
                _scanningSimulator ? 'SCANNING…' : 'SIMULATOR DEVICES'),
            if (_simulatorDevices.isEmpty && !_scanningSimulator)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No simulator plugin registered.\nEnsure DEV_MODE=true.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.tokens.textTertiary, fontSize: 14),
                  ),
                ),
              ),
            for (final device in _simulatorDevices)
              _SimulatorDeviceTile(
                device: device,
                onTap: () => _assignDevice(
                  _assigningRole ?? SensorRole.trainer,
                  device,
                ),
              ),
            if (_scanningSimulator)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
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
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Tap the scan button to search\nfor nearby cycling devices.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: context.tokens.textTertiary, fontSize: 14),
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final scanned in devices)
                      _ScannedDeviceTile(
                        scanned: scanned,
                        isConnecting: _connectingRoles.isNotEmpty,
                        onTap: () => _assignDevice(
                          _assigningRole ??
                              _defaultRoleFor(scanned.device.protocol),
                          scanned.device,
                        ),
                      ),
                    if (isScanning)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Scan failed: $e',
                          style: const TextStyle(color: Colors.red, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _startScan,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: (isScanning || _scanningSimulator)
            ? context.tokens.textDisabled
            : Colors.blue,
        foregroundColor: Colors.white,
        onPressed: (isScanning || _scanningSimulator) ? null : _startScan,
        child: Icon(
          (isScanning || _scanningSimulator)
              ? Icons.bluetooth_searching
              : Icons.search,
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

  /// The role a device's protocol is assigned to by default when the user
  /// taps it without first selecting a role slot.
  static SensorRole _defaultRoleFor(DeviceProtocol protocol) {
    switch (protocol) {
      case DeviceProtocol.bleFtms:
      case DeviceProtocol.antFec:
      case DeviceProtocol.simulator:
        return SensorRole.trainer;
      case DeviceProtocol.bleHr:
        return SensorRole.heartRate;
      case DeviceProtocol.blePower:
        return SensorRole.power;
      case DeviceProtocol.bleCsc:
        return SensorRole.cadenceSpeed;
    }
  }

  Future<void> _assignDevice(SensorRole role, TrainerDevice device) async {
    _log.info('[BLE-DEBUG] Assigning ${device.name} '
        '(${device.id}, protocol=${device.protocol}) to role $role');

    setState(() {
      _connectingRoles.add(role);
      _bleError = null;
    });

    try {
      final service = ref.read(devicePairingServiceProvider);
      final port = await service.assign(role, device);
      if (!mounted) return;

      // Trainer role also drives the legacy single-trainer providers that
      // the route simulator / workout engine send ERG/SIM commands through.
      if (role == SensorRole.trainer) {
        ref.read(trainerDeviceProvider.notifier).state = device;
        ref.read(activeTrainerPortProvider.notifier).state = port;
      }

      final updated = ref.read(pairedDevicesProvider).withRole(
            role,
            PairedDevice(
              deviceId: device.id,
              name: device.name,
              protocol: device.protocol,
            ),
          );
      ref.read(pairedDevicesProvider.notifier).state = updated;
      await ref.read(appPreferencesProvider).setPairedDevices(updated);

      final saved = ref.read(savedDeviceIdsProvider);
      if (!saved.contains(device.id)) {
        ref.read(savedDeviceIdsProvider.notifier).state = [...saved, device.id];
      }

      ref.read(roleConnectionStatusProvider.notifier).markConnected(role);
    } catch (e, st) {
      _log.severe('[BLE-DEBUG] Assign to $role failed: $e', e, st);
      ref.read(roleConnectionStatusProvider.notifier).markFailed(role);
      if (mounted) {
        setState(() => _bleError = 'Connection failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _connectingRoles.remove(role);
          _assigningRole = null;
        });
      }
    }
  }

  Future<void> _forgetRole(SensorRole role) async {
    final service = ref.read(devicePairingServiceProvider);
    await service.release(role);

    if (role == SensorRole.trainer) {
      ref.read(trainerDeviceProvider.notifier).state = null;
      ref.read(activeTrainerPortProvider.notifier).state = null;
    }

    ref.read(roleConnectionStatusProvider.notifier).clearRole(role);

    final updated = ref.read(pairedDevicesProvider).withoutRole(role);
    ref.read(pairedDevicesProvider.notifier).state = updated;
    await ref.read(appPreferencesProvider).setPairedDevices(updated);
  }

  /// Retries the connection for an already-paired role — the way back from
  /// a failed auto-reconnect (device asleep at app start) without having to
  /// forget the pairing and scan for it again.
  Future<void> _reconnectRole(SensorRole role) async {
    final saved = ref.read(pairedDevicesProvider).forRole(role);
    if (saved == null) return;

    await _assignDevice(
      role,
      TrainerDevice(
        id: saved.deviceId,
        name: saved.name,
        protocol: saved.protocol,
      ),
    );
  }

  Future<void> _renameRole(SensorRole role, String newName) async {
    final paired = ref.read(pairedDevicesProvider);
    final existing = paired.forRole(role);
    if (existing == null || newName.trim().isEmpty) return;

    final updated = paired.withRole(role, PairedDevice(
      deviceId: existing.deviceId,
      name: newName.trim(),
      protocol: existing.protocol,
    ));
    ref.read(pairedDevicesProvider.notifier).state = updated;
    await ref.read(appPreferencesProvider).setPairedDevices(updated);
  }
}

// ---------------------------------------------------------------------------
// Role slot tile
// ---------------------------------------------------------------------------

class _RoleSlotTile extends StatelessWidget {
  const _RoleSlotTile({
    required this.role,
    required this.device,
    required this.isConnected,
    required this.isAssigning,
    required this.isConnecting,
    required this.onTapAssign,
    required this.onReconnect,
    required this.onForget,
    required this.onRename,
  });

  final SensorRole role;
  final PairedDevice? device;

  /// Whether the paired device actually has a live connection right now —
  /// distinct from [device] being non-null, which only means a pairing was
  /// saved (and survives app restarts regardless of reachability).
  final bool isConnected;
  final bool isAssigning;
  final bool isConnecting;
  final VoidCallback onTapAssign;
  final VoidCallback onReconnect;
  final VoidCallback onForget;
  final ValueChanged<String> onRename;

  @override
  Widget build(BuildContext context) {
    final assigned = device != null;
    final live = assigned && isConnected;

    final tokens = context.tokens;
    return Container(
      key: ValueKey('role-slot-${role.name}'),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: live
            ? Colors.green.withValues(alpha: 0.12)
            : isAssigning
                ? Colors.amber.withValues(alpha: 0.12)
                : tokens.surfaceTier2,
        borderRadius: BorderRadius.circular(12),
        border: isAssigning
            ? Border.all(color: Colors.amber.withValues(alpha: 0.4))
            : null,
      ),
      child: ListTile(
        leading: Icon(
          roleIcon(role),
          color: live ? Colors.green : tokens.textDisabled,
        ),
        title: Text(
          roleLabel(role),
          style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          switch ((assigned, live, isConnecting)) {
            (false, _, _) => 'Tap to assign',
            (_, _, true) => 'Connecting to ${device!.name}…',
            (_, true, _) => device!.name,
            _ => '${device!.name} — not connected, tap to reconnect',
          },
          style: TextStyle(
            color: live
                ? tokens.textSecondary
                : assigned && !isConnecting
                    ? Colors.orange
                    : tokens.textDisabled,
            fontSize: 12,
          ),
        ),
        trailing: isConnecting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (assigned) ...[
                    if (!live)
                      IconButton(
                        key: ValueKey('reconnect-${role.name}'),
                        tooltip: 'Reconnect',
                        icon: const Icon(Icons.refresh,
                            color: Colors.orange, size: 20),
                        onPressed: onReconnect,
                      ),
                    IconButton(
                      key: ValueKey('rename-${role.name}'),
                      icon: Icon(Icons.edit, color: tokens.textDisabled, size: 20),
                      onPressed: () => _showRenameDialog(context),
                    ),
                    IconButton(
                      key: ValueKey('forget-${role.name}'),
                      icon: Icon(Icons.link_off, color: tokens.textTertiary, size: 20),
                      onPressed: onForget,
                    ),
                  ] else
                    Icon(
                      isAssigning ? Icons.radio_button_checked : Icons.add,
                      color: isAssigning ? Colors.amber : tokens.textDisabled,
                    ),
                ],
              ),
        // An assigned-but-disconnected slot retries the connection; an empty
        // slot starts the assign flow. A live one has nothing to do.
        onTap: isConnecting
            ? null
            : !assigned
                ? onTapAssign
                : live
                    ? null
                    : onReconnect,
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context) async {
    final controller = TextEditingController(text: device?.name ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Rename ${roleLabel(role)} device'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) onRename(result);
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
    final tokens = context.tokens;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: value
            ? Colors.deepPurple.withValues(alpha: 0.15)
            : tokens.surfaceTier2,
        borderRadius: BorderRadius.circular(12),
        border: value
            ? Border.all(color: Colors.deepPurple.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Icon(Icons.computer,
              color: value ? Colors.deepPurple : tokens.textDisabled, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Simulator Mode',
              style: TextStyle(
                color: value ? Colors.deepPurple.shade200 : tokens.textTertiary,
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
    final tokens = context.tokens;
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
          style: TextStyle(color: tokens.textPrimary),
        ),
        subtitle: Row(
          children: [
            _ProtocolBadge(device.protocol.name),
            const SizedBox(width: 8),
            if (device.isControllable)
              Text('Controllable',
                  style: TextStyle(color: tokens.textDisabled, fontSize: 10)),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: tokens.textDisabled),
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
        style: TextStyle(
          color: context.tokens.textTertiary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
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

    final tokens = context.tokens;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: tokens.surfaceTier2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          _deviceIcon(scanned.device.protocol.name),
          color: tokens.textSecondary,
        ),
        title: Text(
          name,
          style: TextStyle(color: tokens.textPrimary),
        ),
        subtitle: Row(
          children: [
            _ProtocolBadge(scanned.device.protocol.name),
            const SizedBox(width: 8),
            _RssiIndicator(rssi: scanned.rssi),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: tokens.textDisabled),
        onTap: onTap,
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
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tokens.surfaceTier3,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _protocolLabel(protocol),
        style: TextStyle(
          color: tokens.textTertiary,
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
            color: active ? Colors.green : context.tokens.textDisabled,
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
