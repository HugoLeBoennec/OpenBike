# Store screenshots & assets checklist

Apple screenshots (iPhone, iPad, Mac) are produced by
`tool/screenshots/take_screenshots.sh` into `docs/store/screenshots/` — see
`tool/screenshots/README.md`. Google Play screenshots are still captured by
hand. This is a checklist for whoever does that capture, plus where the
results go.

## Where assets live

Store metadata and images go under `fastlane/metadata/` (the conventional
layout for `fastlane deliver`/`supply`, if release automation adopts
fastlane later) or, until then, `docs/release/assets/<platform>/` as plain
files — either works with the store consoles' manual upload flow used at
v1.0.

## Screens to capture (both light and dark theme — P7 shipped both)

1. Home screen with a recent ride.
2. Ride screen mid-workout (HUD showing target/actual power, elevation
   profile visible).
3. Workout builder / library.
4. Training calendar / PMC chart (P5).
5. History / ride summary detail.
6. Device scan / pairing screen.

## Required sizes per store

### Google Play

- Phone screenshots: 16:9 or 9:16, min 320px, max 3840px on the long edge
  (2–8 images).
- 7" and 10" tablet screenshots (if claiming tablet support — OpenBike's
  responsive layouts from P3 support this).
- Feature graphic: 1024×500 PNG/JPEG.
- App icon: already generated via `flutter_launcher_icons`
  (`flutter_launcher_icons.yaml`) — export the 512×512 hi-res version Play
  Console wants separately from the adaptive icon.

### Apple App Store

- 6.9" iPhone (1320×2868, iPhone 17 Pro Max class) — required; App Store
  Connect scales it down for smaller iPhones. 6.3" (1206×2622) is optional.
- 13" iPad (2064×2752) — required, since the iOS target supports iPad
  (`TARGETED_DEVICE_FAMILY = "1,2"`).
- Mac (2880×1800) — required for the Mac App Store listing.
- App icon: 1024×1024 PNG, no alpha channel (export from
  `assets/icon/app_icon.png`, flattened).

## How to capture

```bash
# Apple (one target at a time; ~20 min each, see tool/screenshots/README.md)
tool/screenshots/take_screenshots.sh ios-6.9
tool/screenshots/take_screenshots.sh ipad-13
tool/screenshots/take_screenshots.sh macos

# Android Emulator
flutter build apk --release
# install on an emulator matching the target screenshot size, screenshot
# via `adb exec-out screencap -p > screenshot.png`
```

Toggle Settings → Theme between Light/Dark/System to capture both variants
of each screen listed above.

## Checklist

- [ ] Phone screenshots captured, both themes, all 6 screens above.
- [ ] Tablet/iPad screenshots captured (if claiming tablet support).
- [ ] Feature graphic (Play) designed.
- [ ] Hi-res app icons exported for both stores.
- [ ] Listing copy drafted (see `docs/release/play-store.md` /
      `docs/release/app-store.md` for the compliance copy; marketing copy
      — title/description/keywords — is a maintainer call, not scripted
      here).
