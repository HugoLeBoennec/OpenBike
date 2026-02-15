# OpenBike

Open-source indoor cycling app — smart trainer control, structured workouts, route simulation.

Runs on **Android, iOS, macOS, Linux, Windows, and Web**.

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
- **Linux / Windows**: ANT+ USB dongle support is planned.
- **Web**: BLE is not available; the app runs in simulation mode.

## License

TBD
