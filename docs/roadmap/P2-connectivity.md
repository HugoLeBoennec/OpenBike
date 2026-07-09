---
phase: P2
title: Connectivity — multi-sensor pairing, background recording, Windows BLE
status: DONE
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
- [x] Register `SensorDevicePlugin` in `main.dart` `_registerPlugins` alongside
      `FtmsDevicePlugin`. Order matters in `PluginRegistry.getPluginForDevice` (first
      `canHandle` wins) — FTMS plugin must keep claiming FTMS devices; the sensor plugin
      handles HR-only / power-only / CSC-only peripherals. Also added
      `DeviceProtocol.bleHr` (HR straps were previously misclassified as `blePower`).
- [x] `BleTransport` currently assumes a **single active connection** — extend it to
      hold concurrent connections keyed by device id (scan logic and backoff reconnect
      stay shared). Preserve the existing single-connection API used by
      `FtmsDevicePlugin` or migrate callers.
      **Accept:** unit tests for multi-connection lifecycle in
      `test/infrastructure/ble/ble_transport_test.dart` (connect trainer + HRM simultaneously,
      independent disconnect/reconnect). ✅ 8 new tests via an injectable connection
      factory + backoff calculator seam.

### 2. Per-role pairing slots
- [x] Introduce `SensorRole { trainer, heartRate, power, cadenceSpeed }` in the domain
      and a `PairedDevices` model: role → saved device id (extend
      `AppPreferences.savedDeviceIds` in
      `lib/infrastructure/preferences/app_preferences.dart` to a role-keyed map with
      migration from the flat list). Implemented in
      `lib/core/domain/entities/paired_devices.dart` +
      `AppPreferences.pairedDevices`/`setPairedDevices`.
- [x] Wire `SensorFusion` priorities per role: dedicated HR strap > FTMS-embedded HR;
      crank power meter > trainer power only if user assigns it as the power source.
      Implemented as `DevicePairingService` (trainer role = `SensorPriority.normal`,
      every other role = `.high`).
- [x] Rework `device_scan_screen.dart` into a device-management screen: role slots at
      top (tap to assign from scan results), scan list below with protocol badges
      (already exist), per-device forget/rename. Auto-reconnect on app start per saved
      role (extends existing saved-device logic + `ConnectionMonitor`). Auto-reconnect
      implemented as `autoReconnectPairedRolesProvider`, watched once from `HomeScreen`.
      **Accept:** widget tests: assign HRM to heartRate slot, readings from that device
      win fusion; forget clears slot; state survives restart (prefs round-trip test). ✅

### 3. In-ride connection UX
- [x] Ride-screen banner (in `ride_screen.dart`) driven by `TrainerEvent.disconnected` /
      `ConnectionMonitor` state: "Trainer connection lost — reconnecting…" with per-role
      granularity, auto-dismiss on reconnect. Show sensor status dots (trainer/HR/power)
      in `RideHeaderBar`. Implemented as `roleConnectionStatusProvider` +
      `ConnectionBanner` + `_SensorStatusDots`.
      **Accept:** widget test firing `TrainerEvent.disconnected` on the `EventBus` shows
      the banner; `connected` hides it. ✅

### 4. Background recording
- [x] Android: foreground service via `flutter_foreground_task` (add dependency) started
      when `RecordingEngine` starts and stopped on stop — notification shows elapsed
      time + current power. Add `FOREGROUND_SERVICE` +
      `FOREGROUND_SERVICE_CONNECTED_DEVICE` permissions and service declaration to the
      manifest (P1 deliberately left these to this phase). Implemented as
      `BackgroundRecordingService` + `ForegroundServiceController` seam
      (`FlutterForegroundTaskController` on Android, no-op elsewhere).
- [x] iOS: verify `bluetooth-central` background mode (added in P1) keeps
      `RecordingEngine` sampling while backgrounded; document limitations. Reasoning
      (not device-verified — see Pending hardware QA): the background mode keeps the
      whole process alive, not just BLE I/O, so `RecordingEngine`'s plain
      `Timer.periodic` keeps ticking normally — the same process, same isolate, same
      timers as foreground. Known iOS limitation: if the user force-quits the app from
      the app switcher, recording stops immediately (no independent OS-level background
      task), unlike Android's foreground service.
