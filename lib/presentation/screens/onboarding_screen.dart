import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../../core/domain/entities/paired_devices.dart';
import '../../core/domain/entities/trainer_device.dart';
import '../../core/domain/entities/user_profile.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../infrastructure/ble/ble_permission_handler.dart';
import '../../infrastructure/ble/ble_transport.dart';
import '../../infrastructure/observability/crash_reporting_service.dart';
import '../format/unit_formatter.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/crash_reporting_consent_dialog.dart';
import '../widgets/edit_value_dialog.dart';

final _log = Logger('OnboardingScreen');

/// First-run onboarding — 6-page flow: welcome, profile, units & body,
/// sensor scan, connection test, ready.
///
/// Every page after Welcome exposes a "Skip setup" action that saves
/// whatever defaults are set so far and lands on Home immediately, per P7's
/// "skippable path" requirement — the user is never forced through the
/// whole flow to reach the app.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pageCount = 6;
  static const _scanPage = 3;

  final _pageController = PageController();
  int _currentPage = 0;

  // Profile values (defaults matching the pre-onboarding fallback profile —
  // see settings_screen.dart's _defaultProfile()).
  double _ftp = 200;
  double _weight = 75;
  double _height = 178;
  int _maxHr = 190;
  UnitSystem _unitSystem = UnitSystem.metric;

  // Whether user connected a device during onboarding.
  bool _deviceConnected = false;
  String? _connectedDeviceName;

  // Scan page state.
  bool _hasScanned = false;
  String? _scanError;
  bool _bluetoothAccessDenied = false;

  /// Id of the device a connection is in flight for — its row shows a
  /// spinner and every other row is disabled until it settles.
  String? _connectingDeviceId;
  String? _connectError;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  UserProfile _buildProfile() {
    return UserProfile(
      ftp: Watts(_ftp),
      weight: _weight,
      height: _height,
      restingHr: const HeartRate(60),
      maxHr: HeartRate(_maxHr),
      name: '',
    );
  }

  Future<void> _saveAndComplete() async {
    final profile = _buildProfile();
    ref.read(userProfileProvider.notifier).state = profile;
    ref.read(storageProvider).saveProfile(profile);

    final unitValue = _unitSystem == UnitSystem.imperial ? 'imperial' : 'metric';
    ref.read(unitSystemProvider.notifier).state = unitValue;
    await ref.read(appPreferencesProvider).setUnitSystem(unitValue);

    await ref.read(appPreferencesProvider).setOnboardingCompleted(true);
    await _maybeAskCrashReportingConsent();
  }

  /// Asks once, right after onboarding, whether to opt in to crash
  /// reporting — never shown again regardless of the answer (the choice
  /// stays editable in Settings). No-op on repeat visits (e.g. "I'll set up
  /// later" then later completing onboarding again isn't possible since
  /// [AppPreferences.hasCompletedOnboarding] gates the route, but the guard
  /// keeps this safe either way).
  Future<void> _maybeAskCrashReportingConsent() async {
    final appPrefs = ref.read(appPreferencesProvider);
    if (appPrefs.hasAskedCrashReportingConsent || !mounted) return;

    final enabled = await showCrashReportingConsentDialog(context);
    ref.read(crashReportingEnabledProvider.notifier).state = enabled;
    await appPrefs.setCrashReportingEnabled(enabled);
    await CrashReportingService.apply(enabled: enabled);
    await appPrefs.setHasAskedCrashReportingConsent(true);
  }

  /// "I'll set up later" — saves whatever defaults are set so far and lands
  /// on Home immediately, from any page in the flow.
  Future<void> _skipToHome() async {
    await _saveAndComplete();
    if (mounted) context.go('/');
  }

  Future<void> _finish() async {
    await _saveAndComplete();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      backgroundColor: tokens.surfaceTier0,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentPage > 0)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 4),
                  child: TextButton(
                    key: const Key('onboardingSkipButton'),
                    onPressed: _skipToHome,
                    child: Text("I'll set up later",
                        style: TextStyle(color: tokens.textTertiary)),
                  ),
                ),
              )
            else
              const SizedBox(height: 48),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcomePage(),
                  _buildProfilePage(),
                  _buildUnitsAndBodyPage(),
                  _buildScanPage(),
                  _buildConnectionTestPage(),
                  _buildReadyPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PageDots(count: _pageCount, current: _currentPage),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Page 1: Welcome ──────────────────────────────────────────────────

  Widget _buildWelcomePage() {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pedal_bike,
            size: 120,
            color: Colors.deepOrange,
          ),
          const SizedBox(height: 32),
          Text(
            'OpenBike',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Open-source indoor cycling',
            style: TextStyle(color: tokens.textTertiary, fontSize: 16),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _nextPage,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Get Started',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            key: const Key('welcomeSkipButton'),
            onPressed: _skipToHome,
            child: Text("I'll set up later",
                style: TextStyle(color: tokens.textTertiary)),
          ),
        ],
      ),
    );
  }

  // ─── Page 2: Profile Setup ────────────────────────────────────────────

  Widget _buildProfilePage() {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: tokens.textTertiary),
          const SizedBox(height: 16),
          Text(
            'Your Profile',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'These values help calculate power zones\nand training metrics.',
            textAlign: TextAlign.center,
            style: TextStyle(color: tokens.textTertiary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _ProfileField(
            key: const Key('onboardingFtpField'),
            icon: Icons.bolt,
            label: 'FTP',
            value: '${_ftp.round()} W',
            description: 'Functional Threshold Power — the max power '
                'you can sustain for 1 hour.',
            onTap: () async {
              final v = await showEditValueDialog(
                context: context,
                title: 'FTP',
                currentValue: _ftp,
                unit: 'W',
                min: 50,
                max: 500,
                allowDecimals: false,
              );
              if (v != null) setState(() => _ftp = v);
            },
          ),
          const SizedBox(height: 12),
          _ProfileField(
            key: const Key('onboardingWeightField'),
            icon: Icons.monitor_weight_outlined,
            label: 'Weight',
            value: UnitFormatter(_unitSystem).weightKg(_weight),
            description: 'Used for power-to-weight and simulation accuracy.',
            onTap: () async {
              final v = await showEditValueDialog(
                context: context,
                title: 'Weight',
                currentValue: _weight,
                unit: 'kg',
                min: 30,
                max: 200,
              );
              if (v != null) setState(() => _weight = v);
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _nextPage,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 3: Units & Body ─────────────────────────────────────────────

  Widget _buildUnitsAndBodyPage() {
    final tokens = context.tokens;
    final formatter = UnitFormatter(_unitSystem);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.straighten, size: 64, color: tokens.textTertiary),
          const SizedBox(height: 16),
          Text(
            'Units & Body',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Optional — height and max heart rate refine your zones. '
            'You can change these anytime in Settings.',
            textAlign: TextAlign.center,
            style: TextStyle(color: tokens.textTertiary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          SegmentedButton<UnitSystem>(
            key: const Key('onboardingUnitSystemSelector'),
            segments: const [
              ButtonSegment(
                value: UnitSystem.metric,
                label: Text('Metric (km)'),
              ),
              ButtonSegment(
                value: UnitSystem.imperial,
                label: Text('Imperial (mi)'),
              ),
            ],
            selected: {_unitSystem},
            onSelectionChanged: (selection) =>
                setState(() => _unitSystem = selection.first),
          ),
          const SizedBox(height: 16),
          _ProfileField(
            key: const Key('onboardingHeightField'),
            icon: Icons.height,
            label: 'Height',
            value: formatter.heightCm(_height),
            description: 'Optional — used for aerodynamic drag estimation.',
            onTap: () async {
              final v = await showEditValueDialog(
                context: context,
                title: 'Height',
                currentValue: _height,
                unit: 'cm',
                min: 100,
                max: 230,
                allowDecimals: false,
              );
              if (v != null) setState(() => _height = v);
            },
          ),
          const SizedBox(height: 12),
          _ProfileField(
            key: const Key('onboardingMaxHrField'),
            icon: Icons.favorite,
            label: 'Max Heart Rate',
            value: '$_maxHr bpm',
            description: 'Optional — used for heart-rate zone calculations.',
            onTap: () async {
              final v = await showEditValueDialog(
                context: context,
                title: 'Max Heart Rate',
                currentValue: _maxHr.toDouble(),
                unit: 'bpm',
                min: 120,
                max: 230,
                allowDecimals: false,
              );
              if (v != null) setState(() => _maxHr = v.round());
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _nextPage,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 4: Sensor Scan ──────────────────────────────────────────────

  Widget _buildScanPage() {
    final tokens = context.tokens;
    final scanState = ref.watch(bleScanStateProvider);
    final devices = ref.watch(bleScanResultsProvider).valueOrNull ?? const [];
    final isScanning = scanState.valueOrNull == BleTransportState.scanning;
    final isConnecting = _connectingDeviceId != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_searching, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            'Connect Your Trainer',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Turn on your smart trainer, then tap Scan\nto find it nearby.',
            textAlign: TextAlign.center,
            style: TextStyle(color: tokens.textTertiary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('onboardingScanButton'),
              onPressed: isScanning || isConnecting ? null : _scan,
              icon: isScanning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(isScanning ? 'Scanning…' : 'Scan for Devices'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: tokens.textDisabled),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: devices.isNotEmpty
                ? ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (_, i) => _buildScannedDeviceRow(devices[i]),
                  )
                : _buildScanEmptyState(isScanning),
          ),
          if (_connectError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _connectError!,
                key: const Key('onboardingConnectError'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  key: const Key('scanSkipButton'),
                  onPressed: _nextPage,
                  child: Text('Skip',
                      style: TextStyle(color: tokens.textTertiary)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScannedDeviceRow(BleScannedDevice scanned) {
    final tokens = context.tokens;
    final device = scanned.device;
    final name = device.name.isNotEmpty ? device.name : 'Unknown Device';
    final connecting = _connectingDeviceId == device.id;
    return ListTile(
      leading: const Icon(Icons.bluetooth, color: Colors.blue, size: 20),
      title: Text(name, style: TextStyle(color: tokens.textPrimary)),
      subtitle: connecting
          ? Text('Connecting…',
              style: TextStyle(color: tokens.textTertiary, fontSize: 12))
          : null,
      trailing: connecting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.chevron_right, color: tokens.textDisabled),
      dense: true,
      onTap: _connectingDeviceId == null ? () => _connectTrainer(device) : null,
    );
  }

  /// What the device list shows when it has nothing to list: progress while
  /// scanning, the reason a scan couldn't run, or tips after an empty scan.
  Widget _buildScanEmptyState(bool isScanning) {
    final tokens = context.tokens;
    if (isScanning) {
      return Center(
        child: Text(
          'Looking for devices…',
          style: TextStyle(color: tokens.textDisabled, fontSize: 13),
        ),
      );
    }
    if (_scanError != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _scanError!,
            key: const Key('onboardingScanError'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.orange, fontSize: 13),
          ),
          if (_bluetoothAccessDenied)
            TextButton(
              key: const Key('onboardingOpenSettingsButton'),
              onPressed: () =>
                  ref.read(bleTransportProvider).openPermissionSettings(),
              child: const Text('Open Settings'),
            ),
        ],
      );
    }
    return Center(
      child: Text(
        _hasScanned
            ? 'No devices found. Make sure your trainer is awake and not '
                'connected to another app, then scan again.'
            : 'No devices found yet.',
        textAlign: TextAlign.center,
        style: TextStyle(color: tokens.textDisabled, fontSize: 13),
      ),
    );
  }

  Future<void> _scan() async {
    setState(() {
      _scanError = null;
      _bluetoothAccessDenied = false;
      _connectError = null;
    });
    final transport = ref.read(bleTransportProvider);
    await transport.startScan(timeout: const Duration(seconds: 10));
    if (!mounted) return;
    setState(() {
      _hasScanned = true;
      _scanError = transport.lastScanError;
      _bluetoothAccessDenied =
          transport.lastScanProblem == BleAvailability.permissionDenied;
    });
  }

  /// Pairs [device] to the trainer role via [devicePairingServiceProvider] —
  /// the same per-role pairing service the Devices screen uses (P2), so a
  /// trainer connected during onboarding is a real pairing, not just a
  /// local flag. Reuses the service rather than the Devices screen's full
  /// multi-role slot UI, which doesn't fit this single-purpose step.
  Future<void> _connectTrainer(TrainerDevice device) async {
    if (_connectingDeviceId != null) return;
    setState(() {
      _connectingDeviceId = device.id;
      _connectError = null;
    });

    try {
      // This step pairs a single trainer, so the scan has done its job —
      // and connecting mid-scan is unreliable on some Android stacks.
      await ref.read(bleTransportProvider).stopScan();

      final service = ref.read(devicePairingServiceProvider);
      final port = await service.assign(SensorRole.trainer, device);
      if (!mounted) return;

      ref.read(trainerDeviceProvider.notifier).state = device;
      ref.read(activeTrainerPortProvider.notifier).state = port;

      final updated = ref.read(pairedDevicesProvider).withRole(
            SensorRole.trainer,
            PairedDevice(
              deviceId: device.id,
              name: device.name,
              protocol: device.protocol,
            ),
          );
      ref.read(pairedDevicesProvider.notifier).state = updated;
      await ref.read(appPreferencesProvider).setPairedDevices(updated);

      ref
          .read(roleConnectionStatusProvider.notifier)
          .markConnected(SensorRole.trainer);

      if (!mounted) return;
      setState(() {
        _deviceConnected = true;
        _connectedDeviceName = device.name;
        _connectingDeviceId = null;
      });
      // The handshake can take several seconds; if the user skipped ahead
      // meanwhile, don't yank them forward again — the connection-test
      // page picks up _deviceConnected on its own.
      if (_currentPage == _scanPage) _nextPage();
    } catch (e, st) {
      // Non-fatal — the user can retry, skip, or pair later from the
      // Devices tab — but it must be visible, not swallowed.
      _log.warning('Onboarding connect to ${device.name} failed: $e', e, st);
      if (!mounted) return;
      setState(() {
        _connectingDeviceId = null;
        _connectError = "Couldn't connect to ${device.name}. Make sure it's "
            'awake and not connected to another app, then tap it again.';
      });
    }
  }

  // ─── Page 5: Connection Test ──────────────────────────────────────────

  Widget _buildConnectionTestPage() {
    final tokens = context.tokens;
    if (!_deviceConnected) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_disabled,
                size: 64, color: tokens.textDisabled),
            const SizedBox(height: 16),
            Text(
              'No Device Connected',
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You can connect to a trainer later\nfrom the Devices tab.',
              textAlign: TextAlign.center,
              style: TextStyle(color: tokens.textTertiary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _nextPage,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    const Text('Continue', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      );
    }

    final power = ref.watch(livePowerProvider);
    final cadence = ref.watch(liveCadenceProvider);
    final hr = ref.watch(liveHeartRateProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            'Connected!',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _connectedDeviceName != null && _connectedDeviceName!.isNotEmpty
                ? 'Live data from $_connectedDeviceName:'
                : 'Live data from your trainer:',
            style: TextStyle(color: tokens.textTertiary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _LiveDataRow(
            icon: Icons.bolt,
            label: 'Power',
            value: '${power.value.round()} W',
            active: power.value > 0,
          ),
          _LiveDataRow(
            icon: Icons.rotate_right,
            label: 'Cadence',
            value: '${cadence.rpm.round()} rpm',
            active: cadence.rpm > 0,
          ),
          _LiveDataRow(
            icon: Icons.favorite,
            label: 'Heart Rate',
            value: '${hr.bpm} bpm',
            active: hr.bpm > 0,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _nextPage,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 6: Ready ────────────────────────────────────────────────────

  Widget _buildReadyPage() {
    final tokens = context.tokens;
    final formatter = UnitFormatter(_unitSystem);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rocket_launch, size: 80, color: Colors.deepOrange),
          const SizedBox(height: 24),
          Text(
            "You're All Set!",
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'FTP: ${_ftp.round()} W  •  Weight: ${formatter.weightKg(_weight)}',
            style: TextStyle(color: tokens.textTertiary, fontSize: 14),
          ),
          if (_deviceConnected)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Trainer connected',
                style: TextStyle(color: Colors.green, fontSize: 14),
              ),
            ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('onboardingFinishButton'),
              onPressed: _finish,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Start Riding',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  final int count;
  final int current;

  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == current
                ? tokens.textPrimary
                : tokens.textPrimary.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.surfaceTier2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepOrange, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: tokens.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(description,
                      style: TextStyle(color: tokens.textDisabled, fontSize: 11)),
                ],
              ),
            ),
            Text(value, style: TextStyle(color: tokens.textTertiary, fontSize: 16)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: tokens.textDisabled, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LiveDataRow extends StatelessWidget {
  const _LiveDataRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.active,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(active ? Icons.check_circle : Icons.radio_button_unchecked,
              color: active ? Colors.green : tokens.textDisabled, size: 20),
          const SizedBox(width: 12),
          Icon(icon, color: tokens.textTertiary, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: tokens.textPrimary)),
          const Spacer(),
          Text(value, style: TextStyle(color: tokens.textTertiary)),
        ],
      ),
    );
  }
}
