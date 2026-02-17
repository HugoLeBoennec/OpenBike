import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data_field_type.dart';

// ---------------------------------------------------------------------------
// Ride screen layout configuration
// ---------------------------------------------------------------------------

class RideScreenConfig {
  final List<List<DataFieldType>> pages;
  final int columns;
  final int rows;
  final bool showChart;
  final bool showPowerGauge;

  const RideScreenConfig({
    required this.pages,
    this.columns = 2,
    this.rows = 2,
    this.showChart = true,
    this.showPowerGauge = false,
  });

  // -------------------------------------------------------------------------
  // Default presets
  // -------------------------------------------------------------------------

  static const defaultPortrait = RideScreenConfig(
    pages: [
      [
        DataFieldType.power,
        DataFieldType.cadence,
        DataFieldType.heartRate,
        DataFieldType.speed,
      ],
      [
        DataFieldType.avgPower,
        DataFieldType.normalizedPower,
        DataFieldType.tss,
        DataFieldType.intensityFactor,
      ],
    ],
    columns: 2,
    rows: 2,
  );

  static const defaultLandscape = RideScreenConfig(
    pages: [
      [
        DataFieldType.power,
        DataFieldType.cadence,
        DataFieldType.heartRate,
        DataFieldType.speed,
        DataFieldType.distance,
        DataFieldType.elapsedTime,
      ],
    ],
    columns: 3,
    rows: 2,
    showPowerGauge: true,
  );

  static const defaultDesktop = RideScreenConfig(
    pages: [
      [
        DataFieldType.power,
        DataFieldType.threeSecAvgPower,
        DataFieldType.avgPower,
        DataFieldType.normalizedPower,
        DataFieldType.cadence,
        DataFieldType.heartRate,
        DataFieldType.speed,
        DataFieldType.distance,
        DataFieldType.elapsedTime,
        DataFieldType.tss,
        DataFieldType.intensityFactor,
        DataFieldType.calories,
      ],
    ],
    columns: 3,
    rows: 4,
    showPowerGauge: true,
  );
}

// ---------------------------------------------------------------------------
// State notifier
// ---------------------------------------------------------------------------

class RideScreenConfigNotifier extends StateNotifier<RideScreenConfig> {
  RideScreenConfigNotifier() : super(RideScreenConfig.defaultPortrait);

  bool _userCustomized = false;

  /// Auto-adapts layout based on screen dimensions. Respects manual overrides.
  void adaptToLayout({required bool isLandscape, required bool isDesktop}) {
    if (_userCustomized) return;
    if (isDesktop) {
      state = RideScreenConfig.defaultDesktop;
    } else if (isLandscape) {
      state = RideScreenConfig.defaultLandscape;
    } else {
      state = RideScreenConfig.defaultPortrait;
    }
  }

  /// Replaces a single field in the grid. Marks config as user-customized.
  void setFieldAt(int pageIndex, int fieldIndex, DataFieldType type) {
    _userCustomized = true;
    final newPages = state.pages
        .map((page) => List<DataFieldType>.from(page))
        .toList();
    if (pageIndex < newPages.length &&
        fieldIndex < newPages[pageIndex].length) {
      newPages[pageIndex][fieldIndex] = type;
    }
    state = RideScreenConfig(
      pages: newPages,
      columns: state.columns,
      rows: state.rows,
      showChart: state.showChart,
      showPowerGauge: state.showPowerGauge,
    );
  }
}
