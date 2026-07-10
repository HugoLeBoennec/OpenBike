import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/application/services/services.dart';
import '../../core/domain/entities/entities.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/personal_records_panel.dart';

/// Performance Management Chart — CTL/ATL/TSB trend, weekly TSS, totals, and
/// a personal-records panel.
class TrendsScreen extends ConsumerStatefulWidget {
  const TrendsScreen({super.key});

  @override
  ConsumerState<TrendsScreen> createState() => _TrendsScreenState();
}

enum _Range { oneMonth, threeMonths, sixMonths, twelveMonths }

extension on _Range {
  int get months => switch (this) {
        _Range.oneMonth => 1,
        _Range.threeMonths => 3,
        _Range.sixMonths => 6,
        _Range.twelveMonths => 12,
      };

  String get label => switch (this) {
        _Range.oneMonth => '1M',
        _Range.threeMonths => '3M',
        _Range.sixMonths => '6M',
        _Range.twelveMonths => '12M',
      };
}

class _TrendsScreenState extends ConsumerState<TrendsScreen> {
  _Range _range = _Range.threeMonths;

  @override
  Widget build(BuildContext context) {
    final fitnessAsync = ref.watch(fitnessHistoryProvider);
    final ridesAsync = ref.watch(rideHistoryProvider);
    final recordsAsync = ref.watch(personalRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trends'),
      ),
      body: fitnessAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Couldn\'t load trends: $e',
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(fitnessHistoryProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (allPoints) {
          if (allPoints.isEmpty) {
            return Center(
              child: Text(
                'No ride history yet.\nComplete a ride to see fitness trends.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.tokens.textDisabled, fontSize: 13),
              ),
            );
          }

          final cutoff = DateTime.now().subtract(Duration(days: _range.months * 30));
          final points = allPoints.where((p) => !p.date.isBefore(cutoff)).toList();
          final visible = points.isEmpty ? allPoints : points;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _RangeSelector(
                selected: _range,
                onSelected: (r) => setState(() => _range = r),
              ),
              const SizedBox(height: 16),
              ridesAsync.maybeWhen(
                data: (rides) => _TotalsRow(rides: rides),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              _SectionLabel('FITNESS / FATIGUE / FORM'),
              const SizedBox(height: 8),
              SizedBox(height: 220, child: _PmcChart(points: visible)),
              const SizedBox(height: 8),
              _PmcLegend(latest: visible.last),
              const SizedBox(height: 24),
              _SectionLabel('WEEKLY TSS'),
              const SizedBox(height: 8),
              SizedBox(height: 160, child: _WeeklyTssChart(points: visible)),
              const SizedBox(height: 24),
              _SectionLabel('PERSONAL RECORDS'),
              const SizedBox(height: 8),
              recordsAsync.maybeWhen(
                data: (records) => PersonalRecordsPanel(records: records),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Range selector
// ---------------------------------------------------------------------------

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selected, required this.onSelected});
  final _Range selected;
  final ValueChanged<_Range> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final r in _Range.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ChoiceChip(
                key: Key('range-${r.label}'),
                label: Center(child: Text(r.label)),
                selected: r == selected,
                onSelected: (_) => onSelected(r),
                selectedColor: Colors.deepOrange,
                backgroundColor: context.tokens.surfaceTier2,
                labelStyle: TextStyle(
                  color: r == selected
                      ? Colors.white
                      : context.tokens.textTertiary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Totals row
// ---------------------------------------------------------------------------

class _TotalsRow extends ConsumerWidget {
  const _TotalsRow({required this.rides});
  final List<Ride> rides;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(unitFormatterProvider);
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));

    final weekRides = rides.where((r) => r.startTime.isAfter(weekAgo)).toList();
    final monthRides = rides.where((r) => r.startTime.isAfter(monthAgo)).toList();

    final weekTime = weekRides.fold<Duration>(
        Duration.zero, (sum, r) => sum + r.activeDuration);
    final weekDistance = weekRides.fold<Distance>(
        Distance.zero, (sum, r) => sum + r.totalDistance);
    final monthTss =
        monthRides.fold<double>(0, (sum, r) => sum + (r.cachedTss ?? 0));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _TotalStat(label: 'TIME (7D)', value: _formatHours(weekTime)),
        _TotalStat(
            label: 'DISTANCE (7D)',
            value:
                '${formatter.distanceValue(weekDistance).toStringAsFixed(0)} ${formatter.distanceUnit}'),
        _TotalStat(label: 'TSS (30D)', value: monthTss.round().toString()),
      ],
    );
  }

  String _formatHours(Duration d) {
    final h = d.inMinutes / 60;
    return '${h.toStringAsFixed(1)}h';
  }
}

class _TotalStat extends StatelessWidget {
  const _TotalStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: tokens.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: tokens.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// PMC chart (CTL/ATL lines + TSB area)
// ---------------------------------------------------------------------------

class _PmcChart extends StatelessWidget {
  const _PmcChart({required this.points});
  final List<FitnessDataPoint> points;

  @override
  Widget build(BuildContext context) {
    final ctlSpots = <FlSpot>[];
    final atlSpots = <FlSpot>[];
    final tsbSpots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      ctlSpots.add(FlSpot(i.toDouble(), points[i].ctl));
      atlSpots.add(FlSpot(i.toDouble(), points[i].atl));
      tsbSpots.add(FlSpot(i.toDouble(), points[i].tsb));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: tsbSpots,
            isCurved: false,
            color: Colors.purpleAccent.withValues(alpha: 0.6),
            barWidth: 1,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.purpleAccent.withValues(alpha: 0.15),
            ),
          ),
          LineChartBarData(
            spots: ctlSpots,
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: atlSpots,
            isCurved: true,
            color: Colors.orangeAccent,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
      duration: Duration.zero,
    );
  }
}

class _PmcLegend extends StatelessWidget {
  const _PmcLegend({required this.latest});
  final FitnessDataPoint latest;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _LegendStat(color: Colors.blueAccent, label: 'CTL (Fitness)', value: latest.ctl),
        _LegendStat(color: Colors.orangeAccent, label: 'ATL (Fatigue)', value: latest.atl),
        _LegendStat(color: Colors.purpleAccent, label: 'TSB (Form)', value: latest.tsb),
      ],
    );
  }
}

class _LegendStat extends StatelessWidget {
  const _LegendStat({required this.color, required this.label, required this.value});
  final Color color;
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(value.round().toString(),
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: context.tokens.textTertiary, fontSize: 10)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Weekly TSS bar chart
// ---------------------------------------------------------------------------

class _WeeklyTssChart extends StatelessWidget {
  const _WeeklyTssChart({required this.points});
  final List<FitnessDataPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    // Bucket into 7-day windows starting from the first point's date.
    final weeks = <double>[];
    var weekSum = 0.0;
    for (var i = 0; i < points.length; i++) {
      weekSum += points[i].tss;
      if ((i + 1) % 7 == 0 || i == points.length - 1) {
        weeks.add(weekSum);
        weekSum = 0;
      }
    }

    final groups = <BarChartGroupData>[
      for (var i = 0; i < weeks.length; i++)
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: weeks[i],
            width: (200 / weeks.length).clamp(3, 18),
            color: Colors.deepOrange,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ]),
    ];

    return BarChart(
      BarChartData(
        barGroups: groups,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: TextStyle(color: context.tokens.textDisabled, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(enabled: false),
      ),
      duration: Duration.zero,
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.tokens.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}
