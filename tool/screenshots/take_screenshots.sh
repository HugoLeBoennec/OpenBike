#!/bin/bash
#
# Captures OpenBike's App Store screenshots. See tool/screenshots/README.md.
#
#   tool/screenshots/take_screenshots.sh <ios-6.9|ios-6.3|ipad-13|macos> [passes]
#
# passes: comma-separated subset of static,ftp,route,workout (default: all).
# Writes only the captured files into docs/store/screenshots/<target>/
# (override with OUT_DIR=...), as opaque RGB PNGs at the exact store size.
#
# Builds from a throwaway copy of the repo, never the working tree: the first
# iOS/macOS build with a newer Flutter can rewrite tracked Xcode and Pod
# files, and the macOS copy gets its own bundle id so it never shares a sandbox
# container with a real install. iOS targets run on a dedicated simulator that
# is deleted afterwards. The driver itself keeps its database and preferences
# in memory.

set -euo pipefail

TARGET=${1:-}
PASSES=${2:-all}
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
OUT_DIR=${OUT_DIR:-$REPO/docs/store/screenshots/$TARGET}
MIN_FREE_GB=${MIN_FREE_GB:-6}
TIMEOUT_MIN=${TIMEOUT_MIN:-45}
SHOTS_BUNDLE_ID=run.records.openbike.screenshots

case "$TARGET" in
  ios-6.9)
    # The iPhone size App Store Connect requires; it scales it down for
    # smaller iPhones.
    PLATFORM=ios SIZE=1320x2868
    DEVICE_TYPE=com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max ;;
  ios-6.3)
    PLATFORM=ios SIZE=1206x2622
    DEVICE_TYPE=com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro ;;
  ipad-13)
    PLATFORM=ios SIZE=2064x2752
    DEVICE_TYPE=com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M5-12GB ;;
  macos)
    PLATFORM=macos SIZE=2880x1800 ;;
  *)
    echo "usage: $0 <ios-6.9|ios-6.3|ipad-13|macos> [static,ftp,route,workout]" >&2
    exit 2 ;;
esac

die() { echo "error: $*" >&2; exit 1; }
log() { echo "==> $*"; }
free_mb() { df -m / | awk 'NR==2 {print $4}'; }

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------

FLUTTER=${FLUTTER:-$(command -v flutter || true)}
[ -n "$FLUTTER" ] || die "flutter is not on PATH (or set FLUTTER=/path/to/bin/flutter)"
python3 -c 'import PIL' 2>/dev/null \
  || die "python3 needs Pillow: python3 -m pip install pillow"
# A fresh build plus a simulator easily takes 4–5 GB, and running out of disk
# mid-build leaves Xcode's package cache half-extracted.
[ "$(free_mb)" -ge $((MIN_FREE_GB * 1024)) ] \
  || die "need ${MIN_FREE_GB} GB free on / (have $(($(free_mb) / 1024)) GB); override with MIN_FREE_GB"

WORK=$(mktemp -d "${TMPDIR:-/tmp}/openbike-shots.XXXXXX")
APP=$WORK/app
RAW=$WORK/raw
LOG=$WORK/flutter.log
mkdir -p "$RAW"
RUN_PID=""
SIM_UDID=""

