# App Store screenshots

This folder produces the App Store screenshots in `docs/store/screenshots/`
using generic seeded data and the DEV_MODE trainer simulator. The simulator
is used only to produce the data shown in the captures; the driver is a
separate entrypoint that `lib/` never imports, so it never ships.

| File | Role |
|---|---|
| `take_screenshots.sh` | Orchestrator: scratch copy → device → build/run → capture → finalize |
| `driver.dart` | Flutter entrypoint that seeds data and walks the screens |
| `finalize.py` | Flattens to RGB (the store rejects alpha) and checks exact sizes |

## Usage

```bash
tool/screenshots/take_screenshots.sh ios-6.9            # iPhone 6.9"  → 1320×2868 (required)
tool/screenshots/take_screenshots.sh ios-6.3            # iPhone 6.3"  → 1206×2622 (optional)
tool/screenshots/take_screenshots.sh ipad-13            # iPad 13"     → 2064×2752
tool/screenshots/take_screenshots.sh macos              # Mac          → 2880×1800

tool/screenshots/take_screenshots.sh ipad-13 route      # just re-take one pass
OUT_DIR=/tmp/shots tool/screenshots/take_screenshots.sh ios-6.3 static  # dry run elsewhere
```

Run the targets one after another, not in parallel: each takes a few GB of
disk and the Xcode builds compete.

Requirements:
- macOS with Xcode and an iOS simulator runtime that has the iPhone 17 Pro
  Max, iPhone 17 Pro and iPad Pro 13-inch (M5) device types.

App Store Connect requires the 6.9" iPhone set and scales it down for
smaller iPhones; the 6.3" set is optional.
- `flutter` on `PATH`, or `FLUTTER=/path/to/bin/flutter`.
- `python3` with Pillow (`python3 -m pip install pillow`).
- At least 6 GB free on `/` (`MIN_FREE_GB` to override).

Other knobs: `TIMEOUT_MIN` (default 45), `IOS_RUNTIME` (a simulator runtime
identifier; default is the newest installed), and `KEEP_WORK=1` (keep the
scratch copy and `flutter.log` for debugging).

## What gets captured

Passes (second argument, comma-separated; default `all`):

| Pass | Files | Time |
|---|---|---|
| `static` | `03-workout-library`, `04-workout-editor`, `05-trends` | ~10 s |
| `ftp` | `06-ftp-test`, plus `07-ftp-history` when the chart is below the fold | ~10 s |
| `route` | `02-route-simulation`, 1.45 km into a made-up 17 km route | ~3.5 min |
| `workout` | `01-ride-workout`, 11:40 into a 3×12 sweet-spot workout | ~12 min |

The ride passes run in real time: the timers, workout engine and route
simulator all use the wall clock.

Seeded data, defined in `driver.dart` under "Seed data":
- rider "Rider", FTP 251 W;
- about 6 months of rides, so CTL/ATL/TSB and personal records look
  realistic;
- an FTP history of two ramp tests and two 20-minute tests;
- a custom "Threshold Ladder" workout;
- the "Rolling Hills Loop" route.

None of it uses real people or places.

## How it stays out of your way

- **Scratch copy.** It builds from a copy of the repo in `$TMPDIR`, never
  the working tree. The first iOS/macOS build with a newer Flutter can
  rewrite tracked Xcode/Pod files (for example the Swift Package Manager
  migration).
- **In-memory data.** The driver's database and preferences live in memory.
- **Separate macOS app.** The macOS build uses bundle ID
  `run.records.openbike.screenshots`, so it never touches a real install's
  sandbox container. macOS keeps a ~32 KB metadata stub at
  `~/Library/Containers/run.records.openbike.screenshots` that scripts
  aren't allowed to delete; it's harmless.
- **Temporary simulators.** iOS targets get a dedicated simulator (en_US
  locale, status bar 9:41 with full signal and battery). It's deleted
  afterwards.
- **Package cache reuse.** Already-downloaded Swift packages from
  `build/*/SourcePackages` are reused as APFS clones. Without them, the first
  build downloads about 2 GB of Sentry binaries.

## Known quirks

- **iPad (iPadOS 26+):** in windowed-apps mode the simulator shows a resize
  grabber in the bottom-right corner and the app name in the status bar.
  There's no `simctl` switch for full-screen mode.
- **macOS:** the capture is the window's content (no title bar), rendered by
  the app itself at 2×. That way the output is 2880×1800 even on a
  non-Retina display. An OpenBike window opens during the run; it's fine
  if it's covered or in the background, but don't close it.
- **Workouts in the captures use only steady steps.** `WorkoutMiniProfile`
  doesn't draw ramps and repeated intervals correctly yet (see
  `docs/release/app-store-fix-plan.md`, T11). The library screenshot still
  shows the bundled workouts as they render today.
