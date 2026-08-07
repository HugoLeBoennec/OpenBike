# Windows & Linux distribution

Neither platform needs anything resembling the Apple/Google enrollment in
`docs/release/store-setup.md`. Windows has one decision to make about signing;
Linux has none at all.

## Windows

### The problem with what CI produces today

`.github/workflows/release.yml`'s `windows` job runs `dart run msix:create`
with no certificate configured, so the `msix` tool **self-signs with a
generated test certificate**. Windows refuses to install an MSIX whose signing
certificate it doesn't trust, and there is no "install anyway" button — the
user would have to extract the certificate and add it to Local Machine →
Trusted People by hand first.

So the current `.msix` is fine as a CI artifact and for sideloading on your own
machine, but it is **not installable by an ordinary user**. Pick a real channel
below before advertising a Windows download.

### Options

| Option | Cost | Install UX | Notes |
|---|---|---|---|
| **Microsoft Store** | **free** | one click, auto-updates | Microsoft signs the package for you |
| Azure Trusted Signing | $9.99/mo | one click | short-lived certs, designed for CI |
| Traditional OV cert | ~$200–400/yr | one click | since 2023 the key must live on an HSM/hardware token — awkward in CI |
| Plain portable `.zip` | free | unzip & run, SmartScreen warning | no installer, no updates, always works |
| Self-signed MSIX *(current)* | free | **effectively broken** | see above |

**Recommendation: Microsoft Store as the primary channel, plus a portable
`.zip` on GitHub Releases for people who avoid the Store.** Store registration
became free for individual developers, and free for company accounts in May
2026, so the main reason to avoid it is gone. It also solves SmartScreen
reputation and auto-updates, neither of which a direct download gives you.

Use Azure Trusted Signing instead only if you specifically want signed direct
downloads without a Store listing.

### Microsoft Store steps

1. Register at <https://partner.microsoft.com/dashboard> (free; identity
   verification, no credit card).
2. Reserve the app name **OpenBike** under Apps and games → New product.
3. Partner Center then shows the identity values it assigned, under Product
   management → Product identity: `Package/Identity/Name`,
   `Package/Identity/Publisher`, and the publisher display name.
4. Copy those into `pubspec.yaml`'s `msix_config`. **They must match exactly**
   or the Store rejects the upload. The current values are placeholders that
   only suit sideloading:

   ```yaml
   msix_config:
     display_name: OpenBike
     identity_name: 12345HugoLeBoennec.OpenBike   # from Partner Center
     publisher: CN=ABCD1234-...                    # from Partner Center
     publisher_display_name: <your Partner Center publisher name>
     logo_path: assets/icon/app_icon.png
     capabilities: internetClient, bluetooth
   ```

5. Build a Store package — no certificate involved, the Store signs it:

   ```bash
   flutter build windows --release
   dart run msix:create --store --build-windows false
   ```

6. Upload the `.msix` in Partner Center and submit.

### Portable ZIP (do this regardless — it's ~4 lines of CI)

Zip `build/windows/x64/runner/Release/` whole. Users unzip and run
`open_bike.exe`; SmartScreen shows a one-time "unknown publisher" warning that
they can click through via More info → Run anyway.

Note the machine needs the **Microsoft Visual C++ Redistributable** — most
Windows machines already have it, but say so on the release page.

## Linux

**Nothing to register, nothing to buy, nothing to sign.** Linux has no
equivalent of Apple/Microsoft code signing for desktop apps; the closest thing
is publishing through a distro/store that builds and signs on its own infra.

### The problem with what CI produces today

The `linux` job tars up `build/linux/x64/release/bundle`. That works, but the
user must already have the runtime libraries installed — `libgtk-3-0`,
`libsecret-1-0`, `libjsoncpp`, `libcurl`, plus a running BlueZ.

The desktop entry and icons are **not** missing from the tarball, which is easy
to assume: the `install()` rules at the end of `linux/CMakeLists.txt` put a
full hicolor theme and the `.desktop` file inside the bundle, at
`data/icons/hicolor/*/apps/run.records.openbike.png` and
`data/applications/run.records.openbike.desktop`. What is missing is
**registration** — nothing copies those two trees into the XDG directories the
desktop environment actually searches, so extracting the tarball gives you a
working binary with no menu entry.

That distinction is why `scripts/install-linux.sh` exists (see *Command-line
install* below) rather than a repackaging format: the payload is already
correct, it just needs to land in the right place.

### Options

