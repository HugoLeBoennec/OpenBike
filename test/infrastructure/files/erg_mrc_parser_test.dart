import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/domain/entities/workout_step.dart';
import 'package:open_bike/infrastructure/files/erg_parser.dart';
import 'package:open_bike/plugins/plugin_manifest.dart';

// =============================================================================
// Sample ERG file (absolute watts)
// =============================================================================

const _ergFile = '''
[COURSE HEADER]
VERSION = 2
DESCRIPTION = FTP Test
MINUTES	WATTS
[END COURSE HEADER]
[COURSE DATA]
0.00	100
5.00	100
5.00	200
10.00	200
10.00	150
15.00	250
[END COURSE DATA]
''';

// =============================================================================
// Sample MRC file (percent of FTP)
// =============================================================================

const _mrcFile = '''
[COURSE HEADER]
VERSION = 2
DESCRIPTION = Sweet Spot
MINUTES	PERCENT
[END COURSE HEADER]
[COURSE DATA]
0.00	50
5.00	50
5.00	88
25.00	88
25.00	55
30.00	55
[END COURSE DATA]
''';

// =============================================================================
// Ramp detection file
// =============================================================================

const _rampFile = '''
[COURSE HEADER]
DESCRIPTION = Ramp Test
MINUTES	PERCENT
[END COURSE HEADER]
[COURSE DATA]
0.00	50
5.00	100
5.00	100
10.00	100
10.00	80
15.00	50
[END COURSE DATA]
''';

// =============================================================================
// Minimal file with no header
// =============================================================================

const _minimalErg = '''
[COURSE DATA]
0.00	150
3.00	150
3.00	250
6.00	250
[END COURSE DATA]
''';

void main() {
  late ErgMrcParser parser;

  setUp(() {
    parser = ErgMrcParser();
  });

  // ===========================================================================
  // ERG parsing
  // ===========================================================================

  group('ErgMrcParser — ERG file', () {
    test('parses name from DESCRIPTION', () async {
      final workout = await parser.parse(_ergFile);
      expect(workout.name, 'FTP Test');
    });

    test('produces correct number of steps', () async {
      final workout = await parser.parse(_ergFile);
      // 3 point-pairs → 3 steps.
      expect(workout.steps, hasLength(3));
    });

    test('plateau detected as steady state', () async {
      final workout = await parser.parse(_ergFile);
      // First pair: 0-5min at 100W → steady.
      expect(workout.steps[0].type, StepType.steadyState);
      expect(workout.steps[0].powerTargetPercent, closeTo(100, 0.01));
      expect(workout.steps[0].durationSeconds, 300); // 5 min
    });

    test('second plateau is steady state', () async {
      final workout = await parser.parse(_ergFile);
      expect(workout.steps[1].type, StepType.steadyState);
      expect(workout.steps[1].powerTargetPercent, closeTo(200, 0.01));
      expect(workout.steps[1].durationSeconds, 300);
    });

    test('different start/end detected as ramp', () async {
      final workout = await parser.parse(_ergFile);
      // Third pair: 150 → 250 over 5 min.
      expect(workout.steps[2].type, StepType.ramp);
      expect(workout.steps[2].powerLowPercent, closeTo(150, 0.01));
      expect(workout.steps[2].powerHighPercent, closeTo(250, 0.01));
      expect(workout.steps[2].durationSeconds, 300);
    });

    test('source is erg', () async {
      final workout = await parser.parse(_ergFile);
      expect(workout.source, 'erg');
    });
  });

  // ===========================================================================
  // MRC parsing
  // ===========================================================================

  group('ErgMrcParser — MRC file', () {
    test('detects MRC format from header', () async {
      final workout = await parser.parse(_mrcFile);
      expect(workout.source, 'mrc');
    });

    test('parses name', () async {
      final workout = await parser.parse(_mrcFile);
      expect(workout.name, 'Sweet Spot');
    });

    test('produces 3 steady-state steps', () async {
      final workout = await parser.parse(_mrcFile);
      expect(workout.steps, hasLength(3));
      for (final step in workout.steps) {
        expect(step.type, StepType.steadyState);
      }
    });

    test('power values are FTP percentages', () async {
      final workout = await parser.parse(_mrcFile);
      expect(workout.steps[0].powerTargetPercent, closeTo(50, 0.01));
      expect(workout.steps[1].powerTargetPercent, closeTo(88, 0.01));
      expect(workout.steps[2].powerTargetPercent, closeTo(55, 0.01));
    });

    test('durations are correct', () async {
      final workout = await parser.parse(_mrcFile);
      expect(workout.steps[0].durationSeconds, 300); // 5 min
      expect(workout.steps[1].durationSeconds, 1200); // 20 min
      expect(workout.steps[2].durationSeconds, 300); // 5 min
    });

    test('total duration = 30 min', () async {
      final workout = await parser.parse(_mrcFile);
      expect(workout.totalDuration, const Duration(minutes: 30));
    });
  });

  // ===========================================================================
  // Ramp detection
  // ===========================================================================

  group('ErgMrcParser — ramp detection', () {
    test('different start/end → ramp step', () async {
      final workout = await parser.parse(_rampFile);
      // First pair: 50 → 100 (ramp up).
      expect(workout.steps[0].type, StepType.ramp);
      expect(workout.steps[0].powerLowPercent, closeTo(50, 0.01));
      expect(workout.steps[0].powerHighPercent, closeTo(100, 0.01));
    });

    test('same start/end → steady state', () async {
      final workout = await parser.parse(_rampFile);
      // Second pair: 100 → 100.
      expect(workout.steps[1].type, StepType.steadyState);
    });

    test('ramp down detected', () async {
      final workout = await parser.parse(_rampFile);
      // Third pair: 80 → 50 (ramp down).
      expect(workout.steps[2].type, StepType.ramp);
      expect(workout.steps[2].powerLowPercent, closeTo(80, 0.01));
      expect(workout.steps[2].powerHighPercent, closeTo(50, 0.01));
    });
  });

  // ===========================================================================
  // Minimal / edge cases
  // ===========================================================================

  group('ErgMrcParser — edge cases', () {
    test('minimal file without header', () async {
      final workout = await parser.parse(_minimalErg);
      expect(workout.steps, hasLength(2));
      expect(workout.name, 'Imported Workout');
    });

    test('empty content produces empty steps', () async {
      final workout = await parser.parse('');
      expect(workout.steps, isEmpty);
    });

    test('no COURSE DATA section produces empty steps', () async {
      final workout = await parser.parse('[COURSE HEADER]\n[END COURSE HEADER]');
      expect(workout.steps, isEmpty);
    });
  });

  // ===========================================================================
  // Serialize / round-trip
  // ===========================================================================

  group('ErgMrcParser — serialize', () {
    test('serialized MRC can be re-parsed', () async {
      final original = await parser.parse(_mrcFile);
      final serialized = await parser.serialize(original);
      final reparsed = await parser.parse(serialized);

      expect(reparsed.steps.length, original.steps.length);
      for (var i = 0; i < original.steps.length; i++) {
        expect(reparsed.steps[i].durationSeconds,
            original.steps[i].durationSeconds);
        expect(reparsed.steps[i].powerTargetPercent,
            closeTo(original.steps[i].powerTargetPercent, 1));
      }
    });
  });

  // ===========================================================================
  // Plugin interface
  // ===========================================================================

  group('ErgMrcParser — plugin interface', () {
    test('manifest type is format', () {
      expect(parser.manifest.type, PluginType.format);
    });

    test('supported extensions', () {
      expect(parser.supportedExtensions, ['.erg', '.mrc']);
    });
  });
}
