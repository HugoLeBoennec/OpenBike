import 'dart:io' show File;

import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/application/services/tss_estimator.dart';
import '../../core/domain/entities/workout.dart';
import '../../core/domain/entities/workout_step.dart';
import '../../infrastructure/files/zwo_parser.dart';
import '../models/ride_extra.dart';
import '../state/providers.dart';

/// Detail view for a single workout — power profile chart, stats, step list.
class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({super.key, required this.workoutIndex});

  final int workoutIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutListProvider);
    if (workoutIndex < 0 || workoutIndex >= workouts.length) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Workout'),
          backgroundColor: Colors.black,
        ),
        body: const Center(
          child: Text('Workout not found.',
              style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    final workout = workouts[workoutIndex];
    final totalMin = workout.totalDuration.inMinutes;
    final stepCount = workout.steps.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(workout.name),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            key: const Key('shareZwoButton'),
            icon: const Icon(Icons.ios_share),
            tooltip: 'Share as .zwo',
            onPressed: () => _shareAsZwo(context, workout),
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
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
          ],

          // Steps list
          const Text(
            'STEPS',
            style: TextStyle(
              color: Colors.white54,
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
            const Text(
              'TEXT EVENTS',
              style: TextStyle(
                color: Colors.white54,
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
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
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
            onPressed: () {
              context.go('/ride', extra: RideExtra(workout: workout));
            },
            child: const Text('Start Workout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Future<void> _shareAsZwo(BuildContext context, Workout workout) async {
    try {
      final xml = await ZwoParser().serialize(workout);
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save workout',
        fileName: '${workout.name}.zwo',
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
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Power profile bar chart
// ---------------------------------------------------------------------------

class _PowerProfileChart extends StatelessWidget {
  const _PowerProfileChart({required this.steps});
  final List<WorkoutStep> steps;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();

    final groups = <BarChartGroupData>[];
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: step.powerTargetPercent,
              width: (200 / steps.length).clamp(4, 24),
              color: _stepColor(step.type),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(2)),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: groups,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}%',
                style: const TextStyle(color: Colors.white30, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(enabled: false),
      ),
      duration: Duration.zero,
    );
  }

  Color _stepColor(StepType type) {
    switch (type) {
      case StepType.warmup:
        return Colors.blue;
      case StepType.cooldown:
        return Colors.blue;
      case StepType.steadyState:
        return Colors.green;
      case StepType.interval:
        return Colors.orange;
      case StepType.freeRide:
        return Colors.grey;
      case StepType.ramp:
        return Colors.teal;
    }
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
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: Colors.white54,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: _stepColor(step.type),
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
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_formatSeconds(step.totalDurationSeconds)} • ${step.powerTargetPercent.toStringAsFixed(0)}% FTP'
                  '${step.repeat != null && step.repeat! > 1 ? ' × ${step.repeat}' : ''}',
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          if (step.cadenceTarget != null)
            Text(
              '${step.cadenceTarget} rpm',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Color _stepColor(StepType type) {
    switch (type) {
      case StepType.warmup:
        return Colors.blue;
      case StepType.cooldown:
        return Colors.blue;
      case StepType.steadyState:
        return Colors.green;
      case StepType.interval:
        return Colors.orange;
      case StepType.freeRide:
        return Colors.grey;
      case StepType.ramp:
        return Colors.teal;
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
