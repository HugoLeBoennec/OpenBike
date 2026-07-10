import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/entities/workout.dart';
import '../state/providers.dart';
import '../widgets/workout_mini_profile.dart';

/// Workout library — lists imported workouts and allows importing new ones.
///
/// Kept as [WorkoutBuilderScreen] for backwards compatibility with router.
class WorkoutBuilderScreen extends ConsumerWidget {
  const WorkoutBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Workouts'),
        backgroundColor: Colors.black,
      ),
      body: workouts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center, size: 48, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text(
                    'No workouts yet.\nImport a .zwo, .erg, or .mrc file.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final w = workouts[index];
                return _WorkoutTile(
                  workout: w,
                  onTap: () => context.push('/workouts/$index'),
                  onLongPress: () => _confirmDelete(context, ref, index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _importWorkout(context, ref),
        child: const Icon(Icons.file_open, color: Colors.white),
      ),
    );
  }

  Future<void> _importWorkout(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zwo', 'erg', 'mrc'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    final content = await _readFile(file.path!);
    if (content == null) return;

    final ext = '.${file.extension?.toLowerCase() ?? ''}';
    final registry = ref.read(pluginRegistryProvider);
    final formatPlugin = registry.getFormatForExtension(ext);

    if (formatPlugin == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No parser found for $ext files')),
        );
      }
      return;
    }

    try {
      final workout = await formatPlugin.parse(content);
      final current = ref.read(workoutListProvider);
      ref.read(workoutListProvider.notifier).state = [...current, workout];
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse workout: $e')),
        );
      }
    }
  }

  Future<String?> _readFile(String path) async {
    try {
      return await File(path).readAsString();
    } catch (_) {
      return null;
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Delete Workout',
            style: TextStyle(color: Colors.white)),
        content: const Text('Remove this workout from the library?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final current = List.of(ref.read(workoutListProvider));
              current.removeAt(index);
              ref.read(workoutListProvider.notifier).state = current;
              Navigator.pop(ctx);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Workout tile
// ---------------------------------------------------------------------------

class _WorkoutTile extends StatelessWidget {
  const _WorkoutTile({
    required this.workout,
    required this.onTap,
    required this.onLongPress,
  });

  final Workout workout;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final minutes = workout.totalDuration.inMinutes;
    final stepCount = workout.steps.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: SizedBox(
          width: 48,
          height: 32,
          child: WorkoutMiniProfile(steps: workout.steps),
        ),
        title: Text(
          workout.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '$stepCount steps • $minutes min',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}

