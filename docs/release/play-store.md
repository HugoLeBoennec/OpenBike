# Google Play Store listing

## App identity

- Package name: `run.records.openbike` (`android/app/build.gradle.kts`) —
  permanent once the first bundle is uploaded to Play; it can never be
  changed for this listing.
- `compileSdk 36`, `targetSdk 36`, `minSdk` inherited from
  `flutter.minSdkVersion` (24 / Android 7.0+ on Flutter 3.41).
- **Play target-API deadline: 2026-08-31.** From that date new apps *and*
  updates must target API 36 or Play Console rejects the upload; an
  extension to 2026-11-01 can be requested. `targetSdk` is already 36, so
  this is satisfied — bump it again each year Play raises the bar (usually
  alongside a Flutter SDK bump in `.github/workflows/ci.yml`'s
  `FLUTTER_VERSION`). See
  <https://support.google.com/googleplay/android-developer/answer/11926878>.
- Category: **Health & Fitness** (or **Sports**, whichever a maintainer
  prefers at listing time — both fit).

## Data Safety form

Answer the Play Console Data Safety questionnaire based on
`docs/privacy-policy.md`. Key answers:

- **Location**: not collected. The app never requests location permission,
  never uses GPS, and does not track live position — routes come from GPX
  files the user imports. Bluetooth scanning uses the `neverForLocation`
  flag (`android/app/src/main/AndroidManifest.xml`), so Android itself
  doesn't treat this app's BLE usage as location access.

  One nuance to answer knowingly rather than reflexively: rendering a route
  map fetches tiles from `tile.openstreetmap.org`, which reveals the map
  area on screen (plus the IP, as with any request) to the OpenStreetMap
  Foundation. That area reflects an imported route, not a device position,
  and no ride data accompanies it — which is why "not collected" is the
  defensible answer here. It is disclosed in `docs/privacy-policy.md`
  under "Maps" regardless, because the store form is a floor, not a
  ceiling. If the app ever gains live GPS tracking, this answer changes.

- **Encrypted in transit**: yes. Every remote endpoint is HTTPS (Strava
  API/OAuth, OpenStreetMap tiles, Sentry). There are no cleartext requests,
  no `usesCleartextTraffic`, and no ATS exceptions. Use the `https://`
  Sentry DSN if crash reporting is configured.
- **Health & fitness data** (heart rate, power, workout history): collected,
  but stored only on-device (SQLite) — not shared with any third party
  unless the user explicitly connects and uploads to Strava (or a future
  export integration). Declare it "collected, not shared" with an exception
  noted for the opt-in Strava export path ("shared only with user's
  explicit action").
- **App activity / crash logs**: collected only if the user opts in to
  crash reporting (Settings → About), and declared as "optional, user
  controlled". No analytics/advertising data collected.
- **Data deletion**: uninstalling the app deletes all local data; Strava
  disconnect (Settings → Connections) revokes the stored token.

## Foreground service declaration

OpenBike declares `FOREGROUND_SERVICE` +
`FOREGROUND_SERVICE_CONNECTED_DEVICE` (see
`android/app/src/main/AndroidManifest.xml`, wired to
`flutter_foreground_task` — see `docs/roadmap/P2-connectivity.md`) to keep
BLE sensor recording alive with the screen off. Play's foreground service
policy requires a plain-language justification at submission time:

> "OpenBike runs a foreground service during an active ride recording to
> maintain a continuous Bluetooth connection to the user's smart trainer,
> heart rate monitor, and other cycling sensors, so recording continues
> uninterrupted when the screen is off or the app is backgrounded. The
> service only runs while a ride is being recorded and stops immediately
> when the ride ends."

## Content rating

Fitness/utility app, no user-generated content, no ads, no in-app
purchases at v1.0 (see `docs/roadmap/P10-monetization-optional.md` for the
optional future path) → expect the lowest content rating tier (e.g. PEGI 3
/ Everyone) from the standard IARC questionnaire.

## Permissions declared

| Permission | Why |
|---|---|
| `BLUETOOTH_SCAN` (`neverForLocation`), `BLUETOOTH_CONNECT` | Connect to trainer/sensors |
| `BLUETOOTH`, `BLUETOOTH_ADMIN`, `ACCESS_FINE_LOCATION` (`maxSdkVersion=30`) | Legacy BLE requirement on Android ≤ 11 only |
| `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_CONNECTED_DEVICE`, `POST_NOTIFICATIONS` | Background ride recording (see above) |
| `INTERNET` | Strava upload, crash reporting (if opted in) |

## Store listing checklist

- [ ] App title, short & full description.
- [ ] Privacy policy URL (`docs/privacy-policy.md`, hosted — see that
      file's hosting note) entered in Play Console.
- [ ] Screenshots/feature graphic — see `docs/release/assets.md`.
- [ ] Data Safety form submitted (above).
- [ ] Content rating questionnaire submitted (above).
- [ ] Internal testing track set up (`docs/release/beta.md`) before any
      production rollout.
