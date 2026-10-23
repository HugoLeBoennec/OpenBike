---
phase: P12
title: Route library — saved GPX routes, ride ↔ route link, GPX export
status: IN_PROGRESS
depends_on: [P3, P6]
validation:
  - flutter analyze
  - flutter test
---

# P12 — Route library

## Context

"Simulate Route" on Home opens the file picker, parses the GPX and goes straight
to `/ride` (`lib/presentation/screens/home_screen.dart`, `_pickRoute`). Nothing
is kept: the rider has to find the file again for every ride, rides don't record
which route they followed, and the GPX encoder written in P6
(`lib/infrastructure/files/gpx_encoder.dart`) is offered nowhere because a stored
ride has no route to place its readings on.

This phase adds a library of routes the rider has saved, linked to the rides
done on them. It is built so a second source of routes — the races a rider is
registered for on Records — can be added later without a migration or any
Records code in this repo. That part is tracked separately in
[P13](P13-records-route-source.md).

## Decisions

Settled with the maintainer before implementation (2026-10-23):

- **Entry:** the Home card opens a new `/routes` screen. The trainer check moves
  from before the file picker to **Start ride**, so routes can be browsed and
  managed with no trainer paired.
- **One preview sheet** for both a freshly picked file and a saved route:
  elevation profile, distance / climbing / max grade, **Start ride**.
  - Picked file: editable name + a **Save to library** switch. The switch keeps
    the position it was left in (stored in `AppPreferences`, ON the first time).
    With the switch on, Start ride saves the route before the trainer check,
    and a **Save without riding** button keeps it without riding — otherwise
    saving would need a paired trainer.
  - Saved route: the rides done on it instead of the switch.
- **Default name:** GPX track name → GPX metadata name → file name →
  "Unnamed route".
- **"Use once"** routes are not stored at all, and their rides carry no route
  link. The ride summary offers **Save this route to library** while the route
  is still in memory, which also links that ride.
- **Duplicate detection** compares the route's shape — its length and five
  points along it, within a tolerance — not the file's bytes, so the same
  route exported by two tools still matches. A
  duplicate import says "Already in your library as …", hides the switch, and
  rides the saved copy so the ride is linked.
- **Sort:** last ridden (default; never-ridden routes by date added), date added,
  name, distance, climbing — the choice is remembered. **Search** filters by
  name. **Long-press** a route to rename or delete it, as in the workout list.
- **Delete** warns when rides used the route; the rides stay, only their link
  is cleared.
- **History** shows the route name on linked rides, looked up from the route
  rather than stored on the ride, so a rename updates past rides too.
- **GPX export** is a file-export plugin like FIT / TCX, shown only on rides
  linked to a route.

## Data model

- New `saved_routes` table: `id`, `name`, `source` (`import` today; P13 adds
  `records`), `external_ref` (source-side id, null for imports), `gpx` (raw GPX
  text — kept so a better parser later improves every saved route), `fingerprint`
  (the encoded `RouteShape` duplicate detection compares), cached `distance_m` / `ascent_m`, `profile_json`
  (~64 elevation samples for list thumbnails), `created_at`.
- `rides.route_id` — nullable, no FK constraint (SQLite doesn't enforce them
  here; `deleteRoute` clears it by hand, as `deleteRide` already does for
  scheduled workouts).
- Ride count and last-ridden date are derived from `rides`, not stored, so
  deleting a ride keeps them right.
- Schema v6 → v7, step-by-step migration with a v7 snapshot in `drift_schemas/`.

## Tasks

### 1. Data
- [x] `SavedRoute` entity (summary only — no GPX text, so the list never loads
      every file) and `Ride.routeId`.
      (`lib/core/domain/entities/`)
- [x] `saved_routes` table + `rides.route_id`, schema v7, `from6To7` migration,
      `drift_schema_v7.json` + generated `schema_v7.dart` / `schema_versions.dart`.
      (`lib/infrastructure/persistence/app_database.dart`)
- [x] `StoragePort` + `DriftStorage`: save / list (with ride count and last
      ridden) / load GPX / rename / delete (clears `rides.route_id`) / link a
      ride to a route.
- [x] `RouteLibrary` service: turns GPX text into a draft (parsed `Route`,
      fingerprint, summary, default name with file-name fallback), finds a
      duplicate, saves a draft. `GpxRouteParser.parse` gains a `fallbackName`.
      (`lib/core/application/services/route_library.dart`)
      **Accept:** migration test (v6 data survives, v7 table usable); storage
      tests for every new method; service tests for fingerprint stability
      (same shape, different file text → same fingerprint), naming fallbacks and
      summary values.

### 2. Library UI
- [x] Providers: saved routes, sort + search state, "Save to library" switch
      (persisted).
- [x] `/routes` screen: search, sort menu, route tiles (profile thumbnail,
      distance, climbing, "3× · 4 d ago" / "never ridden"), empty state, import
      FAB, long-press rename / delete with the ride-count warning.
      (`lib/presentation/screens/route_library_screen.dart`)
- [x] Preview sheet shared by import and saved routes; duplicate notice;
      trainer check on **Start ride**.
      (`lib/presentation/widgets/route_preview_sheet.dart`)
- [x] Home card opens `/routes`.
      **Accept:** widget tests for the library (sort, search, empty state) and
      the sheet (switch remembers its position, duplicate notice, saved-route
      mode).

### 3. Ride ↔ route link
- [x] Link finished rides to the saved route they followed — an active-route
      provider set by `RideScreen` plus a linker on `RideStopped`, like
      `scheduledWorkoutLinkerProvider`, so every way of starting the recording
      is covered.
- [x] Ride summary: **Save this route to library** for a "use once" route.
- [x] Route sheet lists the rides done on the route (date, duration, average
      power, finished or not); the best finished time is highlighted.
- [x] History and Home recent rides show the route name; ride detail shows
      "Route: …" linking to the route.
- [x] `GpxFileExportPlugin` with a `requires-route` capability; the export
      section hides it for rides without a route.
      (`lib/plugins/exports/gpx_file_export_plugin.dart`)
      **Accept:** linker test (saved route links, use-once doesn't, free ride
      doesn't); GPX plugin test (writes a file that re-parses to the route's
      distance; refuses a ride without a route); widget test that the GPX button
      only shows on linked rides.

## Out of scope

- Resuming a route part-way (start offset in `RouteSimulator`).
- Bundled starter routes.
- Records routes — [P13](P13-records-route-source.md).
