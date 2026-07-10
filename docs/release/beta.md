# Beta testing & QA gate

v1.0 ships only after a beta period on both mobile stores' internal test
tracks and the QA matrix below is fully executed. This is the gate between
"CI green" and "cut the release tag" in `docs/release/checklist.md`.

## Setting up the tracks

### TestFlight (iOS)

1. Upload a build via `flutter build ipa` (see
   `.github/workflows/release.yml`'s `ios` job, or locally with a
   Developer ID) to App Store Connect.
2. App Store Connect → TestFlight → add internal testers (up to 100, no
   review needed) for the first round; add an external testing group
   (requires one-time Beta App Review) once internal testers are through
   the QA matrix below.
3. Internal testers get a build notification automatically; external
   testers need an invite link/email from App Store Connect.

### Play internal testing (Android)

1. Upload a build via `flutter build appbundle` (see the `android` job in
   `.github/workflows/release.yml`) to Play Console.
2. Play Console → Testing → Internal testing → create a release, add
   testers by email list or a shareable opt-in link.
3. Promote the same release to the Closed/Open testing track once the QA
   matrix passes, before a production rollout.

## Invite process

- Recruit testers who actually own the hardware the QA matrix needs (a
  smart trainer, an HR strap, at minimum) — a build that only ever runs in
  the simulator (`DEV_MODE`) doesn't validate the things beta exists to
  validate.
- Share the TestFlight/Play opt-in link plus a short brief: what to test
  (a full ride start-to-finish, a structured workout, a GPX route, an
  export), and where to report issues (GitHub Issues).
- Track feedback and crashes (if testers opt in to crash reporting) for at
  least one full week before considering the beta "crash-free" — see the
  go/no-go section below.

## QA matrix

Compiled from every phase's "Pending hardware QA" section — the acceptance
criteria that were implemented and unit-tested but need a real device to
confirm end-to-end. None of these block CI; all of them block the v1.0
go/no-go below.

### Connectivity (P1, P2)

- [ ] Fresh install on a physical Android 12+ device: permission prompts
      appear, scan finds a real trainer/HRM.
- [ ] Fresh install on a physical iPhone: Bluetooth permission prompt
      appears with the usage string, scan works.
- [ ] Trainer (FTMS) + HR strap paired simultaneously; HR strap wins HR
      fusion.
- [ ] ERG target power and SIM grade verified against a real trainer
      (Wahoo/Elite/Tacx) — **2+ different trainer models**, per
      `docs/roadmap/P9-release.md`'s QA matrix requirement.
- [ ] Background recording soak test (Android + iOS, 30 min, screen off /
      app backgrounded): no gaps > 2 s in `SensorReadings` timestamps, and
      the Android notification updates correctly.
- [ ] Windows: real scan+connect with a BLE dongle or built-in radio.
- [ ] Linux: real scan+connect on a machine with a BlueZ-capable adapter.

### Ride experience (P3)

- [ ] Full ZWO workout on a real trainer: targets track, HUD countdown
      matches ERG changes.
- [ ] GPX ride: grade changes felt on the trainer match the profile marker
      position.

### Desktop (P8)

- [ ] macOS: BLE trainer + HRM ride end-to-end on Apple silicon.
- [ ] Windows 11: BLE trainer + HRM ride end-to-end.
- [ ] (Stretch, non-blocking) ANT+ dongle session on macOS/Windows with a
      bundled libusb binary — see `docs/release/antplus-usb.md`.

### Full flows (all platforms)

- [ ] Complete ride → summary → history → detail flow.
- [ ] Workout builder: create, save, run a custom workout.
- [ ] Route simulation: import a GPX file, ride it, verify FIT/TCX export.
- [ ] Strava connect → auto-upload a ride → verify it appears on Strava.
- [ ] Crash reporting toggle: opt in, force a test crash (dev build only),
      confirm it reaches Sentry; opt out, confirm it doesn't.

## v1.0 go/no-go

All of the following must be true before tagging `v1.0.0` (see
`docs/release/checklist.md` §"cut the tag"):

- [ ] CI green on `main`.
- [ ] Every item in the QA matrix above checked off by a human tester on
      real hardware.
- [ ] Crash-free week: zero unresolved crash reports from beta testers who
      opted in to crash reporting over a 7-day window (or explicitly waived
      with a documented reason if too few testers opted in to be
      statistically meaningful).
- [ ] Licensing done (`LICENSE`/`NOTICE` committed, in-app license screen
      verified).
- [ ] Both store listings created and passing each console's automated
      pre-submission checks (Play Console pre-launch report, App Store
      Connect's build processing/validation) — full manual review approval
      is not required to tag, only to go live.

Record the sign-off (date, who ran the matrix, any waived items and why)
in the release's GitHub Release notes or a dated entry appended to this
file.
