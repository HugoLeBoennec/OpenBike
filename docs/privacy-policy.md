# OpenBike Privacy Policy

_Last updated: 2026-07-10_

OpenBike is a local-first indoor cycling app. This policy describes what
data the app collects, where it lives, and what — if anything — ever
leaves your device.

## Summary

- **Your ride, workout, and profile data stays on your device** in a local
  SQLite database. OpenBike has no backend server and no account system.
- **No ride data is uploaded unless you explicitly connect a third-party
  service** (e.g. Strava) and choose to export a ride to it.
- The one automatic exception is **map tiles**: viewing a route map fetches
  map images from OpenStreetMap, which necessarily reveals the map area
  you're viewing. See "Maps" below.
- **Crash reporting is off by default** and, if you opt in, never includes
  ride data, location, or personal information.
- OpenBike does not use analytics, advertising SDKs, or any form of
  behavioral tracking.

## Data collected and where it lives

| Data | Stored where | Leaves the device? |
|---|---|---|
| Profile (FTP, weight, height, resting/max HR) | Local SQLite (`AppDatabase`) | No |
| Rides, workouts, personal records | Local SQLite | No |
| Paired device IDs, app settings | Local device preferences | No |
| Bluetooth sensor data (power, cadence, heart rate, speed) | Processed in memory, persisted locally as part of a ride recording | No |
| Strava OAuth token (if connected) | Device secure storage (`flutter_secure_storage` — OS keychain/keystore) | Sent to Strava's API only when you upload a ride or disconnect |
| Crash reports (if opted in) | N/A — sent directly to Sentry | Stack traces and basic app/OS version only; see below |
| Map tile requests (when a route map is on screen) | Not stored | Map area being viewed + your IP go to OpenStreetMap; see "Maps" |

## Bluetooth

OpenBike uses Bluetooth Low Energy to connect to your smart trainer, heart
rate monitor, and other cycling sensors. On Android this is requested with
the `neverForLocation` flag, meaning the app does not use Bluetooth
scanning to determine your location, and doesn't request location
permission on Android 12+. OpenBike does not use GPS location at all —
"routes" are simulated from imported GPX files, not tracked live.

## Third-party integrations (opt-in only)

Connecting Strava (or any future export integration) is entirely optional
and initiated by you in Settings → Connections. OpenBike only sends data
to that service when you tap "upload" (or enable auto-upload) for a
specific ride. Disconnecting revokes and deletes the locally stored token.
See each service's own privacy policy for how they handle data you send
them (e.g. [Strava's privacy policy](https://www.strava.com/legal/privacy)).

## Maps

When a screen shows a route on a map, OpenBike downloads map tile images
from the OpenStreetMap Foundation's public tile servers
(`tile.openstreetmap.org`). Those requests necessarily tell OpenStreetMap
which map area is being displayed — which corresponds to the area of the
route you're viewing — along with your IP address, as with any web request.

This is the only network request the app makes without you asking for it,
and it happens only while a map is actually on screen. No ride data,
timing, power or heart-rate information is included. See the
[OpenStreetMap Foundation privacy policy](https://osmfoundation.org/wiki/Privacy_Policy).

Note that OpenBike does not use GPS or track your live location at all —
routes come from GPX files you import.

## Crash reporting (opt-in, default off)

See `docs/release/analytics.md` for the full technical design. In short:

- Off by default; you're asked once after onboarding and can change this
  anytime in Settings → About → Crash reporting.
- When on, crash/error reports (stack traces, app version, OS version) are
  sent to Sentry. Ride data, breadcrumbs, and any user-identifying context
  are stripped before an event is sent.
- When off (the default), or when a build has no crash-reporting DSN
  configured at all, the app never contacts Sentry.

## No analytics, no ads

OpenBike has no event tracking, no usage funnels, and no advertising or
tracking SDKs of any kind. See `docs/release/analytics.md` for the
decision record.

## Data deletion

Uninstalling the app deletes all locally stored data (profile, rides,
workouts, settings). If you connected Strava, disconnecting in
Settings → Connections revokes the token before uninstalling; Strava
retains whatever activities you previously uploaded to it independently of
OpenBike, per Strava's own retention policy.

## Children's privacy

OpenBike is not directed at children and does not knowingly collect data
from children.

## Changes to this policy

Material changes will be noted in `CHANGELOG.md` and reflected here with an
updated "Last updated" date.

## Contact

Open an issue on the [OpenBike GitHub repository](https://github.com/HugoLeBoennec/OpenBike).

---

**Hosting note (maintainer).** Both stores require this policy at a stable,
publicly reachable URL — no login, no redirect wall — and Play will reject
the listing without one. The plan is to serve it from `records.run`
alongside the download page.

Whichever host you use, do this before submitting:

1. Publish this document at a permanent path, e.g.
   `https://records.run/openbike/privacy`. Avoid a URL that encodes a
   version or date; the same link has to keep working for the life of the
   listing.
2. Record that URL in `docs/release/play-store.md` and
   `docs/release/app-store.md`, replacing the placeholders there.
3. Apple additionally requires a **Support URL** in App Store Connect —
   `https://records.run/openbike/support` or equivalent. Plan for it now
   even though only Play is in scope for the first release.

GitHub Pages (Settings → Pages → serve `/docs`) works as a fallback and
costs nothing, but note it would serve this file's raw Markdown filename
under a `github.io` domain unless configured with a custom domain.
