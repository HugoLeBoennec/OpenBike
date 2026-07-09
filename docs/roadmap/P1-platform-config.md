---
phase: P1
title: Platform config — permissions, signing, deep links, branding
status: IN_PROGRESS
depends_on: [P0]
validation:
  - flutter analyze
  - flutter test
---

# P1 — Platform configuration

## Context

The single biggest shippability blocker: **the Android manifest declares no permissions
at all** and **iOS has no Bluetooth usage descriptions**, so BLE fails/crashes on real
devices and both stores would reject the app. This phase makes every target platform's
native configuration correct and consistent. `BlePermissionHandler`
(`lib/infrastructure/ble/ble_permission_handler.dart`) already requests the right
runtime permissions — the manifests just never declared them.

## Tasks

### 1. Android (`android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts`)
- [x] Declare permissions:
      ```xml
      <uses-permission android:name="android.permission.BLUETOOTH_SCAN"
                       android:usesPermissionFlags="neverForLocation" />
      <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
      <!-- Legacy (API <= 30) -->
      <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
      <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
      <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30" />
      <uses-feature android:name="android.hardware.bluetooth_le" android:required="true" />
      <uses-permission android:name="android.permission.INTERNET" />
      ```
      (Foreground-service permissions are added in P2 with the service itself.)
- [x] App label → `OpenBike` (currently lowercase `open_bike`).
- [x] Pin `minSdkVersion 23` and set explicit `targetSdkVersion`/`compileSdkVersion`
      meeting current Play requirements (API 34+), instead of `flutter.minSdkVersion`.
- [x] Release signing: keystore loaded from `android/key.properties` (gitignored) with
      graceful fallback to debug signing when absent; document keystore generation in
      `docs/release/android-signing.md`.
      **Accept:** `flutter build apk --debug` passes in CI; manifest contains the
      permissions above.

### 2. iOS (`ios/Runner/Info.plist`)
- [x] Add `NSBluetoothAlwaysUsageDescription` (+ `NSBluetoothPeripheralUsageDescription`
      for older iOS): "OpenBike uses Bluetooth to connect to your smart trainer, heart
      rate monitor, and cycling sensors."
- [x] Add `UIBackgroundModes` → `bluetooth-central` (keeps sensor data flowing when
      backgrounded; recording behavior itself is P2).
- [x] Display name `OpenBike`; set `CFBundleShortVersionString`/build from pubspec as
      usual; minimum iOS 13.0 in the Podfile/project if not already.
      **Accept:** `flutter build ios --no-codesign` passes in CI; plist contains the keys.

### 3. Deep links for OAuth (`openbike://` — constant renamed in P0)
- [x] Android: `intent-filter` with `android:scheme="openbike"` on MainActivity.
- [x] iOS: `CFBundleURLTypes` with scheme `openbike`.
- [x] macOS: `CFBundleURLTypes` in `macos/Runner/Info.plist` (desktop OAuth may instead
      use loopback redirect — P6 decides; register the scheme anyway, it is harmless).
      **Accept:** schemes present in all three files. (End-to-end callback handling is
      wired in P6.)

### 4. macOS / Windows / Linux hygiene
- [x] `macos/Runner/Info.plist`: fix `NSBluetoothAlwaysUsageDescription` — it currently
      says "**PedalHub** needs Bluetooth…" → OpenBike wording. Verify entitlements keep
      `com.apple.security.device.bluetooth` (already present in both
      `DebugProfile.entitlements` and `Release.entitlements`).
- [x] Windows/Linux: set window title and executable/app name to `OpenBike` in
      `windows/runner/main.cpp` and `linux/my_application.cc` if they still say
      `open_bike`.
- [x] Add `windows` (and optionally `macos` review) targets to
      `flutter_launcher_icons.yaml` and regenerate icons
      (`dart run flutter_launcher_icons`). Source assets exist at `assets/icon/`.
      **Accept:** all desktop builds pass in CI; `grep -ri pedalhub .` (excluding
      `docs/`) returns nothing anywhere in the repo.

## Validation

```bash
flutter analyze && flutter test
grep -ri pedalhub --include="*.plist" --include="*.xml" --include="*.cc" --include="*.cpp" . # empty
grep -c "BLUETOOTH_SCAN" android/app/src/main/AndroidManifest.xml   # >= 1
grep -c "NSBluetoothAlwaysUsageDescription" ios/Runner/Info.plist   # >= 1
```

CI green including `build-android`, `build-ios`, `build-macos`, `build-windows`.

### Pending hardware QA `[HW]`
- Fresh install on a physical Android 12+ device: permission prompts appear, scan finds a
  real trainer/HRM.
- Fresh install on a physical iPhone: Bluetooth permission prompt appears with the usage
  string, scan works.

## Definition of done
Frontmatter `status: DONE`, checkboxes ticked, CI green, README status board updated,
hardware QA items recorded above for a human tester.
