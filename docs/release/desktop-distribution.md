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
`libsecret-1-0`, `libjsoncpp`, `libcurl`, plus a running BlueZ — and
`linux/com.openbike.open_bike.desktop` isn't installed anywhere, so there's no
menu entry or icon.

### Options

| Option | Cost | Reach | Effort |
|---|---|---|---|
| **Flathub** | free | the de facto Linux app store; surfaces in GNOME Software & KDE Discover | manifest PR to `flathub/flathub`, bundles its own deps |
| Snap | free | Ubuntu default | `snapcraft.yaml`; BlueZ needs a manual interface connection |
| AppImage | free | universal single file | easiest to automate; no discovery, no updates |
| `.deb` / `.rpm` | free | distro-native | per-distro maintenance |
| `tar.gz` *(current)* | free | none | already done; keep as fallback |

**Recommendation: keep the `tar.gz`, and target Flathub as the real channel —
but not yet.** `docs/roadmap/P8-desktop.md` still lists Linux BLE as
unverified (the `flutter_blue_plus` BlueZ backend has had no hardware QA). A
store listing sets an expectation a best-effort tarball doesn't, so confirm a
real trainer connects on Linux first. AppImage is a reasonable intermediate
step if you want a better download without committing to a listing.

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
