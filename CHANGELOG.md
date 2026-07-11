# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Manual trainer control (ERG target, resistance level, SIM difficulty)
  available during free rides; TCX file export.

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
