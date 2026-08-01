# OpenBike app icon — v2 "Route inside"

The mark: a wheel rim whose interior is the elevation profile of the ride. One ring
(r330, stroke 46 on a 1024 grid), one ridge (stroke 38), one summit right of centre.

> This directory is **source, not build output** — despite arriving as `dist/`. What the
> app builds against is generated from it; see [Regenerating](#regenerating). Sections
> below marked _(repo)_ describe how this package is wired into OpenBike and replace the
> generic handoff instructions the package shipped with.

| Token | Value | Use |
|---|---|---|
| Accent | `#FF5A16` | route fill, brand accent |
| Ink | `#0E1216` | icon field, adaptive background |
| Paper | `#F2F0EC` | rim, ridge line |

## Two versions, on purpose

- **Primary** (`app_icon.svg`) — ink field, orange route, light rim. Everything ≥48px.
- **Inverted** (`app_icon_inverted.svg`) — orange field, silhouette route, no ridge line.
  Used for the 16/32px favicons where the ridge stroke would blur.

## Folders

```
app_icon*.png   1024 masters rendered from vector/ (see Regenerating) — mirrored into assets/icon/
vector/     source SVGs (primary, foreground, background, monochrome, inverted, transparent mark)
ios/        Icon-App-*.png
android/    mipmap-*dpi: ic_launcher + adaptive foreground / background / monochrome
macos/      16 → 1024
windows/    ico/icon-*.png
linux/      16 → 512 — the source for linux/icons/hicolor/ (repo)
web/        favicons, PWA icon-192/512, maskable variants — not wired up, web is out of scope (repo)
store/      Play listing + GitHub avatar — uploaded by hand, not part of any build (repo)
```

The per-platform PNGs are the handoff/reference set. Every platform except Linux is generated
by `flutter_launcher_icons` from the masters rather than copied from here, so editing a PNG in
this directory changes nothing on its own.

Two notes on the package as delivered: `ios/*.png` do carry an alpha channel despite the note
above claiming otherwise, and `store/play-512.png` is 1024×1024, not 512. Neither matters for
the build — `remove_alpha_ios` strips alpha from the generated iOS icons regardless.

## Regenerating _(repo)_

The launcher-icon config lives at the repo root and reads `assets/icon/`, which mirrors the
three 1024 masters at the top of this directory. v2 shipped no masters — they were rendered
from the vector source with headless Chrome, which needs no extra tooling on macOS:

```
for n in app_icon app_icon_foreground app_icon_monochrome; do
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    --headless --disable-gpu --screenshot="$n.png" --window-size=1024,1024 \
    --force-device-scale-factor=1 --default-background-color=00000000 \
    "file://$PWD/vector/$n.svg"
done
cp app_icon*.png ../assets/icon/
```

Then, from the repo root:

```
dart run flutter_launcher_icons        # Android, iOS, macOS, Windows (.ico included)
dart run flutter_native_splash:create
```

Both are configured to skip web. Linux is covered by neither tool: refresh
`linux/icons/hicolor/<size>x<size>/apps/com.openbike.open_bike.png` from `linux/openbike-<size>.png`
by hand, and keep the size list in `linux/my_application.cc` in sync with what ships here.

## Monochrome / tinted mode

Android `monochrome` and iOS tinted mode throw away colour and use **alpha** as the mask.
The mono asset is therefore a single flat colour: the route is a filled silhouette held
off the rim by a 55-unit transparent gap. Do not "fix" it by painting the gap dark — an
opaque dark shape has alpha 1 and the whole mark collapses into a solid disc.

## Safe zone

Adaptive foreground and maskable web icons keep the full mark inside the centred 683px
circle of the 1024 canvas (66%), so no mask — circle, squircle or rounded square — clips it.

## Not included

Wordmark and splash artwork are laid out in `Icon Directions.dc.html` (2e, 2f) but not
exported here — they need the Archivo font file. Ask and I'll cut them as SVG with
outlined text.
