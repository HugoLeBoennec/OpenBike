# OpenBike

Open-source indoor cycling app — smart trainer control, structured workouts, route simulation.

Runs on **Android, iOS, macOS and Windows**, with best-effort **Linux** support.

## Architecture

The project follows **Hexagonal Architecture** (Clean Architecture) with strict dependency rules: inner layers never depend on outer layers.

```
lib/
├── core/                          # Pure Dart — no Flutter imports
│   ├── domain/
│   │   ├── entities/              # Ride, Workout, WorkoutStep, Trainer, SensorReading, PowerZone, UserProfile
│   │   ├── value_objects/         # Watts, Cadence, HeartRate, Speed, Distance, Grade (freezed)
│   │   └── ports/                 # Abstract interfaces: TrainerPort, SensorPort, ExportPort, StoragePort
│   ├── application/
│   │   ├── use_cases/             # StartRide, StopRide, ConnectTrainer, ExecuteWorkout, SimulateRoute, ExportActivity
│   │   └── services/              # WorkoutEngine, PhysicsEngine, ZoneCalculator
│   └── events/                    # EventBus + typed events (PowerUpdate, CadenceUpdate, HrUpdate, etc.)
│
├── infrastructure/                # Adapters implementing ports
│   ├── ble/                       # BLE transport: FTMS client, CPS/CSC/HRS readers
│   ├── ant/                       # ANT+ via USB (desktop): FE-C profile
│   ├── files/                     # Parsers: GPX, ZWO, ERG/MRC — Encoders: FIT, TCX
│   ├── api/                       # OAuth2 clients: Strava, Garmin Connect, TrainingPeaks
│   └── persistence/               # SQLite via Drift, export queue with retry
│
├── plugins/                       # Plugin system for extensibility
│   ├── plugin_registry.dart       # Central registry, dynamic loading
│   ├── plugin_interfaces.dart     # DevicePlugin, ExportPlugin, WorkoutFormatPlugin, WidgetPlugin
│   ├── devices/                   # Device plugins
│   ├── exports/                   # Export plugins
│   └── formats/                   # Format plugins
│
└── presentation/                  # Flutter UI
    ├── state/                     # Riverpod providers
    ├── screens/                   # RideScreen, WorkoutBuilderScreen, HistoryScreen, SettingsScreen, DeviceScanScreen
    ├── widgets/                   # PowerGauge, ZoneBar, LiveChart, DataFieldGrid, GpxProfileWidget
    └── router.dart                # go_router configuration
```

### Dependency rules

| Layer          | Can depend on              |
|----------------|----------------------------|
| domain         | nothing                    |
| application    | domain                     |
| events         | domain                     |
| infrastructure | domain, application        |
| plugins        | domain, application        |
| presentation   | all layers above           |

### Key technologies

- **State management** — Riverpod
- **Immutable models** — freezed + freezed_annotation
- **Persistence** — Drift (SQLite)
- **Navigation** — go_router
- **BLE** — flutter_blue_plus (FTMS, CPS, CSC, HRS)
- **Code generation** — build_runner

## Getting started

```bash
# Install dependencies
flutter pub get

# Generate freezed classes and Drift code
flutter pub run build_runner build --delete-conflicting-outputs

# Run on the current device
flutter run
```

### Platform-specific setup

- **Android / iOS / macOS**: BLE permissions are required. See `flutter_blue_plus` docs.
- **Windows**: BLE is supported. ANT+ USB dongle support is optional — see
  [docs/release/antplus-usb.md](docs/release/antplus-usb.md).
- **Linux**: builds and runs, but BLE goes through BlueZ and has not been
  verified against real trainer hardware (`docs/roadmap/P8-desktop.md`).
  Treat it as best-effort. Install from a release with:

  ```bash
  curl -fsSL https://github.com/HugoLeBoennec/OpenBike/releases/latest/download/install.sh | sh
  ```

  It verifies the download against `SHA256SUMS` and installs under `$HOME`
  with no root; `sh -s -- --uninstall` reverses it. See
  [docs/release/desktop-distribution.md](docs/release/desktop-distribution.md).
- **Web**: not supported. BLE is unavailable in the browser for the profiles
  this app needs, so there is no web build target.

## License

Apache License 2.0 — see [LICENSE](LICENSE) and [NOTICE](NOTICE). Chosen (over
GPL/MPL) because the open-core split (`docs/roadmap/README.md` §"Open-core
strategy") requires the closed-source `openbike_private_plugins` companion
package to be able to link against this core; Apache-2.0 also adds an express
patent grant that plain MIT lacks. Third-party package licenses are listed
in-app at Settings → About → Open-source licenses.
