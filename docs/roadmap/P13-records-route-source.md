---
phase: P13
title: Records race courses in the route library (private integration)
status: NOT_STARTED
depends_on: [P12]
validation:
  - flutter analyze
  - flutter test
---

# P13 — Records race courses in the route library

## Context

P12 gives OpenBike a route library. This phase adds a second source to it: the
bike course of the races a rider has on **Records**, so they can train on the
course before race day or ride a past race again.

Records is a private integration (see `docs/release/private-plugins.md`): this
repo must not contain its code, endpoints or credentials (CI checks
`grep -ri "opencoach\|records_api" lib/`). The work is therefore split across
three places, and this file is where all of it is tracked:

| Where | What |
|---|---|
| **Records** (`Records` repo, Next.js) | an ecosystem API endpoint + scope that lists the rider's races with a bike course and serves the course |
| **`openbike_private_plugins`** (private repo — does not exist yet) | a `RecordsRouteSource` that calls that API |
| **OpenBike** (this repo) | a generic route-source seam and the library UI that shows any registered source |

## What Records has today (checked 2026-10-23)

- Records is an OpenID Connect provider for the ecosystem, OpenBike first
  (`lib/ecosystem/scopes.ts`, client created by
  `scripts/register-openbike-client.ts`). The only data scope is
  `results.read`.
- Race courses (`models/raceCourseSchema.ts`) are **already parsed**, not GPX
  files: ordered segments `nat` / `transition` / `velo` / `cap`, each a list of
  `{lat, lng, ele?, d}`, keyed by `catalogId` + `year` (`year: null` = applies
  to every edition). Status `valide` / `en_attente`, source `officiel` /
  `communaute`.
- Registrations (`models/athleteEventRegistrationSchema.ts`,
  `pages/api/registration/my-upcoming.ts`) have status `interested` /
  `registered`; the existing endpoint is session-authenticated, not part of the
  ecosystem API.

## Decisions so far

- **Which races:** upcoming races the rider is registered for (soonest first,
  with a countdown) **and** past races they have a result for (to ride again,
  later against their race-day bike split). Only races whose course has a bike
  segment are listed.
- **Storage:** Records courses are cached in P12's `saved_routes` with
  `source = 'records'` and `external_ref = '<catalogId>:<year>'`, so they work
  offline and link to rides like any other route. They can't be renamed or
  deleted from OpenBike; they refresh when the library opens.
- **Format:** the plugin turns the course's bike points into GPX text before
  handing it over, so the library keeps a single storage format and parser.

## Open questions

- A course with **several `velo` segments** (rare: split bike legs) — join them
  or offer each?
- Courses with status `en_attente` (community upload not yet validated) — show
  them, flagged, or hide them?
- Scope name and whether it covers both registrations and courses
  (e.g. `races.read`), or two scopes.

## Tasks

### A. Prerequisites shared with the Records export plugin
These are not specific to routes: the Records and OpenCoach export plugins need
them too, and none of them exists yet (see "Wiring it into a release build" in
`docs/release/private-plugins.md`, status *designed, not implemented*).
- [ ] Create the private repo `openbike_private_plugins` with `register.dart`
      mirroring `lib/plugins/private_registration.dart`.
- [ ] Records sign-in from OpenBike (OIDC auth-code + PKCE against the Records
      client already registered), with tokens in secure storage.
- [ ] Release workflow: deploy key, `dependency_overrides`, swap of
      `private_registration.dart` before `flutter build`.

### B. Records side (`Records` repo)
- [ ] Scope for reading the rider's races and their courses, declared in
      `lib/ecosystem/scopes.ts`.
- [ ] `GET /api/ecosystem/v1/me/races` — upcoming registrations
      (`interested` / `registered`) and past claimed results, each with race
      name, date, distance label, and whether a bike course exists + its
      distance and climbing.
- [ ] `GET /api/ecosystem/v1/courses/<catalogId>/<year>/bike` — the bike
      segment's points.
- [ ] Tests for both endpoints (own data only, scope enforced, races without a
      bike course left out).

### C. OpenBike public seam (this repo)
- [ ] `RouteSourcePlugin` interface in `lib/plugins/plugin_interfaces.dart`:
      manifest, `isAuthenticated`, `listRoutes()` (summaries with an optional
      date and section — e.g. upcoming / past), `loadRouteGpx(externalRef)`.
- [ ] `extraRouteSources()` hook in `private_registration.dart` (returns
      `const []`) and `registerPrivatePlugins`; registry support; test with a
      fake source, as `test/plugins/private_plugins_test.dart` does for exports.
- [ ] Library screen: one section per registered source above "Saved", from
      its summaries; caching into `saved_routes`; read-only tiles (no rename /
      delete); offline falls back to the cache.
- [ ] Update `docs/release/private-plugins.md` (seam section and private repo
      layout).

### D. Private plugin (`openbike_private_plugins`)
- [ ] `RecordsRouteSource` implementing `RouteSourcePlugin` against B's
      endpoints, sharing the Records sign-in from A.
- [ ] Bike points → GPX text.
- [ ] Register it in `register.dart`.
