import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/workout_builder.dart';
import 'package:open_bike/core/domain/entities/workout.dart';
import 'package:open_bike/core/domain/entities/workout_step.dart';
import 'package:open_bike/infrastructure/files/zwo_parser.dart';
import 'package:open_bike/plugins/plugin_manifest.dart';

// =============================================================================
// Sample ZWO files
// =============================================================================

/// Simple 10-minute warmup from 25% to 75% FTP.
const _simpleWarmup = '''
<workout_file>
  <name>Simple Warmup</name>
  <description>Basic warm-up ramp</description>
  <workout>
    <Warmup Duration="600" PowerLow="0.25" PowerHigh="0.75" Cadence="85"/>
  </workout>
</workout_file>
''';

/// 5×1min on / 2min off interval workout with warmup and cooldown.
const _intervalWorkout = '''
<workout_file>
  <name>5x1min VO2max</name>
  <description>Short VO2max intervals</description>
  <workout>
    <Warmup Duration="300" PowerLow="0.25" PowerHigh="0.75"/>
    <IntervalsT Repeat="5" OnDuration="60" OffDuration="120" OnPower="1.20" OffPower="0.55" Cadence="100" CadenceResting="85"/>
    <Cooldown Duration="300" PowerLow="0.75" PowerHigh="0.25"/>
  </workout>
</workout_file>
''';

/// Sweet Spot workout: warmup → 2×20min at 88-93% → cooldown, with text events.
const _sweetSpot = '''
<workout_file>
  <name>Sweet Spot 2x20</name>
  <description>Two 20-minute blocks in the sweet spot zone</description>
  <workout>
    <Warmup Duration="600" PowerLow="0.40" PowerHigh="0.75">
      <textevent timeoffset="0" message="Let's get warmed up!" duration="15"/>
      <textevent timeoffset="300" message="Halfway through warmup" duration="10"/>
    </Warmup>
    <SteadyState Duration="1200" Power="0.88" Cadence="90">
      <textevent timeoffset="0" message="First block — find your rhythm" duration="15"/>
    </SteadyState>
    <SteadyState Duration="300" Power="0.55">
      <textevent timeoffset="0" message="Easy spin, recover" duration="10"/>
    </SteadyState>
    <SteadyState Duration="1200" Power="0.93" Cadence="90">
      <textevent timeoffset="0" message="Second block — push through!" duration="15"/>
    </SteadyState>
    <Cooldown Duration="300" PowerLow="0.65" PowerHigh="0.30"/>
  </workout>
</workout_file>
''';

/// Workout with FreeRide and Ramp steps.
const _mixedSteps = '''
<workout_file>
  <name>Mixed Steps</name>
  <workout>
    <Warmup Duration="300" PowerLow="0.30" PowerHigh="0.60"/>
    <FreeRide Duration="600"/>
    <Ramp Duration="120" PowerLow="0.60" PowerHigh="1.00"/>
    <SteadyState Duration="60" Power="1.00"/>
    <Cooldown Duration="180" PowerLow="0.70" PowerHigh="0.30"/>
  </workout>
</workout_file>
''';

/// Minimal file without a `<workout_file>` root (just `<workout>`).
const _minimalZwo = '''
<workout>
  <Warmup Duration="120" PowerLow="0.50" PowerHigh="0.75"/>
  <SteadyState Duration="300" Power="0.90"/>
</workout>
''';

