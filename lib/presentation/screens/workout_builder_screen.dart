import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';

class WorkoutBuilderScreen extends ConsumerWidget {
  const WorkoutBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: workouts.isEmpty
          ? const Center(child: Text('No workouts yet. Import or create one.'))
          : ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final w = workouts[index];
                return ListTile(
                  title: Text(w.name),
                  subtitle: Text('${w.steps.length} steps — ${w.totalDuration.inMinutes} min'),
                  onTap: () {
                    // TODO: Open workout detail / execute
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create new workout
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
