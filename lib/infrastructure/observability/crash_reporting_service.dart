import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Opt-in crash reporting — see docs/release/analytics.md.
///
/// The app only ever talks to Sentry when both conditions hold:
///  1. A DSN was supplied at build time via `--dart-define=SENTRY_DSN`
///     (release/CI builds only — see docs/release/secrets.md's pattern).
///  2. The user has opted in via Settings → About → Crash reporting.
///
/// Condition 2 is re-checked live on every event via [isEnabled] rather than
/// baked in once at init, so flipping the Settings toggle takes effect
/// immediately without an app restart.
class CrashReportingService {
  const CrashReportingService._();

  /// Runs [appRunner] (which must call `runApp`) inside Sentry's error zone
  /// when [dsn] is non-empty; otherwise runs it directly with no Sentry
  /// involvement at all — the "no DSN" path never touches the network.
  static Future<void> run({
    required String dsn,
    required bool Function() isEnabled,
    required AppRunner appRunner,
  }) async {
    if (dsn.isEmpty) {
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        // No PII, no screenshots, no ride data — stack traces and basic
        // device/app metadata only.
        options.sendDefaultPii = false;
        options.attachScreenshot = false;
        options.beforeSend = (event, hint) =>
            isEnabled() ? redactEvent(event) : null;
        options.beforeBreadcrumb = (breadcrumb, hint) =>
            isEnabled() ? breadcrumb : null;
      },
      appRunner: appRunner,
    );
  }

  /// Strips fields that could carry ride data or user identity (breadcrumbs,
  /// legacy `extra` map, user context) before an event would leave the
  /// device. Exposed standalone so the redaction logic — and the opt-out
  /// drop in [run]'s `beforeSend` — are unit-testable without a real Sentry
  /// transport.
  @visibleForTesting
  static SentryEvent redactEvent(SentryEvent event) {
    event.breadcrumbs = null;
    // ignore: deprecated_member_use
    event.extra = null;
    event.user = null;
    return event;
  }
}
