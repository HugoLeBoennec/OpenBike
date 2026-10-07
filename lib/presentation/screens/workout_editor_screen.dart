import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/application/services/tss_estimator.dart';
import '../../core/domain/entities/workout.dart';
import '../../core/domain/entities/workout_step.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/workout_mini_profile.dart';

/// Create/edit UI for a [Workout] — step list (reorder/duplicate/delete),
/// per-step editor sheet, live power-profile preview, and computed totals.
///
/// `workoutId == null` creates a new workout; otherwise it edits (and
/// re-saves) the workout with that id, including imported ones.
class WorkoutEditorScreen extends ConsumerStatefulWidget {
  const WorkoutEditorScreen({super.key, this.workoutId});

  final String? workoutId;

  @override
  ConsumerState<WorkoutEditorScreen> createState() => _WorkoutEditorScreenState();
}

class _WorkoutEditorScreenState extends ConsumerState<WorkoutEditorScreen> {
  late final String _id;
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late List<WorkoutStep> _steps;
  List<TextEvent> _textEvents = const [];
  String? _source;

  @override
  void initState() {
    super.initState();
    Workout? existing;
    if (widget.workoutId != null) {
      final matches =
          ref.read(workoutListProvider).where((w) => w.id == widget.workoutId);
      existing = matches.isEmpty ? null : matches.first;
    }

    _id = existing?.id ?? const Uuid().v4();
    _nameController = TextEditingController(text: existing?.name ?? '');
    _descController = TextEditingController(text: existing?.description ?? '');
    _steps = List.of(existing?.steps ?? const []);
    _textEvents = existing?.textEvents ?? const [];
    _source = existing?.source;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.workoutId != null;

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _steps.fold<int>(0, (sum, s) => sum + s.totalDurationSeconds);
    final tss = estimateWorkoutTss(_steps);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Workout' : 'New Workout'),
        actions: [
          TextButton(
            key: const Key('workoutSaveButton'),
            onPressed: _steps.isEmpty ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('workoutNameField'),
            controller: _nameController,
            style: TextStyle(color: context.tokens.textPrimary),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: context.tokens.textTertiary),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('workoutDescriptionField'),
            controller: _descController,
            style: TextStyle(color: context.tokens.textPrimary),
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: context.tokens.textTertiary),
            ),
          ),
          const SizedBox(height: 20),
          if (_steps.isNotEmpty) ...[
            SizedBox(
              height: 100,
              child: WorkoutMiniProfile(
                steps: _steps,
                size: const Size(double.infinity, 100),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TotalStat(label: 'DURATION', value: '${totalSeconds ~/ 60} min'),
                _TotalStat(
                    label: 'EST. TSS', value: tss.toStringAsFixed(0), key: const Key('workoutTssValue')),
                _TotalStat(label: 'STEPS', value: '${_steps.length}'),
              ],
            ),
            const SizedBox(height: 20),
          ],
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
          ReorderableListView.builder(
            key: const Key('workoutStepList'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _steps.length,
            // Each tile has its own leading ReorderableDragStartListener;
            // the default trailing handles would duplicate it on desktop.
            buildDefaultDragHandles: false,
            onReorderItem: _onReorder,
            itemBuilder: (context, index) => _StepTile(
              key: ValueKey('step-$index-${_steps[index].hashCode}'),
              index: index,
              step: _steps[index],
              onTap: () => _editStep(index),
              onDuplicate: () => _duplicateStep(index),
              onDelete: () => _deleteStep(index),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('addStepButton'),
            onPressed: _addStep,
            icon: const Icon(Icons.add),
            label: const Text('Add step'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step list mutations
  // ---------------------------------------------------------------------------

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final step = _steps.removeAt(oldIndex);
      _steps.insert(newIndex, step);
    });
  }

  Future<void> _addStep() async {
    final step = await showModalBottomSheet<WorkoutStep>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.tokens.surfaceTier2,
      builder: (_) => const _StepEditorSheet(),
    );
    if (step != null) setState(() => _steps.add(step));
  }

  Future<void> _editStep(int index) async {
    final step = await showModalBottomSheet<WorkoutStep>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.tokens.surfaceTier2,
      builder: (_) => _StepEditorSheet(initial: _steps[index]),
    );
    if (step != null) setState(() => _steps[index] = step);
  }

  void _duplicateStep(int index) {
    setState(() => _steps.insert(index + 1, _steps[index]));
  }

  void _deleteStep(int index) {
    setState(() => _steps.removeAt(index));
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  void _save() {
    final workout = Workout(
      id: _id,
      name: _nameController.text.trim().isEmpty ? 'Untitled Workout' : _nameController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      steps: List.unmodifiable(_steps),
      source: _source,
      textEvents: _textEvents,
    );

    ref.read(storageProvider).saveWorkout(workout);

    final current = ref.read(workoutListProvider);
    final idx = current.indexWhere((w) => w.id == workout.id);
    ref.read(workoutListProvider.notifier).state = idx == -1
        ? [...current, workout]
        : [for (var i = 0; i < current.length; i++) i == idx ? workout : current[i]];

    if (context.mounted) context.pop();
  }
}

