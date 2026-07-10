# Release checklist

Steps to cut a new OpenBike release, from a green `main` to store submission.
See also: `docs/release/beta.md` (beta gate that must pass first) and
`CHANGELOG.md` (Keep a Changelog format).

## 1. Pre-flight (on `main`)

- [ ] `flutter analyze && flutter test` pass locally.
- [ ] CI (`.github/workflows/ci.yml`) is green on the commit being released.
- [ ] `docs/release/beta.md`'s go/no-go checklist has passed (crash-free
      beta week, QA matrix complete).
- [ ] `CHANGELOG.md` has a dated entry for the new version (move
      `[Unreleased]` items under it).
- [ ] `pubspec.yaml` version bumped: `X.Y.Z+build` — bump `X.Y.Z` per
      semver, always increment `build` (Android `versionCode` / iOS
      `CURRENT_PROJECT_VERSION` both derive from it automatically, see
      `android/app/build.gradle.kts` / `ios/Runner.xcodeproj`).
- [ ] Version string literals in `lib/presentation/screens/settings_screen.dart`
      (About tile, license page) match the new `pubspec.yaml` version.

## 2. Cut the tag

```bash
git tag vX.Y.Z
git push origin vX.Y.Z
```

- [ ] `.github/workflows/release.yml` run is green (or intentionally
      partial — e.g. Linux is best-effort and iOS/macOS/Windows signing
      steps are skipped without secrets configured; see that workflow's
      per-job comments).
- [ ] The draft GitHub Release has the expected assets attached: Android
      `.aab`, iOS `.ipa` (only if signing secrets are configured), macOS
      `.dmg`, Windows `.msix`, Linux `.tar.gz`.
- [ ] Edit the draft release notes (auto-generated from commits) for
      clarity, then publish it.

## 3. Store submission

- [ ] Android: upload the `.aab` to Play Console per
      `docs/release/play-store.md` (internal testing track first, then
      staged production rollout).
- [ ] iOS: upload the `.ipa` via Transporter (or `xcrun altool`/Xcode) to
      App Store Connect per `docs/release/app-store.md`; submit for review.
- [ ] Privacy policy (`docs/privacy-policy.md`) is hosted at a stable URL
      and linked from both store listings.
- [ ] Data Safety (Play) / privacy nutrition label (App Store) forms filled
      in and submitted.
- [ ] Windows: MSIX published to GitHub Releases (default — see
      `docs/release/app-store.md`'s Microsoft Store note for the
      alternative).

## 4. Post-release

- [ ] `docs/roadmap/README.md` status board and this phase's frontmatter
      reflect the shipped state.
- [ ] If crash reporting is enabled for this build (`docs/release/analytics.md`),
      monitor the Sentry project for regressions over the first 48h.
- [ ] Bump `pubspec.yaml` to the next dev version and open a fresh
      `[Unreleased]` section in `CHANGELOG.md`.

## v1.0 go/no-go (first release only)

Full checklist — including the hardware QA matrix compiled from every
phase's "Pending hardware QA" section — lives in `docs/release/beta.md`
("v1.0 go/no-go"). Do not tag `v1.0.0` until every item there is checked
off.
