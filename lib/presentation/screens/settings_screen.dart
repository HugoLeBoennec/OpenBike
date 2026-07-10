import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/entities/user_profile.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/connections_section.dart';
import '../widgets/edit_value_dialog.dart';

/// Settings screen — user profile, display, connections.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final formatter = ref.watch(unitFormatterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // ----- User Profile -----
          _SectionHeader('USER PROFILE'),
          _SettingsTile(
            icon: Icons.bolt,
            title: 'FTP',
            value: profile != null ? '${profile.ftp.value.round()} W' : 'Not set',
            onTap: () => _editFtp(context, ref, profile),
          ),
          _SettingsTile(
            icon: Icons.monitor_weight_outlined,
            title: 'Weight',
            value: profile?.weight != null
                ? formatter.weightKg(profile!.weight)
                : 'Not set',
            onTap: () => _editWeight(context, ref, profile),
          ),
          _SettingsTile(
            icon: Icons.height,
            title: 'Height',
            value: profile?.height != null
                ? formatter.heightCm(profile!.height)
                : 'Not set',
            onTap: () => _editHeight(context, ref, profile),
          ),
          _SettingsTile(
            icon: Icons.favorite_border,
            title: 'Resting HR',
            value: profile?.restingHr != null
                ? '${profile!.restingHr.bpm} bpm'
                : 'Not set',
            onTap: () => _editRestingHr(context, ref, profile),
          ),
          _SettingsTile(
            icon: Icons.favorite,
            title: 'Max HR',
            value: profile?.maxHr != null
                ? '${profile!.maxHr.bpm} bpm'
                : 'Not set',
            onTap: () => _editMaxHr(context, ref, profile),
          ),

          const SizedBox(height: 8),

          // ----- Connections -----
          _SectionHeader('CONNECTIONS'),
          const ConnectionsSection(),

          const SizedBox(height: 8),

          // ----- Display -----
          _SectionHeader('DISPLAY'),
          _SettingsTile(
            icon: Icons.straighten,
            title: 'Units',
            value: ref.watch(unitSystemProvider) == 'metric'
                ? 'Metric (km/h)'
                : 'Imperial (mph)',
            onTap: () {
              final current = ref.read(unitSystemProvider);
              final next = current == 'metric' ? 'imperial' : 'metric';
              ref.read(unitSystemProvider.notifier).state = next;
              ref.read(appPreferencesProvider).setUnitSystem(next);
            },
          ),
          _SettingsTile(
            icon: Icons.dark_mode,
            title: 'Theme',
            value: _themeLabel(ref.watch(themeModeProvider)),
            onTap: () {
              final current = ref.read(themeModeProvider);
              final next = _nextThemeMode(current);
              ref.read(themeModeProvider.notifier).state = next;
              ref.read(appPreferencesProvider).setThemeMode(next);
            },
          ),
          _SettingsTile(
            icon: Icons.pause_circle_outline,
            title: 'Auto-pause',
            value: ref.watch(autoPauseEnabledProvider) ? 'On' : 'Off',
            valueColor:
                ref.watch(autoPauseEnabledProvider) ? Colors.green : null,
            onTap: () {
              final next = !ref.read(autoPauseEnabledProvider);
              ref.read(autoPauseEnabledProvider.notifier).state = next;
              ref.read(appPreferencesProvider).setAutoPauseEnabled(next);
            },
          ),

          const SizedBox(height: 8),

          // ----- About -----
          _SectionHeader('ABOUT'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'OpenBike',
            value: 'v1.0.0',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Open-source licenses',
            value: '',
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'OpenBike',
              applicationVersion: '1.0.0',
            ),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Crash reporting',
            value: ref.watch(crashReportingEnabledProvider) ? 'On' : 'Off',
            valueColor:
                ref.watch(crashReportingEnabledProvider) ? Colors.green : null,
            onTap: () {
              final next = !ref.read(crashReportingEnabledProvider);
              ref.read(crashReportingEnabledProvider.notifier).state = next;
              ref.read(appPreferencesProvider).setCrashReportingEnabled(next);
            },
          ),

          // ----- Dev Tools (DEV_MODE only) -----
          if (ref.watch(devModeProvider)) ...[
            const SizedBox(height: 8),
            _SectionHeader('DEVELOPER'),
            _SettingsTile(
              icon: Icons.bug_report,
              title: 'Dev Tools',
              value: '',
              onTap: () => context.push('/dev'),
            ),
          ],
        ],
      ),
    );
  }

  static String _themeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Light';
      case 'system':
        return 'System';
      case 'dark':
      default:
        return 'Dark';
    }
  }

  /// Cycles Dark -> Light -> System -> Dark on tap.
  static String _nextThemeMode(String current) {
    switch (current) {
      case 'dark':
        return 'light';
      case 'light':
        return 'system';
      case 'system':
      default:
        return 'dark';
    }
  }

  UserProfile _defaultProfile() {
    return const UserProfile(
      ftp: Watts(200),
      weight: 75,
      height: 178,
      restingHr: HeartRate(60),
      maxHr: HeartRate(190),
      name: '',
    );
  }

  Future<void> _editFtp(
      BuildContext context, WidgetRef ref, UserProfile? profile) async {
    final current = profile ?? _defaultProfile();
    final value = await showEditValueDialog(
      context: context,
      title: 'FTP',
      currentValue: current.ftp.value,
      unit: 'W',
      min: 50,
      max: 500,
      allowDecimals: false,
    );
    if (value == null) return;
    final updated = current.copyWith(ftp: Watts(value));
    ref.read(userProfileProvider.notifier).state = updated;
    _saveProfile(ref, updated);
  }

  Future<void> _editWeight(
      BuildContext context, WidgetRef ref, UserProfile? profile) async {
    final current = profile ?? _defaultProfile();
    final value = await showEditValueDialog(
      context: context,
      title: 'Weight',
      currentValue: current.weight,
      unit: 'kg',
      min: 30,
      max: 200,
    );
    if (value == null) return;
    final updated = current.copyWith(weight: value);
    ref.read(userProfileProvider.notifier).state = updated;
    _saveProfile(ref, updated);
  }

  Future<void> _editHeight(
      BuildContext context, WidgetRef ref, UserProfile? profile) async {
    final current = profile ?? _defaultProfile();
    final value = await showEditValueDialog(
      context: context,
      title: 'Height',
      currentValue: current.height,
      unit: 'cm',
      min: 100,
      max: 230,
      allowDecimals: false,
    );
    if (value == null) return;
    final updated = current.copyWith(height: value);
    ref.read(userProfileProvider.notifier).state = updated;
    _saveProfile(ref, updated);
  }

  Future<void> _editRestingHr(
      BuildContext context, WidgetRef ref, UserProfile? profile) async {
    final current = profile ?? _defaultProfile();
    final value = await showEditValueDialog(
      context: context,
      title: 'Resting Heart Rate',
      currentValue: current.restingHr.bpm.toDouble(),
      unit: 'bpm',
      min: 30,
      max: 120,
      allowDecimals: false,
    );
    if (value == null) return;
    final updated = current.copyWith(restingHr: HeartRate(value.round()));
    ref.read(userProfileProvider.notifier).state = updated;
    _saveProfile(ref, updated);
  }

  Future<void> _editMaxHr(
      BuildContext context, WidgetRef ref, UserProfile? profile) async {
    final current = profile ?? _defaultProfile();
    final value = await showEditValueDialog(
      context: context,
      title: 'Max Heart Rate',
      currentValue: current.maxHr.bpm.toDouble(),
      unit: 'bpm',
      min: 120,
      max: 230,
      allowDecimals: false,
    );
    if (value == null) return;
    final updated = current.copyWith(maxHr: HeartRate(value.round()));
    ref.read(userProfileProvider.notifier).state = updated;
    _saveProfile(ref, updated);
  }

  void _saveProfile(WidgetRef ref, UserProfile profile) {
    ref.read(storageProvider).saveProfile(profile);
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
// Settings tile
// ---------------------------------------------------------------------------

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ListTile(
      leading: Icon(icon, color: tokens.textTertiary, size: 22),
      title: Text(title, style: TextStyle(color: tokens.textPrimary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? tokens.textTertiary,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: tokens.textDisabled, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}
