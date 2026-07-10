import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../plugins/exports/strava_export_plugin.dart';
import '../state/providers.dart';

/// Routes incoming `openbike://strava/callback` deep links to
/// [StravaExportPlugin.handleCallback].
///
/// Mobile only (Android/iOS) — desktop platforms complete the OAuth flow
/// via [DesktopOAuthLoopbackServer] instead, since custom URL schemes
/// aren't reliably routed back into a running desktop app.
class StravaDeepLinkListener extends ConsumerStatefulWidget {
  const StravaDeepLinkListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<StravaDeepLinkListener> createState() =>
      _StravaDeepLinkListenerState();
}

class _StravaDeepLinkListenerState
    extends ConsumerState<StravaDeepLinkListener> {
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      final appLinks = AppLinks();
      _sub = appLinks.uriLinkStream.listen(_handleUri);
    }
  }

  void _handleUri(Uri uri) {
    if (uri.scheme != 'openbike' || uri.host != 'strava') return;

    final plugins = ref.read(exportPluginsProvider);
    final strava = plugins['strava-export'];
    if (strava is StravaExportPlugin) {
      strava.handleCallback(uri);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