// ---------------------------------------------------------------------------
// Totals
// ---------------------------------------------------------------------------

class _TotalStat extends StatelessWidget {
  const _TotalStat({required this.label, required this.value, super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(color: context.tokens.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: context.tokens.textTertiary, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step tile
// ---------------------------------------------------------------------------

class _StepTile extends StatelessWidget {
  const _StepTile({
    super.key,
    required this.index,
    required this.step,
    required this.onTap,
    required this.onDuplicate,
    required this.onDelete,
  });

  final int index;
  final WorkoutStep step;
  final VoidCallback onTap;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: context.tokens.surfaceTier2,
        borderRadius: BorderRadius.circular(8),
      ),
      // Transparent Material so ListTile's ink draws above this
      // container's background instead of being hidden by it.
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          onTap: onTap,
          leading: ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_handle, color: context.tokens.textDisabled),
          ),
          title: Text(_typeLabel(step.type), style: TextStyle(color: context.tokens.textPrimary)),
          subtitle: Text(_subtitle(step), style: TextStyle(color: context.tokens.textTertiary, fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: Key('duplicateStepButton-$index'),
                icon: Icon(Icons.copy, size: 18, color: context.tokens.textDisabled),
                onPressed: onDuplicate,
              ),
              IconButton(
                key: Key('deleteStepButton-$index'),
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(WorkoutStep step) {
    final mins = (step.totalDurationSeconds / 60).toStringAsFixed(1);
    switch (step.type) {
      case StepType.interval:
        return '${step.repeat ?? 1} x (${step.durationSeconds}s @ ${step.powerTargetPercent.toStringAsFixed(0)}% '
            '/ ${step.offDurationSeconds ?? 0}s @ ${(step.powerLowPercent ?? 0).toStringAsFixed(0)}%) — $mins min';
      case StepType.warmup:
      case StepType.cooldown:
      case StepType.ramp:
        return '${step.durationSeconds}s — '
            '${(step.powerLowPercent ?? 0).toStringAsFixed(0)}% → ${(step.powerHighPercent ?? 0).toStringAsFixed(0)}%';
      case StepType.freeRide:
        return '${step.durationSeconds}s — free ride';
      case StepType.steadyState:
        return '${step.durationSeconds}s @ ${step.powerTargetPercent.toStringAsFixed(0)}%';
    }
  }

  String _typeLabel(StepType type) {
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
// Per-step editor sheet
// ---------------------------------------------------------------------------

class _StepEditorSheet extends StatefulWidget {
  const _StepEditorSheet({this.initial});
  final WorkoutStep? initial;

  @override
  State<_StepEditorSheet> createState() => _StepEditorSheetState();
}

class _StepEditorSheetState extends State<_StepEditorSheet> {
  late StepType _type;
  late TextEditingController _duration;
  late TextEditingController _power;
  late TextEditingController _powerLow;
  late TextEditingController _powerHigh;
  late TextEditingController _cadence;
  late TextEditingController _repeat;
  late TextEditingController _offDuration;
  late TextEditingController _cadenceResting;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    _type = s?.type ?? StepType.steadyState;
    _duration = TextEditingController(text: '${s?.durationSeconds ?? 300}');
    _power = TextEditingController(text: '${s?.powerTargetPercent.toStringAsFixed(0) ?? 100}');
    _powerLow = TextEditingController(text: '${s?.powerLowPercent?.toStringAsFixed(0) ?? 50}');
    _powerHigh = TextEditingController(text: '${s?.powerHighPercent?.toStringAsFixed(0) ?? 75}');
    _cadence = TextEditingController(text: s?.cadenceTarget?.toString() ?? '');
    _repeat = TextEditingController(text: '${s?.repeat ?? 4}');
    _offDuration = TextEditingController(text: '${s?.offDurationSeconds ?? 60}');
    _cadenceResting = TextEditingController(text: s?.cadenceResting?.toString() ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _duration,
      _power,
      _powerLow,
      _powerHigh,
      _cadence,
      _repeat,
      _offDuration,
      _cadenceResting,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _isRamp => _type == StepType.warmup || _type == StepType.cooldown || _type == StepType.ramp;
  bool get _isInterval => _type == StepType.interval;
  bool get _isFreeRide => _type == StepType.freeRide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<StepType>(
              key: const Key('stepTypeDropdown'),
              initialValue: _type,
              dropdownColor: context.tokens.surfaceTier2,
              style: TextStyle(color: context.tokens.textPrimary),
              decoration: const InputDecoration(labelText: 'Type'),
              items: StepType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(_label(t))))
                  .toList(),
              onChanged: (t) => setState(() => _type = t ?? _type),
            ),
            const SizedBox(height: 12),
            _numberField(
              key: const Key('stepDurationField'),
              label: _isInterval ? 'On duration (s)' : 'Duration (s)',
              controller: _duration,
            ),
            const SizedBox(height: 12),
            if (_isRamp) ...[
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      key: const Key('stepPowerLowField'),
                      label: 'From %FTP',
                      controller: _powerLow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numberField(
                      key: const Key('stepPowerHighField'),
                      label: 'To %FTP',
                      controller: _powerHigh,
                    ),
                  ),
                ],
              ),
            ] else if (!_isFreeRide) ...[
              _numberField(
                key: const Key('stepPowerField'),
                label: _isInterval ? 'On %FTP' : 'Target %FTP',
                controller: _power,
              ),
            ],
            if (_isInterval) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _numberField(
                      key: const Key('stepRepeatField'),
                      label: 'Repeat count',
                      controller: _repeat,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numberField(
                      key: const Key('stepOffDurationField'),
                      label: 'Off duration (s)',
                      controller: _offDuration,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _numberField(
                key: const Key('stepOffPowerField'),
                label: 'Off %FTP',
                controller: _powerLow,
              ),
              const SizedBox(height: 12),
              _numberField(
                key: const Key('stepCadenceRestingField'),
                label: 'Resting cadence (optional)',
                controller: _cadenceResting,
                required: false,
              ),
            ],
            const SizedBox(height: 12),
            _numberField(
              key: const Key('stepCadenceField'),
              label: 'Cadence target (optional)',
              controller: _cadence,
              required: false,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('stepSaveButton'),
                onPressed: _saveStep,
                child: const Text('Save step'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField({
    required Key key,
    required String label,
    required TextEditingController controller,
    bool required = true,
  }) {
    return TextField(
      key: key,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: context.tokens.textPrimary),
      decoration: InputDecoration(labelText: label),
    );
  }

  void _saveStep() {
    final duration = int.tryParse(_duration.text) ?? 0;
    final cadence = int.tryParse(_cadence.text);

    WorkoutStep step;
    switch (_type) {
      case StepType.warmup:
      case StepType.cooldown:
      case StepType.ramp:
        step = WorkoutStep(
          type: _type,
          durationSeconds: duration,
          powerTargetPercent: 0,
          powerLowPercent: double.tryParse(_powerLow.text) ?? 0,
          powerHighPercent: double.tryParse(_powerHigh.text) ?? 0,
          cadenceTarget: cadence,
        );
        break;
      case StepType.steadyState:
        step = WorkoutStep(
          type: _type,
          durationSeconds: duration,
          powerTargetPercent: double.tryParse(_power.text) ?? 0,
          cadenceTarget: cadence,
        );
        break;
      case StepType.interval:
        step = WorkoutStep(
          type: _type,
          durationSeconds: duration,
          offDurationSeconds: int.tryParse(_offDuration.text) ?? 0,
          powerTargetPercent: double.tryParse(_power.text) ?? 0,
          powerLowPercent: double.tryParse(_powerLow.text) ?? 0,
          repeat: int.tryParse(_repeat.text) ?? 1,
          cadenceTarget: cadence,
          cadenceResting: int.tryParse(_cadenceResting.text),
        );
        break;
      case StepType.freeRide:
        step = WorkoutStep(
          type: _type,
          durationSeconds: duration,
          powerTargetPercent: 0,
        );
        break;
    }

    Navigator.of(context).pop(step);
  }

  String _label(StepType type) {
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
