# Apple App Store listing

## App identity

- Bundle ID: `run.records.openbike` (committed in the Xcode project).
- Version: the app reports `1.0.0` (`pubspec.yaml`'s `1.0.0+N`), so the App
  Store Connect version record must be named **1.0.0**, not "1.0".
- URL scheme `openbike://` registered for the Strava OAuth callback
  (`ios/Runner/Info.plist`'s `CFBundleURLTypes`, see
  `docs/roadmap/P6-integrations.md`).
- Category: **Health & Fitness** (or **Sports**).

## Privacy nutrition label

Answer App Store Connect's "App Privacy" questionnaire based on
`docs/privacy-policy.md`. Key answers:

- **Health & Fitness** data (heart rate, power/cadence, workout history):
  collected, but **not linked to identity** and **not used for tracking**
  — it's stored locally and only leaves the device if the user explicitly
  connects and uploads to Strava. Declare the Strava export path as "used
  for App Functionality" (user-initiated export), not analytics.
- **Diagnostics → Crash Data**: collected only if the user opts in
  (Settings → About → Crash reporting, off by default) — "used for App
  Functionality", not linked to identity, not used for tracking. Sentry is
  never initialised for opted-out users, and for opted-in users it runs
  Dart-side only, with no user ID and no device hash on any event (see
  `docs/release/analytics.md`). Don't declare Device ID. If the native
  crash handler is ever re-enabled, add Identifiers → Device ID (not linked,
  App Functionality) and update the privacy policy.
- **Network request not covered by a data type:** route maps fetch tiles
  from `tile.openstreetmap.org` (the requester's IP and the map area leave
  the device). Off by default; the user turns the map on in the ride's route pane; see
  `lib/presentation/widgets/route_mini_map.dart` and the default in
  `lib/presentation/state/providers.dart`. No ride data is included.
- **Identifiers / Location / Contact Info / Usage Data**: none collected.
  No `NSLocationWhenInUseUsageDescription` or any location entitlement is
  present in `ios/Runner/Info.plist` — OpenBike never requests location.
- **Data not collected for tracking**: OpenBike doesn't use IDFA and has no
  App Tracking Transparency prompt because it does no cross-app tracking.

## Bluetooth purpose strings (already in place)

`ios/Runner/Info.plist` sets both:

- `NSBluetoothAlwaysUsageDescription`
- `NSBluetoothPeripheralUsageDescription`

> "OpenBike uses Bluetooth to connect to your smart trainer, heart rate
> monitor, and cycling sensors."

Review this string reads naturally in the review build's actual usage
flow (device scan screen) before submitting — Apple rejects purpose
strings that don't match observed behavior.

`NSPhotoLibraryUsageDescription` and `NSAppleMusicUsageDescription` are also
set, but never prompted: file_picker's Swift package always links its photo
and music pickers, and App Store Connect rejects an upload (ITMS-90683) that
links those APIs without purpose strings.

The Bluetooth prompt itself depends on `PERMISSION_BLUETOOTH=1` in
`ios/Podfile`'s `post_install` — without it permission_handler reports
Bluetooth as permanently denied and scanning never starts.

## Background modes (already in place)

`UIBackgroundModes` includes `bluetooth-central` (background BLE recording
— see `docs/roadmap/P2-connectivity.md`). Known iOS limitation to note in
review notes if asked: force-quitting the app from the app switcher stops
recording immediately (no independent OS-level background task, unlike
Android's foreground service) — this is expected `bluetooth-central`
behavior, not a bug.

## App Review notes to prepare

- A demo account/flow isn't needed (no login), but reviewers may not own a
  BLE trainer — mention the `DEV_MODE` physics-backed simulator
  (`lib/infrastructure/simulator/`) exists for internal testing but is not
  present in release builds (gated on `--dart-define=DEV_MODE`, off by
  default) so reviewers should not expect a simulator toggle in the
  shipped app; describe the expected real-hardware pairing flow instead.
- Note that Strava connection is optional and the app is fully functional
  without it.

## Store listing checklist

- [ ] App name, subtitle, description, keywords.
- [ ] Privacy policy URL (`docs/privacy-policy.md`, hosted) entered in App
      Store Connect.
- [ ] Screenshots (all required device sizes) — see `docs/release/assets.md`.
- [ ] App Privacy questionnaire submitted (above).
- [ ] TestFlight build uploaded and internal testers invited
      (`docs/release/beta.md`) before submitting for external review.

## Microsoft Store (Windows)

Moved to `docs/release/desktop-distribution.md`, which also covers Linux.

Note the assumption that used to live here — "a signed `.msix` attached
directly to GitHub Releases" — was wrong: the release workflow has no
code-signing certificate configured, so `msix:create` self-signs with a
generated test certificate, and Windows will not install an MSIX signed by an
untrusted certificate. That artifact is sideload-only. See
`docs/release/desktop-distribution.md` for the actual options (the Microsoft
Store is now free for individual *and* company accounts, and signs the package
for you).

## macOS (Mac App Store)

- Category: `LSApplicationCategoryType` is
  `public.app-category.healthcare-fitness` in `macos/Runner/Info.plist`
  (App Store Connect rejects Mac uploads without it, ITMS-90242).
- Export compliance: `ITSAppUsesNonExemptEncryption` is `false` there too,
  for the same reasons as iOS.
- Sandbox entitlements (`macos/Runner/Release.entitlements`): app sandbox,
  `network.client`, `network.server` (the Strava sign-in listens on a
  loopback port to catch the OAuth redirect), `files.user-selected.read-write`,
  `device.bluetooth`, `device.usb` (ANT+ dongle).
- Privacy manifest: `macos/Runner/PrivacyInfo.xcprivacy`, same content as
  `ios/Runner/PrivacyInfo.xcprivacy` (declares required-reason APIs used by
  SQLite and the plugins, plus opt-in crash data).
