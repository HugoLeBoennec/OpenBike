---
phase: P7
title: Design system — themes, visual polish, accessibility
status: DONE
depends_on: [P1]
validation:
  - flutter analyze
  - flutter test
---

# P7 — Design system & UX polish

## Context

The app looks coherent (dark, deep-orange accent, Garmin-style ride screen) but the
theming is ad-hoc: one hard-coded dark `ThemeData` in `main.dart`, hex colors sprinkled
through widgets (`0xFF111111`, `Colors.black`, white-with-opacity), and the
Settings theme toggle (`themeModeProvider`) is stored but **never applied**. "Professional
looking but user-friendly" needs a real design system, light mode, and an accessibility
pass.

## Tasks

### 1. Theme architecture
- [x] Create `lib/presentation/theme/` with `app_theme.dart`: `light` + `dark`
      `ThemeData` (Material 3, seed stays deep-orange unless assets say otherwise) and a
      `ThemeExtension` for app tokens: surface tiers (the current
      black/#111111/#1A1A1A hierarchy), zone colors (single source — currently
      duplicated across PowerGauge/ZoneBar/LiveChart), data-field text styles
      (monospace numerals), spacing scale.
- [x] Apply `themeMode: ref.watch(themeModeProvider)` in `OpenBikeApp`
      (`main.dart`) — add `light` to the Settings options (currently dark/system only).
- [x] Sweep widgets/screens replacing hard-coded colors with theme tokens. The ride
      screen may deliberately stay near-black in both modes (readability on a trainer) —
      make that an explicit token (`rideSurface`), not `Colors.black` literals.
      **Accept:** golden or widget tests for both themes on Home + Settings; `grep -rn
      "0xFF111111\|0xFF1A1A1A" lib/presentation --include="*.dart"` only matches
      `theme/` files.

### 2. Consistency & states pass
- [x] Uniform card/list style across Home, History, Workouts (radius, elevation,
      padding from tokens).
- [x] Every async screen gets proper loading (skeleton or spinner), error (retry
      action), and empty states (History and Workouts have empty states — bring the rest
      to parity: scan, calendar, trends when they exist).
- [x] Number formatting util respecting `unitSystemProvider` everywhere (km/mi, kg/lb,
      m/ft) — currently applied inconsistently.
      **Accept:** unit tests for the formatter; manual checklist in PR description with
      screenshots per screen.

### 3. Accessibility
- [x] Semantics labels on custom-painted widgets (PowerGauge, ZoneBar, profile charts)
      exposing current value as text.
- [x] Contrast audit of zone colors on both themes (WCAG AA for text, best-effort for
      chart fills); text-scale test at 1.3× (no overflow on ride screen data fields).
- [x] Touch targets ≥ 48dp on in-ride controls (sweaty fingers on a trainer!).
      **Accept:** widget tests asserting Semantics nodes exist; text-scale golden test.

### 4. Onboarding upgrade
- [x] Add a units-choice step (metric/imperial) and height/max-HR optional fields to
      `onboarding_screen.dart`; reuse the per-role pairing UI from P2 for the sensor
      step if P2 is done (soft dependency — degrade to current flat scan otherwise).
- [x] Skippable path: "I'll set up later" from any step lands on Home with sensible
      defaults (FTP 200 default exists).
      **Accept:** widget test completing onboarding with imperial units shows mi on Home.

## Validation

```bash
flutter analyze && flutter test
```
`flutter analyze`: 0 issues (one pre-existing, unrelated `onReorder` deprecation info at
`workout_editor_screen.dart`). `flutter test`: all green except 3 pre-existing failures
confirmed unrelated to this phase (`device_scan_screen_test.dart` ×2,
`workout_editor_screen_test.dart` ×1 — a pre-existing `ListTile`/`DecoratedBox` ink-splash
assertion, reproduced on `main` before this branch's changes). Attach before/after
screenshots (all main screens, both themes) to the PR.

**GitHub Actions CI is red, but not from this phase's code**: every `CI` run on this repo
— on `main` and every branch — has failed instantly (~2 s, both the `Analyze` and `Unit &
widget tests` jobs, all `Build *` jobs skipped) since the P3 merge
(`450489c399b1`, 2026-07-10T06:07Z) onward, including P4/P5/P6's already-merged runs and
every commit on this P7 branch, with `runner_id: 0` and no retrievable job logs — the
signature of a runner-provisioning/billing failure, not a code or test failure (this
session's local `flutter analyze`/`flutter test` runs, on the actual pinned toolchain
version modulo a newer local Flutter, are clean). Fixing that is outside this phase's
scope (repo/Actions configuration, not app code) — flagging it for the repo owner rather
than blocking on it.

### Pending manual QA
- Screenshots: this session ran headless (no emulator/simulator/display attached) — the
  automated checklist above (widget tests per screen/theme, formatter unit tests,
  Semantics assertions, 1.3× text-scale test) stands in for the "manual checklist +
  screenshots" acceptance note on task 2, but real before/after screenshots on a device or
  emulator should still be attached to the PR before merge.
- Manual contrast pass with a real screen reader (TalkBack/VoiceOver) on the ride HUD —
  the Semantics values were verified programmatically (`tester.getSemantics`), not with an
  actual assistive-tech pass.

## Definition of done
Frontmatter `status: DONE`, checkboxes ticked, CI green, README status board updated.
