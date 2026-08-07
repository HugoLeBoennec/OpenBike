# Private plugins (open-core seam)

OpenBike core is open source (MIT/Apache-2.0 — see P9). Two integrations
are explicitly **not** public because they're user-specific services with
no public API surface to document safely in an open repo:

- **Records**
- **OpenCoach**

Both are implemented as `ExportPlugin`s (`lib/plugins/plugin_interfaces.dart`)
in a **separate private repository**, `openbike_private_plugins`, and are
loaded into the public app through the seam described below. This repo
contains **no code, endpoints, or credentials for either service** — that's
enforced by CI (`grep -ri "opencoach\|records_api" lib/` must be empty; see
the P6 phase's `validation` block).

## The seam

- `lib/plugins/private_registration.dart` — the checked-in **public
  default**. Exposes two hook functions:

  ```dart
  List<ExportPlugin> extraExportPlugins() => const [];
  List<DevicePlugin> extraDevicePlugins() => const [];
  ```

  Both return empty lists. This is what every public build, PR, and CI run
  compiles against — there is no conditional import guarding this, because
  Dart can't conditionally import a package that isn't a pubspec
  dependency at all. The public app must compile and pass CI with **no**
  private package present, so the stub is the actual default, not a
  fallback branch.

- `lib/plugins/private_plugins.dart` — `registerPrivatePlugins(registry,
  {extraExportPlugins, extraDevicePlugins})` resolves the two hooks
  (defaulting to the stub above) and registers whatever they return into
  the `PluginRegistry`. `lib/main.dart` calls this, unparameterized, at the
  end of `_registerPlugins`. Because the hooks are also constructor
  parameters, tests can pass a fake hook directly — see
  `test/plugins/private_plugins_test.dart` — without ever touching the
  stub file or needing the private package.

- **Connections UI** (`lib/presentation/widgets/connections_section.dart`)
  is data-driven off `exportPluginsProvider`, which in turn reflects
  whatever's in the `PluginRegistry`. Once a private plugin registers, its
  row (Connect/Disconnect, auto-upload toggle) appears automatically — no
  per-service UI code needed in the public repo.

## Private repo layout (`openbike_private_plugins`)

A separate, private GitHub repo with roughly:

```
openbike_private_plugins/
  pubspec.yaml           # depends on the public open_bike package for
                          # ExportPlugin/DevicePlugin/PluginManifest/etc.
  lib/
    register.dart        # exports extraExportPlugins()/extraDevicePlugins()
    records_export_plugin.dart
    opencoach_export_plugin.dart
```

`register.dart` mirrors the public stub's shape so the release-build swap
(below) is a drop-in replacement:

```dart
List<ExportPlugin> extraExportPlugins() => [
      RecordsExportPlugin(config: /* ... */),
      OpenCoachExportPlugin(config: /* ... */),
    ];

List<DevicePlugin> extraDevicePlugins() => const [];
```

`RecordsExportPlugin`/`OpenCoachExportPlugin` implement `ExportPlugin`
exactly like `StravaExportPlugin` does in the public repo (OAuth/API
details live entirely in the private repo — the maintainer fills those in
there, not here).

## Wiring it into a release build

> **Status: designed, not implemented.** `.github/workflows/release.yml`
> contains none of the steps below — no deploy key, no `dependency_overrides`
> injection, no file swap — and `pubspec.yaml` has no `dependency_overrides`
> block. Every build produced today, release builds included, compiles
> against the stub and ships with no private plugins.
>
> This is deliberate: `openbike_private_plugins` does not exist yet, and
> wiring a swap that has nothing to swap in would mean its first real
> execution happened during an actual release build. Implement this section
> together with the private repo, when there is something to test it
> against. Until then, treat what follows as the intended design.

The swap needs two things a public/dev build never does:

1. **Adds the git dependency** to `pubspec.yaml` for that build only, via
   an SSH deploy key scoped read-only to `openbike_private_plugins`:

   ```yaml
   dependency_overrides:
     openbike_private_plugins:
       git:
         url: git@github.com:<org>/openbike_private_plugins.git
         ref: main
   ```

   The deploy key is stored as a GitHub Actions secret (e.g.
   `PRIVATE_PLUGINS_DEPLOY_KEY`) and loaded with
   `webfactory/ssh-agent` (or equivalent) before `flutter pub get`.

2. **Replaces `lib/plugins/private_registration.dart`** with a version that
   imports the private package:

   ```dart
   export 'package:openbike_private_plugins/register.dart';
   ```

   (An `export` works here because the function signatures match exactly;
   a thin re-export avoids needing an `import`+forwarding-function pair.)
   This file swap happens as a CI step (`cp` from a path checked into the
   release workflow, or piped from a secret) immediately before `flutter
   build`, and is never committed back to the public branch.

Public PRs, `flutter analyze`, and `flutter test` never see either change —
they run against the stub, exactly as any external contributor's build
would.

## Testing the seam without the private repo

`test/plugins/private_plugins_test.dart` proves the mechanism works end to
end using a fake in-test plugin:

```dart
registerPrivatePlugins(
  registry,
  extraExportPlugins: () => [FakeRecordsPlugin()],
);
expect(registry.allManifests.map((m) => m.id), contains('records-export'));
```

This is the same hook a real `openbike_private_plugins/register.dart`
would satisfy — no private code needed to verify the seam itself.
