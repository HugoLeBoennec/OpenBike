# App Store submission — fix plan

Findings from the 2026-10-07 App Store readiness audit, written as tasks
to fix one at a time. Each task stands alone: it says why the change
is needed, where to make it, what "done" means, and how to check it.

T1–T17: every file:line was checked against branch `ftp-test-guidance` at
commit `0c8a98b` (most of these are now done; see the Status column).
T18–T22 were added after the Google Play screenshot run and checked
against `main` at `6a2f5aa`. If a line has moved, search for the quoted
symbol.

---

## Ground rules (read before every task)

1. **One task per session/commit.** Don't fold neighbouring fixes in.
2. **Leave other people's uncommitted work alone.** Run `git status`
   before starting. Anything already modified or untracked that your task
   doesn't need is the owner's. Don't stage it, revert it, or `git
   checkout --`/`git restore` it. If your task has to edit one of those
   files, keep the existing hunks intact. Stage files by name; never use
   `git add -A` or `git add .`.
3. **Flutter isn't on `PATH` in non-interactive shells.** Use
   `export PATH=/Users/hugo/Developer/flutter/bin:$PATH` (Flutter 3.47.4).
4. After every code task, run `flutter analyze` and the tests named in the
   task (or `flutter test` if none are named). Both must pass.
5. After changing a `@freezed` class, run codegen:
   `dart run build_runner build --delete-conflicting-outputs`.
6. **Disk space is tight on this machine** (it has filled up during builds).
   Before any `flutter build`/`flutter run`, run `df -h /`. Don't start an
   iOS, macOS or Android build with less than 6 GB free.
   - The first macOS build downloads about 2 GB of Sentry binaries.
   - An Android screenshot run takes about 4 GB including the emulator.
7. **Check `git diff` after any build.** T5 already ran the one-time macOS
   migration. Flutter can still rewrite tracked Xcode/Pod/Gradle files on
   a build; don't commit such rewrites unless the task is about them (T21
   is).
8. Match the surrounding code: comment density, naming, Riverpod patterns,
   `context.tokens` theming.

---

## Owner decisions needed before starting

Sonnet: if a decision below hasn't been made, use the default and say so
in your summary.

| ID | Question | Options | Default |
|---|---|---|---|
| D1 | App Store Connect version string vs build | (a) Rename the App Store Connect version record to **1.0.0**; no code change. (b) Keep "1.0" and build with `--build-name=1.0`. | (a) |
| D2 | How far to take crash-reporting privacy (T6) | (a) **Dart-only reporting**: turn off Sentry's native crash handler so every event passes through the Dart redaction. (b) Keep native crash reports and disclose "Device ID" in App Privacy. (c) Remove Sentry for v1.0. | (a) |
| D3 | macOS App Store category (T1) | `public.app-category.healthcare-fitness` or `public.app-category.sports` | healthcare-fitness (matches `docs/release/app-store.md`) |
| D4 | Mac App Store upload for v1.0 (T16) | Manual Xcode archive/upload, or a new CI job | Manual. T16 is optional. |
| D5 | Flutter version on CI vs local, before T21 | (a) Move CI from `3.41.x` to the local `3.47.x`, then do the full AGP 9 + built-in Kotlin migration. (b) Keep CI on `3.41.x` and postpone T21 until CI moves; the full migration needs Flutter ≥ 3.47. | (a) |

---

## Task index

Status as of `main` @ `6a2f5aa` (PR #21). Don't redo tasks marked done.

| ID | Title | Kind | Blocks submission? | Status |
|---|---|---|---|---|
| T1 | macOS Info.plist: category + export compliance | Config | **Yes** (ITMS-90242) | Done (`d88f1e8`) |
| T2 | macOS Release entitlements: allow the Strava sign-in server | Config | **Yes** (Strava broken on Mac) | Done (`d88f1e8`) |
| T3 | Add PrivacyInfo.xcprivacy (iOS + macOS) | Config | **Likely** (ITMS-91053) | Done (`d88f1e8`) |
| T4 | Version string alignment (D1) | Config/CI | **Yes** if D1=(b) | No code under D1=(a); owner renames the App Store Connect version to 1.0.0 |
| T5 | macOS signing team + one-time Flutter SPM migration | Config | **Yes** for Mac | Done (`d88f1e8`) |
| T6 | Make crash reporting truly opt-in and anonymous | Code | **Yes** (App Privacy answers are wrong today) | Done (`0a3557f`) |
| T7 | Bring privacy docs in line with T6 and the audit | Docs | Yes (policy must match behaviour) | Done (`c104a66`) |
| T8 | Ride session teardown (workout/route/recording) | Code | Functional bug | Done (`425e6fd`) |
| T9 | ERG status banner shows the manual value during a workout | Code | Visible in hero screenshot | Done (`a58c033`) |
| T10 | iPad/Mac ride screen always uses the phone layout | Code | Visible in iPad/Mac screenshots | Done (`610fede`) |
| T11 | Workout profile chart: ramps invisible, repeats drawn solid | Code | Visible in library/HUD | Done (`cbbd9c4`) |
| T12 | ListTile debug assertion in the workout library | Code | Polish | Done (`14ad033`) |
| T13 | Duplicate drag handles in the workout editor (desktop) | Code | Polish | Done (`14ad033`) |
| T14 | FTP Test page highlights the "Home" tab | Code | Optional polish | Open |
| T15 | Verify Strava token storage on a signed Mac build | Manual check | Verify | Open (manual) |
| T16 | Mac App Store build/upload path | CI/docs | Optional (D4) | Done: manual section in `macos-signing.md` |
| T17 | Retake store screenshots | Assets | After T8–T13 | Done (`559efa3`) |
| T18 | Live ride metrics never update; paused time counted as ride time | Code | **Yes**: wrong numbers in every tablet/desktop ride shot | Open |
| T19 | Ride timer wraps onto two lines on small tablets | Code | Visible in 7" tablet shots | Open |
| T20 | Portrait tablets: ride screen leaves most of the screen empty | Code | Visible in iPad/Android tablet shots | Open |
| T21 | Flutter end-of-support warnings (Gradle/AGP, CocoaPods-only plugins) | Build/CI | Not today; will fail a future Flutter upgrade | Open (needs D5) |
| T22 | Retake the ride screenshots affected by T18–T20 | Assets | After T18–T20 | Open |

Suggested order for what's left: T18 → T19 → T20 → T22 → (T14) → T15 →
T21. T21 is independent: do it after D5, in its own branch, since it touches
CI and the Android build.

---

## T1 — macOS Info.plist: category + export compliance

**Why.** `macos/Runner/Info.plist` has no `LSApplicationCategoryType`, and Mac
App Store Connect rejects the upload for that (ITMS-90242). It also has no
`ITSAppUsesNonExemptEncryption`, so every upload would ask the
export-compliance question. The iOS plist already answers it at
`ios/Runner/Info.plist:38-45`; copy that comment's reasoning.

**Where.** `macos/Runner/Info.plist` (no entries exist yet; add them next to
`LSMinimumSystemVersion`).

**Change.**
```xml
<key>LSApplicationCategoryType</key>
<string>public.app-category.healthcare-fitness</string>   <!-- D3 -->
<!-- Export compliance: same reasoning as ios/Runner/Info.plist — only
     standard HTTPS (Strava, opt-in Sentry) and the OS keychain. -->
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

