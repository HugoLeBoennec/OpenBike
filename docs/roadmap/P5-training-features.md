---
phase: P5
title: Training features — calendar, PMC, personal records
status: DONE
depends_on: [P4]
validation:
  - flutter analyze
  - flutter test
---

# P5 — Training features

## Context

Subscription apps differentiate on *training structure over time*: plan workouts on a
calendar, track fitness/fatigue (Performance Management Chart: CTL/ATL/TSB from daily
TSS), and celebrate personal records. OpenBike already computes TSS/IF/NP per ride and
caches them on the ride row (`Rides` table) — this phase builds the longitudinal layer
on top.

## Tasks

### 1. Training calendar
- [x] New Drift table `ScheduledWorkouts` (id, workoutId FK, date, completedRideId?,
      notes) + incremental migration (schema v+1; pattern established in P0). Extend
      `StoragePort`/`DriftStorage` with CRUD + regenerate.
- [x] `CalendarScreen` (new tab or Home entry): month grid + day list; tap a day →
      schedule a workout from the library; scheduled item → "Start now" (routes to
      `/ride` with the workout) and auto-links the completed ride
      (`completedRideId`) when a ride started from a scheduled item finishes.
- [x] Home screen: "Today" card showing today's scheduled workout.
      **Accept:** storage tests for CRUD + ride-linking; widget test scheduling and
      completing a workout marks the calendar entry done.

### 2. Performance Management Chart (PMC)
- [x] `FitnessCalculator` service in `lib/core/application/services/`:
      daily TSS aggregation → CTL (42-day exponentially weighted avg), ATL (7-day),
      TSB = CTL − ATL. Pure Dart, seeded from ride history
      (`StoragePort.getAllRides` summaries — cached tss already on the row).
- [x] `TrendsScreen` with fl_chart: CTL/ATL lines + TSB area over selectable ranges
      (1/3/6/12 months); weekly TSS bar chart; totals row (time, distance, TSS this
      week/month).
- [x] Home screen: compact fitness sparkline + current CTL/TSB numbers.
      **Accept:** unit tests for CTL/ATL/TSB math against hand-computed sequences
      (including gap days = 0 TSS); widget test renders chart from synthetic history.

### 3. Personal records
- [x] On ride save (hook into `RecordingEngine.stop` flow), compute best 5 s / 1 min /
      5 min / 20 min mean-max power from readings; store in a new `PersonalRecords`
      table (duration, watts, rideId, date) keeping all-time + last-90-day bests.
- [x] Ride summary: "New PR!" badges when beaten. History/Trends: PR panel.
- [x] Backfill: one-time job computing PRs from existing rides (idempotent).
      **Accept:** unit test for mean-max power extraction (rolling window) and PR
      update logic; backfill test.

### 4. Data hygiene for longitudinal metrics
- [x] FTP history: store FTP changes with effective dates (new small table or profile
      history) so TSS of old rides stays computed against the FTP of that day
      (`ftpAtTime` already exists on rides — use it consistently in the PMC).
      **Accept:** PMC test where FTP changes mid-history produces stable past values.

## Validation

```bash
flutter analyze && flutter test
```
CI green. Migration tests pass (schema bump). Dev-tools "Generate 1h Ride"
(`dev_tools_screen.dart`) remains a quick way to seed data for manual review.

## Definition of done
Frontmatter `status: DONE`, checkboxes ticked, CI green, README status board updated.
