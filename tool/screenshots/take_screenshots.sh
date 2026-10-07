#!/bin/bash
#
# Captures OpenBike's App Store and Google Play screenshots. See
# tool/screenshots/README.md.
#
#   tool/screenshots/take_screenshots.sh <target> [passes]
#
# target: ios-6.9, ios-6.3, ipad-13, macos, android-phone, android-7in,
#         android-10in
# passes: comma-separated subset of static,ftp,route,workout (default: all).
# Writes only the captured files into docs/store/screenshots/<target>/
# (override with OUT_DIR=...), as opaque RGB PNGs at the exact store size.
#
# Builds from a throwaway copy of the repo, never the working tree: the first
# iOS/macOS build with a newer Flutter can rewrite tracked Xcode and Pod
# files, and the macOS copy gets its own bundle id so it never shares a sandbox
# container with a real install. iOS and Android targets run on a dedicated
# simulator/emulator that is deleted afterwards. The driver itself keeps its
# database and preferences in memory.

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
  # Google Play: no side longer than twice the other, and tablet shots must
  # be exactly 9:16 with both sides >= 1080 px to qualify for promotion. The
  # tablets use a tablet density so the app lays out at >= 600 dp, as on a
  # real 7"/10" tablet.
  android-phone)
    PLATFORM=android SIZE=1080x1920 LCD_DENSITY=420 ;;
  android-7in)
    PLATFORM=android SIZE=1080x1920 LCD_DENSITY=280 ;;
  android-10in)
    PLATFORM=android SIZE=1440x2560 LCD_DENSITY=280 ;;
  *)
    echo "usage: $0 <ios-6.9|ios-6.3|ipad-13|macos|android-phone|android-7in|android-10in> [static,ftp,route,workout]" >&2
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