**Done when.** Both keys exist with the values above, and
`plutil -lint macos/Runner/Info.plist` passes.

**Verify.** `plutil -lint macos/Runner/Info.plist`. A build isn't required.

---

## T2 — macOS Release entitlements: allow the Strava sign-in server

**Why.** On desktop, Strava OAuth catches the redirect with a local
HTTP server:
`lib/infrastructure/oauth/desktop_oauth_loopback_server.dart:24`
(`HttpServer.bind(InternetAddress.loopbackIPv4, 0)`), started from
`lib/presentation/widgets/connections_section.dart:22`. A sandboxed app needs
`com.apple.security.network.server` to listen for connections, even on
loopback. Only `macos/Runner/DebugProfile.entitlements:11` has it, so
Strava works in dev builds and fails in the App Store build.

**Where.** `macos/Runner/Release.entitlements`

**Change.** Add:
```xml
<key>com.apple.security.network.server</key>
<true/>
```

**Done when.** Release and DebugProfile both have `network.server`.
`plutil -lint` passes.

**Verify.** `plutil -lint macos/Runner/Release.entitlements`. The real check
happens in T15.

---

## T3 — Add PrivacyInfo.xcprivacy (iOS + macOS)

**Why.** Neither app target has a privacy manifest. A scan of the last iOS
release build (`build/ios/iphoneos/Runner.app`) found these:

| Binary | Required-reason APIs referenced | Ships its own manifest? |
|---|---|---|
| `Frameworks/CSQLite.framework` | `stat`, `fstat`, `lstat` (file timestamp), `statfs` (disk space) | **No** |
| `Frameworks/flutter_foreground_task.framework` | `NSUserDefaults` | **No** |
| `Runner` (statically links SPM plugin code) | `NSUserDefaults`, `stat`, `fstat`, `systemUptime` | partly (via plugin bundles) |

Uploads containing required-reason APIs without a declared reason get
ITMS-91053. The app-level manifest covers the gaps. Apple enforces this for
iOS/iPadOS uploads; add the same file on macOS for consistency.

You can re-run the scan yourself:
```bash
A=build/ios/iphoneos/Runner.app
for b in $A/Runner $A/Frameworks/*.framework/*; do
  file "$b" | grep -q Mach-O || continue
  echo "$(basename "$b"): $(nm -u "$b" 2>/dev/null | grep -oE '_(stat|fstat|lstat|statfs|statvfs|mach_absolute_time)$|NSUserDefaults' | sort -u | tr '\n' ' ')"
done
```

**Where.** New files `ios/Runner/PrivacyInfo.xcprivacy` and
`macos/Runner/PrivacyInfo.xcprivacy`. Each also has to be registered in its
Xcode project (see below), or it won't be copied into the bundle.

**Content (same for both).** If D2 = (c) (Sentry removed), drop the
`NSPrivacyCollectedDataTypes` entry. Otherwise keep it.
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSPrivacyTracking</key>
	<false/>
	<key>NSPrivacyTrackingDomains</key>
	<array/>
	<key>NSPrivacyCollectedDataTypes</key>
	<array>
		<dict>
			<key>NSPrivacyCollectedDataType</key>
			<string>NSPrivacyCollectedDataTypeCrashData</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<false/>
			<key>NSPrivacyCollectedDataTypeTracking</key>
			<false/>
			<key>NSPrivacyCollectedDataTypePurposes</key>
			<array>
				<string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
			</array>
		</dict>
	</array>
	<key>NSPrivacyAccessedAPITypes</key>
	<array>
		<dict>
			<key>NSPrivacyAccessedAPIType</key>
			<string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
			<key>NSPrivacyAccessedAPITypeReasons</key>
			<array><string>C617.1</string></array>
		</dict>
		<dict>
			<key>NSPrivacyAccessedAPIType</key>
			<string>NSPrivacyAccessedAPICategoryDiskSpace</string>
			<key>NSPrivacyAccessedAPITypeReasons</key>
			<array><string>E174.1</string></array>
		</dict>
		<dict>
			<key>NSPrivacyAccessedAPIType</key>
			<string>NSPrivacyAccessedAPICategoryUserDefaults</string>
			<key>NSPrivacyAccessedAPITypeReasons</key>
			<array><string>CA92.1</string></array>
		</dict>
		<dict>
			<key>NSPrivacyAccessedAPIType</key>
			<string>NSPrivacyAccessedAPICategorySystemBootTime</string>
			<key>NSPrivacyAccessedAPITypeReasons</key>
			<array><string>35F9.1</string></array>
		</dict>
	</array>
