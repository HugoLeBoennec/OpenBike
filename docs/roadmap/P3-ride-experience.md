---
phase: P3
title: Ride experience — workout HUD, route profile, in-ride guidance
status: DONE
depends_on: [P1]
validation:
  - flutter analyze
  - flutter test
---

# P3 — Ride experience

## Context

The ride screen (`lib/presentation/screens/ride_screen.dart`) renders live data
beautifully but gives **no guidance during a structured workout** (no current step,
target power, or countdown — `WorkoutEngine` emits all of it via `WorkoutProgress` at
1 Hz, nothing consumes it visually) and **no route visualization during GPX simulation**
(`GpxProfileWidget` in `lib/presentation/widgets/gpx_profile_widget.dart` is fully built
and never used). This phase turns the ride screen into a Wahoo/Elite-class experience.

## Tasks

### 1. Workout HUD
- [x] New `WorkoutHudWidget` in `lib/presentation/widgets/`, shown on the ride screen
      whenever a workout is active (`currentWorkoutProvider` non-null). Consumes
      `WorkoutEngine.progressStream` (expose via a Riverpod provider next to the
      existing `simulationProgressProvider` pattern in
      `lib/presentation/state/providers.dart`). Contents:
      - current step type + target power (W and %FTP), step countdown, step progress bar
      - next step preview ("Next: 3 min @ 250 W")
      - ERG compliance indicator: 3 s avg power vs target (use existing
        `threeSecondAvgPowerProvider`), colored on/under/over
      - whole-workout mini profile with position cursor (reuse `_MiniProfilePainter`
        from `workout_builder_screen.dart` — extract it into a shared widget first)
- [x] Step controls: skip step (`WorkoutEngine.skip`) and workout pause/resume tied
      into the existing `RideHeaderBar` pause flow (shared via
      `lib/presentation/widgets/ride_pause_actions.dart`).
- [x] Text-event toasts: surface `Workout.textEvents` at their offsets (engine already
      computes the active text event) as non-blocking overlays.
      **Accept:** widget tests: HUD shows target from a fake `WorkoutProgress`; skip
      advances step; compliance color changes with live power.

### 2. Route simulation UI
- [x] Integrate `GpxProfileWidget` into the ride screen for route rides
      (`routeSimulatorProvider` active): elevation profile with position marker,
      current grade, distance remaining — replacing/augmenting the LiveChart pane in all
      three layouts (portrait/landscape/desktop).
- [x] Upcoming-gradient strip: colored segments for the next ~1 km (color by grade
      severity, same palette as zone colors for consistency).
- [x] Route completion flow: on `SimulationEvent.completed`, prompt to stop & save.
      **Accept:** widget tests with a synthetic `Route`: marker advances with
      `SimulationProgress`; completion dialog appears.

### 3. Stretch (do not block phase completion)
- [x] Mini-map via `flutter_map` (OSM tiles) showing GPX track + position. Keep behind a
      toggle; offline-safe (hide on no connectivity — `connectivity_plus` already a dep).

### 4. Small in-ride polish
- [x] Lap feedback: on lap, show last-lap summary snackbar (avg W / duration) — data
      available from `RecordingEngine` lap indices.
- [x] Auto-pause option (speed < 2 km/h for 5 s → pause prompt), setting in Settings,
      default off.
      **Accept:** unit test for auto-pause trigger logic.

## Validation

```bash
flutter analyze && flutter test
```
`flutter analyze` and `flutter test` (553 tests) pass locally. `full_flow_test.dart` was
extended with two new scenarios (HUD appears on a workout ride; completion dialog appears
on route finish) and statically verified via `flutter analyze`, but could not be executed
in this environment — running `flutter test integration_test/` requires a Linux desktop
build, and `sqlite3_flutter_libs`' CMake step fetches the sqlite3 amalgamation from
`sqlite.org`, which this sandbox's network policy blocks (403). This mirrors the existing
`build-linux` CI job already being `continue-on-error` for the same class of native-build
flakiness — the GitHub Actions `test` job only runs `flutter test` (the `test/` unit and
widget suite), not `integration_test/`, so this does not affect CI-green status. Run
`flutter test integration_test/full_flow_test.dart` on a machine with full network access
to confirm before relying on it.

### Pending hardware QA `[HW]`
- Full ZWO workout on a real trainer: targets track, HUD countdown matches ERG changes.
- GPX ride: grade changes felt on trainer match the profile marker position.
- `integration_test/full_flow_test.dart`'s new HUD/route-completion scenarios, on a
  machine that can reach `sqlite.org` for the Linux desktop build (see note above).

## Definition of done
Frontmatter `status: DONE`, checkboxes ticked, CI green, README status board updated.
