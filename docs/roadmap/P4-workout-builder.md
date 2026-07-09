---
phase: P4
title: Workout builder, FTP tests, starter library
status: NOT_STARTED
depends_on: [P3]
validation:
  - flutter analyze
  - flutter test
---

# P4 — Workout builder & FTP tests

## Context

`workout_builder_screen.dart` is a library/importer only — users can import
ZWO/ERG/MRC files but cannot create or edit workouts. The fluent `WorkoutBuilder`
service (`lib/core/application/services/workout_builder.dart`) and the full
`WorkoutStep` model (warmup/cooldown/steady/interval/ramp/freeRide with repeats) already
exist; this phase adds the editing UI and the FTP-test flows every subscription app has.

## Tasks

### 1. Interval editor
- [ ] New `WorkoutEditorScreen` (route `/workouts/edit/:id?` — new + edit modes) with:
      - step list (reorder by drag, duplicate, delete)
      - per-step editor sheet: type, duration, power target %FTP (single or low→high for
        ramps), cadence target, repeat count + off-power/off-duration for intervals
      - live power-profile preview (reuse the shared mini-profile widget extracted in P3)
        updating as steps change
      - computed totals: duration + estimated TSS (reuse zone/NP math from
        `lib/core/domain/entities/ride.dart` — estimate NP from step targets)
- [ ] Persist via existing `StoragePort.saveWorkout` (Drift `Workouts` table, steps as
      JSON — already supported). Edit re-opens imported workouts too.
- [ ] Entry points: FAB on the workout library screen; "Edit" on
      `workout_detail_screen.dart`; "Save as workout" from an imported file.
      **Accept:** widget tests: build a 2×(5 min @ 105%) interval workout via UI,
      saved Workout has correct steps/durations; TSS estimate matches hand-computed
      value ±1.

### 2. Export symmetry
- [ ] "Share as .zwo" on workout detail using the existing `ZwoParser.serialize`
      round-trip (`lib/infrastructure/files/zwo_parser.dart`) + platform share/save
      (file_picker already a dep).
      **Accept:** serialize→parse round-trip test of an editor-created workout.

### 3. FTP tests
- [ ] Bundle two test protocols as code-defined workouts (via `WorkoutBuilder`):
      **Ramp test** (start 100 W, +20 W/min to failure) and **20-minute test**
      (warmup, 20 min freeRide, cooldown).
- [ ] Post-ride FTP detection in the ride-summary flow
      (`ride_summary_screen.dart`): ramp → 75% of best 1-min power; 20-min → 95% of
      20-min avg power. Compute from recorded readings; prompt "New FTP: 262 W — update
      profile?" → `StoragePort.saveProfile` + `userProfileProvider`.
- [ ] Best-effort ramp-failure detection: user hits Stop; take best 1-min power from the
      recording.
      **Accept:** unit tests for both FTP formulas on synthetic readings; widget test
      for the update-profile prompt.

### 4. Starter workout library
- [ ] Bundle 10–15 classic public-domain workout *structures* (e.g. 2×20 @ 95%, Over-Unders,
      Sweet Spot 3×12, VO2 5×3, recovery spin, plus the two FTP tests) defined in code
      (`lib/core/application/services/bundled_workouts.dart`) and seeded into the DB on
      first run (idempotent — check by id). Generic names/descriptions only; do not copy
      branded workout names or copyrighted plan text from commercial apps.
      **Accept:** fresh-install test shows the bundled list; re-run does not duplicate.

## Validation

```bash
flutter analyze && flutter test
```
CI green. Extend `integration_test/full_flow_test.dart`: create workout in editor →
start it → HUD shows step 1 target.

## Definition of done
Frontmatter `status: DONE`, checkboxes ticked, CI green, README status board updated.
