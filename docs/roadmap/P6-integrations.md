---
phase: P6
title: Integrations — Strava UI, GPX export, open-core seam, Records & OpenCoach
status: DONE
depends_on: [P2]
validation:
  - flutter analyze
  - flutter test
---

# P6 — Integrations & open-core split

## Context

The Strava plugin (`lib/plugins/exports/strava_export_plugin.dart`) is fully implemented
(OAuth2, secure tokens, upload, rate limiting) but the Settings screen never calls it
(`settings_screen.dart:78` is `// TODO: OAuth flow`) and no deep-link callback reaches
`handleCallback`. GPX export throws `UnimplementedError`. Additionally, OpenBike is
**open source with an open-core split**: OAuth client credentials and the **Records**
and **OpenCoach** connections must live outside the public repo, loaded through the
existing plugin seams.

## Tasks

### 1. Wire Strava end-to-end
- [x] Add `app_links` dependency; listen for `openbike://strava/callback` (scheme
      registered in P1) at app level and route the URI to
      `StravaExportPlugin.handleCallback`. (`StravaDeepLinkListener`, mobile-only.)
- [x] Desktop (Windows/macOS/Linux): custom schemes are unreliable — implement the
      loopback alternative: temporary `HttpServer` on `127.0.0.1:<random port>`,
      redirect URI `http://127.0.0.1:<port>/callback`, used when
      `Platform.isWindows||isMacOS||isLinux`. Keep the scheme path for mobile. Both feed
      the same `handleCallback`. (`DesktopOAuthLoopbackServer` +
      `StravaExportPlugin.authenticateWithRedirect`, orchestrated by
      `connectExportPlugin()`.)
- [x] Settings → Connections section: Strava row shows state (connected as <athlete> /
      not connected), Connect launches `authenticate()`, Disconnect calls
      `disconnect()`; restore session on app start (`restoreSession` exists).
      (`ConnectionsSection`/`ConnectionTile`; `main.dart` calls `restoreSession()` for
      any registered `StravaExportPlugin` at startup.)
- [x] Auto-upload toggle (per service): on ride save, enqueue export automatically via
      the existing `ExportQueueService`. (`AppPreferences.autoUploadTargets` +
      `autoUploadProvider`, watched from `RideScreen`.)
      **Accept:** unit tests with a mocked http client: callback → token exchange →
      `isAuthenticated`; loopback server round-trip test; widget test for the
      Connections UI states. — `test/plugins/exports/strava_export_plugin_test.dart`,
      `test/infrastructure/oauth/desktop_oauth_loopback_server_test.dart`,
      `test/presentation/widgets/connections_section_test.dart`.

### 2. GPX export
- [x] Implement `ExportFormat.gpx` in
      `lib/core/application/use_cases/export_service.dart:49`: for simulated route rides
      emit track points from the route geometry + timestamps/HR/cadence/power extensions
      (`gpxtpx` extension) — for non-route rides export without positions (time series
      only) or disable the option. Reuse the `gpx`/`xml` packages. (`GpxEncoder`; `Ride`
      has no persisted route/position data outside an in-progress `RouteSimulator`
      session, so `exportToFile`/`encodeGpx` take an explicit `Route` and throw the
      typed `GpxExportUnsupported` — not the old `UnimplementedError` — when it's
      omitted, so callers can disable the option for non-route rides.)
      **Accept:** encoder test: exported GPX re-parses with `GpxRouteParser` and point
      count/distance match. — `test/infrastructure/files/encoders_test.dart`
      (`GpxEncoder` group).

### 3. Open-core seam (credentials + private plugins)
- [x] Formalize the build-time credential injection already used in `main.dart`
      (`STRAVA_CLIENT_ID`/`STRAVA_CLIENT_SECRET` via `--dart-define`):
      document in `docs/release/secrets.md`; CI release builds read them from GitHub
      Actions secrets; public/dev builds simply run without Strava registered (already
      graceful).
