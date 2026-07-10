---
phase: P7
title: Design system — themes, visual polish, accessibility
status: IN_PROGRESS
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
- [ ] Create `lib/presentation/theme/` with `app_theme.dart`: `light` + `dark`
      `ThemeData` (Material 3, seed stays deep-orange unless assets say otherwise) and a
      `ThemeExtension` for app tokens: surface tiers (the current
      black/#111111/#1A1A1A hierarchy), zone colors (single source — currently
      duplicated across PowerGauge/ZoneBar/LiveChart), data-field text styles
      (monospace numerals), spacing scale.
- [ ] Apply `themeMode: ref.watch(themeModeProvider)` in `OpenBikeApp`
      (`main.dart`) — add `light` to the Settings options (currently dark/system only).
- [ ] Sweep widgets/screens replacing hard-coded colors with theme tokens. The ride
      screen may deliberately stay near-black in both modes (readability on a trainer) —
      make that an explicit token (`rideSurface`), not `Colors.black` literals.
      **Accept:** golden or widget tests for both themes on Home + Settings; `grep -rn
      "0xFF111111\|0xFF1A1A1A" lib/presentation --include="*.dart"` only matches
      `theme/` files.

### 2. Consistency & states pass
- [ ] Uniform card/list style across Home, History, Workouts (radius, elevation,
      padding from tokens).
- [ ] Every async screen gets proper loading (skeleton or spinner), error (retry
      action), and empty states (History and Workouts have empty states — bring the rest
      to parity: scan, calendar, trends when they exist).
- [ ] Number formatting util respecting `unitSystemProvider` everywhere (km/mi, kg/lb,
      m/ft) — currently applied inconsistently.
      **Accept:** unit tests for the formatter; manual checklist in PR description with
      screenshots per screen.

### 3. Accessibility
- [ ] Semantics labels on custom-painted widgets (PowerGauge, ZoneBar, profile charts)
      exposing current value as text.
- [ ] Contrast audit of zone colors on both themes (WCAG AA for text, best-effort for
      chart fills); text-scale test at 1.3× (no overflow on ride screen data fields).
- [ ] Touch targets ≥ 48dp on in-ride controls (sweaty fingers on a trainer!).
      **Accept:** widget tests asserting Semantics nodes exist; text-scale golden test.

### 4. Onboarding upgrade
- [ ] Add a units-choice step (metric/imperial) and height/max-HR optional fields to
      `onboarding_screen.dart`; reuse the per-role pairing UI from P2 for the sensor
      step if P2 is done (soft dependency — degrade to current flat scan otherwise).
- [ ] Skippable path: "I'll set up later" from any step lands on Home with sensible
      defaults (FTP 200 default exists).
      **Accept:** widget test completing onboarding with imperial units shows mi on Home.

## Validation

```bash
flutter analyze && flutter test
```
CI green. Attach before/after screenshots (all main screens, both themes) to the PR.

## Definition of done
Frontmatter `status: DONE`, checkboxes ticked, CI green, README status board updated.
