---
phase: P2
title: Connectivity — multi-sensor pairing, background recording, Windows BLE
status: NOT_STARTED
depends_on: [P1]
validation:
  - flutter analyze
  - flutter test
---

# P2 — Connectivity hardening

## Context

The FTMS trainer path is production-quality, but a serious training app pairs **multiple
devices at once with distinct roles**: a smart trainer (FTMS) *plus* a dedicated HR strap
*plus* optionally a crank power meter or cadence sensor, with per-role priority when
sources overlap. The pieces exist — `SensorDevicePlugin`
(`lib/infrastructure/ble/sensors/sensor_device_plugin.dart`) and `SensorFusion`
(`sensor_fusion.dart`) — but the sensor plugin is never registered and the scan UI is a
flat single-connection list. Recording also dies when the app is backgrounded, and
Windows has no BLE backend at all ("PC" is a first-class target).

## Tasks

### 1. Register and route standalone sensors
- [ ] Register `SensorDevicePlugin` in `main.dart` `_registerPlugins` alongside
      `FtmsDevicePlugin`. Order matters in `PluginRegistry.getPluginForDevice` (first
      `canHandle` wins) — FTMS plugin must keep claiming FTMS devices; the sensor plugin
      handles HR-only / power-only / CSC-only peripherals.
- [ ] `BleTransport` currently assumes a **single active connection** — extend it to
      hold concurrent connections keyed by device id (scan logic and backoff reconnect
      stay shared). Preserve the existing single-connection API used by
      `FtmsDevicePlugin` or migrate callers.
      **Accept:** unit tests for multi-connection lifecycle in
      `test/infrastructure/ble/ble_transport_test.dart` (connect trainer + HRM simultaneously,
      independent disconnect/reconnect).

### 2. Per-role pairing slots
- [ ] Introduce `SensorRole { trainer, heartRate, power, cadenceSpeed }` in the domain
      and a `PairedDevices` model: role → saved device id (extend
      `AppPreferences.savedDeviceIds` in
      `lib/infrastructure/preferences/app_preferences.dart` to a role-keyed map with
      migration from the flat list).
- [ ] Wire `SensorFusion` priorities per role: dedicated HR strap > FTMS-embedded HR;
      crank power meter > trainer power only if user assigns it as the power source.
- [ ] Rework `device_scan_screen.dart` into a device-management screen: role slots at
      top (tap to assign from scan results), scan list below with protocol badges
      (already exist), per-device forget/rename. Auto-reconnect on app start per saved
      role (extends existing saved-device logic + `ConnectionMonitor`).
      **Accept:** widget tests: assign HRM to heartRate slot, readings from that device
      win fusion; forget clears slot; state survives restart (prefs round-trip test).

### 3. In-ride connection UX
- [ ] Ride-screen banner (in `ride_screen.dart`) driven by `TrainerEvent.disconnected` /
      `ConnectionMonitor` state: "Trainer connection lost — reconnecting…" with per-role
      granularity, auto-dismiss on reconnect. Show sensor status dots (trainer/HR/power)
      in `RideHeaderBar`.
      **Accept:** widget test firing `TrainerEvent.disconnected` on the `EventBus` shows
      the banner; `connected` hides it.

### 4. Background recording
- [ ] Android: foreground service via `flutter_foreground_task` (add dependency) started
      when `RecordingEngine` starts and stopped on stop — notification shows elapsed
      time + current power. Add `FOREGROUND_SERVICE` +
      `FOREGROUND_SERVICE_CONNECTED_DEVICE` permissions and service declaration to the
      manifest (P1 deliberately left these to this phase).
- [ ] iOS: verify `bluetooth-central` background mode (added in P1) keeps
      `RecordingEngine` sampling while backgrounded; document limitations.
- [ ] Keep `WakelockPlus` behavior on the ride screen as-is for foreground use.
      **Accept:** `[HW]` 30-min ride with screen off / app backgrounded on Android and
      iOS has no gaps > 2 s in `SensorReadings` timestamps. Unit-testable part: service
      lifecycle bound to `RecordingState` transitions.

### 5. Windows BLE backend (macOS already works)
- [ ] Behind the existing `BleTransport` abstraction, adopt
      [`flutter_blue_plus_windows`](https://pub.dev/packages/flutter_blue_plus_windows)
      (drop-in API over flutter_blue_plus). If it proves unmaintained/broken during
      execution, fall back to [`universal_ble`](https://pub.dev/packages/universal_ble)
      with a thin adapter implementing the same surface `BleTransport` consumes.
- [ ] Gate by platform in one place (conditional import or runtime switch in
      `BleTransport`); no other file should know which backend is active.
- [ ] Linux: best-effort — if the chosen package supports BlueZ, enable it; otherwise
      leave a stub that reports "BLE unavailable" gracefully in the scan UI (no crash).
      **Accept:** `flutter build windows` green; scan screen on Windows shows adapter-on
      state; `[HW]` real scan+connect on a Windows machine with BLE radio.

### 6. ANT+ note
ANT+ FE-C is fully coded but needs a USB backend — that is deliberately a **stretch task
in P8**, not here. Do not start it in this phase.

## Validation

```bash
flutter analyze && flutter test
```
CI green (all platform builds). Integration tests
(`integration_test/scan_connect_ride_test.dart`) still pass with the simulator plugin.

### Pending hardware QA `[HW]`
- Trainer (FTMS) + HR strap paired simultaneously; HR strap wins HR fusion.
- ERG target power and SIM grade verified against a real trainer (Wahoo/Elite/Tacx).
- Background recording soak test (Android + iOS, 30 min).
- Windows: scan/connect/ride with a BLE dongle or built-in radio.

## Definition of done
Frontmatter `status: DONE`, checkboxes ticked, CI green, README status board updated,
hardware QA matrix recorded for a human tester.
