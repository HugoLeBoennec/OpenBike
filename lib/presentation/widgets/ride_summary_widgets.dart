import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../infrastructure/persistence/export_queue_service.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// New personal records banner
// ---------------------------------------------------------------------------

class NewPersonalRecordsBanner extends StatelessWidget {
  const NewPersonalRecordsBanner({super.key, required this.durations});

  /// Duration buckets (seconds) this ride set an all-time best for.
  final List<int> durations;

  static const _labels = {5: '5 sec', 60: '1 min', 300: '5 min', 1200: '20 min'};

  @override
  Widget build(BuildContext context) {
    final labels = durations.map((d) => _labels[d] ?? '${d}s').join(', ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New PR!',
                    style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                Text(
                  'Best-ever $labels power',
                  style: TextStyle(color: context.tokens.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header card
// ---------------------------------------------------------------------------

class HeaderCard extends ConsumerWidget {
  const HeaderCard({super.key, required this.ride});
  final Ride ride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(unitFormatterProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.surfaceTier2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          HeaderStat(
            label: 'DATE',
            value: formatDate(ride.startTime),
          ),
          HeaderStat(
            label: 'DURATION',
            value: formatDuration(ride.activeDuration),
          ),
          HeaderStat(
            label: 'DISTANCE',
            value: formatter.distance(ride.totalDistance),
          ),
        ],
      ),
    );
  }
}

class HeaderStat extends StatelessWidget {
  const HeaderStat({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: tokens.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: tokens.textDisabled, fontSize: 10, letterSpacing: 1)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Metrics grid (2×3)
// ---------------------------------------------------------------------------

class MetricsGrid extends StatelessWidget {
  const MetricsGrid({super.key, required this.ride, required this.ftp});
  final Ride ride;
  final Watts ftp;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        MetricCell(
            label: 'AVG POWER', value: '${ride.averagePower.value.round()}', unit: 'W'),
        MetricCell(
            label: 'NP', value: '${ride.normalizedPower.value.round()}', unit: 'W'),
        MetricCell(
            label: 'MAX POWER', value: '${ride.maxPower.value.round()}', unit: 'W'),
        MetricCell(
            label: 'TSS', value: ride.tss(ftp).round().toString()),
        MetricCell(
            label: 'IF',
            value: ride.intensityFactor(ftp).toStringAsFixed(2)),
        MetricCell(
            label: 'AVG HR', value: '${ride.averageHr.bpm}', unit: 'bpm'),
      ],
    );
  }
}

class MetricCell extends StatelessWidget {
  const MetricCell({super.key, required this.label, required this.value, this.unit});
  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value,
                style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
            if (unit != null)
              Text(' $unit',
                  style: TextStyle(color: tokens.textDisabled, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: tokens.textDisabled, fontSize: 9, letterSpacing: 0.8)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Power chart
// ---------------------------------------------------------------------------

class RidePowerChart extends StatelessWidget {
  const RidePowerChart({
    super.key,
    required this.ride,
    required this.zones,
    required this.ftp,
  });

  final Ride ride;
  final List<PowerZone> zones;
  final Watts ftp;

  @override
  Widget build(BuildContext context) {
    final readings = ride.readings;
    if (readings.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (int i = 0; i < readings.length; i++) {
      final power = readings[i].power?.value ?? 0;
      spots.add(FlSpot(i.toDouble(), power));
    }

    final maxY = (ride.maxPower.value * 1.1).clamp(100, 2000).toDouble();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ftp.value > 0 ? ftp.value : 100,
          getDrawingHorizontalLine: (value) => FlLine(
            color: context.tokens.surfaceTier3Line,
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.15,
            color: Colors.blue,
            barWidth: 1,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
      duration: Duration.zero,
    );
  }
}

// ---------------------------------------------------------------------------
// Zone distribution chart
// ---------------------------------------------------------------------------

class ZoneDistributionChart extends StatelessWidget {
  const ZoneDistributionChart({
    super.key,
    required this.ride,
    required this.zones,
    required this.ftp,
  });

  final Ride ride;
  final List<PowerZone> zones;
  final Watts ftp;

  @override
  Widget build(BuildContext context) {
    if (ftp.value == 0 || zones.isEmpty) return const SizedBox.shrink();

    final zoneCounts = List.filled(zones.length, 0);
    final total = ride.readings.length;
    if (total == 0) return const SizedBox.shrink();

    for (final reading in ride.readings) {
      final pct = ((reading.power?.value ?? 0) / ftp.value) * 100;
      for (int i = 0; i < zones.length; i++) {
        if (zones[i].contains(pct)) {
          zoneCounts[i]++;
          break;
        }
      }
    }

    return Column(
      children: [
        for (int i = 0; i < zones.length; i++)
          ZoneBarWidget(
            zoneIndex: i + 1,
            zone: zones[i],
            fraction: total > 0 ? zoneCounts[i] / total : 0,
            seconds: zoneCounts[i],
          ),
      ],
    );
  }
}

class ZoneBarWidget extends StatelessWidget {
  const ZoneBarWidget({
    super.key,
    required this.zoneIndex,
    required this.zone,
    required this.fraction,
    required this.seconds,
  });

  final int zoneIndex;
  final PowerZone zone;
  final double fraction;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    final timeStr = '$minutes:${secs.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              'Z$zoneIndex',
              style: TextStyle(
                  color: zone.color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: LayoutBuilder(builder: (_, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: context.tokens.surfaceTier2,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Container(
                    height: 18,
                    width: constraints.maxWidth * fraction,
                    decoration: BoxDecoration(
                      color: zone.color.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              timeStr,
              style: TextStyle(color: context.tokens.textTertiary, fontSize: 11),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Laps table
// ---------------------------------------------------------------------------

class LapsTable extends StatelessWidget {
  const LapsTable({super.key, required this.ride});
  final Ride ride;

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(
      color: context.tokens.textDisabled,
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(width: 40, child: Text('LAP', style: headerStyle)),
              Expanded(child: Text('DURATION', style: headerStyle)),
              SizedBox(
                  width: 60,
                  child: Text('AVG W', style: headerStyle, textAlign: TextAlign.right)),
              SizedBox(
                  width: 60,
                  child: Text('AVG HR', style: headerStyle, textAlign: TextAlign.right)),
            ],
          ),
        ),
        for (int i = 0; i < ride.laps.length; i++)
          LapRow(index: i, lap: ride.laps[i], ride: ride),
      ],
    );
  }
}

class LapRow extends StatelessWidget {
  const LapRow({super.key, required this.index, required this.lap, required this.ride});
  final int index;
  final Lap lap;
  final Ride ride;

  @override
  Widget build(BuildContext context) {
    final lapReadings = ride.readings.length > lap.endIndex
        ? ride.readings.sublist(lap.startIndex, lap.endIndex + 1)
        : <SensorReading>[];

    final avgPower = lapReadings.isEmpty
        ? 0
        : lapReadings
                .where((r) => r.power != null)
                .map((r) => r.power!.value)
                .fold<double>(0, (a, b) => a + b) /
            lapReadings.where((r) => r.power != null).length;

    final avgHr = lapReadings.isEmpty
        ? 0
        : lapReadings
                .where((r) => r.heartRate != null)
                .map((r) => r.heartRate!.bpm)
                .fold<int>(0, (a, b) => a + b) /
            lapReadings.where((r) => r.heartRate != null).length.clamp(1, 99999);

    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('${index + 1}',
                style: TextStyle(color: tokens.textPrimary, fontSize: 13)),
          ),
          Expanded(
            child: Text(formatDuration(lap.duration),
                style: TextStyle(color: tokens.textSecondary, fontSize: 13)),
          ),
          SizedBox(
            width: 60,
            child: Text('${avgPower.round()}',
                style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                textAlign: TextAlign.right),
          ),
          SizedBox(
            width: 60,
            child: Text('${avgHr.round()}',
                style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Export section
// ---------------------------------------------------------------------------

class ExportSection extends ConsumerWidget {
  const ExportSection({super.key, required this.rideId});
  final String rideId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plugins = ref.watch(exportPluginsProvider);
    final queueAsync = ref.watch(exportQueueProvider);

    if (plugins.isEmpty) {
      return Text(
        'No export plugins configured.',
        style: TextStyle(color: context.tokens.textDisabled, fontSize: 13),
      );
    }

    return Wrap(
      spacing: 8,
      children: [
        for (final entry in plugins.entries)
          ExportButton(
            rideId: rideId,
            pluginId: entry.key,
            pluginName: entry.value.manifest.name,
            isAuthenticated: entry.value.isAuthenticated,
            queueItems: queueAsync.valueOrNull ?? [],
          ),
      ],
    );
  }
}

class ExportButton extends ConsumerWidget {
  const ExportButton({
    super.key,
    required this.rideId,
    required this.pluginId,
    required this.pluginName,
    required this.isAuthenticated,
    required this.queueItems,
  });

  final String rideId;
  final String pluginId;
  final String pluginName;
  final bool isAuthenticated;
  final List<ExportQueueItem> queueItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // queueItems (exportQueueProvider) is newest-first, so the first match
    // for this ride/target is the current attempt.
    final item = queueItems
        .cast<ExportQueueItem?>()
        .firstWhere((i) => i!.rideId == rideId && i.target == pluginId, orElse: () => null);

    final isSuccess = item?.isSuccess ?? false;
    final isBusy = item != null && (item.isUploading || item.isPending);
    final isTerminallyFailed =
        item != null && item.isFailed && item.retryCount >= ExportQueueService.maxRetries;
    final isRetrying =
        item != null && item.isFailed && item.retryCount < ExportQueueService.maxRetries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: isSuccess
                ? Colors.green
                : isTerminallyFailed
                    ? Colors.redAccent
                    : context.tokens.textSecondary,
            side: BorderSide(
              color: isSuccess
                  ? Colors.green
                  : isTerminallyFailed
                      ? Colors.redAccent.withValues(alpha: 0.5)
                      : context.tokens.textDisabled,
            ),
          ),
          onPressed: isSuccess || isBusy || isRetrying
              ? null
              : () => isTerminallyFailed
                  ? ref.read(exportQueueServiceProvider).retry(item.id)
                  : ref.read(exportRideProvider)(rideId, pluginId),
          icon: Icon(
            isSuccess
                ? Icons.check_circle
                : isTerminallyFailed
                    ? Icons.refresh
                    : isBusy || isRetrying
                        ? Icons.hourglass_top
                        : Icons.upload,
            size: 16,
          ),
          label: Text(isTerminallyFailed ? 'Retry $pluginName' : pluginName),
        ),
        if (item != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4),
            child: Text(
              _statusLabel(item),
              style: TextStyle(
                color: isTerminallyFailed
                    ? Colors.redAccent
                    : context.tokens.textDisabled,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  String _statusLabel(ExportQueueItem item) {
    if (item.isSuccess) return 'Uploaded';
    if (item.isUploading) return 'Uploading…';
    if (item.isPending) return 'Queued';
    if (item.isFailed) {
      if (item.retryCount < ExportQueueService.maxRetries) {
        return 'Retrying (${item.retryCount}/${ExportQueueService.maxRetries})…';
      }
      return 'Failed: ${item.errorMessage ?? 'unknown error'}';
    }
    return '';
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '$m:${s.toString().padLeft(2, '0')}';
}

String formatDate(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}
