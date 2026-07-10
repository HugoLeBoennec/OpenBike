# Google Play Store listing

## App identity

- Package name: `com.openbike.open_bike` (`android/app/build.gradle.kts`)
- `compileSdk 36`, `targetSdk 35`, `minSdk 23` (Android 6.0+) — targetSdk
  meets Play's "target API level" requirement as of this writing; bump it
  each year Play raises the bar (usually alongside a Flutter SDK bump in
  `.github/workflows/ci.yml`'s `FLUTTER_VERSION`).
- Category: **Health & Fitness** (or **Sports**, whichever a maintainer
  prefers at listing time — both fit).

## Data Safety form

Answer the Play Console Data Safety questionnaire based on
`docs/privacy-policy.md`. Key answers:

- **Location**: not collected. Bluetooth scanning uses the
  `neverForLocation` flag (`android/app/src/main/AndroidManifest.xml`), so
  Android itself doesn't treat this app's BLE usage as location access.
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
