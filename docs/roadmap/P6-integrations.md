---
phase: P6
title: Integrations — Strava UI, GPX export, open-core seam, Records & OpenCoach
status: NOT_STARTED
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
- [ ] Add `app_links` dependency; listen for `openbike://strava/callback` (scheme
      registered in P1) at app level and route the URI to
      `StravaExportPlugin.handleCallback`.
- [ ] Desktop (Windows/macOS/Linux): custom schemes are unreliable — implement the
      loopback alternative: temporary `HttpServer` on `127.0.0.1:<random port>`,
      redirect URI `http://127.0.0.1:<port>/callback`, used when
      `Platform.isWindows||isMacOS||isLinux`. Keep the scheme path for mobile. Both feed
      the same `handleCallback`.
- [ ] Settings → Connections section: Strava row shows state (connected as <athlete> /
      not connected), Connect launches `authenticate()`, Disconnect calls
      `disconnect()`; restore session on app start (`restoreSession` exists).
- [ ] Auto-upload toggle (per service): on ride save, enqueue export automatically via
      the existing `ExportQueueService`.
      **Accept:** unit tests with a mocked http client: callback → token exchange →
      `isAuthenticated`; loopback server round-trip test; widget test for the
      Connections UI states.

### 2. GPX export
- [ ] Implement `ExportFormat.gpx` in
      `lib/core/application/use_cases/export_service.dart:49`: for simulated route rides
      emit track points from the route geometry + timestamps/HR/cadence/power extensions
      (`gpxtpx` extension) — for non-route rides export without positions (time series
      only) or disable the option. Reuse the `gpx`/`xml` packages.
      **Accept:** encoder test: exported GPX re-parses with `GpxRouteParser` and point
      count/distance match.

### 3. Open-core seam (credentials + private plugins)
- [ ] Formalize the build-time credential injection already used in `main.dart`
      (`STRAVA_CLIENT_ID`/`STRAVA_CLIENT_SECRET` via `--dart-define`):
      document in `docs/release/secrets.md`; CI release builds read them from GitHub
      Actions secrets; public/dev builds simply run without Strava registered (already
      graceful).
- [ ] Create the private-plugin seam: an optional registration hook — e.g.
      `List<ExportPlugin> Function()? extraExportPlugins` +
      `List<DevicePlugin> Function()? extraDevicePlugins` resolved in `main.dart` via a
      conditional import of `package:openbike_private_plugins/register.dart` falling
      back to a no-op stub file in-repo. The public app must compile and pass CI with
      no private package present.
- [ ] Scaffold the private package layout in docs (`docs/release/private-plugins.md`):
      a separate private repo `openbike_private_plugins` exposing `register.dart`;
      release CI adds it via a git dependency + SSH deploy key.
      **Accept:** public build compiles with the stub; a fake in-test implementation of
      the hook registers and appears in `PluginRegistry.allManifests`.

### 4. Records & OpenCoach connections (private plugins)
- [ ] Define the *open* contract only: `ExportPlugin` implementations named
      `RecordsExportPlugin` / `OpenCoachExportPlugin` will live in the private package
      (they are user-specific services; API details supplied by the maintainer there).
      In the public repo: add their manifest ids to the Connections UI so that when the
      private package registers them, Settings shows Connect/Disconnect rows
      automatically for **any** registered export plugin (make the Connections section
      data-driven from `exportPluginsProvider` instead of hard-coded rows).
      **Accept:** widget test: registering a fake extra plugin makes a Connections row
      appear with working state transitions. **No Records/OpenCoach code or endpoints in
      the public repo.**

### 5. Cleanup
- [ ] TrainingPeaks: legacy stub deleted in P0; do not reintroduce unless it lands in
      the private package later.
- [ ] Ride summary export section: show per-target queue status from
      `ExportQueueService.queueStream` (uploading / retrying (n) / failed with reason /
      done), with manual retry (service method exists).
      **Accept:** widget test driving queue states through the stream.

## Validation

```bash
flutter analyze && flutter test
grep -ri "opencoach\|records_api" lib/  # empty — no private endpoints in public code
```
CI green. `[HW]`/manual: full Strava round-trip with real credentials on one mobile +
one desktop platform (record → auto-upload → activity visible as VirtualRide).

## Definition of done
Frontmatter `status: DONE`, checkboxes ticked, CI green, README status board updated.
