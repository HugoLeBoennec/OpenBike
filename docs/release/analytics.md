# Analytics & crash reporting decision

**Decision for v1.0: no behavioral analytics.** OpenBike ships with opt-in
crash reporting only (below) — no event tracking, no usage funnels, no
third-party analytics SDK of any kind. Privacy is a deliberate selling point
against subscription training apps that track usage extensively; this is
revisited post-launch only if there's a concrete product question analytics
would answer that user interviews/support tickets can't.

## Crash reporting (opt-in, default off)

Implemented via `sentry_flutter` — see
`lib/infrastructure/observability/crash_reporting_service.dart`.

- **Off by default.** The user is asked once, immediately after onboarding
  completes (`lib/presentation/screens/onboarding_screen.dart`'s
  `_maybeAskCrashReportingConsent`), via
  `lib/presentation/widgets/crash_reporting_consent_dialog.dart`. The choice
  is always changeable afterwards in Settings → About → Crash reporting.
- **No DSN, no Sentry at all.** `CrashReportingService` takes the DSN from
  `--dart-define=SENTRY_DSN` (empty string when the flag isn't passed, the
  same pattern as the Strava OAuth credentials in `docs/release/secrets.md`).
  When empty, `start` returns immediately — `SentryFlutter.init` is never
  called, so builds without the secret (every public/dev/CI build) never
  make a network call to Sentry, opted in or not.
- **Opted out means never started.** `main` loads the preferences first and
  calls `CrashReportingService.apply(enabled: ...)`. `SentryFlutter.init`
  only runs for opted-in users, so the native SDK (crash handler, sessions,
  hang and watchdog tracking) isn't running for anyone else.
- **Live start/stop, no restart needed.** The Settings toggle and the
  post-onboarding consent call `apply`: on starts Sentry, off calls
  `Sentry.close()`, which also closes the native SDK. `beforeSend`/
  `beforeBreadcrumb` additionally drop anything queued after a stop.
- **Dart-side reporting only.** `enableNativeCrashHandling` is off because
  the native handler attaches a persistent per-install user ID that bypasses
  the Dart redaction. Native crashes are therefore not reported; Dart and
  Flutter errors are. Sessions, app-hang and watchdog tracking, client
  reports, performance tracing, native breadcrumbs, screenshots and view
  hierarchy are all off.
- **No PII, no ride data.** `sendDefaultPii` is off, the user is cleared from
  the native scope after init, and `CrashReportingService.redactEvent`
  strips `breadcrumbs`, the legacy `extra` map, `user` and
  `contexts.app.device_app_hash` (a hash of the device/vendor ID) before an
  event leaves the device. What remains is the stack trace, app and OS
  version, and device model. Routes, power/HR samples and workout data are
  never constructed into breadcrumbs in the first place; the strip is a
  defense-in-depth backstop against a future call site adding one.

## CI / release builds

Add `SENTRY_DSN` as a GitHub Actions secret and pass it the same way as the
Strava credentials:

```bash
flutter build apk --release --dart-define=SENTRY_DSN=${{ secrets.SENTRY_DSN }}
```

Until that secret is configured, release builds simply run with crash
reporting compiled out (the "no DSN" path above) — this is a safe default,
not a broken one.
