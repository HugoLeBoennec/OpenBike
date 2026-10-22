# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Manual trainer control (ERG target, resistance level, SIM difficulty)
  available during free rides; TCX file export.
- **Guided FTP test** (`/ftp-test`, reachable from a Home dashboard card):
  explains what FTP is, recommends a protocol (ramp for the first two tests,
  then the 20-minute test), lists preparation guidance, and launches the test
  ride. Results are charted over time, and FTP history now records whether a
  value was measured or typed by hand.
- **FTP retest reminder** — the Home card flags a retest once the interval
  since the last measured test has elapsed. Defaults to six weeks, adjustable
  from four to sixteen in Settings.
- During a workout, the power you ride is drawn over the workout profile;
  route rides show the live power/HR chart under the elevation profile.
- The training calendar shows finished rides on their day, with dots for
  done (green), missed (red) and planned (blue) workouts. Riding a planned
  workout from the library ticks it off.
- An ⓘ on Home and Trends explains CTL (fitness), ATL (fatigue) and TSB
  (form).
- Rides can be deleted from their History page; completed calendar entries
  and FTP test results can be removed (removing the latest test restores the
  FTP before it).
- ERG eases off when your cadence collapses: under 50 rpm for 3 seconds,
  the trainer drops to half the target until you're back above 60 rpm for
  3 seconds, and a banner says why. Works in workouts and manual ERG, and
  makes restarting from a standstill bearable.
- The ramp test ends by itself once you can't hold it (10 seconds under
  60 rpm or under 80% of the target, from the 8th step), or when you tap the
  new **I'm done** button that replaces skip during the ramp. Either drops
  to a new 5-minute cooldown and shows your FTP estimate.

### Changed
- Every ride (workouts, FTP tests, Free Ride and routes) needs a connected
  trainer; without one, the app offers to connect it.
- Skip ends one phase at a time: in an interval set, one effort or one
  recovery rather than the whole set.
- The ride screen shows all 12 data fields when there's room for them (Mac
  windows, iPads), and the live chart labels its FTP line and its power and
  HR lines.
- FTP tests only offer a result once ridden far enough (8 steps of the ramp,
  or the full 20-minute effort), and warn when the result is far below the
  current FTP.
- Pausing during the hard part of an FTP test warns that the rest makes the
  result read high.
- The Garmin Connect export is now called FIT File. File exports open the
  share sheet once saved and are no longer offered for auto-upload.
- Power is written in W everywhere, personal records included.

### Fixed
- The first Bluetooth scan always came back empty; devices now appear on
  the first scan.
- Onboarding shows progress while pairing the trainer and reports
  connection failures instead of silently staying put. When Bluetooth is
  unavailable, onboarding and the Devices screen say why (access denied,
  radio off, unsupported) and offer Open Settings.
- Workouts and routes start the recording with them, instead of running
  while the ride timer sat at zero.
- FIT and TCX exports work offline and on iPad, where the share button did
  nothing.
- Ride distance counts from the start of the ride, not from the trainer's
  own counter; FIT and TCX exports carry the corrected distance.
- The live chart and 3-second power kept going while the app was hidden or
  the screen off, instead of freezing.
- Skipping a workout step moves the timeline and the HUD at once.
- The workout detail chart showed a single bar and step targets read 0% for
  ramps; Share as .zwo failed on phones.
- CTL, ATL and TSB stopped at the last ride's day and only refreshed after
  a restart; they now run to today and update after each ride.
- On Android 12 and newer, Bluetooth was always refused ("OpenBike isn't
  allowed to use Bluetooth") even with Nearby devices allowed, so no
  trainer or sensor could be found or connected.
- Every 30-second auto-save stored all the ride's readings again, so a
  17-minute ride held its first minutes up to 35 times. FIT and TCX exports
  and Strava uploads carried the copies, average power read low, and FTP
  test results read high (the ramp test took a few seconds for its best
  minute). Rides already recorded are cleaned up the first time the app
  opens.
- Rides recorded heart rate for only about half their seconds with an HR
  strap paired, and a paired power meter lost to the trainer's own power
  just as often: the trainer's raw readings reached the recording between
  the merged ones. The recording, route simulation and ERG cadence
  safeguard now all use the merged reading the ride screen shows.
- FIT exports and Strava uploads reported a 200 W FTP whatever yours was,
  so their TSS and IF disagreed with the app's; they now use the FTP the
  ride was scored against.

## [1.0.0] - 2026-07-10

First public release. Built in ten phases (`docs/roadmap/`) from an existing
core (BLE/FTMS trainer control, physics engine, workout/route engines, FIT/TCX
export) up to a store-ready app across iOS, Android, macOS, Windows, and
best-effort Linux.

### Added
- **Connectivity**: Android/iOS Bluetooth permissions and background modes;
  per-role sensor pairing (trainer/HR/power/cadence) via `SensorDevicePlugin`;
  background recording via a foreground service; native Windows BLE backend.
- **Ride experience**: workout HUD, live elevation/route profile
  (`GpxProfileWidget`), reconnect banner, keyboard shortcuts and fullscreen
  toggle on desktop.
- **Workout builder**: a visual step editor, FTP test protocols, and a
  bundled starter workout library, in addition to the existing ZWO/ERG
  import.
- **Training features**: a training calendar, Performance Management Chart
  (CTL/ATL/TSB), and personal records tracking.
- **Integrations**: Strava OAuth connect/upload UI, working GPX export, and
  an open-core plugin seam (`lib/plugins/private_plugins.dart`) for the
  closed-source Records/OpenCoach connections shipped separately.
- **Design system**: light/dark/system theming, accessibility pass, visual
  polish across every screen.
- **Desktop**: macOS DMG and Windows MSIX packaging, remembered window
  bounds, and an ANT+ FE-C stretch implementation (dart:ffi libusb backend;
  ships without a bundled libusb binary — see
  `docs/release/antplus-usb.md`).
- **Release engineering**: Apache-2.0 licensing, opt-in crash reporting
  (`sentry_flutter`, off by default, no PII — see
  `docs/release/analytics.md`), tag-driven release pipeline
  (`.github/workflows/release.yml`), and store-compliance documentation
  (`docs/release/`).

### Fixed
- CI hygiene, correctness fixes, and destructive-migration guards carried
  over from the pre-phase codebase (P0).

[Unreleased]: https://github.com/HugoLeBoennec/OpenBike/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/HugoLeBoennec/OpenBike/releases/tag/v1.0.0
