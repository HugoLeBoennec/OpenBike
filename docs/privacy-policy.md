# OpenBike Privacy Policy

_Last updated: 2026-07-10_

OpenBike is a local-first indoor cycling app. This policy describes what
data the app collects, where it lives, and what — if anything — ever
leaves your device.

## Summary

- **Your ride, workout, and profile data stays on your device** in a local
  SQLite database. OpenBike has no backend server and no account system.
- **Nothing is uploaded unless you explicitly connect a third-party
  service** (e.g. Strava) and choose to export a ride to it.
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

**Hosting note (maintainer TODO):** both app stores require this policy at
a stable, publicly reachable URL. The simplest option is GitHub Pages
(Settings → Pages → serve `/docs`) pointing at this file, or any static
host — publish it and record the final URL in `docs/release/play-store.md`
and `docs/release/app-store.md` before submitting either listing.