- [x] Keep `WakelockPlus` behavior on the ride screen as-is for foreground use.
      **Accept:** `[HW]` 30-min ride with screen off / app backgrounded on Android and
      iOS has no gaps > 2 s in `SensorReadings` timestamps. Unit-testable part: service
      lifecycle bound to `RecordingState` transitions. ✅ 9 tests covering
      start-on-recording/stop-on-idle/stays-running-through-pause/dispose.

### 5. Windows BLE backend (macOS already works)
- [x] Behind the existing `BleTransport` abstraction, adopt
      [`flutter_blue_plus_windows`](https://pub.dev/packages/flutter_blue_plus_windows)
      (drop-in API over flutter_blue_plus). If it proves unmaintained/broken during
      execution, fall back to [`universal_ble`](https://pub.dev/packages/universal_ble)
      with a thin adapter implementing the same surface `BleTransport` consumes.
      **Deviation:** `flutter_blue_plus_windows` is confirmed incompatible — it pins
      `flutter_blue_plus <1.35.0`, conflicting with our `^1.36.8`. Rather than bolting on
      `universal_ble` (a different plugin with its own UUID/connection model, requiring
      a real abstraction rewrite of `BleConnection`/`BleTransport` — exactly the "DO NOT
      REBUILD" BLE stack), upgraded `flutter_blue_plus` itself: `1.36.8` → `2.3.10`, which
      added native Windows (`flutter_blue_plus_winrt`) and Linux (`flutter_blue_plus_linux`,
      BlueZ via pure Dart) platform backends as federated dependencies. Confirmed via
      `.flutter-plugins-dependencies` / `dart_plugin_registrant.dart` that both resolve
      and register automatically; `windows/flutter/generated_plugins.cmake` now links
      `flutter_blue_plus_winrt`. Only required app-code change: `BleConnection.connect()`
      now passes `license: License.nonprofit` (2.x license requirement — user-approved;
      revisit before any commercial/monetized release, see P10).
- [x] Gate by platform in one place (conditional import or runtime switch in
      `BleTransport`); no other file should know which backend is active. **Satisfied
      trivially** — there is no per-app gating code at all; the single `flutter_blue_plus`
      package dispatches to the right platform implementation internally, so
      `BleTransport`/`BleConnection` are completely unchanged for this.
- [x] Linux: best-effort — if the chosen package supports BlueZ, enable it; otherwise
      leave a stub that reports "BLE unavailable" gracefully in the scan UI (no crash).
      `flutter_blue_plus_linux` supports BlueZ natively (no stub needed); on any platform
      where the adapter isn't available/on, `BlePermissionHandler._ensureBluetoothOn()`
      already surfaces a friendly `lastScanError` in the scan screen (no crash) —
      pre-existing, platform-agnostic behavior that now also covers Windows/Linux for free.
      **Accept:** `flutter build windows` green; scan screen on Windows shows adapter-on
      state; `[HW]` real scan+connect on a Windows machine with BLE radio. `flutter
      analyze`/`flutter test` are green in this sandbox (no Windows/Linux/Android
      toolchain available here to run the native builds — see Pending hardware QA).

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
- Trainer (FTMS) + HR strap paired simultaneously; HR strap wins HR fusion (logic unit-
  tested with fakes in `device_pairing_service_test.dart` and
  `device_scan_screen_test.dart`; needs a real trainer + HR strap).
- ERG target power and SIM grade verified against a real trainer (Wahoo/Elite/Tacx).
- Background recording soak test (Android + iOS, 30 min, screen off / app backgrounded) —
  confirm no gaps > 2 s in `SensorReadings` timestamps and that the Android notification
  updates correctly.
- Windows: `flutter build windows`, scan screen shows adapter-on state, real scan+connect
  with a BLE dongle or built-in radio.
- Linux: `flutter build linux` (this session installed the CI-required
  `libgtk-3-dev`/`libsecret-1-dev`/`libjsoncpp-dev` locally and got past plugin
  resolution, but a full build wasn't completed in this sandbox — no outbound access to
  fetch the vendored sqlite3 source during CMake configure). Real scan+connect on a Linux
  machine with a BlueZ-capable adapter.
- This session had no Android SDK / Windows / macOS / Linux GUI toolchain available to
  run `flutter build apk|windows|macos|linux`, so those CI jobs are the first real
  confirmation this phase's dependency/manifest changes build cleanly end-to-end —
  watch them on push.

## Definition of done
Frontmatter `status: DONE`, checkboxes ticked, CI green, README status board updated,
hardware QA matrix recorded for a human tester.
