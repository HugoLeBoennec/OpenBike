# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Code generation (required after editing freezed models or Drift schemas)
flutter pub run build_runner build --delete-conflicting-outputs

# Run app (standard)
flutter run

# Run app with simulator device plugin enabled
flutter run --dart-define=DEV_MODE=true

# Run app with Strava export enabled
flutter run --dart-define=STRAVA_CLIENT_ID=... --dart-define=STRAVA_CLIENT_SECRET=...

# Lint
flutter analyze

# Tests
flutter test
flutter test integration_test/
```

## Architecture

The app follows **Hexagonal / Clean Architecture** with strict one-way dependencies: `core` → `infrastructure` → `plugins` → `presentation`.

### `lib/core/` — Pure Dart, zero Flutter imports

- **`domain/entities/`** — `Ride`, `Workout`, `WorkoutStep`, `Trainer`, `SensorReading`, `PowerZone`, `UserProfile`
- **`domain/value_objects/`** — `Watts`, `Cadence`, `HeartRate`, `Speed`, `Distance`, `Grade` (freezed)
- **`domain/ports/`** — `TrainerPort`, `SensorPort`, `ExportPort`, `StoragePort` (abstract interfaces)
- **`application/use_cases/`** — `StartRide`, `StopRide`, `ConnectTrainer`, `ExecuteWorkout`, `SimulateRoute`, `ExportActivity`
- **`application/services/`** — `WorkoutEngine`, `PhysicsEngine`, `ZoneCalculator`, `RecordingEngine`, `ConnectionMonitor`
- **`events/`** — `EventBus` + typed events (`SensorEvent`, `PowerUpdate`, `CadenceUpdate`, `HrUpdate`, …)

### `lib/infrastructure/` — Adapters implementing ports

- **`ble/`** — BLE transport: FTMS client, CPS/CSC/HRS profile readers (flutter_blue_plus)
- **`files/`** — Parsers: GPX, ZWO, ERG/MRC — Encoders: FIT, TCX
- **`api/`** — OAuth2 clients: Strava, Garmin Connect, TrainingPeaks
- **`persistence/`** — SQLite via Drift (`AppDatabase`, `DriftStorage`, `ExportQueueService`)
- **`preferences/`** — `AppPreferences` (SharedPreferences wrapper)
- **`simulator/`** — `SimulatorDevicePlugin` + `CyclingPhysicsEngine` (DEV_MODE only)

### `lib/plugins/` — Plugin system

Four plugin types defined in [lib/plugins/plugin_interfaces.dart](lib/plugins/plugin_interfaces.dart):

- **`DevicePlugin`** — `scan()`, `connect(TrainerDevice) → TrainerPort`, `canHandle(TrainerDevice)`
- **`ExportPlugin`** — `isAuthenticated`, `authenticate()`, `disconnect()`, `export(Ride) → String`
- **`WorkoutFormatPlugin`** — `supportedExtensions`, `parse()`, `serialize()`
- **`WidgetPlugin`** — `build(context, Stream<SensorReading>) → Widget`

The `PluginRegistry` holds typed lists and provides lookup. Plugins are registered in `main.dart`'s `_registerPlugins()`. Adding a new plugin = implement the interface + register it there.

### `lib/presentation/` — Flutter UI

**State** ([lib/presentation/state/providers.dart](lib/presentation/state/providers.dart)) uses **Riverpod**. All providers are in one file. Providers that depend on singletons created in `main.dart` (DB, EventBus, BleTransport, PluginRegistry) are overridden via `ProviderContainer` overrides.

**Key data flow:** `TrainerPort` emits sensor data → fires `SensorEvent` on `EventBus` → `liveSensorBridgeProvider` listens and pushes into `livePowerProvider`/`liveCadenceProvider`/`liveHeartRateProvider` (all `StateProvider`) → UI rebuilds.

**Navigation** uses go_router with two zones:
- Full-screen (no bottom nav): `/onboarding`, `/ride`, `/ride/summary/:id`, `/scan`
- Shell routes (AppShell with bottom nav): `/` (Home), `/workouts`, `/history`, `/settings`, `/dev`

### `lib/main.dart` — Wiring

Bootstraps the entire app: opens Drift DB → creates singletons → registers plugins → loads preferences → builds `ProviderContainer` with overrides → sets up Strava OAuth deep link → runs app.

## Key Libraries

| Library | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.6.1 | State management |
| freezed | code-gen | Immutable models & unions |
| drift | ^2.20.3 (pinned) | SQLite ORM |
| go_router | ^14.8.1 | Navigation |
| flutter_blue_plus | ^1.36.8 | BLE (FTMS, CPS, CSC, HRS) |
| mocktail | ^1.0.4 | Mocking in tests |

**Note:** Drift is pinned at 2.20.3 with sqlite3 2.4.6 for Dart <3.6 compatibility. Do not upgrade without checking Dart SDK version.

## Code Generation

Models annotated with `@freezed` and Drift table definitions require code generation. After modifying these files, run `build_runner build`. Generated files (`*.freezed.dart`, `*.g.dart`) are committed to the repo.
