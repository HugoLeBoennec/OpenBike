import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/oauth/desktop_oauth_loopback_server.dart';
import '../../plugins/exports/strava_export_plugin.dart';
import '../../plugins/plugin_interfaces.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';

/// Initiates the OAuth flow for [plugin].
///
/// Desktop platforms (Windows/macOS/Linux) spin up a
/// [DesktopOAuthLoopbackServer] since custom URL schemes aren't reliably
/// routed back into a running app there; mobile relies on
/// [StravaDeepLinkListener] to catch the `openbike://` redirect and call
/// [ExportPlugin.authenticate]'s default flow.
Future<void> connectExportPlugin(ExportPlugin plugin) async {
  final isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  if (plugin is StravaExportPlugin && isDesktop) {
    final server = DesktopOAuthLoopbackServer();
    try {
      final redirectUri = await server.start();
      await plugin.authenticateWithRedirect(redirectUri.toString());
      final callback = await server.waitForCallback();
      await plugin.handleCallback(callback);
    } finally {
      await server.close();
    }
    return;
  }
  await plugin.authenticate();
}

/// Bumped after a connect/disconnect action so [ConnectionsSection] re-reads
/// [ExportPlugin.isAuthenticated] — that getter isn't itself reactive.
final connectionsRefreshProvider = StateProvider<int>((ref) => 0);

/// Settings → Connections: one row per registered [ExportPlugin], driven
/// entirely by [exportPluginsProvider] so private-package plugins (see
/// `docs/release/private-plugins.md`) get a working row automatically once
/// registered — no per-service code needed here.
class ConnectionsSection extends ConsumerWidget {
  const ConnectionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(connectionsRefreshProvider);
    final plugins = ref.watch(exportPluginsProvider);

    if (plugins.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'No export plugins configured.',
          style: TextStyle(color: context.tokens.textDisabled, fontSize: 13),
        ),
      );
    }

    return Column(
      children: [
        for (final entry in plugins.entries)
          ConnectionTile(pluginId: entry.key, plugin: entry.value),
      ],
    );
  }
}

class ConnectionTile extends ConsumerStatefulWidget {
  const ConnectionTile({super.key, required this.pluginId, required this.plugin});

  final String pluginId;
  final ExportPlugin plugin;

  @override
  ConsumerState<ConnectionTile> createState() => _ConnectionTileState();
}

class _ConnectionTileState extends ConsumerState<ConnectionTile> {
  bool _busy = false;
  String? _error;

  bool get _requiresAuth =>
      widget.plugin.manifest.capabilities.contains('oauth2');

  IconData get _icon {
    final caps = widget.plugin.manifest.capabilities;
    if (caps.contains('oauth2')) return Icons.cloud_upload_outlined;
    if (caps.contains('file-export')) return Icons.save_alt_outlined;
    return Icons.extension_outlined;
  }

  Future<void> _toggleConnection() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (widget.plugin.isAuthenticated) {
        await widget.plugin.disconnect();
      } else {
        await connectExportPlugin(widget.plugin);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _busy = false);
      ref.read(connectionsRefreshProvider.notifier).state++;
    }
  }

  String get _statusText {
    if (!_requiresAuth) return 'Available';
    if (!widget.plugin.isAuthenticated) return 'Not connected';
    final athleteName = widget.plugin is StravaExportPlugin
        ? (widget.plugin as StravaExportPlugin).athleteName
        : null;
    return athleteName != null ? 'Connected as $athleteName' : 'Connected';
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = widget.plugin.isAuthenticated;
    final manifest = widget.plugin.manifest;

    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(_icon, color: tokens.textTertiary, size: 22),
          title: Text(manifest.name, style: TextStyle(color: tokens.textPrimary)),
          subtitle: _error != null
              ? Text(_error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12))
              : null,
          trailing: _requiresAuth
              ? _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: _toggleConnection,
                      child: Text(
                        isAuthenticated ? 'Disconnect' : 'Connect',
                        style: TextStyle(
                          color: isAuthenticated ? Colors.redAccent : Colors.green,
                        ),
                      ),
                    )
              : Text('Available',
                  style: TextStyle(color: tokens.textTertiary, fontSize: 14)),
          onTap: _requiresAuth && !_busy ? _toggleConnection : null,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 56, right: 16, bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _statusText,
                  style: TextStyle(
                    color: isAuthenticated || !_requiresAuth
                        ? Colors.green
                        : tokens.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ),
              Text('Auto-upload',
                  style: TextStyle(
                    color: isAuthenticated
                        ? tokens.textSecondary
                        : tokens.textDisabled,
                    fontSize: 12,
                  )),
              Switch(
                value: ref.watch(appPreferencesProvider)
                    .isAutoUploadEnabled(widget.pluginId),
                onChanged: isAuthenticated
                    ? (value) async {
                        await ref
                            .read(appPreferencesProvider)
                            .setAutoUploadEnabled(widget.pluginId, value);
                        setState(() {});
                      }
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
