---
phase: P8
title: Desktop — macOS + Windows first-class, packaging, ANT+ stretch
status: DONE
depends_on: [P2]
validation:
  - flutter analyze
  - flutter test
---

# P8 — Desktop (macOS + Windows first-class, Linux best-effort)

## Context

"PC" is a first-class target: **Windows and macOS at equal priority**, Linux
best-effort. macOS is the easy win — flutter_blue_plus already supports it and the
Bluetooth entitlements are in place; it mainly needs packaging/signing. Windows got its
BLE backend in P2 and needs packaging. The desktop ride layout already exists
(≥1200 px branch in `ride_screen.dart`; `NavigationRail` in `app_shell.dart`).

## Tasks

### 1. Desktop app behavior
- [x] Window management via `window_manager` package: min size (e.g. 1024×700),
      remember size/position, sensible default, app title "OpenBike".
- [x] Keyboard shortcuts on the ride screen (`Shortcuts`/`Actions`): Space =
      start/pause/resume, L = lap, Esc = stop (with the existing confirm dialog),
      F = fullscreen toggle.
- [x] Fullscreen ride mode (hide shell chrome) — ideal for a laptop on the handlebars.
      **Accept:** widget tests for shortcut→intent mapping; manual QA checklist.

### 2. macOS packaging & signing
- [x] Release configuration: Developer ID signing + hardened runtime + notarization
      (document Apple Developer requirements in `docs/release/macos-signing.md`;
      CI job builds unsigned artifact, signing runs with secrets when configured).
- [x] DMG artifact via `create-dmg` (or `appdmg`) in a release CI job (tag-triggered —
      job added here, extended in P9).
- [x] Verify BLE works in release sandbox build (entitlements already present in
      `macos/Runner/Release.entitlements`).
      **Accept:** CI produces a .dmg artifact on tag; `[HW]` install + scan/connect on a
      physical Mac.

### 3. Windows packaging
- [x] MSIX via the `msix` pub package (`msix_config` in pubspec): identity, icons
      (generated in P1), capabilities include `bluetooth`.
- [x] Release CI job step producing the .msix artifact (unsigned/dev-cert for now;
      store-signing decision in P9).
      **Accept:** CI produces .msix artifact; `[HW]` install + scan/connect on a
      physical Windows machine with BLE.

### 4. Linux (best-effort — never blocks)
- [x] If the P2 BLE backend gained BlueZ support: quick QA pass. Either way produce a
      tar.gz bundle artifact from the existing `build-linux` job; skip AppImage/Flatpak
      unless trivial.

### 5. Stretch: ANT+ USB dongle (do not block phase)
The full ANT+ FE-C protocol stack exists (`lib/infrastructure/ant/` — framing, channel
init, FE-C pages, control, `AntFecTrainerAdapter`) and is blocked only on the abstract
`UsbBackend` having no implementation.
- [x] Implement `LibusbBackend` via `dart:ffi` + libusb (or the `quick_usb` package if
      it suffices): open Dynastream USB stick (vendor 0x0FCF), bulk read/write —
      the interface `UsbBackend` expects is defined in
      `lib/infrastructure/ant/ant_usb_transport.dart`.
- [x] Fix the two `// For now` items in `ant_device_plugin.dart` (lines ~75/124):
      real channel-ID request instead of hardcoded `ant_fec_0`/wildcard 0.
- [x] Register `AntDevicePlugin` in `main.dart` on desktop platforms (the commented
      block at `main.dart:82-92`).
- [ ] Bundle/ship libusb per platform (macOS dylib, Windows dll) with license notice.
      Code + bundling steps documented in `docs/release/antplus-usb.md`; the actual
      binary + Xcode/CMake wiring is a follow-up (needs a real sourced binary, not
      something to fabricate here).
      **Accept:** unit tests against a mock `UsbBackend` (protocol tests already exist
      in `test/ant/`); `[HW]` real dongle + trainer session.

## Validation

```bash
flutter analyze && flutter test
```
CI green including `build-macos` and `build-windows`; packaging jobs produce artifacts.

### Pending hardware QA `[HW]`
- macOS: BLE trainer + HRM ride end-to-end on Apple silicon.
- Windows 11: BLE trainer + HRM ride end-to-end.
- (Stretch) Bundle a real libusb binary per platform (see
  `docs/release/antplus-usb.md`) and run an ANT+ dongle session on both.

## Definition of done
Frontmatter `status: DONE`, checkboxes ticked (stretch section may remain unticked
without blocking), CI green, README status board updated.