if [ "$PLATFORM" = android ]; then
  flutter_config() {
    "$FLUTTER" config --machine 2>/dev/null | python3 -c \
      "import json, sys; print(json.load(sys.stdin).get('$1', ''))" 2>/dev/null || true
  }
  SDK=${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$(flutter_config android-sdk)}}
  SDK=${SDK:-$HOME/Library/Android/sdk}
  ADB=$SDK/platform-tools/adb
  EMULATOR=$SDK/emulator/emulator
  [ -x "$ADB" ] && [ -x "$EMULATOR" ] \
    || die "Android SDK with platform-tools and emulator not found (set ANDROID_HOME)"
  ABI=$([ "$(uname -m)" = arm64 ] && echo arm64-v8a || echo x86_64)
  # Newest installed phone image (google_apis or Play) for this host's ABI.
  latest_android_image() {
    local dir rel
    for dir in "$SDK"/system-images/android-*/google_apis*/"$ABI"; do
      [ -d "$dir" ] || continue
      case "$dir" in *_tablet/* | *_tv/* | *_wear/* | *_automotive/*) continue ;; esac
      rel=${dir#"$SDK"/system-images/}
      echo "system-images;${rel//\//;}"
    done | sort -t';' -k2,2V | tail -1
  }
  IMAGE=${ANDROID_IMAGE:-$(latest_android_image)}
  [ -n "$IMAGE" ] || die "no Android system image installed for $ABI (sdkmanager \"system-images;android-36;google_apis_playstore;$ABI\")"
fi

WORK=$(mktemp -d "${TMPDIR:-/tmp}/openbike-shots.XXXXXX")
APP=$WORK/app
RAW=$WORK/raw
LOG=$WORK/flutter.log
mkdir -p "$RAW"
RUN_PID=""
SIM_UDID=""
EMU_PID=""
SERIAL=""

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
  if [ -n "$EMU_PID" ]; then
    "$ADB" -s "$SERIAL" emu kill >/dev/null 2>&1 || true
    sleep 2
    kill "$EMU_PID" 2>/dev/null || true
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
EXCLUDES=(
  --exclude '/build' --exclude '.dart_tool' --exclude '/.git'
  --exclude '/ios/Pods' --exclude '/macos/Pods' --exclude '.symlinks'
  --exclude 'ephemeral' --exclude '/docs/store'
  --exclude '/windows' --exclude '/linux' --exclude '/web'
)
if [ "$PLATFORM" = android ]; then
  # Signing material isn't needed for a debug build; don't copy it around.
  EXCLUDES+=(--exclude '/android/.gradle' --exclude '/android/app/build'
             --exclude 'key.properties' --exclude '*.jks' --exclude '*.keystore')
else
  EXCLUDES+=(--exclude '/android')
fi
rsync -a "${EXCLUDES[@]}" "$REPO/" "$APP/"

if [ "$PLATFORM" = android ]; then
  # One-shot Gradle daemon: nothing lingers in memory after the run.
  printf '\norg.gradle.daemon=false\n' >>"$APP/android/gradle.properties"
fi

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
[ "$PLATFORM" = android ] || seed_swift_packages

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
elif [ "$PLATFORM" = android ]; then
  # The AVD lives in the work dir, so it never shows up in (or touches)
  # ~/.android/avd and disappears with the cleanup.
  export ANDROID_AVD_HOME=$WORK/avd
  mkdir -p "$ANDROID_AVD_HOME"
  AVD=openbike_shots
  # The AVD config is written directly rather than with avdmanager: configs
  # from an avdmanager older than the emulator can make the emulator skip the
  # hypervisor and crash in software emulation. Keys mirror what Android
  # Studio writes, minus device skins and cameras.
  IFS=';' read -r _ API TAG _ <<<"$IMAGE"
  log "Creating emulator (${SIZE} @ ${LCD_DENSITY} dpi, $IMAGE)"
  mkdir -p "$ANDROID_AVD_HOME/$AVD.avd"
  printf 'avd.ini.encoding=UTF-8\npath=%s\ntarget=%s\n' \
    "$ANDROID_AVD_HOME/$AVD.avd" "$API" >"$ANDROID_AVD_HOME/$AVD.ini"
  cat >"$ANDROID_AVD_HOME/$AVD.avd/config.ini" <<EOF
AvdId=$AVD
avd.ini.displayname=OpenBike screenshots
avd.ini.encoding=UTF-8
PlayStore.enabled=$([[ $TAG == *playstore* ]] && echo true || echo false)
abi.type=$ABI
disk.dataPartition.size=6G
fastboot.forceColdBoot=yes
hw.accelerometer=yes
hw.arc=false
hw.audioInput=no
hw.battery=yes
hw.camera.back=none
hw.camera.front=none
hw.cpu.arch=$([ "$ABI" = arm64-v8a ] && echo arm64 || echo x86_64)
hw.cpu.ncore=4
hw.dPad=no
hw.gps=yes
hw.gpu.enabled=yes
hw.gpu.mode=auto
hw.initialOrientation=portrait
hw.keyboard=yes
hw.lcd.density=$LCD_DENSITY
hw.lcd.width=${SIZE%x*}
hw.lcd.height=${SIZE#*x}
hw.mainKeys=no
hw.ramSize=2048
hw.sdCard=no
hw.sensors.orientation=yes
hw.sensors.proximity=yes
hw.trackBall=no
image.sysdir.1=system-images/$API/$TAG/$ABI/
runtime.network.latency=none
runtime.network.speed=full
showDeviceFrame=no
skin.dynamic=no
skin.name=$SIZE
skin.path=_no_skin
tag.id=$TAG
tag.ids=$TAG
target=$API
vm.heapSize=256
EOF

  PORT=5584
  while "$ADB" devices | grep -q "^emulator-${PORT}[[:space:]]"; do PORT=$((PORT + 2)); done
  SERIAL=emulator-$PORT
  log "Booting $SERIAL headless"
  "$EMULATOR" -avd "$AVD" -port "$PORT" -no-window -no-audio -no-boot-anim \
    -no-snapshot ${EMULATOR_GPU:+-gpu "$EMULATOR_GPU"} \
    >"$WORK/emulator.log" 2>&1 &
  EMU_PID=$!
  boot_deadline=$(($(date +%s) + 600))
  until [ "$("$ADB" -s "$SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ]; do
    kill -0 "$EMU_PID" 2>/dev/null || { tail -20 "$WORK/emulator.log" >&2; die "emulator exited during boot"; }
    [ "$(date +%s)" -lt "$boot_deadline" ] || die "emulator didn't boot within 10 minutes"
    sleep 3
  done

  adbs() { "$ADB" -s "$SERIAL" "$@"; }
  # Gesture navigation (a thin handle instead of the 3-button bar) and a
  # 12-hour clock, then System UI demo mode: 9:41, full battery and signal,
  # no notification icons (the ride's foreground-service notification would
  # otherwise show).
  adbs shell cmd overlay enable com.android.internal.systemui.navbar.gestural >/dev/null 2>&1 || true
  adbs shell settings put system time_12_24 12
  demo() { adbs shell am broadcast -a com.android.systemui.demo -e command "$@" >/dev/null; }
  demo_allowed() {
    [ "$(adbs shell settings get global sysui_demo_allowed 2>/dev/null | tr -d '\r')" = 1 ]
  }
  # System UI ignores demo-mode broadcasts unless sysui_demo_allowed is 1, and
  # first-boot setup can reset that setting a minute or so after boot, so this
  # runs again whenever the setting has been reset (see the capture loop).
  # The network order matters on recent System UI: mobile hidden first, then
  # Wi-Fi, gives a stable bar (9:41 and battery only), while other orders let a
  # "no service"/satellite icon creep back in.
  status_bar_demo() {
    for _ in $(seq 1 30); do
      adbs shell settings put global sysui_demo_allowed 1 >/dev/null 2>&1 || true
      demo_allowed && break
      sleep 2
    done
    sleep 1
    demo enter
    demo clock -e hhmm 0941
    demo battery -e level 100 -e plugged false -e powersave false
    demo network -e mobile hide
    demo network -e wifi show -e level 4 -e fully true -e ssid OpenBike -e activity none
    demo notifications -e visible false
    sleep 1.5
  }
  status_bar_demo
  APP_ID=$(sed -nE 's/^[[:space:]]*applicationId = "([^"]+)".*/\1/p' "$APP/android/app/build.gradle.kts" | head -1)
  [ -n "$APP_ID" ] || die "could not read applicationId from android/app/build.gradle.kts"
  DEVICE=$SERIAL
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
granted=""
while :; do
  # Android: once the app is installed and running, grant what a real rider
  # grants while pairing. The ride's connectedDevice foreground service needs
  # a Bluetooth permission on Android 14+, and Android 13+ would otherwise ask
  # for notifications on screen when recording starts.
  if [ "$PLATFORM" = android ] && [ -z "$granted" ] && grep -q 'OPENBIKE_VIEW' "$LOG"; then
    for perm in POST_NOTIFICATIONS BLUETOOTH_SCAN BLUETOOTH_CONNECT; do
      adbs shell pm grant "$APP_ID" "android.permission.$perm" >/dev/null 2>&1 || true
    done
    # Demo mode is idempotent; re-applying once the app runs covers a System
    # UI that wasn't ready yet when the emulator first reported booted.
    status_bar_demo
    granted=1
  fi

  # iOS/Android: the driver holds each screen for a few seconds after this
  # marker.
  while read -r name; do
    case "$seen" in *" $name "*) continue ;; esac
    sleep 0.3
    if [ "$PLATFORM" = android ]; then
      demo_allowed || status_bar_demo
      adbs exec-out screencap -p >"$RAW/$name.png"
    else
      xcrun simctl io "$SIM_UDID" screenshot --type=png "$RAW/$name.png" >/dev/null 2>&1
    fi
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
