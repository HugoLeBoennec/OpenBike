# Apple App Store listing

## App identity

- Bundle ID: `$(PRODUCT_BUNDLE_IDENTIFIER)` (set per Xcode signing config —
  see `docs/release/checklist.md`/CI secrets, not committed).
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
- **Diagnostics** (crash data): declare as collected only if the user opts
  in (Settings → About → Crash reporting, off by default) — "used for App
  Functionality", not linked to identity, not used for tracking.
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
