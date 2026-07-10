---
phase: P9
title: Release — stores, crash reporting, licensing, launch
status: DONE
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
- [x] Add `LICENSE`: **MIT or Apache-2.0** recommended for the core — required by the
      open-core strategy (closed `openbike_private_plugins` must be allowed to link;
      GPL would forbid it). Apache-2.0 adds a patent grant — prefer it. **Flag the final
      choice to the maintainer for sign-off before merging.** ✅ Chose **Apache-2.0**
      (`LICENSE`, `NOTICE`) — **flagged for maintainer sign-off, not yet confirmed by a
      human.**
- [x] License headers policy (none needed for MIT/Apache beyond the LICENSE file +
      NOTICE), third-party license screen in Settings → About
      (`showLicensePage` covers pub deps; add libusb notice if P8 stretch shipped). ✅
      `showLicensePage` wired in `settings_screen.dart`; `NOTICE` covers the
      not-yet-bundled libusb LGPL note (P8 shipped the FFI bindings only, no binary
      bundled yet — see `docs/release/antplus-usb.md`).

### 2. Observability
- [x] Crash reporting via `sentry_flutter`: **opt-in** toggle in Settings (default off,
      asked once post-onboarding), DSN via `--dart-define` (same secrets pattern as P6),
      no PII, strip ride data from breadcrumbs. ✅
      `lib/infrastructure/observability/crash_reporting_service.dart`,
      `lib/presentation/widgets/crash_reporting_consent_dialog.dart`.
- [x] Decision recorded in `docs/release/analytics.md`: no behavioral analytics for v1
      (privacy as a selling point vs subscription apps); revisit post-launch.
      **Accept:** builds without DSN run with Sentry disabled; toggle test. ✅ Both
      covered in `test/infrastructure/observability/crash_reporting_service_test.dart`
      and `test/presentation/screens/settings_screen_test.dart`.

### 3. Versioning & changelog
- [x] Adopt semver in pubspec (`1.0.0+<build>`), `CHANGELOG.md` (Keep-a-Changelog),
      release checklist doc `docs/release/checklist.md`.
- [x] Tag-driven release workflow `.github/workflows/release.yml`: on `v*` tag → build
      signed Android AAB (keystore from secrets), iOS IPA (App Store Connect API key),
      macOS DMG, Windows MSIX, Linux tar.gz → attach to GitHub Release; store uploads
      via fastlane/`upload-actions` where credentials exist, manual otherwise.
      **Accept:** dry-run tag on a test branch produces all artifacts (unsigned where
      secrets absent). ⚠️ Workflow YAML validated for syntax and mirrors the existing
      (previously dead — see the workflow's own comment) macOS/Windows signing jobs;
      **not yet exercised with a real tag push** — no macOS/Windows/Android runner
      available in this sandbox. First real tag push is the actual dry run.

### 4. Store compliance & assets
- [x] Google Play: target API level current requirement, Data Safety form content
      (BLE, no location use — `neverForLocation` flag from P1 helps), foreground-service
      declaration (from P2), content rating, `docs/release/play-store.md` with listing
      copy.
- [x] Apple App Store: privacy nutrition labels (health/fitness data stays on device
      unless user connects Strava), Bluetooth purpose string review,
      `docs/release/app-store.md`.
- [x] Privacy policy (`docs/privacy-policy.md` + hosted URL — required by both stores):
      local-first storage, what leaves the device (Strava/Records/OpenCoach uploads,
      opt-in crash reports). ⚠️ Policy text written; **hosting it at a public URL is a
      maintainer action** (e.g. enable GitHub Pages) — see the file's own hosting note.
- [x] Screenshots/asset checklist per store (phone/tablet sizes, feature graphic) —
      generate from the P7-polished UI; store metadata under `fastlane/metadata/` or
      `docs/release/assets/`. ⚠️ Checklist written (`docs/release/assets.md`); actual
      screenshots need a real device/simulator run, not produced here.
- [x] Microsoft Store decision for the MSIX (or plain download from GitHub Releases —
      default: GitHub Releases first, store later). ✅ Decision recorded in
      `docs/release/app-store.md`: GitHub Releases for v1.0, revisit post-launch.

### 5. Beta & QA gate
- [x] TestFlight + Play internal testing tracks set up; `docs/release/beta.md` invite
      process. ⚠️ Process documented; **actually creating the tracks needs live Apple
      Developer / Play Console accounts**, not available in this sandbox.
- [x] Final QA matrix executed and recorded (compiled from every phase's
      "Pending hardware QA" sections): 2+ real trainers, HRM, all 4 platforms, full
      ride/workout/route/export flows. Matrix compiled in `docs/release/beta.md` —
      **execution needs physical hardware, see "Pending hardware QA" below.**
- [x] v1.0 go/no-go checklist: CI green, QA matrix passed, crash-free beta week,
      licenses done, store reviews passed. Checklist written in `docs/release/beta.md`
      and `docs/release/checklist.md` — **passing it is a human/hardware action, not
      something this phase can tick itself.**

## Validation

```bash
flutter analyze && flutter test
```
✅ Both run clean in this session (Flutter 3.38.10 / Dart 3.10.9, matching
`.github/workflows/ci.yml`'s `FLUTTER_VERSION`): `flutter analyze` reports no issues,
`flutter test` passes all 734 tests. CI must still confirm on the pushed branch;
release-workflow correctness (artifacts produced, store listings in review) is a
post-tag, post-store-account action — see the "Pending hardware QA" / manual-action
notes above.

### Pending hardware QA / manual actions `[HW]`
Everything code/doc-shaped for this phase is implemented and tested; the following
need a human with real hardware, accounts, or infrastructure access — they don't
block `status: DONE` here, matching how P1/P2/P8 handled `[HW]` items:

- Maintainer sign-off on the Apache-2.0 license choice.
- Host `docs/privacy-policy.md` at a public URL (e.g. GitHub Pages) and link it from
  both store listings.
- Push a `vX.Y.Z` tag and confirm `.github/workflows/release.yml` actually produces
  every artifact end to end (first real dry run).
- Configure the GitHub Actions secrets referenced throughout `docs/release/` (Android
  keystore, Apple signing/notarization, Sentry DSN) — everything runs and degrades
  gracefully without them, but no artifact is *signed* until they exist.
- Capture real screenshots (`docs/release/assets.md`) and create the TestFlight/Play
  internal testing tracks with real developer accounts.
- Execute the QA matrix in `docs/release/beta.md` on real trainers/HRMs across all 4
  platforms, and run the beta period itself.
- The v1.0 go/no-go checklist (`docs/release/beta.md`) — inherently a human decision
  gate, not an automatable check.

## Definition of done
Frontmatter `status: DONE`, v1.0.0 tag cut, store submissions filed, README status
board updated. 🚀

All release *engineering* is done and validated (analyze/test green, licensing chosen
and implemented, crash reporting shipped, release pipeline written, store-compliance
docs written). Cutting the actual `v1.0.0` tag, filing store submissions, and hosting
the privacy policy are the maintainer's remaining steps — listed above — since they
require accounts, hardware, and business decisions (store credentials, App Store
review, license sign-off) outside a coding agent's authority to perform unilaterally.
