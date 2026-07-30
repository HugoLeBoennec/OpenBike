# Store account & certificate setup

One-time setup to go from "builds locally" to "submittable". Do this **before**
tagging a release — `docs/release/checklist.md` assumes the accounts,
identifiers and signing secrets described here already exist.

Order matters: the permanent decisions in §0 cannot be undone once the first
build is uploaded, and the Play tester requirement in §2 has a 14-day floor
that dominates the whole schedule.

## 0. Decide these first — they are permanent

| Decision | Current value | Can it change later? |
|---|---|---|
| iOS/macOS bundle ID | `com.openbike.openBike` | **No**, once uploaded to App Store Connect |
| Android package name | `com.openbike.open_bike` | **No**, once uploaded to Play |
| App Store app name | `OpenBike` | Renamable, but must be globally unique at creation |
| Play developer account type | *undecided* | **No** — see §2, this is the big one |
| Apple account type | *undecided* | Switching individual → organization means re-enrolling |

The iOS and Android identifiers differ (`openBike` vs `open_bike`). That is
harmless — Apple and Google are separate namespaces and neither cares what the
other uses — but check both are actually free before enrolling, because you
only find out at creation time.

`com.openbike.*` is reverse-DNS for a domain you may not own. Neither store
verifies this, so it is fine in practice; only revisit if you later acquire a
domain you'd rather key the identity to.

## 1. Apple — $99/year, 1–2 days

### 1a. Enrol

<https://developer.apple.com/programs/enroll/>

- **Individual**: fast (often same day). Your legal name is shown publicly as
  the seller on the App Store.