</dict>
</plist>
```
Reason codes: C617.1 = timestamps of files inside the app container
(SQLite database); E174.1 = check free space before writing (SQLite);
CA92.1 = UserDefaults readable only by this app; 35F9.1 = elapsed time /
timers.

**Registering in Xcode (edit `project.pbxproj` by hand, carefully):**
For each of `ios/Runner.xcodeproj/project.pbxproj` and
`macos/Runner.xcodeproj/project.pbxproj`:
1. Make two new unique 24-character uppercase hex IDs. Check each with
   `grep -c <ID> project.pbxproj` → must print 0.
2. `PBXFileReference` section: add
   `<ID1> /* PrivacyInfo.xcprivacy */ = {isa = PBXFileReference; lastKnownFileType = text.xml; path = PrivacyInfo.xcprivacy; sourceTree = "<group>"; };`
   For macOS, use `path = Runner/PrivacyInfo.xcprivacy;` *only if* the other
   entries in that project's Runner group use `Runner/`-prefixed paths
   (`Info.plist` there is `path = Runner/Info.plist`). Copy the style of the
   `Info.plist` reference in the same file.
3. `PBXBuildFile` section: add
   `<ID2> /* PrivacyInfo.xcprivacy in Resources */ = {isa = PBXBuildFile; fileRef = <ID1> /* PrivacyInfo.xcprivacy */; };`
4. In the `PBXGroup` that lists `Info.plist`, add `<ID1> /* PrivacyInfo.xcprivacy */,` to `children`.
5. In the Runner target's `PBXResourcesBuildPhase` `files` list, add
   `<ID2> /* PrivacyInfo.xcprivacy in Resources */,`
6. The iOS pbxproj has the owner's uncommitted SPM changes (see Ground
   rule 2). Keep them.

**Done when.**
- Both files exist and pass `plutil -lint`.
- Both projects reference them in Resources.
- `xcodebuild -project ios/Runner.xcodeproj -list` and the same for macOS
  still parse.

**Verify.**
- `plutil -lint ios/Runner/PrivacyInfo.xcprivacy macos/Runner/PrivacyInfo.xcprivacy`
- `xcodebuild -project ios/Runner.xcodeproj -list >/dev/null && xcodebuild -project macos/Runner.xcodeproj -list >/dev/null`
- If disk allows (rule 6): `flutter build ios --release --no-codesign`, then
  `ls build/ios/iphoneos/Runner.app/PrivacyInfo.xcprivacy`.

---

## T4 — Version string alignment (only if D1 = b)

**Why.** `pubspec.yaml:4` is `version: 1.0.0+2`, so the bundle reports
`CFBundleShortVersionString` **1.0.0** (build 2). App Store Connect's version
record is "1.0", so the strings don't match.

**If D1 = (a):** no code change. Only note in
`docs/release/app-store.md` that the App Store Connect version is `1.0.0`.

**If D1 = (b):** add `--build-name=1.0` to the `flutter build ipa` command
(`.github/workflows/release.yml` ~line 110) and the `flutter build macos`
command (~line 146). Leave Android/Windows/Linux alone. Mention the flag in
`docs/release/checklist.md` §1, wherever version/build numbers are
described.

**Done when.** Built iOS/macOS bundles report the version App Store Connect expects.

---

## T5 — macOS signing team + one-time Flutter SPM migration

**Why.**
- The macOS Runner target has no `DEVELOPMENT_TEAM`. The iOS target uses
  `48428D3DL2` (an uncommitted owner change in
  `ios/Runner.xcodeproj/project.pbxproj`).
- The macOS project hasn't been through Flutter 3.47's migration. On the
  first `flutter build macos`/`flutter run -d macos`, Flutter will rewrite
  `macos/Runner.xcodeproj/project.pbxproj` (add the Swift Package Manager
  integration), update `macos/Podfile`, and raise `MACOSX_DEPLOYMENT_TARGET`
  from 10.15 to **12.0**. This was seen in a scratch copy. Better to make
  that diff once, on purpose, and review it.

**Steps.**
1. Check `df -h /` (need ≥ 6 GB).
2. Run `flutter build macos --debug`. Let the migration happen.
3. In `macos/Runner.xcodeproj/project.pbxproj`, add
   `DEVELOPMENT_TEAM = 48428D3DL2;` to the **Runner target's** Debug, Release
   and Profile build configurations. These are the configs with
   `baseConfigurationReference = ... AppInfo.xcconfig`, near the
   `CODE_SIGN_ENTITLEMENTS` lines. Don't add it to the project-level
   configs or the "Flutter Assemble" target.
4. Review `git diff macos/`. It should contain only the SPM migration,
   the deployment-target bump and the team. Commit macOS changes separately
   from anything else.

**Done when.** `flutter build macos --debug` succeeds a second time with no
further project rewrites, and `git diff macos/` is reviewed and committed.

---

## T6 — Make crash reporting truly opt-in and anonymous

**Why (from the SDK source, sentry_flutter 9.24.0 / sentry-cocoa 8.58.3).**
Today, when a build includes a DSN (release CI passes `SENTRY_DSN`:
`.github/workflows/release.yml` ~lines 114, 149):

- `CrashReportingService.run`
  (`lib/infrastructure/observability/crash_reporting_service.dart:20-44`)
  always calls `SentryFlutter.init`. The user's toggle is only checked in the
  **Dart** `beforeSend`/`beforeBreadcrumb` (lines 37-40).
- The native SDK starts as well (`autoInitializeNativeSdk` defaults to true).
  The plugin installs its *own* native `beforeSend`, which never looks at the
  toggle:
  `~/.pub-cache/hosted/pub.dev/sentry_flutter-9.24.0/ios/sentry_flutter/Sources/sentry_flutter/SentryFlutterPlugin.swift:319-320`.
  So for an **opted-out** user, these still get sent: native crashes, app
  hangs and watchdog terminations (all enabled by default), plus
  release-health **sessions on every launch**
  (`sentry_flutter_options.dart:41,52,173,262`).
- Native events get `user.id` = a persistent random per-install ID
  (sentry-cocoa `Sources/Sentry/SentryClient.m:979-987`). All events carry
  `contexts.app.device_app_hash`, which is a hash of `identifierForVendor`
  on iOS / the `en0` MAC address on macOS, plus model and bundle ID
  (`Sources/SentryCrash/Recording/Monitors/SentryCrashMonitor_System.m:396-403`,
  merged into Dart events through the native scope). `redactEvent` (lines
  52-58) doesn't remove that hash.

The privacy policy (`docs/privacy-policy.md:79`) and App Privacy answers
(`docs/release/app-store.md:22-24`) say the opposite.

**Target behaviour.**
- No DSN → Sentry is never touched (unchanged).
- DSN + opted out → `SentryFlutter.init` is **never called**. Opting out at
  runtime calls `Sentry.close()`, which also closes the native SDK through
  `NativeSdkIntegration.close`.
- DSN + opted in → Sentry is initialised with only what "crash data, not
  linked" allows, and every outgoing event has no user and no
  `device_app_hash`.

**Change.**
1. `lib/main.dart:42-86`: load `SharedPreferences`/`AppPreferences`
   **before** deciding about Sentry. Today they load inside `_runApp`
   (`onPreferencesLoaded` callback). Pass `appPrefs` into `_runApp` and
   remove the holder/callback.
2. `crash_reporting_service.dart`: replace `run(...)` with something like:
   - `static Future<void> start({required String dsn, required bool Function() isEnabled})`:
     a no-op if `dsn` is empty or Sentry is already running. Otherwise
     `SentryFlutter.init(...)` **without** `appRunner`; since Flutter 3.3 the
     error zone isn't needed. Call `runApp` normally afterwards.
   - `static Future<void> stop()`: `await Sentry.close()` if it's running.
   - Keep `isEnabled()` checks in `beforeSend`/`beforeBreadcrumb` as a
     backstop.
   - Options to set:
     - Keep: `sendDefaultPii = false`, `attachScreenshot = false`.
     - Add: `attachViewHierarchy = false`, `enableAutoSessionTracking = false`,
       `enableAppHangTracking = false`,
       `enableWatchdogTerminationTracking = false`, `sendClientReports = false`,
       `enableAutoPerformanceTracing = false`, `enableAutoNativeBreadcrumbs = false`.
     - **D2 = (a):** also `enableNativeCrashHandling = false`.
     - Confirm every option name exists in
       `~/.pub-cache/hosted/pub.dev/sentry_flutter-9.24.0/lib/src/sentry_flutter_options.dart`
       (and `sentry-9.24.0/lib/src/sentry_options.dart`) before using it.
   - `redactEvent`: also clear `event.contexts.app?.deviceAppHash`. The field
     is mutable: `sentry-9.24.0/lib/src/protocol/sentry_app.dart:48`.
   - Set `Sentry.configureScope((s) => s.setUser(null))` after init, so no
     user syncs to the native scope.
3. `main.dart`: `if (sentryDsn.isNotEmpty && appPrefs.crashReportingEnabled) await CrashReportingService.start(...)`.
4. Wire the toggle so changes take effect live:
   - Settings → About → Crash reporting:
     `lib/presentation/screens/settings_screen.dart:146-152`.
   - Post-onboarding consent:
     `lib/presentation/screens/onboarding_screen.dart:97`.
   - On → `start`, off → `stop`. The DSN can come from
     `const String.fromEnvironment('SENTRY_DSN')` inside the service, or
     from a small provider. Follow how the codebase already handles
     dart-defines.
5. If D2 = (b): keep the native crash handler and skip
   `enableNativeCrashHandling = false`. T7 then has to disclose "Device ID".
   If D2 = (c): remove `sentry_flutter` from `pubspec.yaml`, delete the
   service, its test, the toggle/consent UI and the `SENTRY_DSN` defines, and
   update T3/T7.

**Tests.**
- Update `test/infrastructure/observability/crash_reporting_service_test.dart`.
  - `redactEvent` strips `user`, `breadcrumbs`, `extra`, and
    `contexts.app.deviceAppHash`.
  - `start` with an empty DSN never initialises Sentry. Make
    initialisation injectable if needed; keep it simple.

**Done when.**
- An opted-out user never causes `SentryFlutter.init` to run.
- Toggling off closes Sentry, and toggling on starts it.
- Every event that reaches `beforeSend` leaves without a user or
  `device_app_hash`.
- `flutter analyze`, `flutter test` pass.

---

## T7 — Bring privacy docs in line with T6 and the audit

**Where / what.**
- `docs/privacy-policy.md`
  - Crash table row (line ~32) and "Crash reporting" section (~lines 69-79):
    describe the T6 behaviour exactly, including what *is* sent (stack trace,
    app/OS version, device model).
  - If D2 = (b), say the reports include a per-device hash.
  - Bump "Last updated".
- `docs/release/app-store.md`
  - "App identity" (lines 5-7) is out of date. The bundle ID is committed as
    `run.records.openbike`; don't describe it as "set per Xcode signing
    config, not committed".
  - "Privacy nutrition label" (lines 13-31): Diagnostics → Crash Data, not
    linked, App Functionality, only if opted in. If D2 = (b), add
    Identifiers → Device ID (not linked, App Functionality).
  - Add a line noting the OpenStreetMap tile requests: off by default,
    user-toggled, IP + map area to `tile.openstreetmap.org`
    (`lib/presentation/widgets/route_mini_map.dart:63-69`; toggle default
    `lib/presentation/state/providers.dart:883`).
  - Add a "macOS" subsection: category (T1), sandbox entitlements including
    `network.server` (T2), privacy manifest (T3).
- `docs/release/analytics.md`: the "Live opt-out" paragraph describes the old
  `beforeSend`-only design. Rewrite it for start/stop.

**Done when.** Every statement in these docs matches the code after T6. No
code changes in this task.

---

## T8 — Ride session teardown (workout / route / recording)

**Why.** Nothing resets ride state when a ride ends.

From the code:
- `confirmStopRide` (`lib/presentation/widgets/ride_pause_actions.dart:54-90`)
  and the route-completion `_stopAndSave`
  (`lib/presentation/screens/ride_screen.dart:187-200`) stop the
  `RecordingEngine` only. They never stop the `WorkoutEngine` or
  `RouteSimulator`, and never clear `currentWorkoutProvider`.
- Nothing in `lib/` ever writes `currentWorkoutProvider` back to null.
- `WorkoutEngine.stop()` (`lib/core/application/services/workout_engine.dart:214-224`)
  fires **no** event. `RouteSimulator.stop()`
  (`lib/core/application/services/route_simulator.dart:163-169`) fires none
  either.
- So `TrainerModeController` (`trainer_mode_controller.dart:97-123`) keeps
  `_hasActiveWorkout` / `_hasActiveRoute` true forever after a ride ends
  early.
- `leaveRide` (`ride_pause_actions.dart:94-125`) tells the user "Your current
  ride data will be lost" but never stops the `RecordingEngine`. It keeps
  sampling and **auto-saving every 30 s** (`recording_engine.dart:354-368`) as
  a `RideStatus.active` ride.

Seen in a real run: a route ride after a workout ride showed
"ERG · 150 W" where it should have shown "SIM · Difficulty 50%". From
reading the code (not reproduced):
- An ended-early workout keeps sending ERG targets until its schedule
  finishes.
- The next ride shows the stale workout HUD (`ride_screen.dart:256-260`
  checks `currentWorkoutProvider` first).
- Starting another workout while the engine runs throws
  (`workout_engine.dart:153`).
- After "Leave ride", the next `RecordingEngine.start()` throws
  (`recording_engine.dart:96`).

**Change.**
1. `lib/core/events/app_event.dart`: add `WorkoutEvent.stopped()` and
   `SimulationEvent.stopped()`. Run codegen (rule 5).
2. `WorkoutEngine.stop()` fires `WorkoutEvent.stopped()`.
   `RouteSimulator.stop()` fires `SimulationEvent.stopped()`.
3. `TrainerModeController`: handle `stopped` like `completed`. Reset the flag
   and `_applyDefaultMode()`. Both `.when` calls are exhaustive, so the
   compiler will point to them.
4. `RecordingEngine`: add `Future<void> discard()`. It cancels the
   timers/subscriptions like `stop()` does, deletes the partially auto-saved
   ride via `_storage.deleteRide(id)`, and returns to idle **without** firing
   `RideStopped`, so auto-upload and calendar linking don't run.
5. In `ride_pause_actions.dart`, add one helper, e.g.
   `void endRideSession(WidgetRef ref)`. It should:
   - stop the workout engine if it isn't idle, and set
     `currentWorkoutProvider` to null;
   - stop the route simulator if it's running. Guard with
     `activeTrainerPortProvider != null`, because `routeSimulatorProvider`
     throws without a trainer;
   - clear `powerHistoryProvider` / `hrHistoryProvider`.
   - **Don't** clear `activeFtpTestProvider`. The ride summary's
     `FtpTestPrompt` still needs it.
6. Call `endRideSession` from `confirmStopRide` (after `engine.stop`, before
   navigating) and from `_stopAndSave` in `ride_screen.dart`.
   `leaveRide` → if recording is in progress and confirmed, call
   `recordingEngine.discard()`, then `endRideSession`, then navigate.
7. `RideScreen.initState` (`ride_screen.dart:50-93`), defensive: if the
   workout engine or route simulator isn't idle when a new ride starts, stop
   it first.

**Tests.**
- `test/core/application/services/workout_engine_test.dart`: `stop()` emits
  `WorkoutEvent.stopped()`. Fix existing tests that assert exact event lists.
- `route_simulator_test.dart`: same for `SimulationEvent.stopped()`.
- `trainer_mode_controller_test.dart`: a workout that's started then
  stopped, followed by a route that starts → mode becomes `simulation`.
- `recording_engine_test.dart`: `discard()` returns to idle, deletes the
  auto-saved ride, and emits no `RideStopped`.

**Done when.** All of the above pass. Stopping or leaving a ride leaves no
running engine, no stale workout HUD and no active-status ride in storage.

---

## T9 — ERG status banner shows the manual value during a workout

**Why.** While a workout is running, `ManualTrainerControls` shows only
`_TrainerStatusBanner`
(`lib/presentation/widgets/manual_trainer_controls.dart:23-36`). Its ERG text
reads `ergTargetWattsProvider` (lines 153-157), which is the **last manual**
ERG value, so it shows "ERG · 150 W" while the workout drives 226 W. You
can see this in every `01-ride-workout.png`.

**Change.** In `_TrainerStatusBanner`, when `currentWorkoutProvider != null`
and `workoutProgressProvider` has a value, show
`progress.targetPower.value.round()` for ERG. Otherwise keep the current
behaviour. Don't change `ergTargetWattsProvider` (manual mode still needs it).

**Tests.** Extend `test/presentation/widgets/manual_trainer_controls_test.dart`:
with an active workout whose progress target is 226 W and a manual ERG
value of 150, the banner reads "226 W".

**Done when.** The test passes and the banner matches the HUD target during
workouts.

---

## T10 — iPad/Mac ride screen always uses the phone layout

**Why.** `RideScreenConfigNotifier.adaptToLayout`
(`lib/presentation/models/ride_screen_config.dart:96-105`) is called only
from tests (`test/presentation/models/ride_screen_config_test.dart:76-93`).
So the ride screen always uses `defaultPortrait`: 4 fields, no power
gauge. That's true even in the ≥600 px "landscape" and ≥1200 px "desktop"
branches of `RideScreen`'s `LayoutBuilder`
(`lib/presentation/screens/ride_screen.dart:229-243`). On iPad and Mac, most
of the screen stays empty, and the route profile stretches to the full
window height.

**Change.**
1. Make `adaptToLayout` idempotent: only assign `state` when the target
   preset differs, e.g. by tracking the last applied layout. That way,
   calling it every layout pass can't cause a rebuild loop.
2. In `RideScreen`'s `LayoutBuilder`, work out the layout class (desktop if
   `maxWidth >= 1200`, landscape if `>= 600`, else portrait). Call
   `adaptToLayout(isLandscape: ..., isDesktop: ...)` in a post-frame
   callback / `Future.microtask`. Providers can't be modified during
   build; follow the microtask pattern already used in `providers.dart`.
3. User customisation (`setFieldAt` → `_userCustomized`) must still win.

**Tests.**
- `ride_screen_config_test.dart`: calling `adaptToLayout` twice with the
  same arguments notifies listeners only once.
- If practical, add a widget test that pumps the ride layout at
  1032×1376 and checks for six data fields and a `PowerGauge`.

**Done when.**
- iPad portrait (1032 pt wide) shows the 6-field/3-column grid + power gauge.
- Mac (≥1200 pt) shows the 12-field desktop preset + gauge.
- Phone is unchanged.

---

## T11 — Workout profile chart: ramps invisible, repeats drawn solid

**Why.** `_MiniProfilePainter`
(`lib/presentation/widgets/workout_mini_profile.dart:40-63`) draws each step
as one rectangle at `powerTargetPercent` for the step's whole duration. But
`WorkoutBuilder` (`lib/core/application/services/workout_builder.dart`) sets
these fields:
- warm-up / cool-down / ramp: `powerTargetPercent: 0` with
  `powerLowPercent` → `powerHighPercent`, so they're drawn at **zero height**;
- intervals: on-power = `powerTargetPercent`, off-power = `powerLowPercent`,
  with `repeat` and `offDurationSeconds`. They're drawn as **one solid bar**
  at on-power;
- free ride: target 0 → invisible.

This one widget is used by the library tiles, workout editor, in-ride HUD,
home and calendar (`grep -rn "WorkoutMiniProfile(" lib`), so all of them
are wrong for bundled workouts.

**Change.**
1. Pull the geometry out into a pure, testable function in the same file
   (mark it `@visibleForTesting`), e.g. `List<ProfileSegment> profileSegments(List<WorkoutStep> steps)`.
   Each segment holds a start/end time and a start/end percent.
   - Ramps (warm-up, cool-down, ramp) → one segment going low→high.
   - Interval with `repeat` → `repeat ×` [on segment, off segment].
   - Steady → flat.
   - Free ride → a flat, low placeholder level so it stays visible. Pick a
     constant and say why in a comment.
2. Painter: `maxPower` = largest percent across all segment endpoints. Draw
   each segment as a filled polygon (a trapezoid for ramps). Keep the
   per-type colours and the progress cursor. Cursor maths is time-based and
   must stay correct.
3. Don't change `Workout.totalDuration` or `WorkoutStep.totalDurationSeconds`.

**Tests.** New `test/presentation/widgets/workout_mini_profile_test.dart`:
- a warm-up 600 s 40→75 gives one segment 40→75;
- intervals `repeat: 3, on 720 @ 90, off 300 @ 55` give 6 alternating
  segments;
- the sum of segment durations equals `Workout.totalDuration` for every
  `BundledWorkouts.all` entry.

**Done when.** Tests pass. "Sweet Spot 3x12" visibly shows a warm-up ramp
and three blocks.

---

## T12 — ListTile debug assertion in the workout library

**Why.** In debug builds, opening Workouts logs "ListTile background color
or ink splashes may be invisible" once per tile. `_WorkoutTile`
(`lib/presentation/screens/workout_builder_screen.dart:198-243`) wraps the
`ListTile` in a `Container` with a background colour. That hides ink
splashes in release too.

**Change.** Replace the coloured `Container` with `Padding(margin)` →
`Material(color: context.tokens.surfaceTier2, borderRadius: BorderRadius.circular(12), clipBehavior: Clip.antiAlias)` → `ListTile`.
Then grep for the same pattern elsewhere
(`grep -rn -B3 "child: ListTile(" lib/presentation`) and fix any other tile
that triggers the assertion.

**Done when.** Opening Workouts in a debug run logs no ListTile assertion,
and tap ripples are visible.

---

## T13 — Duplicate drag handles in the workout editor (desktop)

**Why.** `ReorderableListView.builder`
(`lib/presentation/screens/workout_editor_screen.dart:131`) adds its default
trailing drag handles on desktop, on top of the explicit
`ReorderableDragStartListener` handle at line 279. On macOS each step shows
two handles.

**Change.** Pass `buildDefaultDragHandles: false` to that
`ReorderableListView.builder`.

**Tests.** If `test/presentation/screens/workout_editor_screen_test.dart`
covers reordering, keep it passing. Optionally assert there's exactly one
`Icons.drag_handle` per step.

**Done when.** One handle per step on all platforms, and reordering via the
leading handle still works.

---

## T14 — FTP Test page highlights the "Home" tab (optional)

**Why.** `AppShell._currentIndex` (`lib/presentation/widgets/app_shell.dart:22-28`)
falls back to index 0 for routes that aren't tabs, so `/ftp-test` shows
Home as selected.

**Change (only if the owner wants it).** Let the rail/bar show no
selection, or the originating tab, for non-tab routes. `NavigationRail`
accepts `selectedIndex: null`; `NavigationBar` needs a valid index, so keep
0 there. Small, isolated change.

---

## T15 — Verify Strava token storage on a signed Mac build (manual)

**Why.** `StravaExportPlugin` uses `const FlutterSecureStorage()`
(`lib/plugins/exports/strava_export_plugin.dart:45`). On macOS,
flutter_secure_storage defaults to the data-protection keychain
(`MacOsOptions.useDataProtectionKeyChain = true`). Its README asks for a
keychain-sharing entitlement, which the entitlements files don't have.
This might work with an App Store provisioning profile, but nobody has
tested it.

**Steps.** After T2 and T5:
1. Make a signed Release Mac build (TestFlight for Mac, or a local
   "Apple Development" signed archive).
2. Connect Strava.
3. Quit, relaunch, and confirm it's still connected.

**If it fails** (look for `-34018` / `errSecMissingEntitlement` in Console),
pick one:
- (a) add `keychain-access-groups` with `$(AppIdentifierPrefix)run.records.openbike`
  to both macOS entitlements files; or
- (b) pass `mOptions: MacOsOptions(useDataProtectionKeyChain: false)`.

Note what happened in `docs/release/macos-signing.md`.

---

## T16 — Mac App Store build/upload path (optional, D4)

**Why.** `.github/workflows/release.yml` (macOS job, ~line 125) only makes a
Developer ID-signed, notarised DMG. Mac App Store needs an
Apple Distribution certificate, a Mac Installer Distribution certificate,
a Mac App Store provisioning profile, and an `xcodebuild archive` +
`-exportArchive` (method `app-store-connect`) producing a `.pkg`.

**If D4 = manual.** Add a short section to `docs/release/macos-signing.md`
covering archive and upload from Xcode (Product → Archive → Distribute App
→ App Store Connect). No CI change.

**If D4 = CI.** Add a separate `macos-appstore` job next to the DMG job, with
new secrets, documented in `docs/release/secrets.md`. Don't change the DMG
job.

---

## T17 — Retake store screenshots (after T8–T13)

**Why.** These files in `docs/store/screenshots/` show the bugs above:

| File(s) | Shows |
|---|---|
| `*/01-ride-workout.png` (all three) | "ERG · 150 W" banner (T9) |
| `ipad-13/01,02` and `macos/01,02` | phone layout on large screens (T10) |
| `*/03-workout-library.png` | solid thumbnails (T11) |

`04`–`07` and `ios-6.3/02` are fine as they are.

**Missing set.** App Store Connect *requires* a 6.9" iPhone set
(1320×2868; scaled down for smaller iPhones). The 6.3" set in
`ios-6.3/` is optional and doesn't meet the requirement alone. No
`ios-6.9/` set exists yet, so capture it in full here.

**How.** Use `tool/screenshots/` (see its `README.md`). It handles the
scratch copy, the simulators, the 9:41 status bar, the en_US locale, App Nap,
RGB flattening and size checks. Run the three targets one after another:

```bash
export PATH=/Users/hugo/Developer/flutter/bin:$PATH
tool/screenshots/take_screenshots.sh ios-6.9                    # required, full set
tool/screenshots/take_screenshots.sh ios-6.3 static,workout     # optional set
tool/screenshots/take_screenshots.sh ipad-13 static,route,workout
tool/screenshots/take_screenshots.sh macos static,route,workout
```

- Each `workout` pass takes about 12 minutes of real-time riding; `route`
  takes about 3.5 minutes. Check `df -h /` first (rule 6).
- Look at every new PNG before committing.
- If T11 is done, also switch `_customWorkout()`/`_rideWorkout()` in
  `tool/screenshots/driver.dart` back to `warmup()`/`intervals()`/`cooldown()`
  steps (their comment explains why they're steady-only), then re-take the
  `static` and `workout` passes on all three targets.
- The driver must never be imported from `lib/`. It's only ever built with
  `-t tool/screenshots/driver.dart --dart-define=DEV_MODE=true`.

---

## T18 — Live ride metrics never update; paused time counted as ride time

**Why.** Two layers, both confirmed in code.

1. `currentRideProvider` (`lib/presentation/state/providers.dart:191-193`) is
   a plain `Provider` returning `ref.watch(recordingEngineProvider).currentRide`.
   `recordingEngineProvider` never changes, so the value is computed once
   (when first watched) and never again.
2. A fresh read wouldn't help either. `RecordingEngine` keeps samples in its
   private `_readings` list (`lib/core/application/services/recording_engine.dart:70`,
   appended at `:380`). `_currentRide` is created once at start with no
   readings (`:102-106`). Readings are only copied into a `Ride` by
   `_autoSave` (`:394`) and `stop()` (`:270`).

So the six fields that compute from `currentRideProvider`
(`lib/presentation/models/data_field_type.dart:122-166`: avg power,
normalized power, distance, calories, TSS, IF) stay at `--`/`0`/`0.00` for
the whole ride. You can see it in the committed screenshots:

| Screenshot | What's wrong |
|---|---|
| `docs/store/screenshots/macos/01-ride-workout.png` (11:40 in) | AVG POWER `--`, NP `--`, DISTANCE `0.00`, TSS `0`, IF `0.00`, CALORIES `0` |
| `ipad-13/01`, `android-7in/01`, `android-10in/01` | DISTANCE `0.00` at 31 km/h |

Phone riders see the same on the second data page.

Same root cause: `_currentRide.pauseDuration` is never updated during a
ride. Paused time only accumulates in `_totalPauseDuration`
(`recording_engine.dart:167-180`). `rideElapsedProvider`
(`providers.dart:558-565`) feeds both the header timer
(`lib/presentation/widgets/ride_header_bar.dart:17`) and the TIME field
(`data_field_type.dart:146`). It reads `currentRide.activeDuration`, so it
keeps counting while paused and never subtracts pauses. This part comes
from reading the code; prove it with the test below before fixing.

**Change.**
1. `RecordingEngine`: add a live snapshot getter, e.g. `Ride? get liveRide`.
   It returns `_currentRide?.copyWith(...)` with:
   - `readings: UnmodifiableListView(_readings)` and
     `laps: UnmodifiableListView(_laps)`. These are views; `List.unmodifiable`
     would copy every sample once a second.
   - `pauseDuration:` `_totalPauseDuration`, plus `now - _pauseStartTime` while
     paused.
2. Make `currentRideProvider` tick the way `rideElapsedProvider` does: a
   `StreamProvider<Ride?>` over `Stream.periodic(1 s)` reading
   `engine.liveRide`, emitting once immediately. Update the six call sites in
   `data_field_type.dart` to read `.valueOrNull`. Nothing else in `lib/` reads
   `currentRideProvider` (`grep -rn currentRideProvider lib`).
3. `rideElapsedProvider`: use `engine.liveRide?.activeDuration`, so the timer
   freezes while paused and excludes pauses after resume.
4. Keep it simple first. Average power, NP, TSS and IF each scan all
   readings every second, which is fine for multi-hour rides (≈7k–15k
   samples). If profiling shows otherwise, compute them once per tick in one
   provider and have the fields read that.

**Tests.**
- `test/core/application/services/recording_engine_test.dart`:
  - after N samples, `liveRide.readings.length == N`;
  - `liveRide.totalDistance` equals the last sample's distance;
  - after pause/resume, `liveRide.pauseDuration` includes the pause.
- A data-field widget test: the distance and avg-power cells change after
  the engine records more samples. Follow
  `test/presentation/widgets/data_field_cell_test.dart` /
  `data_field_grid_test.dart`.

**Done when.**
- During a ride, all six fields update every second.
- The header timer stops while paused, and the paused time isn't counted
  after resume.
- `flutter analyze` and `flutter test` pass.

---

## T19 — Ride timer wraps onto two lines on small tablets

**Why.** `RideHeaderBar` (`lib/presentation/widgets/ride_header_bar.dart:45-57`)
puts the timer in an `Expanded` `Text` that is allowed to wrap. The timer is
28 pt bold monospace with letter-spacing 2, next to the sensor dots and three
28 pt buttons. In the ≥ 600 dp layouts the header only gets the left 3/5 of
the screen (`_buildLandscapeLayout` in `ride_screen.dart`). On a 7" portrait
tablet (617 dp wide) that's ~370 dp, and the timer breaks into "00:11:4" /
"0" (`docs/store/screenshots/android-7in/01-ride-workout.png`).

**Change.** Never wrap. Use `maxLines: 1, softWrap: false`, inside a
`FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft)` within
the `Expanded`, so it scales down only when it doesn't fit. Leave the size
alone where it fits.

**Tests.** A widget test that pumps `RideHeaderBar` at 360 dp wide with a
recording in progress. The timer must render as one line (one `Text` line
height) with no overflow exceptions. Also check at 1200 dp that the font
size is unchanged.

**Done when.** No wrap and no RenderFlex overflow from 320 to 1440 dp.

---

## T20 — Portrait tablets: ride screen leaves most of the screen empty

**Why.** `RideScreen` chooses a layout by width only
(`lib/presentation/screens/ride_screen.dart:238-249`: ≥ 1200 desktop, ≥ 600
landscape, else portrait). Portrait tablets all get the side-by-side
landscape layout:
- 7" tablet: 617×1097 dp;
- 10" tablet: 823×1463 dp;
- iPad 13": 1032×1376 dp.

The layout's two panes:
- **Left:** header, zone bar, then `DataFieldGrid`
  (`lib/presentation/widgets/data_field_grid.dart`, a `GridView` with a fixed
  `childAspectRatio: 1.8`), so the six fields fill only two short rows
(~70–90 dp each).
- **Right:** the HUD/route profile (flex 3) above the power gauge (flex 2).

On a tall screen, most of the left pane is blank and the workout HUD
panel is mostly empty. The route elevation profile stretches to the full
height. See `ipad-13/01`, `android-7in/01` and `android-10in/01`.

**Change.**
1. Add a portrait-tablet layout, used when
   `constraints.maxWidth >= 600 && constraints.maxHeight > constraints.maxWidth`.
   Landscape tablets (and anything ≥ 1200 dp wide in landscape) keep the
   current side-by-side layouts.
2. Arrangement, top to bottom: `RideHeaderBar`, `ZoneBar`,
   `ManualTrainerControls`, then the data grid, then a bottom section.
   - Grid: the landscape preset's 6 fields in 3 columns, sized to fill its
     share of the height. Give `DataFieldGrid` an option to derive
     `childAspectRatio` from the available height, or lay rows out with
     `Expanded`.
   - Bottom section: the bottom pane (HUD / route profile / live chart), with
     the `PowerGauge` beside it (`Row`) when `config.showPowerGauge`.
   - Start around grid 4 : bottom 5 and adjust by eye on the screenshots.
3. `_adaptConfigToWidth` (`ride_screen.dart:262-270`): portrait tablets keep
   the landscape preset (6 fields + gauge); only the arrangement changes.
   Phones (< 600 dp) and desktop are unchanged.

**Tests.** A widget test pumping the ride layout at 617×1097, 823×1463 and
1032×1376 should find:
- 6 data cells;
- a `PowerGauge`;
- the bottom pane;
- no overflow.

At 1366×1024 (landscape tablet), the existing side-by-side layout is still
used.

**Done when.** On 7", 10" and iPad portrait, the grid, the HUD/profile and the
gauge fill the screen with no large blank areas. Check with T22's screenshots.

---

## T21 — Flutter end-of-support warnings (Gradle/AGP, CocoaPods-only plugins)

**Why.** These aren't store blockers today, but a future Flutter upgrade will
turn them into build failures. Flutter 3.47.4 prints them on every build:

- **Android.**
  - "Flutter support for your project's Gradle version (8.14.0) will soon be
    dropped. Please upgrade your Gradle version to a version of at least
    9.1.0 soon."
  - "Flutter support for your project's Android Gradle Plugin version
    (Android Gradle Plugin version 8.11.1) will soon be dropped. Please
    upgrade your Android Gradle Plugin version to a version of at least
    Android Gradle Plugin version 9.0.1 soon."
  - Current versions:
    - Gradle 8.14: `android/gradle/wrapper/gradle-wrapper.properties:5`;
    - AGP 8.11.1: `android/settings.gradle.kts:22`;
    - Kotlin plugin 2.2.20: `android/settings.gradle.kts:23`.
- **iOS.** "The following plugins do not support Swift Package Manager for
  ios: flutter_foreground_task, flutter_secure_storage,
  permission_handler_apple. This will become an error in a future version of
  Flutter." This is why `ios/Podfile` / CocoaPods are still needed alongside
  SPM.

**Prerequisite: D5.** CI is pinned to Flutter `3.41.x`
(`.github/workflows/ci.yml:11`). Recent commits (`9406291`, `940aeb8`)
deliberately keep the dependency set resolvable on it, while local
development uses 3.47.4. Per Flutter's docs, AGP 9 with built-in Kotlin needs
Flutter ≥ 3.47. Settle D5 before touching the Android build.

**Change: Android (after D5 = a).**
1. Move CI (`ci.yml`, and `release.yml` if it pins a version) to the same
   Flutter `3.47.x`, and refresh `pubspec.lock` with it. That's one commit.
2. Then follow Flutter's guides; where they disagree with this outline, the
   guides win:
   - https://docs.flutter.dev/release/breaking-changes/migrate-to-agp-9
   - https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers

   In outline:
   - Gradle wrapper to ≥ 9.1.0 (the guide uses 9.3.1). AGP to ≥ 9.0.1 (the
     guide uses 9.1.0). Set the Kotlin Gradle plugin line in
     `settings.gradle.kts` per the guide.
   - In `android/app/build.gradle.kts`, remove `id("kotlin-android")` and
     replace `kotlinOptions { … }` with a top-level
     `kotlin { compilerOptions { … } }`.
   - Flutter may add `android.builtInKotlin=false` and `android.newDsl=false`
     to `android/gradle.properties` as a bridge. Only flip `builtInKotlin` to
     `true` once every plugin in use has dropped the Kotlin Gradle plugin
     (the guide shows how to check).
   - `~/.gradle` already has a Gradle 9.3.1 distribution cached, so there's
     no large download.

**Change: iOS plugins.**
- Run `flutter pub outdated`. Upgrade any of the three plugins whose newer
  versions support SPM and are compatible.
- Note the rest in `docs/release/checklist.md`: CocoaPods stays required
  until upstream adds SPM.
- Don't remove `ios/Podfile` or `macos/Podfile`.

**Verify.**
- `flutter build apk --debug` with no "will soon be dropped" warnings.
- `flutter analyze` and `flutter test` pass.
- CI is green on the new Flutter version.
- Optionally, run `tool/screenshots/take_screenshots.sh android-phone static`
  as an end-to-end smoke test (needs the Android SDK and emulator; see the
  tool's README).

**Done when.**
- The Android build is on Gradle ≥ 9.1 / AGP ≥ 9.0.1 with no deprecation
  warnings.
- CI and local use the same Flutter version.
- Each iOS plugin is either upgraded to an SPM-capable version, or recorded
  as still CocoaPods-only.

---

## T22 — Retake the ride screenshots affected by T18–T20

**Why.** These committed screenshots show the T18–T20 bugs:

| File(s) | Shows |
|---|---|
| `macos/01-ride-workout.png` | Stale fields: avg power, NP, distance, TSS, IF, calories (T18) |
| `macos/02-route-simulation.png` | Check for the same stale fields (desktop preset shows them) (T18) |
| `ipad-13/01,02` | DISTANCE `0.00` (T18); empty lower half (T20) |
| `android-7in/01,02` | DISTANCE `0.00` (T18); timer wrapped onto two lines (T19); empty space (T20) |
| `android-10in/01,02` | DISTANCE `0.00` (T18); empty space (T20) |

The phone sets (`ios-6.9`, `ios-6.3`, `android-phone`) only show the first
data page (power, cadence, heart rate, speed), so they're fine as they are.
So are `03`–`07` everywhere.

**How.** Run the targets one after another, checking `df -h /` before each
(rule 6):

```bash
export PATH=/Users/hugo/Developer/flutter/bin:$PATH
tool/screenshots/take_screenshots.sh ipad-13 route,workout
tool/screenshots/take_screenshots.sh macos route,workout
tool/screenshots/take_screenshots.sh android-7in route,workout
tool/screenshots/take_screenshots.sh android-10in route,workout
```

- Each run takes ~20 minutes: build/boot, then 3.5 min route and 12 min
  workout in real time.
- The Android targets need the Android SDK, emulator and a system image (see
  `tool/screenshots/README.md`).
- Look at every new PNG before committing. On a 01: all six T18 fields are
  non-zero (where shown), the timer is on one line, and nothing is mostly
  blank.
- Known cosmetic issue: the 10" emulator's demo-mode status bar showed two
  Wi-Fi icons. If it recurs, try dropping `-e ssid … -e activity none` from
  `status_bar_demo` in `tool/screenshots/take_screenshots.sh` for that
  target. Re-check that the phone bar still shows 9:41, Wi-Fi and battery
  only.

