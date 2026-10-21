import 'dart:io' show File, Platform;

import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/application/services/tss_estimator.dart';
import '../../core/domain/entities/workout.dart';
import '../../core/domain/entities/workout_step.dart';
import '../../infrastructure/files/zwo_parser.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/start_ride_actions.dart';
import '../widgets/workout_mini_profile.dart';

/// Detail view for a single workout — power profile chart, stats, step list.
class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({super.key, required this.workoutIndex});

  final int workoutIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutListProvider);
    if (workoutIndex < 0 || workoutIndex >= workouts.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Workout'),
        ),
        body: Center(
          child: Text('Workout not found.',
              style: TextStyle(color: context.tokens.textTertiary)),
        ),
      );
    }

    final workout = workouts[workoutIndex];
    final totalMin = workout.totalDuration.inMinutes;
    final stepCount = workout.steps.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
          // Builder gives the share sheet the button's own context to
          // anchor its iPad popover to.
          Builder(
            builder: (buttonContext) => IconButton(
              key: const Key('shareZwoButton'),
              icon: const Icon(Icons.ios_share),
              tooltip: 'Share as .zwo',
              onPressed: () => _shareAsZwo(buttonContext, workout),
            ),
          ),
          IconButton(
            key: const Key('editWorkoutButton'),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => context.push('/workouts/edit/${workout.id}'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Power profile chart
          SizedBox(
            height: 180,
            child: _PowerProfileChart(steps: workout.steps),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatChip(label: 'DURATION', value: '$totalMin min'),
              _StatChip(label: 'STEPS', value: '$stepCount'),
              _StatChip(
                label: 'EST. TSS',
                value: estimateWorkoutTss(workout.steps).toStringAsFixed(0),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          if (workout.description != null && workout.description!.isNotEmpty) ...[
            Text(
              workout.description!,
              style: TextStyle(color: context.tokens.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
          ],

          // Steps list
          Text(
            'STEPS',
            style: TextStyle(
              color: context.tokens.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < workout.steps.length; i++)
            _StepRow(index: i, step: workout.steps[i]),

          // Text events
          if (workout.textEvents.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'TEXT EVENTS',
              style: TextStyle(
                color: context.tokens.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            for (final event in workout.textEvents)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${_formatSeconds(event.offsetSeconds)} — ${event.message}',
                  style: TextStyle(color: context.tokens.textSecondary, fontSize: 13),
                ),
              ),
          ],

          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => startWorkoutRide(context, ref, workout),
            child: const Text('Start Workout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  /// Opens the share sheet on mobile and a save dialog on desktop. File
  /// picker's save dialog can't stand in for the share sheet on mobile: it
  /// throws there unless handed the bytes, and a share sheet is what the
  /// share icon promises (AirDrop, Files, mail to the Zwift machine…).
  Future<void> _shareAsZwo(BuildContext context, Workout workout) async {
    // Workout names are free text; a slash would turn into a directory.
    final fileName =
        '${workout.name.replaceAll(RegExp(r'[/\\:]'), '-')}.zwo';
    final isMobile = Platform.isIOS || Platform.isAndroid;
    try {
      final xml = await ZwoParser().serialize(workout);
      if (isMobile) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsString(xml);
        if (!context.mounted) return;
        // iPads show the share sheet as a popover, which share_plus refuses
        // to open without an on-screen anchor.
        final box = context.findRenderObject() as RenderBox?;
        final origin = box != null && box.hasSize
            ? box.localToGlobal(Offset.zero) & box.size
            : null;
        await Share.shareXFiles([XFile(file.path)],
            sharePositionOrigin: origin);
        return;
      }

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save workout',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['zwo'],
      );
      if (path == null) return;
      await File(path).writeAsString(xml);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved .zwo file')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isMobile
                ? "Couldn't share workout: $e"
                : 'Failed to save: $e'),
          ),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Power profile chart
// ---------------------------------------------------------------------------

/// The workout's power target over time — the same shape as the library's
/// [WorkoutMiniProfile] and the in-ride HUD, with a %FTP axis. Each
/// [profileSegments] piece is filled from the axis up to its target, so ramps
/// slope and interval repeats show as separate blocks.
class _PowerProfileChart extends StatelessWidget {
  const _PowerProfileChart({required this.steps});
  final List<WorkoutStep> steps;

  @override
  Widget build(BuildContext context) {
    final segments = profileSegments(steps);
    if (segments.isEmpty) return const SizedBox.shrink();

    final peak = segments.fold<double>(
      100,
      (prev, s) => [prev, s.startPercent, s.endPercent]
          .reduce((a, b) => a > b ? a : b),
    );

    LineChartBarData area(ProfileSegment seg) {
      final base = workoutStepColor(seg.type);
      final color = seg.isRest ? base.withValues(alpha: 0.45) : base;
      return LineChartBarData(
        spots: [
          FlSpot(seg.startSeconds / 60, seg.startPercent),
          FlSpot(seg.endSeconds / 60, seg.endPercent),
        ],
        color: color,
        barWidth: 0,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: true, color: color),
      );
    }

    return LineChart(
      LineChartData(
        lineBarsData: [for (final seg in segments) area(seg)],
        minX: 0,
        maxX: segments.last.endSeconds / 60,
        minY: 0,
        // Headroom above the hardest effort, on the 50 % gridline grid.
        maxY: (peak / 50).ceil() * 50 + 10,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) => FlLine(
            color: context.tokens.surfaceTier3Line,
            strokeWidth: value == 100 ? 1.5 : 0.5,
            dashArray: value == 100 ? null : [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 50,
              getTitlesWidget: (value, meta) => value % 50 == 0
                  ? Text(
                      '${value.toInt()}%',
                      style: TextStyle(
                          color: context.tokens.textDisabled, fontSize: 10),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: const LineTouchData(enabled: false),
      ),
      duration: Duration.zero,
    );
  }
}

// ---------------------------------------------------------------------------
// Stat chip
// ---------------------------------------------------------------------------

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
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
// Step row
// ---------------------------------------------------------------------------

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.step});
  final int index;
  final WorkoutStep step;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.surfaceTier2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: workoutStepColor(step.type),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stepLabel(step.type),
                  style: TextStyle(
                      color: tokens.textPrimary, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_formatSeconds(step.totalDurationSeconds)} • '
                  '${_targetSummary(step)}',
                  style: TextStyle(color: tokens.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (step.cadenceTarget != null)
            Text(
              '${step.cadenceTarget} rpm',
              style: TextStyle(color: tokens.textDisabled, fontSize: 12),
            ),
        ],
      ),
    );
  }

  /// The step's power target as the engine applies it — ramps run from
  /// `powerLowPercent` to `powerHighPercent`, intervals alternate the on
  /// target with `powerLowPercent` — rather than `powerTargetPercent` alone,
  /// which ramps leave at 0.
  String _targetSummary(WorkoutStep step) {
    String pct(double p) => '${p.toStringAsFixed(0)}%';
    switch (step.type) {
      case StepType.warmup:
      case StepType.cooldown:
      case StepType.ramp:
        final from = step.powerLowPercent ?? step.powerTargetPercent;
        final to = step.powerHighPercent ?? step.powerTargetPercent;
        return from == to ? '${pct(from)} FTP' : '${pct(from)} → ${pct(to)} FTP';
      case StepType.steadyState:
        return '${pct(step.powerTargetPercent)} FTP';
      case StepType.interval:
        final repeat = step.repeat ?? 0;
        final on = '${_formatSeconds(step.durationSeconds)} @ '
            '${pct(step.powerTargetPercent)}';
        if (repeat <= 0) return '$on FTP';
        final offSeconds = step.offDurationSeconds ?? 0;
        if (offSeconds <= 0) return '$repeat × $on FTP';
        final off = step.powerLowPercent ?? step.powerTargetPercent;
        return '$repeat × $on / ${_formatSeconds(offSeconds)} @ ${pct(off)} FTP';
      case StepType.freeRide:
        return 'No target';
    }
  }

  String _stepLabel(StepType type) {
    switch (type) {
      case StepType.warmup:
        return 'Warm Up';
      case StepType.cooldown:
        return 'Cool Down';
      case StepType.steadyState:
        return 'Steady State';
      case StepType.interval:
        return 'Interval';
      case StepType.freeRide:
        return 'Free Ride';
      case StepType.ramp:
        return 'Ramp';
    }
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _formatSeconds(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}
