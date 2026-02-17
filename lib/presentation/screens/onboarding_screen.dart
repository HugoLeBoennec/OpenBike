import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/entities/user_profile.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../infrastructure/ble/ble_transport.dart';
import '../state/providers.dart';
import '../widgets/edit_value_dialog.dart';

/// First-run onboarding — 5-page flow.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Profile values (defaults).
  double _ftp = 200;
  double _weight = 75;

  // Whether user connected a device during onboarding.
  bool _deviceConnected = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finish() {
    // Save profile.
    final profile = UserProfile(
      ftp: Watts(_ftp),
      weight: _weight,
      height: 178,
      restingHr: const HeartRate(60),
      maxHr: const HeartRate(190),
      name: '',
    );
    ref.read(userProfileProvider.notifier).state = profile;
    ref.read(storageProvider).saveProfile(profile);

    // Mark onboarding complete.
    ref.read(appPreferencesProvider).setOnboardingCompleted(true);

    // Navigate to ride screen.
    context.go('/ride');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcomePage(),
                  _buildProfilePage(),
                  _buildScanPage(),
                  _buildConnectionTestPage(),
                  _buildReadyPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PageDots(count: 5, current: _currentPage),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Page 1: Welcome ──────────────────────────────────────────────────

  Widget _buildWelcomePage() {
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
          const Text(
            'OpenBike',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Open-source indoor cycling',
            style: TextStyle(color: Colors.white54, fontSize: 16),
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
        ],
      ),
    );
  }

  // ─── Page 2: Profile Setup ────────────────────────────────────────────

  Widget _buildProfilePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            'Your Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'These values help calculate power zones\nand training metrics.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _ProfileField(
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
            icon: Icons.monitor_weight_outlined,
            label: 'Weight',
            value: '${_weight.toStringAsFixed(1)} kg',
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

  // ─── Page 3: Sensor Scan ──────────────────────────────────────────────

  Widget _buildScanPage() {
    final scanState = ref.watch(bleScanStateProvider);
    final scanResults = ref.watch(bleScanResultsProvider);
    final isScanning = scanState.valueOrNull == BleTransportState.scanning;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_searching, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Connect Your Trainer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Turn on your smart trainer, then tap Scan\nto find it nearby.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isScanning
                  ? null
                  : () => ref
                      .read(bleTransportProvider)
                      .startScan(timeout: const Duration(seconds: 10)),
              icon: Icon(isScanning ? Icons.hourglass_top : Icons.search),
              label: Text(isScanning ? 'Scanning…' : 'Scan for Devices'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.white24),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: scanResults.when(
              data: (devices) {
                if (devices.isEmpty) {
                  return const Center(
                    child: Text(
                      'No devices found yet.',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (_, i) {
                    final d = devices[i];
                    final name = d.device.name.isNotEmpty
                        ? d.device.name
                        : 'Unknown Device';
                    return ListTile(
                      leading: const Icon(Icons.bluetooth,
                          color: Colors.blue, size: 20),
                      title: Text(name,
                          style: const TextStyle(color: Colors.white)),
                      dense: true,
                      onTap: () async {
                        await ref
                            .read(bleTransportProvider)
                            .connectToDevice(d.device.id);
                        if (!mounted) return;
                        ref.read(trainerDeviceProvider.notifier).state =
                            d.device;
                        // Persist device ID.
                        final saved = ref.read(savedDeviceIdsProvider);
                        if (!saved.contains(d.device.id)) {
                          final updated = [...saved, d.device.id];
                          ref.read(savedDeviceIdsProvider.notifier).state =
                              updated;
                          ref
                              .read(appPreferencesProvider)
                              .setSavedDeviceIds(updated);
                        }
                        setState(() => _deviceConnected = true);
                        _nextPage();
                      },
                    );
                  },
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _nextPage,
                  child: const Text('Skip',
                      style: TextStyle(color: Colors.white54)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Page 4: Connection Test ──────────────────────────────────────────

  Widget _buildConnectionTestPage() {
    if (!_deviceConnected) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth_disabled,
                size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            const Text(
              'No Device Connected',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can connect to a trainer later\nfrom the Devices tab.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
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
          const Text(
            'Connected!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Live data from your trainer:',
            style: TextStyle(color: Colors.white54, fontSize: 14),
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

  // ─── Page 5: Ready ────────────────────────────────────────────────────

  Widget _buildReadyPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rocket_launch, size: 80, color: Colors.deepOrange),
          const SizedBox(height: 24),
          const Text(
            "You're All Set!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'FTP: ${_ftp.round()} W  •  Weight: ${_weight.toStringAsFixed(1)} kg',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
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
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
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
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(description,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            Text(value,
                style: const TextStyle(color: Colors.white54, fontSize: 16)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(active ? Icons.check_circle : Icons.radio_button_unchecked,
              color: active ? Colors.green : Colors.white24, size: 20),
          const SizedBox(width: 12),
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
