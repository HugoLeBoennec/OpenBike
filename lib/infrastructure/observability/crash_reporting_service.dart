import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Opt-in crash reporting — see docs/release/analytics.md.
///
/// Sentry is only ever running when both conditions hold:
///  1. A DSN was supplied at build time via `--dart-define=SENTRY_DSN`
///     (release/CI builds only — see docs/release/secrets.md's pattern).
///  2. The user has opted in via onboarding or Settings → About → Crash
///     reporting.
///
/// An opted-out user never causes `SentryFlutter.init` to run, so the native
/// SDK (crash handler, sessions, hang tracking) isn't started either.
/// Flipping the toggle calls [apply], which starts or closes Sentry live.
class CrashReportingService {
  const CrashReportingService._();

  static const String _buildDsn = String.fromEnvironment('SENTRY_DSN');

  /// Swapped in tests so initialisation doesn't need a real Sentry.
  @visibleForTesting
  static Future<void> Function(FlutterOptionsConfiguration) initializer =
      SentryFlutter.init;

  /// Swapped in tests alongside [initializer].
  @visibleForTesting
  static Future<void> Function() closer = Sentry.close;

  static bool _running = false;

  /// Starts or stops Sentry to match the user's choice, using the DSN baked
  /// into this build. A no-op in builds without a DSN.
  static Future<void> apply({required bool enabled}) {
    if (!enabled) return stop();
    return start(dsn: _buildDsn, isEnabled: () => _running);
  }

  /// Starts Sentry when [dsn] is non-empty and it isn't already running.
  /// The "no DSN" path never touches Sentry or the network.
  ///
  /// There is no `appRunner`: since Flutter 3.3 the error zone isn't needed,
  /// the SDK hooks `FlutterError.onError` and `PlatformDispatcher.onError`.
  static Future<void> start({
    required String dsn,
    required bool Function() isEnabled,
  }) async {
    if (dsn.isEmpty || _running) return;
    _running = true;

    try {
      await initializer((options) {
        options.dsn = dsn;
        // No PII, no screenshots, no ride data — stack traces and basic
        // device/app metadata only.
        options.sendDefaultPii = false;
        options.attachScreenshot = false;
        // ignore: experimental_member_use
        options.attachViewHierarchy = false;
        // Crash data only: no release-health sessions, hangs, watchdog
        // terminations, client reports, traces or native breadcrumbs.
        options.enableAutoSessionTracking = false;
        options.enableAppHangTracking = false;
        options.enableWatchdogTerminationTracking = false;
        options.sendClientReports = false;
        options.enableAutoPerformanceTracing = false;
        options.enableAutoNativeBreadcrumbs = false;
        // The native crash handler attaches a persistent per-install user ID
        // that never passes through the Dart-side redaction, so crashes are
        // reported from the Dart side only.
        options.enableNativeCrashHandling = false;
        // Backstop: if an event is somehow queued after an opt-out, drop it.
        options.beforeSend = (event, hint) =>
            isEnabled() ? redactEvent(event) : null;
        options.beforeBreadcrumb = (breadcrumb, hint) =>
            isEnabled() ? breadcrumb : null;
      });

      // Keep any user from syncing into the native scope.
      await Sentry.configureScope((scope) => scope.setUser(null));
    } catch (_) {
      _running = false;
      rethrow;
    }
  }

  /// Closes Sentry (and the native SDK with it) if it is running.
  static Future<void> stop() async {
    if (!_running) return;
    _running = false;
    await closer();
  }

  /// Strips fields that could carry ride data or user identity (breadcrumbs,
  /// legacy `extra` map, user context, the hashed device ID) before an event
  /// would leave the device. Exposed standalone so the redaction logic is
  /// unit-testable without a real Sentry transport.
  @visibleForTesting
  static SentryEvent redactEvent(SentryEvent event) {
    event.breadcrumbs = null;
    // ignore: deprecated_member_use
    event.extra = null;
    event.user = null;
    event.contexts.app?.deviceAppHash = null;
    return event;
  }
}