- **Organization**: requires a [D-U-N-S number](https://developer.apple.com/enroll/duns-lookup/)
  and takes 1–2 weeks. Shows a company name as the seller.

One membership covers iOS, macOS, TestFlight and notarization.

### 1b. Register the App ID

<https://developer.apple.com/account/resources/identifiers/list> → `+` →
App IDs → App → Bundle ID `com.openbike.openBike` (explicit, not wildcard).

OpenBike needs **no** extra capabilities enabled here. Its Bluetooth usage,
background mode and `openbike://` URL scheme are all declared in
`ios/Runner/Info.plist` and none of them is an entitlement. Leave every
capability checkbox off.

### 1c. Create the App Store Connect record

<https://appstoreconnect.apple.com> → Apps → `+` → New App.

- Platform: iOS. Name: `OpenBike` (globally unique across the App Store — if
  taken, pick another and set it here; the on-device name stays whatever
  `CFBundleDisplayName` says).
- Bundle ID: the one from §1b. SKU: any internal string, e.g. `openbike-ios`.
- Category: Health & Fitness (per `docs/release/app-store.md`).

### 1d. Certificates

Two different certificates, for two different distribution channels:

| Target | Certificate | Used for |
|---|---|---|
| iOS App Store / TestFlight | **Apple Distribution** | `.ipa` upload |
| macOS `.dmg` direct download | **Developer ID Application** | signing + notarizing outside the Mac App Store |

Easiest path for both — Xcode manages the App Store one for you:

1. Open `ios/Runner.xcworkspace` in Xcode → Runner target → Signing &
   Capabilities → check *Automatically manage signing* → pick your Team.
   Xcode creates the Apple Distribution cert and provisioning profile.
   (The `CODE_SIGN_IDENTITY = "iPhone Developer"` currently in
   `ios/Runner.xcodeproj/project.pbxproj` is the stock Flutter template value;
   Xcode overrides it once a Team is set. Commit the resulting `DEVELOPMENT_TEAM`
   change.)
2. Developer ID (macOS) — Xcode → Settings → Accounts → your Apple ID →
   Manage Certificates → `+` → **Developer ID Application**. Full detail in
   `docs/release/macos-signing.md`.

Then create an **app-specific password** at
<https://appleid.apple.com> → Sign-In and Security → App-Specific Passwords.
Notarization needs it.

### 1e. Export the CI secrets

Only needed to build signed artifacts *in GitHub Actions*. You can skip this
entirely and archive/upload from Xcode on this Mac instead — see §5.

```bash
# Apple Distribution cert (iOS) — export from Keychain Access as .p12 first
base64 -i ios-dist.p12 | pbcopy          # → IOS_DIST_CERTIFICATE_P12
# Developer ID cert (macOS) — likewise
base64 -i developer-id.p12 | pbcopy      # → MACOS_CERTIFICATE_P12
# Provisioning profile, downloaded from the developer portal
base64 -i OpenBike_AppStore.mobileprovision | pbcopy   # → IOS_PROVISIONING_PROFILE_BASE64
```

`IOS_EXPORT_OPTIONS_PLIST_BASE64` is the base64 of this file (substitute your
10-character Team ID and the profile's *name*, not its filename):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store-connect</string>
  <key>teamID</key>
  <string>ABCDE12345</string>
  <key>signingStyle</key>
  <string>manual</string>
  <key>uploadSymbols</key>
  <true/>
  <key>provisioningProfiles</key>
  <dict>
    <key>com.openbike.openBike</key>
    <string>OpenBike App Store</string>
  </dict>
</dict>
</plist>
```

(`method` is `app-store-connect` on Xcode 15+; older Xcode wants `app-store`.)

## 2. Google Play — $25 once, and a 14-day floor

### 2a. Choose the account type — this sets your timeline

<https://play.google.com/console/signup>

**A personal account created after 13 Nov 2023 must run a closed test with at
least 12 testers opted in continuously for 14 days before it can even apply for
production access.** The testers must actually install and use the app; if the
count drops below 12 the 14-day clock restarts. Organization accounts
registered to a legal business entity are exempt.

So:

- **Personal ($25)** — cheapest, but budget **~3 weeks minimum** from account
  creation to a public listing, and line up 12 real people with Google accounts
  and Android devices before you start.
- **Organization ($25 + D-U-N-S)** — no tester requirement, but you need a
  registered legal entity and the identity verification takes longer.

For an open-source project, recruiting 12 testers from the community is
usually easier than incorporating — but start recruiting *now*, because the
14 days run in parallel with nothing else.

See <https://support.google.com/googleplay/android-developer/answer/14151465>.

### 2b. Create the app

Play Console → Create app → name, default language, App/Game, Free/Paid,
declarations. Then Play Console walks you through the content forms already
answered in `docs/release/play-store.md` (Data Safety, content rating,
foreground-service justification, privacy policy URL).

### 2c. Signing key

Generate an upload keystore per `docs/release/android-signing.md`:

```bash
keytool -genkey -v -keystore ~/openbike-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias openbike
```

Enrol in **Play App Signing** (default for new apps): Google holds the real app
signing key, and your keystore is only the *upload* key. This matters — if you
lose an upload key Google can reset it, whereas losing the app signing key on a
non-Play-App-Signing app permanently orphans the listing.

Back the `.jks` and its passwords up somewhere durable (password manager).
Never commit it; `android/key.properties` is gitignored.

## 3. Windows — no certificate needed if you use the Store

See `docs/release/desktop-distribution.md`. Short version: the self-signed
MSIX the release workflow currently produces **cannot be installed by a normal
user**, so pick a real channel before advertising a Windows download.

## 4. Linux — nothing to buy, nothing to sign

See `docs/release/desktop-distribution.md`. No account, no certificate, no fee.

## 5. You do not have to use CI for the first submission

Every signing secret in §1e exists only so GitHub Actions can build signed
artifacts unattended. For a first release it is usually faster and easier to
build and upload from this Mac:

```bash
export PATH="$HOME/Developer/flutter/bin:$PATH"

# iOS → App Store Connect
flutter build ipa --release \
  --dart-define=STRAVA_CLIENT_ID=... --dart-define=STRAVA_CLIENT_SECRET=...
open build/ios/archive/Runner.xcarchive      # → Xcode Organizer → Distribute App

# Android → Play Console (upload the .aab by hand)
flutter build appbundle --release \
  --dart-define=STRAVA_CLIENT_ID=... --dart-define=STRAVA_CLIENT_SECRET=...
```

Wire up the CI secrets once the manual path has worked at least once — that way
a signing failure in CI is never the thing blocking your first submission.

## 6. Secrets reference

Repository → Settings → Secrets and variables → Actions. Every one of these is
optional; each job degrades to an unsigned artifact when its secret is absent
(see the per-job comments in `.github/workflows/release.yml`).

| Secret | Platform | Source |
|---|---|---|
| `ANDROID_KEYSTORE_BASE64` | Android | §2c, `base64 -i openbike-release.jks` |
| `ANDROID_KEYSTORE_PASSWORD` / `ANDROID_KEY_PASSWORD` / `ANDROID_KEY_ALIAS` | Android | §2c |
| `IOS_DIST_CERTIFICATE_P12` / `IOS_DIST_CERTIFICATE_PASSWORD` | iOS | §1e |
| `IOS_PROVISIONING_PROFILE_BASE64` | iOS | §1e |
| `IOS_EXPORT_OPTIONS_PLIST_BASE64` | iOS | §1e |
| `MACOS_CERTIFICATE_P12` / `MACOS_CERTIFICATE_PASSWORD` | macOS | `docs/release/macos-signing.md` |
| `MACOS_SIGNING_IDENTITY` | macOS | e.g. `Developer ID Application: Name (TEAMID)` |
| `APPLE_ID` / `APPLE_APP_SPECIFIC_PASSWORD` / `APPLE_TEAM_ID` | macOS | §1d |
| `STRAVA_CLIENT_ID` / `STRAVA_CLIENT_SECRET` | all | `docs/release/secrets.md` |
| `SENTRY_DSN` | all | `docs/release/analytics.md` (optional) |

> GitHub Actions rejects `secrets.*` inside a step's `if:`. Any new gated step
> must lift the secret to job-level `env:` and test `env.FOO != ''` — this
> silently produced a zero-job workflow before it was fixed.
