# Contributing to OpenBike

Thanks for your interest. OpenBike is maintained by one person, so the most
useful thing you can do before writing code is **open an issue first** — for
anything larger than a bug fix, agreement on the approach saves you from
building something that gets turned down.

## Getting set up

Requires Flutter **3.41.x** (the version CI pins in
`.github/workflows/ci.yml`).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The `build_runner` step is not optional — `freezed` models and Drift database
code are generated, not committed, so the project does not compile without it.

### Working without hardware

You don't need a smart trainer. Build with `--dart-define=DEV_MODE=true` to
enable the physics-backed simulator and Dev Tools:

```bash
flutter run --dart-define=DEV_MODE=true
```

This replaces the BLE stack with a simulated trainer, so ride recording,
workouts and route simulation are all exercisable from a laptop.

## Before you open a PR

```bash
flutter analyze     # must be clean — CI fails on any issue
flutter test        # must be green
```

Both run on every push. If you touched generated-code inputs (`freezed`
classes, Drift tables), re-run `build_runner` and commit the regenerated
files.

## Architecture

The project follows hexagonal architecture with strict dependency rules,
documented in [README.md](README.md#dependency-rules). The short version:
`core/` is pure Dart with no Flutter imports, and inner layers never depend on
outer ones. A PR that has `core/domain` importing from `presentation/` will be
sent back.

New integrations should be **plugins** rather than special cases wired into
the app — see `lib/plugins/plugin_interfaces.dart` and the existing Strava,
Garmin and TCX export plugins.

## Commit messages

Write the subject in the imperative mood, describing what the change does:

```
Wait for the Bluetooth radio before connecting, fixing auto-reconnect
```

No `feat:`/`fix:` prefixes. If the change isn't self-evident, use the body to
explain *why* — what was wrong before, not a restatement of the diff.

## What is unlikely to be merged

- **Analytics or tracking of any kind.** Staying free of behavioural
  analytics is a deliberate product decision, documented in
  [docs/release/analytics.md](docs/release/analytics.md). Opt-in crash
  reporting is the only telemetry that will ever ship.
- Anything sending ride data off the device without an explicit user action.
- New third-party SDKs with broad permissions or their own telemetry.
- Web support. BLE in the browser can't do what this app needs.

## A note on the private plugins

Two integrations — Records and OpenCoach — live in a separate private package
and are loaded through the seam described in
[docs/release/private-plugins.md](docs/release/private-plugins.md). The public
app compiles and passes CI with a stub that registers nothing, which is what
you and CI both build against.

You never need that package. CI enforces this in both directions: no code or
endpoints for those services may appear in `lib/` or `test/`, and the stub at
`lib/plugins/private_registration.dart` must never import the private package.
If a change of yours trips that guard, it's a mistake in the change, not in
the guard.

## Reporting bugs

Include the platform and OS version, the trainer or sensor involved if it's a
connectivity issue, and steps to reproduce. Logs from a `DEV_MODE` build help
a lot.

For anything security-related, **do not open a public issue** — follow
[SECURITY.md](SECURITY.md).

## Licence

By contributing you agree that your contributions are licensed under the
Apache Licence 2.0, the same as the rest of the project.
