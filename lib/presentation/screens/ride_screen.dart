import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/data_field_type.dart';
import '../models/ride_extra.dart';
import '../state/providers.dart';
import '../widgets/data_field_grid.dart';
import '../widgets/live_chart.dart';
import '../widgets/power_gauge.dart';
import '../widgets/ride_header_bar.dart';
import '../widgets/zone_bar.dart';

/// Main ride screen — Garmin Edge style dark UI with responsive layouts.
///
/// - **Portrait** (<600px): Header → ZoneBar → PageView(grids) → dots → Chart
/// - **Landscape** (≥600px): Row → Left(header+zone+grid) → Right(chart+gauge)
/// - **Desktop** (≥1200px): same as landscape but with larger grid (3×4)
class RideScreen extends ConsumerStatefulWidget {
  const RideScreen({super.key, this.extra});

  final RideExtra? extra;

  @override
  ConsumerState<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends ConsumerState<RideScreen> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();

    // If a workout was passed, set it as the current workout.
    if (widget.extra?.workout != null) {
      Future.microtask(() {
        ref.read(currentWorkoutProvider.notifier).state = widget.extra!.workout;
      });
    }

    // If a route was passed, start the route simulator.
    if (widget.extra?.route != null) {
      Future.microtask(() {
        ref.read(routeSimulatorProvider).start(widget.extra!.route!);
      });
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Bridge EventBus sensor events into live UI providers
    ref.watch(liveSensorBridgeProvider);
    // Activate history updaters so ring buffers receive live data
    ref.watch(powerHistoryUpdaterProvider);
    ref.watch(hrHistoryUpdaterProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 1200) {
                return _buildDesktopLayout(context, ref, constraints);
              } else if (constraints.maxWidth >= 600) {
                return _buildLandscapeLayout(context, ref, constraints);
              } else {
                return _buildPortraitLayout(context, ref, constraints);
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave ride?'),
        content: const Text('Your current ride data will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child:
                const Text('Leave', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  // ─── Portrait ──────────────────────────────────────────────────────

  Widget _buildPortraitLayout(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    final config = ref.watch(rideScreenConfigProvider);
    final pages = config.pages;

    return Column(
      children: [
        const RideHeaderBar(),
        const ZoneBar(),
        Expanded(
          flex: 3,
          child: _PagedDataGrid(
            pages: pages,
            columns: config.columns,
          ),
        ),
        const Expanded(
          flex: 2,
          child: LiveChart(),
        ),
      ],
    );
  }

  // ─── Landscape ─────────────────────────────────────────────────────

  Widget _buildLandscapeLayout(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    final config = ref.watch(rideScreenConfigProvider);
    final fields =
        config.pages.isNotEmpty ? config.pages.first : <DataFieldType>[];

    return Row(
      children: [
        // Left: header + zone + grid
        Expanded(
          flex: 3,
          child: Column(
            children: [
              const RideHeaderBar(),
              const ZoneBar(),
              Expanded(
                child: DataFieldGrid(
                  fields: fields,
                  columns: 3,
                  pageIndex: 0,
                ),
              ),
            ],
          ),
        ),
        // Right: chart + gauge
        Expanded(
          flex: 2,
          child: Column(
            children: [
              const Expanded(
                flex: 3,
                child: LiveChart(),
              ),
              if (config.showPowerGauge)
                const Expanded(
                  flex: 2,
                  child: PowerGauge(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Desktop ───────────────────────────────────────────────────────

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    BoxConstraints constraints,
  ) {
    final config = ref.watch(rideScreenConfigProvider);
    final fields =
        config.pages.isNotEmpty ? config.pages.first : <DataFieldType>[];

    return Row(
      children: [
        // Left: header + zone + large grid
        Expanded(
          flex: 3,
          child: Column(
            children: [
              const RideHeaderBar(),
              const ZoneBar(),
              Expanded(
                child: DataFieldGrid(
                  fields: fields,
                  columns: 3,
                  pageIndex: 0,
                ),
              ),
            ],
          ),
        ),
        // Right: chart + gauge
        Expanded(
          flex: 2,
          child: Column(
            children: [
              const Expanded(
                flex: 3,
                child: LiveChart(),
              ),
              if (config.showPowerGauge)
                const Expanded(
                  flex: 2,
                  child: PowerGauge(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Paged Data Grid (portrait only) ───────────────────────────────────

class _PagedDataGrid extends StatefulWidget {
  final List<List<DataFieldType>> pages;
  final int columns;

  const _PagedDataGrid({
    required this.pages,
    required this.columns,
  });

  @override
  State<_PagedDataGrid> createState() => _PagedDataGridState();
}

class _PagedDataGridState extends State<_PagedDataGrid> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            itemCount: widget.pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return DataFieldGrid(
                fields: widget.pages[index],
                columns: widget.columns,
                pageIndex: index,
              );
            },
          ),
        ),
        if (widget.pages.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _PageDots(
              count: widget.pages.length,
              current: _currentPage,
            ),
          ),
      ],
    );
  }
}

// ─── Page indicator dots ───────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  final int count;
  final int current;

  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == current
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}
