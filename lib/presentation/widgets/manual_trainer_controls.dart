import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/application/services/route_simulator.dart';
import '../../core/application/services/workout_engine.dart';
import '../../core/domain/entities/trainer_device.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';

/// Contextual manual trainer controls for a free ride: an ERG/Resistance
/// mode toggle, a target power stepper or resistance slider, and (during a
/// GPX ride) the gradient difficulty slider.
///
/// Hidden while a structured workout owns the trainer targets — unless the
/// workout is paused, in which case the manual controls reappear as an
/// override. Rendered identically across all three ride-screen layouts
/// (portrait/landscape/desktop).
class ManualTrainerControls extends ConsumerWidget {
  const ManualTrainerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasWorkout = ref.watch(currentWorkoutProvider) != null;
    final workoutState = ref.watch(workoutEngineStateProvider).valueOrNull;
    final simState = ref.watch(simulationStateProvider).valueOrNull;
    final hasRoute = simState != null && simState != SimulationState.idle;

    // A running (non-paused) workout owns the trainer targets — hide manual
    // controls entirely except the status readout. Paused allows an
    // override (e.g. adjusting ERG watts while stopped).
    final workoutOwnsTargets =
        hasWorkout && workoutState != WorkoutEngineState.paused;

    if (workoutOwnsTargets) {
      return const _TrainerStatusBanner();
    }

    if (hasRoute) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TrainerStatusBanner(),
          _GradientDifficultySlider(),
        ],
      );
    }

    final mode = ref.watch(trainerModeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _ModeToggle(),
        if (mode == ControlMode.erg) const _ErgControls() else const _ResistanceControls(),
        const _TrainerStatusBanner(),
      ],
    );
  }
}

// ─── Mode toggle (free ride only: ERG ⇄ Resistance) ────────────────────────

class _ModeToggle extends ConsumerWidget {
  const _ModeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(trainerModeProvider);

    Future<void> select(ControlMode target) {
      if (target == ControlMode.erg) {
        final watts = ref.read(ergTargetWattsProvider);
        return ref
            .read(trainerModeControllerProvider.notifier)
            .switchMode(ControlMode.erg, power: Watts(watts));
      }
      final level = ref.read(resistanceLevelProvider);
      return ref
          .read(trainerModeControllerProvider.notifier)
          .switchMode(ControlMode.resistance, resistance: level);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _ModeToggleButton(
              label: 'ERG',
              icon: Icons.bolt,
              selected: mode == ControlMode.erg,
              onTap: () => select(ControlMode.erg),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ModeToggleButton(
              label: 'Resistance',
              icon: Icons.tune,
              selected: mode == ControlMode.resistance,
              onTap: () => select(ControlMode.resistance),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  const _ModeToggleButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.deepOrange : context.tokens.rideOnSurfaceMuted;
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(label, style: TextStyle(color: color)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: selected ? Colors.deepOrange : context.tokens.rideSurfaceLine),
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
  }
}

// ─── Trainer status banner ─────────────────────────────────────────────────

/// Shows the current control mode and its active target — e.g.
/// "ERG · 200 W", "RESISTANCE · Level 5.0", "SIM · Difficulty 50%".
///
/// While a workout drives the trainer, the ERG target is the workout's
/// current step power rather than the last manually set value.
class _TrainerStatusBanner extends ConsumerWidget {
  const _TrainerStatusBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(trainerModeProvider);

    final workoutOwnsTargets = ref.watch(currentWorkoutProvider) != null &&
        ref.watch(workoutEngineStateProvider).valueOrNull !=
            WorkoutEngineState.paused;
    final manualErgWatts = ref.watch(ergTargetWattsProvider);
    final workoutProgress =
        workoutOwnsTargets ? ref.watch(workoutProgressProvider).valueOrNull : null;
    final double ergWatts = workoutProgress?.targetPower.value ?? manualErgWatts;

    final (label, target, color) = switch (mode) {
      ControlMode.erg => (
          'ERG',
          '${ergWatts.round()} W',
          Colors.deepOrange,
        ),
      ControlMode.resistance => (
          'RESISTANCE',
          'Level ${ref.watch(resistanceLevelProvider).toStringAsFixed(1)}',
          context.tokens.rideOnSurfaceMuted,
        ),
      ControlMode.simulation => (
          'SIM',
          'Difficulty ${(ref.watch(trainerDifficultyProvider) * 100).round()}%',
          Colors.lightBlue,
        ),
    };

    return Container(
      height: 28,
      width: double.infinity,
      color: color.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Text(
        '$label · $target',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── ERG controls (ERG mode, free ride only) ───────────────────────────────

class _ErgControls extends ConsumerWidget {
  const _ErgControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watts = ref.watch(ergTargetWattsProvider);
    final range = ref.watch(ergPowerRangeProvider);

    void setWatts(double newWatts) {
      final clamped = range.clamp(newWatts.round()).toDouble();
      ref.read(ergTargetWattsProvider.notifier).state = clamped;
      ref.read(appPreferencesProvider).setLastErgWatts(clamped);
      ref
          .read(trainerModeControllerProvider.notifier)
          .switchMode(ControlMode.erg, power: Watts(clamped));
    }

    final step = range.incrementWatts <= 0 ? 5 : range.incrementWatts;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => setWatts(watts - step),
              ),
            ),
            SizedBox(
              width: 96,
              child: Text(
                '${watts.round()} W',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setWatts(watts + step),
              ),
            ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            for (final preset in const [100.0, 150.0, 200.0, 250.0])
              if (preset >= range.minWatts && preset <= range.maxWatts)
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => setWatts(preset),
                    child: Text('${preset.round()}W'),
                  ),
                ),
          ],
        ),
      ],
    );
  }
}

// ─── Resistance controls (Resistance mode, free ride only) ─────────────────

class _ResistanceControls extends ConsumerWidget {
  const _ResistanceControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(resistanceLevelProvider);
    final range = ref.watch(resistanceRangeProvider);

    void setLevel(double newLevel) {
      final clamped = range.clamp(newLevel);
      ref.read(resistanceLevelProvider.notifier).state = clamped;
      ref
          .read(trainerModeControllerProvider.notifier)
          .switchMode(ControlMode.resistance, resistance: clamped);
    }

    final divisions = range.increment > 0
        ? ((range.max - range.min) / range.increment).round().clamp(1, 1000)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => setLevel(level - (range.increment > 0 ? range.increment : 0.5)),
            ),
          ),
          Expanded(
            child: Slider(
              value: level.clamp(range.min, range.max),
              min: range.min,
              max: range.max,
              divisions: divisions,
              activeColor: Colors.deepOrange,
              onChanged: setLevel,
              onChangeEnd: (v) => ref.read(appPreferencesProvider).setLastResistanceLevel(v),
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => setLevel(level + (range.increment > 0 ? range.increment : 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gradient difficulty slider (SIM mode / GPX ride only) ─────────────────

class _GradientDifficultySlider extends ConsumerWidget {
  const _GradientDifficultySlider();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final difficulty = ref.watch(trainerDifficultyProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.terrain, color: context.tokens.rideOnSurfaceMuted, size: 16),
          Expanded(
            child: Slider(
              value: difficulty,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              activeColor: Colors.deepOrange,
              onChanged: (v) {
                ref.read(trainerDifficultyProvider.notifier).state = v;
              },
              onChangeEnd: (v) => ref.read(appPreferencesProvider).setTrainerDifficulty(v),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${(difficulty * 100).round()}%',
              style: TextStyle(color: context.tokens.rideOnSurfaceMuted, fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
