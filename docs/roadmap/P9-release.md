---
phase: P9
title: Release — stores, crash reporting, licensing, launch
status: IN_PROGRESS
depends_on: [P1, P2, P3, P4, P5, P6, P7, P8]
validation:
  - flutter analyze
  - flutter test
---

# P9 — Release engineering & launch

## Context

Everything user-facing is built by P1–P8. This phase turns the repo into a releasable
product: observability, licensing (README says "License: TBD" — must be resolved before
any public release), store compliance, and a tag-driven release pipeline. Stretch tasks
from earlier phases (ANT+, Linux packaging, flutter_map) are explicitly **not**
prerequisites.

## Tasks

### 1. Licensing (decide FIRST — affects everything public)
- [ ] Add `LICENSE`: **MIT or Apache-2.0** recommended for the core — required by the
      open-core strategy (closed `openbike_private_plugins` must be allowed to link;
      GPL would forbid it). Apache-2.0 adds a patent grant — prefer it. **Flag the final
      choice to the maintainer for sign-off before merging.**
- [ ] License headers policy (none needed for MIT/Apache beyond the LICENSE file +
      NOTICE), third-party license screen in Settings → About
      (`showLicensePage` covers pub deps; add libusb notice if P8 stretch shipped).

### 2. Observability
- [ ] Crash reporting via `sentry_flutter`: **opt-in** toggle in Settings (default off,
      asked once post-onboarding), DSN via `--dart-define` (same secrets pattern as P6),
      no PII, strip ride data from breadcrumbs.
- [ ] Decision recorded in `docs/release/analytics.md`: no behavioral analytics for v1
      (privacy as a selling point vs subscription apps); revisit post-launch.
      **Accept:** builds without DSN run with Sentry disabled; toggle test.

### 3. Versioning & changelog
- [ ] Adopt semver in pubspec (`1.0.0+<build>`), `CHANGELOG.md` (Keep-a-Changelog),
      release checklist doc `docs/release/checklist.md`.
- [ ] Tag-driven release workflow `.github/workflows/release.yml`: on `v*` tag → build
      signed Android AAB (keystore from secrets), iOS IPA (App Store Connect API key),
      macOS DMG, Windows MSIX, Linux tar.gz → attach to GitHub Release; store uploads
      via fastlane/`upload-actions` where credentials exist, manual otherwise.
      **Accept:** dry-run tag on a test branch produces all artifacts (unsigned where
      secrets absent).

### 4. Store compliance & assets
- [ ] Google Play: target API level current requirement, Data Safety form content
      (BLE, no location use — `neverForLocation` flag from P1 helps), foreground-service
      declaration (from P2), content rating, `docs/release/play-store.md` with listing
      copy.
- [ ] Apple App Store: privacy nutrition labels (health/fitness data stays on device
      unless user connects Strava), Bluetooth purpose string review,
      `docs/release/app-store.md`.
- [ ] Privacy policy (`docs/privacy-policy.md` + hosted URL — required by both stores):
      local-first storage, what leaves the device (Strava/Records/OpenCoach uploads,
      opt-in crash reports).
- [ ] Screenshots/asset checklist per store (phone/tablet sizes, feature graphic) —
      generate from the P7-polished UI; store metadata under `fastlane/metadata/` or
      `docs/release/assets/`.
- [ ] Microsoft Store decision for the MSIX (or plain download from GitHub Releases —
      default: GitHub Releases first, store later).

### 5. Beta & QA gate
- [ ] TestFlight + Play internal testing tracks set up; `docs/release/beta.md` invite
      process.
- [ ] Final QA matrix executed and recorded (compiled from every phase's
      "Pending hardware QA" sections): 2+ real trainers, HRM, all 4 platforms, full
      ride/workout/route/export flows.
- [ ] v1.0 go/no-go checklist: CI green, QA matrix passed, crash-free beta week,
      licenses done, store reviews passed.

## Validation

```bash
flutter analyze && flutter test
```
CI + release workflow green; artifacts produced; both store listings in review or
approved.

## Definition of done
Frontmatter `status: DONE`, v1.0.0 tag cut, store submissions filed, README status
board updated. 🚀
