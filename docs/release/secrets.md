# Build-time credentials

OpenBike is open source, but OAuth client credentials (Strava, and future
services) must not be committed to the public repo. They're injected at
build time via `--dart-define`, read in `lib/main.dart` with
`String.fromEnvironment`, and only registered if present.

## How it works

`lib/main.dart` (`_registerPlugins`) reads:

```dart
const stravaClientId = String.fromEnvironment('STRAVA_CLIENT_ID');
const stravaClientSecret = String.fromEnvironment('STRAVA_CLIENT_SECRET');
if (stravaClientId.isNotEmpty && stravaClientSecret.isNotEmpty) {
  registry.registerExport(StravaExportPlugin(
    config: StravaConfig(clientId: stravaClientId, clientSecret: stravaClientSecret),
  ));
}
```

`String.fromEnvironment` resolves at compile time from `--dart-define` flags.
When a credential is absent (public/dev builds), the value is the empty
string and the plugin is simply never registered — the app compiles and runs
fully without it, and Settings → Connections just doesn't show that row
(see `lib/presentation/widgets/connections_section.dart`, which is
data-driven off whichever export plugins actually got registered).

## Local development

```bash
flutter run \
  --dart-define=STRAVA_CLIENT_ID=<your client id> \
  --dart-define=STRAVA_CLIENT_SECRET=<your client secret>
```

Get a client id/secret by registering an app at
<https://www.strava.com/settings/api>. Set the "Authorization Callback
Domain" to `127.0.0.1` (used by the desktop loopback OAuth flow — see
`lib/infrastructure/oauth/desktop_oauth_loopback_server.dart`); the
`openbike://strava/callback` scheme (mobile) doesn't need a domain entry.

Never put real credentials in a committed file (`.env`, launch config,
etc.) — pass them on the command line or via your IDE's per-run
environment variables, which aren't checked in.

## CI / release builds

Release builds (store submissions, tagged releases) read the same
`--dart-define` flags from GitHub Actions secrets:

```yaml
- run: flutter build apk --release \
    --dart-define=STRAVA_CLIENT_ID=${{ secrets.STRAVA_CLIENT_ID }} \
    --dart-define=STRAVA_CLIENT_SECRET=${{ secrets.STRAVA_CLIENT_SECRET }}
```

Add `STRAVA_CLIENT_ID`/`STRAVA_CLIENT_SECRET` as repository (or
environment-scoped) secrets in GitHub before wiring this into the release
workflow (P9). CI's `analyze`/`test`/debug-build jobs never need real
credentials — they exercise the "plugin absent" path, which is exactly
what public contributors get too.

## Adding a new credentialed service

1. Add a `String.fromEnvironment('<SERVICE>_CLIENT_ID')`-style read in
   `_registerPlugins`, gated the same way as Strava.
2. Document the two new `--dart-define` keys here.
3. Add the corresponding secrets to GitHub Actions once a release workflow
   needs them.

This mechanism is only for OAuth client credentials that are safe to ship
inside the compiled app binary (they identify the app, not a user) but
shouldn't be searchable in the public repo's history. User-specific
services with no public API surface at all (Records, OpenCoach) don't use
this path — see `docs/release/private-plugins.md`.
