---
phase: P0
title: Foundation — CI green, repo hygiene, correctness fixes
status: IN_PROGRESS
depends_on: []
validation:
  - flutter analyze
  - flutter test
---

# P0 — Foundation

## Context

Before feature work starts, the repo needs a single source of truth for "is the build
healthy" (the CI workflow at `.github/workflows/ci.yml` already exists — this phase makes
it green and keeps it green), and a cleanup of known correctness bugs plus the legacy
first-draft code that has been superseded by newer implementations. Removing the dead
paths matters because coding agents in later phases will otherwise extend the wrong copy.

## Tasks

### 1. Make CI green
- [ ] Run `flutter pub get`, `flutter analyze`, `flutter test` locally/CI. Fix every
      analyzer error and test failure found. If a failure reveals a real bug, fix the bug
      (not the test).
      **Accept:** `CI` workflow green on this branch, all jobs (Linux job may be skipped/red — it is `continue-on-error`).
- [ ] Reconcile pubspec toolchain drift: the `dependency_overrides` comment claims
      "pre-Dart 3.6 compatibility" but `pubspec.lock` was generated with Dart ≥3.10 /
      Flutter ≥3.38 (see `sdks:` at the bottom of the lock). Decide the supported
      Flutter version, update the pubspec `environment:` and CI `FLUTTER_VERSION`
      (`.github/workflows/ci.yml`) to match, and drop the drift/sqlite3 overrides if
      they resolve cleanly on the chosen toolchain.
      **Accept:** pubspec comment/constraints match reality; `flutter pub get` clean.

### 2. Delete superseded legacy code (verify no references first with grep)
- [ ] `lib/infrastructure/ble/ftms_client.dart` — old FTMS client without control
      handshake; superseded by `lib/infrastructure/ble/ftms/`.
- [ ] `lib/infrastructure/ble/ble_sensor_reader.dart` — partial reader (stub CSC cadence
      at lines 89–91); superseded by `lib/infrastructure/ble/sensors/`.
- [ ] `lib/core/application/use_cases/execute_workout.dart` — simple duplicate of
      `WorkoutEngine` (steady-state only, own `WorkoutProgress` class); superseded by
      `lib/core/application/services/workout_engine.dart`.
- [ ] `lib/infrastructure/api/strava_client.dart`, `garmin_client.dart`,
      `training_peaks_client.dart` — pure TODO stubs implementing the legacy `ExportPort`;
      the real path is `ExportPlugin` (`lib/plugins/exports/`). Also delete
      `lib/core/application/use_cases/export_activity.dart` (drives the stubs) and, if it
      then has no remaining implementations, remove `ExportPort` from
      `lib/core/domain/ports/export_port.dart` **keeping** the `ExportFormat`/`ExportStatus`
      enums (still used by `ExportService`) — move them if needed.
- [ ] Update barrels (`ble.dart`, `use_cases.dart`, etc.) and any tests referencing the
      deleted files.
      **Accept:** `flutter analyze` clean; `grep -r "FtmsClient\b\|BleSensorReader\|ExecuteWorkout\b" lib test` returns nothing.

### 3. Correctness fixes
- [ ] **FIT encoder FTP bug** — `lib/infrastructure/files/fit_encoder.dart`: `encode()`
      never forwards the athlete FTP to `_writeSession`, so threshold_power/TSS/IF are
      always computed against the hard-coded `Watts(200)` fallback. Thread an
      `Watts? ftp` parameter from `encode()` callers (`ExportService`,
      `lib/plugins/exports/*`) down to `_writeSession`, sourcing FTP from the user
      profile / `ride.ftpAtTime`.
      **Accept:** unit test in `test/infrastructure/files/encoders_test.dart` proving a
      ride encoded with FTP 250 writes threshold_power 250 and matching TSS/IF.
- [ ] **`gradePercent` never persisted** — `lib/infrastructure/persistence/drift_storage.dart`
      `saveSensorReadings` skips the existing `gradePercent` column. Persist it (grade is
      available during SIM rides via `SimulationProgress`; extend `SensorReading` if the
      value isn't carried through — check `RecordingEngine`).
      **Accept:** round-trip test: save readings with grade, read back, grade intact.
- [ ] **Destructive migrations** — `lib/infrastructure/persistence/app_database.dart:155-168`
      drops all tables on upgrade. Replace with incremental Drift migrations (keep the
      drop only for `from < 2` if unavoidable, add proper steps from v2 onward) and call
      `createIndices()` from `onCreate` and post-migration in `onUpgrade`.
      **Accept:** migration test using drift's testing utilities (v2 → v3 no-op migration
      preserves data); indices exist after fresh create.
- [ ] **Storage test coverage** — add `test/infrastructure/persistence/drift_storage_test.dart`
      (in-memory `NativeDatabase.memory()`, pattern in
      `test/infrastructure/exports/export_queue_service_test.dart`): CRUD for rides, readings, laps,
      profile; `deleteRide` cascade behavior.
      **Accept:** tests pass.

### 4. Branding hygiene (code-level; platform files are P1)
- [ ] Rename the Strava redirect scheme constant from `pedalhub://strava/callback` to
      `openbike://strava/callback` in `lib/plugins/exports/strava_export_plugin.dart`
      (platform registration of the scheme happens in P1 — keep the constant in one place
      so P1 only touches platform files).
      **Accept:** `grep -ri pedalhub lib test` returns nothing.

## Validation

```bash
flutter analyze          # zero issues
flutter test             # all pass
grep -ri pedalhub lib/ test/          # empty
grep -rn "UnimplementedError" lib/ | grep -v providers.dart   # only export_service.dart GPX (fixed in P6)
```

CI workflow green on the branch = exit gate.

## Definition of done
Frontmatter `status: DONE`, all checkboxes ticked, CI green, README status board updated.