cleanup() {
  if [ -n "$RUN_PID" ]; then
    pkill -P "$RUN_PID" 2>/dev/null || true
    kill "$RUN_PID" 2>/dev/null || true
  fi
  pkill -f "$APP/build/macos/Build/Products/Debug/OpenBike.app" 2>/dev/null || true
  if [ -n "$SIM_UDID" ]; then
    xcrun simctl shutdown "$SIM_UDID" >/dev/null 2>&1 || true
    xcrun simctl delete "$SIM_UDID" >/dev/null 2>&1 || true
  fi
  if [ "$PLATFORM" = macos ]; then
    defaults delete "$SHOTS_BUNDLE_ID" NSAppSleepDisabled >/dev/null 2>&1 || true
  fi
  if [ -n "${KEEP_WORK:-}" ]; then
    echo "work dir kept: $WORK"
  else
    rm -rf "$WORK"
  fi
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Scratch copy
# ---------------------------------------------------------------------------

log "Copying the repo to $APP"
rsync -a \
  --exclude '/build' --exclude '.dart_tool' --exclude '/.git' \
  --exclude '/ios/Pods' --exclude '/macos/Pods' --exclude '.symlinks' \
  --exclude 'ephemeral' --exclude '/docs/store' \
  --exclude '/android' --exclude '/windows' --exclude '/linux' --exclude '/web' \
  "$REPO/" "$APP/"

# Reuse Swift packages a previous build already downloaded (Sentry's binary
# frameworks alone are ~2 GB) as APFS clones, which take no extra space.
# Optional: if nothing usable is found, Xcode simply downloads them again.
seed_swift_packages() {
  local dst=$APP/build/$PLATFORM/SourcePackages src
  for src in "$REPO/build/$PLATFORM/SourcePackages" \
             "$REPO/build/ios/SourcePackages" \
             "$REPO/build/macos/SourcePackages"; do
    [ -f "$src/workspace-state.json" ] || continue
    mkdir -p "$(dirname "$dst")"
    if ! cp -c -R "$src" "$dst" 2>/dev/null; then
      rm -rf "$dst"
      continue
    fi
    # The state file records absolute artifact paths; point them at the copy.
    sed -i '' -E "s#\"[^\"]*/build/(ios|macos)/SourcePackages/#\"$dst/#g" \
      "$dst/workspace-state.json"
    log "Seeded Swift packages from $src"
    return
  done
}
seed_swift_packages

# ---------------------------------------------------------------------------
# Device
# ---------------------------------------------------------------------------

latest_ios_runtime() {
  xcrun simctl list runtimes available -j | python3 -c '
import json, sys
rts = [r for r in json.load(sys.stdin)["runtimes"]
       if ".SimRuntime.iOS-" in r["identifier"]]
rts.sort(key=lambda r: [int(x) for x in r["version"].split(".")])
print(rts[-1]["identifier"] if rts else "")'
}

if [ "$PLATFORM" = ios ]; then
  RUNTIME=${IOS_RUNTIME:-$(latest_ios_runtime)}
  [ -n "$RUNTIME" ] || die "no iOS simulator runtime installed"
  SIM_UDID=$(xcrun simctl create "OpenBike Shots $TARGET" "$DEVICE_TYPE" "$RUNTIME")
  log "Booting simulator $SIM_UDID ($DEVICE_TYPE, $RUNTIME)"
  xcrun simctl boot "$SIM_UDID"
  xcrun simctl bootstatus "$SIM_UDID" -b >/dev/null
  # en_US gives the conventional "9:41" status-bar clock rather than the
  # host locale's format (e.g. "09:41"); it only applies after a reboot.
  xcrun simctl spawn "$SIM_UDID" defaults write -g AppleLocale en_US
  xcrun simctl spawn "$SIM_UDID" defaults write -g AppleLanguages -array en
  xcrun simctl spawn "$SIM_UDID" defaults write -g AppleICUForce24HourTime -bool false
  xcrun simctl shutdown "$SIM_UDID"
  xcrun simctl boot "$SIM_UDID"
  xcrun simctl bootstatus "$SIM_UDID" -b >/dev/null
  xcrun simctl status_bar "$SIM_UDID" override --time 9:41 \
    --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 --operatorName '' \
    --batteryState charged --batteryLevel 100
  DEVICE=$SIM_UDID
else
  sed -i '' -E "s/^PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = $SHOTS_BUNDLE_ID/" \
    "$APP/macos/Runner/Configs/AppInfo.xcconfig"
  grep -q "= $SHOTS_BUNDLE_ID\$" "$APP/macos/Runner/Configs/AppInfo.xcconfig" \
    || die "could not set the screenshot bundle id in AppInfo.xcconfig"
  # A backgrounded window gets App-Napped and stops producing frames, which
  # stalls the driver's timed ride captures for minutes at a time.
  defaults write "$SHOTS_BUNDLE_ID" NSAppSleepDisabled -bool YES
  DEVICE=macos
fi

# ---------------------------------------------------------------------------
# Run the driver and capture on its markers
# ---------------------------------------------------------------------------

log "Building and running the driver on $TARGET (passes: $PASSES); log: $LOG"
log "A full run takes ~20 minutes: the ride captures wait on simulated riding."
(
  cd "$APP"
  exec caffeinate -di "$FLUTTER" run -d "$DEVICE" \
    -t tool/screenshots/driver.dart \
    --dart-define=DEV_MODE=true --dart-define=SHOTS="$PASSES"
) >"$LOG" 2>&1 </dev/null &
RUN_PID=$!

deadline=$(($(date +%s) + TIMEOUT_MIN * 60))
seen=" "
while :; do
  # iOS: the driver holds each screen for a few seconds after this marker.
  while read -r name; do
    case "$seen" in *" $name "*) continue ;; esac
    sleep 0.3
    xcrun simctl io "$SIM_UDID" screenshot --type=png "$RAW/$name.png" >/dev/null 2>&1
    seen="$seen$name "
    log "captured $name"
  done < <(grep -o 'OPENBIKE_SHOT [0-9a-z-]*' "$LOG" | awk '{print $2}')

  # macOS: the driver has already written the PNG inside its container.
  while read -r name path; do
    case "$seen" in *" $name "*) continue ;; esac
    cp "$path" "$RAW/$name.png"
    seen="$seen$name "
    log "captured $name"
  done < <(grep -o 'OPENBIKE_SAVED .*' "$LOG" | sed 's/^OPENBIKE_SAVED //')

  grep -q 'OPENBIKE_DONE' "$LOG" && break
  if ! kill -0 "$RUN_PID" 2>/dev/null \
     || grep -qE 'Error launching|Could not build|Lost connection to device' "$LOG"; then
    tail -40 "$LOG" >&2
    die "flutter run stopped before the driver finished (KEEP_WORK=1 keeps the log)"
  fi
  [ "$(free_mb)" -ge 400 ] || die "disk almost full ($(free_mb) MB free); stopped"
  [ "$(date +%s)" -lt "$deadline" ] || die "timed out after $TIMEOUT_MIN minutes"
  sleep 0.5
done

log "Writing $OUT_DIR"
python3 "$HERE/finalize.py" "$RAW" "$OUT_DIR" "$SIZE"
