import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/entities/power_zone.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';

/// Real-time area chart showing power (zone-colored) with optional HR overlay.
///
/// Displays the last 5 minutes (300 samples at 1 Hz) as a scrolling chart.
class LiveChart extends ConsumerWidget {
  const LiveChart({super.key});

  static const _windowSize = 300; // 5 minutes

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final powerHistory = ref.watch(powerHistoryProvider);
    final hrHistory = ref.watch(hrHistoryProvider);
    final ftp = ref.watch(ftpProvider);
    final zones = ref.watch(powerZonesProvider);

    // Window the data to last 5 minutes
    final displayPower = powerHistory.length > _windowSize
        ? powerHistory.sublist(powerHistory.length - _windowSize)
        : powerHistory;
    final displayHr = hrHistory.length > _windowSize
        ? hrHistory.sublist(hrHistory.length - _windowSize)
        : hrHistory;

    final maxY = max(ftp.value * 1.5, 100.0);

    if (displayPower.isEmpty) {
      return Container(
        color: context.tokens.rideSurfaceDeep,
        child: const Center(
          child: Text(
            'Start riding to see power data',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      color: context.tokens.rideSurfaceDeep,
      padding: const EdgeInsets.only(top: 8, right: 8, bottom: 4),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (_windowSize - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          clipData: FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ftp.value > 0 ? ftp.value / 2 : 50,
            getDrawingHorizontalLine: (_) => FlLine(
              color: context.tokens.rideSurfaceLine,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(enabled: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              // FTP reference line
              if (ftp.value > 0)
                HorizontalLine(
                  y: ftp.value,
                  color: Colors.yellow.withValues(alpha: 0.4),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
            ],
          ),
          lineBarsData: [
            // Power area chart
            _buildPowerLine(displayPower, maxY, zones, ftp),
            // HR overlay
            if (displayHr.isNotEmpty)
              _buildHrLine(displayHr, maxY),
          ],
        ),
        duration: Duration.zero, // no animation for real-time
      ),
    );
  }

  LineChartBarData _buildPowerLine(
    List<double> data,
    double maxY,
    List<PowerZone> zones,
    Watts ftp,
  ) {
    final spots = <FlSpot>[];
    // Pad left with zeros if data is shorter than window
    final offset = _windowSize - data.length;
    for (var i = 0; i < data.length; i++) {
      spots.add(FlSpot((offset + i).toDouble(), data[i].clamp(0, maxY)));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: Colors.blue,
      barWidth: 1.5,
      isStrokeCapRound: false,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: _buildZoneGradient(zones, ftp, maxY),
      ),
    );
  }

  /// Builds a vertical gradient whose color stops match zone boundaries.
  LinearGradient _buildZoneGradient(
    List<PowerZone> zones,
    Watts ftp,
    double maxY,
  ) {
    if (zones.isEmpty || ftp.value == 0) {
      return LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Colors.blue.withValues(alpha: 0.3), Colors.blue.withValues(alpha: 0.05)],
      );
    }

    final colors = <Color>[];
    final stops = <double>[];

    for (final zone in zones) {
      final minW = zone.minWatts(ftp).value;
      final maxW = zone.maxWatts(ftp).value;
      final stopMin = (minW / maxY).clamp(0.0, 1.0);
      final stopMax = (maxW / maxY).clamp(0.0, 1.0);
      colors.add(zone.color.withValues(alpha: 0.35));
      stops.add(stopMin);
      colors.add(zone.color.withValues(alpha: 0.35));
      stops.add(stopMax);
    }

    return LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: colors,
      stops: stops,
    );
  }

  LineChartBarData _buildHrLine(List<double> data, double maxY) {
    final spots = <FlSpot>[];
    final offset = _windowSize - data.length;
    // Scale HR (typically 60-200 bpm) to the power Y axis
    for (var i = 0; i < data.length; i++) {
      final scaledHr = (data[i] / 200) * maxY; // 200 bpm = top of chart
      spots.add(FlSpot((offset + i).toDouble(), scaledHr.clamp(0, maxY)));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.2,
      color: Colors.red.withValues(alpha: 0.6),
      barWidth: 1,
      isStrokeCapRound: false,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }
}