void main() {
  late ZwoParser parser;

  setUp(() {
    parser = ZwoParser();
  });

  // ===========================================================================
  // Simple Warmup
  // ===========================================================================

  group('ZwoParser — simple warmup', () {
    late Workout workout;
    setUp(() async => workout = await parser.parse(_simpleWarmup));

    test('name and description', () {
      expect(workout.name, 'Simple Warmup');
      expect(workout.description, 'Basic warm-up ramp');
    });

    test('single warmup step', () {
      expect(workout.steps, hasLength(1));
      final step = workout.steps.first;
      expect(step.type, StepType.warmup);
      expect(step.durationSeconds, 600);
      expect(step.powerLowPercent, closeTo(25, 0.01));
      expect(step.powerHighPercent, closeTo(75, 0.01));
      expect(step.cadenceTarget, 85);
    });

    test('total duration', () {
      expect(workout.totalDuration, const Duration(seconds: 600));
    });

    test('source is zwo', () {
      expect(workout.source, 'zwo');
    });
  });

  // ===========================================================================
  // Interval Workout
  // ===========================================================================

  group('ZwoParser — 5x1min VO2max', () {
    late Workout workout;
    setUp(() async => workout = await parser.parse(_intervalWorkout));

    test('has 3 steps: warmup, intervals, cooldown', () {
      expect(workout.steps, hasLength(3));
      expect(workout.steps[0].type, StepType.warmup);
      expect(workout.steps[1].type, StepType.interval);
      expect(workout.steps[2].type, StepType.cooldown);
    });

    test('interval step properties', () {
      final interval = workout.steps[1];
      expect(interval.repeat, 5);
      expect(interval.durationSeconds, 60); // on duration
      expect(interval.offDurationSeconds, 120); // off duration
      expect(interval.powerTargetPercent, closeTo(120, 0.01)); // on power
      expect(interval.powerLowPercent, closeTo(55, 0.01)); // off power
      expect(interval.cadenceTarget, 100);
      expect(interval.cadenceResting, 85);
    });

    test('interval total duration = 5 × (60 + 120) = 900s', () {
      final interval = workout.steps[1];
      expect(interval.totalDurationSeconds, 900);
    });

    test('workout total duration = 300 + 900 + 300 = 1500s', () {
      expect(workout.totalDuration, const Duration(seconds: 1500));
    });
  });

  // ===========================================================================
  // Sweet Spot with text events
  // ===========================================================================

  group('ZwoParser — Sweet Spot 2x20', () {
    late Workout workout;
    setUp(() async => workout = await parser.parse(_sweetSpot));

    test('has 5 steps', () {
      expect(workout.steps, hasLength(5));
      expect(workout.steps[0].type, StepType.warmup);
      expect(workout.steps[1].type, StepType.steadyState);
      expect(workout.steps[2].type, StepType.steadyState);
      expect(workout.steps[3].type, StepType.steadyState);
      expect(workout.steps[4].type, StepType.cooldown);
    });

    test('steady state power values', () {
      expect(workout.steps[1].powerTargetPercent, closeTo(88, 0.01));
      expect(workout.steps[1].cadenceTarget, 90);
      expect(workout.steps[2].powerTargetPercent, closeTo(55, 0.01));
      expect(workout.steps[3].powerTargetPercent, closeTo(93, 0.01));
    });

    test('total duration = 600+1200+300+1200+300 = 3600s', () {
      expect(workout.totalDuration, const Duration(seconds: 3600));
    });

    test('text events are collected with absolute offsets', () {
      expect(workout.textEvents, hasLength(5));

      // First text event: warmup offset 0 → absolute 0.
      expect(workout.textEvents[0].offsetSeconds, 0);
      expect(workout.textEvents[0].message, "Let's get warmed up!");
      expect(workout.textEvents[0].durationSeconds, 15);

      // Second: warmup offset 300 → absolute 300.
      expect(workout.textEvents[1].offsetSeconds, 300);
      expect(workout.textEvents[1].message, 'Halfway through warmup');

      // Third: first SS block offset 0 → absolute 600 (after 600s warmup).
      expect(workout.textEvents[2].offsetSeconds, 600);
      expect(workout.textEvents[2].message, 'First block — find your rhythm');

      // Fourth: recovery offset 0 → absolute 1800 (600+1200).
      expect(workout.textEvents[3].offsetSeconds, 1800);
      expect(workout.textEvents[3].message, 'Easy spin, recover');

      // Fifth: second SS block offset 0 → absolute 2100 (600+1200+300).
      expect(workout.textEvents[4].offsetSeconds, 2100);
      expect(workout.textEvents[4].message, 'Second block — push through!');
    });
  });

  // ===========================================================================
  // Mixed steps (FreeRide, Ramp)
  // ===========================================================================

  group('ZwoParser — mixed steps', () {
    late Workout workout;
    setUp(() async => workout = await parser.parse(_mixedSteps));

    test('parses all step types', () {
      expect(workout.steps, hasLength(5));
      expect(workout.steps[0].type, StepType.warmup);
      expect(workout.steps[1].type, StepType.freeRide);
      expect(workout.steps[2].type, StepType.ramp);
      expect(workout.steps[3].type, StepType.steadyState);
      expect(workout.steps[4].type, StepType.cooldown);
    });

    test('free ride has zero power target', () {
      expect(workout.steps[1].durationSeconds, 600);
      expect(workout.steps[1].powerTargetPercent, 0);
    });

    test('ramp has low/high', () {
      final ramp = workout.steps[2];
      expect(ramp.durationSeconds, 120);
      expect(ramp.powerLowPercent, closeTo(60, 0.01));
      expect(ramp.powerHighPercent, closeTo(100, 0.01));
    });

    test('name defaults when description is missing', () {
      expect(workout.name, 'Mixed Steps');
      expect(workout.description, isNull);
    });
  });

  // ===========================================================================
  // Minimal (no <workout_file> wrapper)
  // ===========================================================================

  group('ZwoParser — minimal ZWO', () {
    test('parses without <workout_file> root', () async {
      final workout = await parser.parse(_minimalZwo);
      expect(workout.steps, hasLength(2));
      expect(workout.steps[0].type, StepType.warmup);
      expect(workout.steps[1].type, StepType.steadyState);
    });
  });

  // ===========================================================================
  // Serialize round-trip
  // ===========================================================================

  group('ZwoParser — serialize / round-trip', () {
    test('serialized workout can be re-parsed', () async {
      final original = await parser.parse(_intervalWorkout);
      final xml = await parser.serialize(original);
      final reparsed = await parser.parse(xml);

      expect(reparsed.name, original.name);
      expect(reparsed.steps.length, original.steps.length);

      for (var i = 0; i < original.steps.length; i++) {
        expect(reparsed.steps[i].type, original.steps[i].type);
        expect(reparsed.steps[i].durationSeconds,
            original.steps[i].durationSeconds);
      }
    });

    test('interval round-trip preserves repeat and off duration', () async {
      final original = await parser.parse(_intervalWorkout);
      final xml = await parser.serialize(original);
      final reparsed = await parser.parse(xml);

      final origInt = original.steps[1];
      final repInt = reparsed.steps[1];
      expect(repInt.repeat, origInt.repeat);
      expect(repInt.offDurationSeconds, origInt.offDurationSeconds);
      expect(repInt.powerTargetPercent,
          closeTo(origInt.powerTargetPercent, 1));
      expect(repInt.powerLowPercent,
          closeTo(origInt.powerLowPercent!, 1));
    });

    test('editor-created workout (WorkoutBuilder, not imported) round-trips',
        () async {
      final original = WorkoutBuilder('2x5 Intervals', description: 'Built in the editor')
          .warmup(duration: 300, fromPercent: 40, toPercent: 70, cadence: 85)
          .intervals(
            repeat: 2,
            onDuration: 300,
            offDuration: 60,
            onPercent: 105,
            offPercent: 50,
          )
          .cooldown(duration: 180, fromPercent: 65, toPercent: 30)
          .build();

      final xml = await parser.serialize(original);
      final reparsed = await parser.parse(xml);

      expect(reparsed.name, original.name);
      expect(reparsed.description, original.description);
      expect(reparsed.steps, hasLength(original.steps.length));
      expect(reparsed.totalDuration, original.totalDuration);

      for (var i = 0; i < original.steps.length; i++) {
        expect(reparsed.steps[i].type, original.steps[i].type);
        expect(reparsed.steps[i].durationSeconds, original.steps[i].durationSeconds);
      }

      final reInterval = reparsed.steps[1];
      final origInterval = original.steps[1];
      expect(reInterval.repeat, origInterval.repeat);
      expect(reInterval.offDurationSeconds, origInterval.offDurationSeconds);
      expect(reInterval.powerTargetPercent, closeTo(origInterval.powerTargetPercent, 1));
      expect(reInterval.powerLowPercent, closeTo(origInterval.powerLowPercent!, 1));
    });
  });

  // ===========================================================================
  // Plugin interface
  // ===========================================================================

  group('ZwoParser — plugin interface', () {
    test('manifest has correct type', () {
      expect(parser.manifest.type, PluginType.format);
    });

    test('supported extensions', () {
      expect(parser.supportedExtensions, ['.zwo']);
    });
  });
}