| Option | Cost | Reach | Effort |
|---|---|---|---|
| **Flathub** | free | the de facto Linux app store; surfaces in GNOME Software & KDE Discover | manifest PR to `flathub/flathub`, bundles its own deps |
| Snap | free | Ubuntu default | `snapcraft.yaml`; BlueZ needs a manual interface connection |
| AppImage | free | universal single file | glibc floor + FUSE dependency, and still no menu entry — see *Why not AppImage* |
| `.deb` / `.rpm` | free | distro-native | per-distro maintenance |
| `tar.gz` + `install.sh` *(current)* | free | direct download | already done; one-command install, see *Command-line install* |

**Recommendation: keep the `tar.gz`, and target Flathub as the real channel —
but not yet.** `docs/roadmap/P8-desktop.md` still lists Linux BLE as
unverified (the `flutter_blue_plus` BlueZ backend has had no hardware QA). A
store listing sets an expectation a best-effort tarball doesn't, so confirm a
real trainer connects on Linux first. In the meantime `scripts/install-linux.sh`
gives the tarball a one-command install without committing to a listing;
AppImage is *not* the intermediate step it first looks like — see *Why not
AppImage* below.

### Flatpak sandbox permissions — the part that's easy to get wrong

OpenBike will not work inside a Flatpak sandbox with default permissions. The
manifest's `finish-args` must include D-Bus access to BlueZ, or scanning
silently finds nothing:

```yaml
finish-args:
  - --share=network            # Strava upload, map tiles
  - --socket=wayland
  - --socket=fallback-x11
  - --device=dri
  - --allow=bluetooth          # AF_BLUETOOTH sockets
  - --system-talk-name=org.bluez   # required — BLE goes through BlueZ on D-Bus
  - --device=all               # only if shipping ANT+ USB (see antplus-usb.md)
```

Flathub reviewers ask for a justification for `--device=all`; if ANT+ USB
support isn't shipping in the first Linux release, leave it out and add it
later with a note pointing at `docs/release/antplus-usb.md`.

### If you stay on direct downloads

Publish a `SHA256SUMS` file alongside the tarball, and optionally sign it with
GPG. That is the normal integrity story for Linux downloads — there is no
OS-level trust prompt to satisfy.

### Command-line install

`scripts/install-linux.sh` is published as a release asset by the `linux` job,
so the documented one-liner is:

```bash
curl -fsSL https://github.com/HugoLeBoennec/OpenBike/releases/latest/download/install.sh | sh
```

It downloads the tarball, **verifies it against `SHA256SUMS` and aborts on a
mismatch** (which is what makes publishing that file worth anything), then
installs entirely under `$HOME` — no root:

| Path | Contents |
|---|---|
| `$XDG_DATA_HOME/openbike/` | the unpacked bundle |
| `~/.local/bin/openbike` | symlink to the binary |
| `$XDG_DATA_HOME/applications/` | the `.desktop` entry |
| `$XDG_DATA_HOME/icons/hicolor/` | the per-size app icons |

Two details worth knowing before editing it:

- It **rewrites `Exec=`** to an absolute path. The shipped entry has a bare
  `Exec=open_bike`, which only resolves when `~/.local/bin` is on `PATH` —
  frequently untrue for the environment a desktop launcher starts from.
- It copies **only** `run.records.openbike.png` out of the icon theme rather
  than the `hicolor` directory wholesale, so it cannot clobber a user's
  `index.theme`.

`--uninstall` reverses all of it; `--version vX.Y.Z` pins a release.

### Why not AppImage

AppImage's one real benefit is bundling dependencies, and OpenBike's are
`libgtk-3`, `libsecret-1`, `libjsoncpp` and `libcurl` — present on essentially
every desktop Linux install. So it bundles libraries the user already has,
while adding:

- **A glibc floor.** AppImage does not bundle glibc, so the image only runs on
  glibc ≥ the build host's. Built on `ubuntu-latest` it will not start on
  Ubuntu 22.04 or Debian 12, presented to users as "your AppImage is broken."
  (This applies to the tarball too — see the note in `release.yml`'s `linux`
  job if it gets pinned to an older runner.)
- **A FUSE dependency.** Type-2 AppImages need `libfuse2`, which Ubuntu has not
  installed by default since 22.04, producing a cryptic
  `error loading libfuse.so.2`.
- **No desktop integration anyway.** The `.desktop` file inside an AppImage is
  not registered by anything; the user needs `appimaged`, Gear Lever or
  AppImageLauncher. A bare AppImage gives *worse* menu/icon integration than
  the tarball plus the install script above.

Bundling GTK properly is also the fiddly part — `gdk-pixbuf` loader caches,
GIO modules and GSettings schema compilation all need handling, and none of it
is testable in CI without real distro images.

Flatpak solves the same problem with discovery, sandboxing, auto-updates and a
build farm, so effort is better spent on the Flathub manifest when Linux is
ready for it. AppImage is a detour rather than a step toward that.
