# macOS release signing & notarization

Release DMGs are signed with a Developer ID Application certificate, run
through the hardened runtime, and notarized by Apple — required for the app
to launch without a Gatekeeper warning on a machine that isn't the one that
built it. When the signing secrets below aren't configured, CI still builds
and uploads an **unsigned** `.app` / `.dmg` artifact so the pipeline works
for every contributor; only the tag-triggered release job attempts signing.

Entitlements (`macos/Runner/Release.entitlements`) are already in place —
sandbox, network client, Bluetooth, and USB (ANT+ dongle, see
`P8-desktop.md` §5) — from P1. This document only covers the
certificate/notarization side.

## Requirements

- An active [Apple Developer Program](https://developer.apple.com/programs/)
  membership (individual or organization).
- A **Developer ID Application** certificate, exported as a `.p12` with a
  password.
- Either an app-specific password for the Apple ID that owns the cert, or an
  App Store Connect API key — either works with `xcrun notarytool`.

## Generate a Developer ID Application certificate

1. Xcode → Settings → Accounts → your Apple ID → Manage Certificates → `+`
   → **Developer ID Application**. (Or via the
   [developer.apple.com certificate portal](https://developer.apple.com/account/resources/certificates/list).)
2. Export it from Keychain Access as a `.p12`, setting an export password.

## Configure GitHub Actions secrets

| Secret | Value |
|---|---|
| `MACOS_CERTIFICATE_P12` | Base64 of the exported `.p12` (`base64 -i cert.p12 \| pbcopy`) |
| `MACOS_CERTIFICATE_PASSWORD` | The `.p12` export password |
| `MACOS_SIGNING_IDENTITY` | Certificate common name, e.g. `Developer ID Application: Your Org (TEAMID)` |
| `APPLE_TEAM_ID` | 10-character Apple Developer Team ID |
| `APPLE_ID` | Apple ID email used for notarization |
| `APPLE_APP_SPECIFIC_PASSWORD` | App-specific password ([appleid.apple.com](https://appleid.apple.com) → Sign-In and Security → App-Specific Passwords) |

(An App Store Connect API key — `APPLE_API_KEY_ID` / `APPLE_API_ISSUER` /
`APPLE_API_KEY_P8` — works as a drop-in alternative to
`APPLE_ID`/`APPLE_APP_SPECIFIC_PASSWORD` for `notarytool`; use whichever the
team already has.)

Never commit the `.p12`, its password, or app-specific passwords — add them
as repository secrets (Settings → Secrets and variables → Actions), same
pattern as `STRAVA_CLIENT_ID`/`STRAVA_CLIENT_SECRET` (see
`docs/release/secrets.md`).

## What the release job does (tag-triggered, `macos` job in `.github/workflows/release.yml`)

1. `flutter build macos --release` — produces `build/macos/Build/Products/Release/OpenBike.app`.
2. If `MACOS_CERTIFICATE_P12` is set: import the cert into a temporary
   keychain, `codesign --deep --force --options runtime --entitlements
   macos/Runner/Release.entitlements --sign "$MACOS_SIGNING_IDENTITY"` the
   `.app`.
3. Package with `create-dmg` (`brew install create-dmg` / npm `create-dmg`
   — CI installs it as a job step) into `OpenBike.dmg`.
4. If signed: `xcrun notarytool submit OpenBike.dmg --apple-id
   "$APPLE_ID" --password "$APPLE_APP_SPECIFIC_PASSWORD" --team-id
   "$APPLE_TEAM_ID" --wait`, then `xcrun stapler staple OpenBike.dmg`.
5. Upload `OpenBike.dmg` as a workflow artifact, which the workflow's
   `publish-release` job then attaches to the tag's GitHub Release
   alongside the other platforms — see `docs/release/checklist.md`.

Local manual signing follows the same three `codesign`/`create-dmg`/
`notarytool` steps — run them directly against a local `flutter build macos
--release` output using your own Developer ID cert loaded in your login
keychain (no need to import a `.p12` when the cert is already there).
