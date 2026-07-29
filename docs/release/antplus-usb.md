# ANT+ USB dongle backend (desktop)

The ANT+ FE-C protocol stack (`lib/infrastructure/ant/` — framing, channel
init, FE-C pages, control, `AntFecTrainerAdapter`) drives trainers over a
Dynastream/Garmin ANT+ USB stick (vendor `0x0FCF`, product `0x1008`/`0x1009`)
via the `UsbBackend` interface in `ant_usb_transport.dart`. `LibusbBackend`
(`lib/infrastructure/ant/libusb_backend.dart`) implements that interface with
hand-written `dart:ffi` bindings to libusb 1.0
(`lib/infrastructure/ant/libusb_ffi_bindings.dart`), registered in
`main.dart` on Linux/macOS/Windows.

It's scoped to the one device family this app talks to: instead of walking
libusb's configuration/interface/endpoint descriptor tree, it hardcodes
interface `0` and the bulk endpoint addresses (`0x81` IN / `0x01` OUT) those
sticks expose on it — the same values used by other open-source ANT+
libraries (e.g. `openant`) for this hardware.

## What's implemented vs. what's still manual

- ✅ FFI bindings (`libusb_ffi_bindings.dart`) — struct layouts and function
  signatures verified against a real `libusb-1.0.so` in development (init,
  device enumeration, descriptor reads, and clean exit all returned the
  expected results).
- ✅ `LibusbBackend` — full `UsbBackend` implementation (open, bulk
  transfer in/out, dispose).
- ✅ `AntDevicePlugin` registered in `main.dart` on desktop, wrapped in a
  `try`/`catch` so a missing/bad libusb binary logs a warning and skips
  registration instead of crashing startup.
- ⬜ **Bundling a real libusb binary into the app** — `DynamicLibrary.open`
  expects `libusb-1.0.dll` / `libusb-1.0.dylib` / `libusb-1.0.so.0` to be
  loadable at runtime (adjacent to the app executable, or already on the
  platform's shared-library search path). No binary is committed to this
  repo yet — see below.
- ⬜ `[HW]` a real dongle + trainer session, per `P8-desktop.md`.

## Sourcing and bundling the binary

libusb is LGPL-2.1 — dynamic linking (what this does) doesn't require the
app to be open source, but the license text must ship alongside the binary.

1. Get official prebuilt binaries from the
   [libusb releases page](https://github.com/libusb/libusb/releases) (or
   build from source), or via a package manager:
   - macOS: `brew install libusb` → `$(brew --prefix libusb)/lib/libusb-1.0.dylib`
   - Windows: [vcpkg](https://vcpkg.io) `vcpkg install libusb` or the
     official Windows binary release (`libusb-1.0.dll`)
   - Linux: usually already present as a system package
     (`libusb-1.0-0`/`libusb1`); `LibusbBackend` opens the versioned
     `libusb-1.0.so.0` SONAME so a system install is picked up directly —
     desktop Linux users installing via a package manager get this for
     free, no bundling needed.
2. **macOS**: add the `.dylib` under `macos/Runner/` and wire it into
   `macos/Runner.xcodeproj` as an embedded framework/library (a "Copy
   Files" build phase, `Frameworks` destination) so it lands in
   `OpenBike.app/Contents/Frameworks/` — same mechanism the `quick_usb`
   pub package uses for its own bundled `libusb-1.0.dylib`
   (`s.vendored_libraries` in a podspec is the CocoaPods equivalent if this
   ever moves to a plugin package instead of an app-local binary).
3. **Windows**: add the `.dll` under `windows/` and a
   `set(...)`/`add_custom_command(TARGET ... POST_BUILD COMMAND
   ${CMAKE_COMMAND} -E copy ...)` step in `windows/CMakeLists.txt` (or list
   it in the runner's `CMakeLists.txt` `BUNDLED_LIBRARIES`, mirroring how
   `quick_usb`'s Windows CMake bundles its own `libusb-1.0.23.dll`) so it
   ends up next to `open_bike.exe`.
4. Add a `THIRD_PARTY_LICENSES` (or equivalent) entry citing libusb's
   LGPL-2.1 license alongside whichever binary gets bundled.

## Fixing the "For now" simplifications from earlier phases

Two hardcodes from the original ANT+ scan/connect implementation are now
resolved via `AntUsbTransport.requestChannelId()` (a `0x4D` Request
Message asking the dongle to report the real channel ID):

- `scan()` used to report every discovered trainer as `ant_fec_0`; it now
  requests the channel ID once a broadcast is heard and uses the real
  device number (`ant_fec_<deviceNumber>`).
- `connect()` used to always open a wildcard channel (`deviceNumber: 0`,
  "accept any device"); it now parses the device number back out of
  `device.id` and locks the channel to that specific trainer.