- [x] Create the private-plugin seam: an optional registration hook —
      `List<ExportPlugin> Function()? extraExportPlugins` +
      `List<DevicePlugin> Function()? extraDevicePlugins`, resolved by
      `registerPrivatePlugins()` (`lib/plugins/private_plugins.dart`) against the
      checked-in no-op stub `lib/plugins/private_registration.dart`. **Not** a Dart
      conditional import as originally sketched — Dart can't conditionally import a
      package that isn't a pubspec dependency at all, so a release build instead swaps
      the stub file for one backed by `package:openbike_private_plugins` (documented in
      `docs/release/private-plugins.md`). The public app compiles and passes CI with no
      private package present — the stub *is* the default, not a fallback branch.
- [x] Scaffold the private package layout in docs (`docs/release/private-plugins.md`):
      a separate private repo `openbike_private_plugins` exposing `register.dart`;
      release CI adds it via a git dependency + SSH deploy key.
      **Accept:** public build compiles with the stub; a fake in-test implementation of
      the hook registers and appears in `PluginRegistry.allManifests`. —
      `test/plugins/private_plugins_test.dart`.

### 4. Records & OpenCoach connections (private plugins)
- [x] Define the *open* contract only: `ExportPlugin` implementations named
      `RecordsExportPlugin` / `OpenCoachExportPlugin` will live in the private package
      (they are user-specific services; API details supplied by the maintainer there).
      In the public repo: add their manifest ids to the Connections UI so that when the
      private package registers them, Settings shows Connect/Disconnect rows
      automatically for **any** registered export plugin (make the Connections section
      data-driven from `exportPluginsProvider` instead of hard-coded rows). (No manifest
      ids are hard-coded anywhere — `ConnectionsSection` iterates
      `exportPluginsProvider` directly, which is strictly more general.)
      **Accept:** widget test: registering a fake extra plugin makes a Connections row
      appear with working state transitions. **No Records/OpenCoach code or endpoints in
      the public repo.** — `test/presentation/widgets/connections_section_test.dart`;
      `grep -ri "opencoach\|records_api" lib/` is empty.

### 5. Cleanup
- [x] TrainingPeaks: legacy stub deleted in P0; do not reintroduce unless it lands in
      the private package later. (Not reintroduced.)
- [x] Ride summary export section: show per-target queue status from
      `ExportQueueService.queueStream` (uploading / retrying (n) / failed with reason /
      done), with manual retry (service method exists). (`ExportButton` in
      `ride_summary_widgets.dart`; `ExportQueueService.maxRetries` made public so the UI
      can distinguish an in-progress backoff retry from a terminal failure.)
      **Accept:** widget test driving queue states through the stream. —
      `test/presentation/widgets/ride_summary_widgets_test.dart`.

## Validation

```bash
flutter analyze && flutter test
grep -ri "opencoach\|records_api" lib/  # empty — no private endpoints in public code
```
Both ran locally against Flutter 3.38.10 (matching `.github/workflows/ci.yml`'s
`FLUTTER_VERSION`): `flutter analyze` — no issues found; `flutter test` — 667/667
passed; the grep check is empty.

**CI status:** GitHub Actions itself is not currently completing runs for this
repository — the `Analyze` and `Unit & widget tests` jobs fail after ~2–4s with 0ms
billable runtime (i.e. a runner never picks up the job), and every build job
(`needs: [analyze, test]`) is skipped as a result. This reproduces identically on
`main` at the already-merged P5 commit (`6ca947e`) starting ~2026-07-10T05:54Z, and on
this branch's push — it is an infrastructure/runner issue on the GitHub Actions side,
not a regression introduced by P6. Re-running the failed jobs via the API was denied
(`403 Resource not accessible by integration`). Local validation above is the
substitute confirmation; re-run CI once GitHub Actions is healthy again.

`[HW]`/manual: full Strava round-trip with real credentials on one mobile + one desktop
platform (record → auto-upload → activity visible as VirtualRide).

## Definition of done
Frontmatter `status: DONE`, checkboxes ticked, README status board updated. CI
confirmation is pending a GitHub Actions infra fix (see Validation note above) —
re-run the workflow once runners are healthy.
