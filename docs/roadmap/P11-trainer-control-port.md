---
phase: P11
title: Port manual trainer control (ERG/resistance/SIM on the fly) from stole-version
status: IN_PROGRESS
depends_on: [P3]
validation:
  - flutter analyze
  - flutter test
---

# P11 — Manual trainer control port (from `stole-version`)

## Context

The maintainer developed features in parallel on branch **`origin/stole-version`**
(3 commits, based on the pre-roadmap commit `30ce486`) that main still lacks — most
importantly **on-the-fly trainer control**: start a free ride and set an ERG target
power, a resistance level, or a SIM difficulty scale mid-ride, without a structured
workout. Main's ride screen only receives targets from `WorkoutEngine` (workouts) or
`RouteSimulator` (GPX); the FTMS layer already supports the commands
(`setTargetPower`/`setTargetResistance`/`setSimulationParameters` in
`lib/infrastructure/ble/ftms/ftms_control_client.dart`).

The branch **cannot be merged** — main has ~62 commits of drift on the same files
(ride screen rebuilt in P3/P7, providers split, Strava plugin evolved in P6, FTMS
control client extended in P0/P2). This phase is a **guided port**: re-implement the
valuable pieces on top of current main, using the branch as the reference
implementation. Read the originals with:

```bash
git fetch origin stole-version
git show origin/stole-version:lib/core/application/services/trainer_mode_controller.dart
git diff 30ce486..origin/stole-version -- lib/infrastructure/ble/ftms/
```

**Skip these branch changes** (already delivered differently by P1/P6, or obsolete):
Strava deep-link handling, athlete-name display, macOS entitlement edits, pubspec/lock
changes, `file_picker_service.dart` (check for an existing equivalent from P4's
import flow first), app icons.

## Tasks

### 1. TrainerModeController (domain service)
- [ ] Port `lib/core/application/services/trainer_mode_controller.dart` (214 lines on
      the branch): mode state (`TrainerModeState`), priority rules (workout power step →
      ERG; workout freeRide step → resistance; GPX route → SIM; nothing → adjustable
      resistance), manual `switchMode(ControlMode, {watts, resistance})`, listening to
      `WorkoutEvent`/`SimulationEvent` on the `EventBus`. Adapt to main's current
      `WorkoutEngine`/`RouteSimulator` event surface — do not regress their existing
      direct control paths; the controller must become the **single writer** to
      `TrainerPort` control methods (route WorkoutEngine's target-power writes through
      it, or clearly document the ownership split).
- [ ] Port its test (`test/core/application/services/trainer_mode_controller_test.dart`,
      266 lines) and adapt to main's test helpers.
      **Accept:** all ported tests green; no duplicate control writes when a workout
      runs (unit test asserting single `setTargetPower` per step change).

### 2. Ride-screen manual controls
- [ ] Re-implement on main's current ride screen (`lib/presentation/screens/ride_screen.dart`,
      P3/P7 version) using the branch's widgets as reference: `_ErgControls` (target
      watts stepper/quick-set), `_ResistanceControls` (level slider),
      `_GradientDifficultySlider` (SIM difficulty % applied to grade sent to trainer),
      `_TrainerStatusBanner` (current mode + target readout). Use P7 theme tokens, all
      three layouts (portrait/landscape/desktop), 48dp touch targets.
- [ ] Show controls contextually: free ride → ERG/resistance selectable; workout active
      → controls hidden (workout owns targets) except pause-time override; GPX ride →
      difficulty slider only.
- [ ] Persist last-used ERG watts / resistance level / difficulty in `AppPreferences`.
      **Accept:** widget tests — switching to ERG fires `switchMode` with chosen watts;
      controls hidden while a workout step is active; difficulty slider scales the grade
      passed to `setSimulationParameters` (unit test on the scaling math).

### 3. FTMS capability parser
- [ ] Port `ftms_capability_parser` + its 190-line test from the branch (compare with
      what P0/P2 already added to `ftms_control_client.dart` — port only the missing
      parts). Use parsed capabilities (supported power/resistance ranges, increments) to
      clamp and step the manual controls (e.g. trainer reports 0–800 W in 5 W steps →
      ERG stepper honors that).
      **Accept:** parser tests green; controls clamp to reported ranges (widget test
      with a fake capability set).

### 4. TCX file export plugin
- [ ] Port `lib/plugins/exports/tcx_file_export_plugin.dart` (88 lines): local TCX file
      export alongside the existing Garmin FIT plugin, registered unconditionally in
      `main.dart`, using main's current `TcxEncoder`. Reconcile with P6's export-status
      UI (row appears automatically if the Connections/export list is plugin-driven).
      **Accept:** unit test — exported file parses as valid XML with expected trackpoint
      count; plugin appears in `PluginRegistry.allManifests`.

### 5. Close out
- [ ] Update `docs/roadmap/README.md` status board row for P11 and tick these boxes.
- [ ] Note in `CHANGELOG.md` under Unreleased: "Manual trainer control (ERG target,
      resistance level, SIM difficulty) available during free rides; TCX file export."

## Validation

```bash
flutter analyze   # zero issues
flutter test      # all pass (target: 734 pre-existing + new)
```
CI green on the branch (if Actions minutes are restored / repo is public).

### Pending hardware QA `[HW]`
- Free ride on a real FTMS trainer: set ERG 200 W on the fly → trainer holds it;
  switch to resistance level → felt change; GPX ride difficulty at 50% → grades felt
  at half strength.

## Definition of done
Frontmatter `status: DONE`, checkboxes ticked, CI green, README status board updated.
