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
- **No DSN, no Sentry at all.** `CrashReportingService.run` takes the DSN
  from `--dart-define=SENTRY_DSN` (empty string when the flag isn't passed,
  the same pattern as the Strava OAuth credentials in
  `docs/release/secrets.md`). When empty, `appRunner` is invoked directly —
  `SentryFlutter.init` is never called, so builds without the secret (every
  public/dev/CI build) never make a network call to Sentry, opted in or not.
- **Live opt-out, no restart needed.** The user's current preference is
  re-read on every event via `isEnabled()` inside `beforeSend`/
  `beforeBreadcrumb`, rather than baked in once at `init()` time, so
  flipping the Settings toggle off drops events starting immediately.
- **No PII, no ride data.** `sendDefaultPii` and `attachScreenshot` are both
  off, and `CrashReportingService.redactEvent` strips `breadcrumbs`, the
  legacy `extra` map, and `user` context before an event would leave the
  device — routes, power/HR samples, and workout data are never constructed
  into breadcrumbs in the first place, but the strip is a defense-in-depth
  backstop against a future call site adding one.

## CI / release builds

Add `SENTRY_DSN` as a GitHub Actions secret and pass it the same way as the
Strava credentials:

```bash
flutter build apk --release --dart-define=SENTRY_DSN=${{ secrets.SENTRY_DSN }}
```

Until that secret is configured, release builds simply run with crash
reporting compiled out (the "no DSN" path above) — this is a safe default,
not a broken one.
