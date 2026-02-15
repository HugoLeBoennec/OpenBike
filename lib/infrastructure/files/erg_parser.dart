import '../../core/domain/entities/workout.dart';
import '../../core/domain/entities/workout_step.dart';
import '../../plugins/plugin_interfaces.dart';
import '../../plugins/plugin_manifest.dart';

/// Parses ERG and MRC workout files implementing [WorkoutFormatPlugin].
///
/// **ERG format**: `MINUTES  WATTS` (absolute power).
/// **MRC format**: `MINUTES  PERCENT` (% of FTP).
///
/// Both share the same structure:
/// ```
/// [COURSE HEADER]
/// ...
/// DESCRIPTION = My Workout
/// MINUTES  WATTS   (or MINUTES  PERCENT)
/// [END COURSE HEADER]
/// [COURSE DATA]
/// 0.00  100
/// 5.00  100
/// 5.00  200
/// 10.00 200
/// [END COURSE DATA]
/// ```
///
/// Two consecutive points at the same power level → `steadyState`.
/// Two consecutive points at different power levels → `ramp`.
class ErgMrcParser implements WorkoutFormatPlugin {
  @override
  PluginManifest get manifest => const PluginManifest(
        id: 'com.openbike.format.erg',
        name: 'ERG/MRC Parser',
        version: '1.0.0',
        type: PluginType.format,
        description: 'ERG and MRC workout file parser',
      );

  @override
  List<String> get supportedExtensions => const ['.erg', '.mrc'];

  // ---------------------------------------------------------------------------
  // parse
  // ---------------------------------------------------------------------------

  @override
  Future<Workout> parse(String content) async {
    final isPercent = _detectMrc(content);
    final lines = content.split('\n');

    String name = 'Imported Workout';
    final points = <_DataPoint>[];

    bool inHeader = false;
    bool inData = false;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Section markers.
      if (line.startsWith('[COURSE HEADER]')) {
        inHeader = true;
        inData = false;
        continue;
      }
      if (line.startsWith('[END COURSE HEADER]')) {
        inHeader = false;
        continue;
      }
      if (line.startsWith('[COURSE DATA]')) {
        inData = true;
        inHeader = false;
        continue;
      }
      if (line.startsWith('[END COURSE DATA]')) break;

      // Header fields.
      if (inHeader) {
        if (line.toUpperCase().startsWith('DESCRIPTION')) {
          final idx = line.indexOf('=');
          if (idx != -1) name = line.substring(idx + 1).trim();
        }
        continue;
      }

      // Data lines.
      if (!inData) continue;

      final parts = line.split(RegExp(r'[\s\t]+'));
      if (parts.length < 2) continue;

      final minute = double.tryParse(parts[0]);
      final value = double.tryParse(parts[1]);
      if (minute == null || value == null) continue;

      points.add(_DataPoint(minute, value));
    }

    // Convert point pairs to steps.
    final steps = <WorkoutStep>[];
    for (var i = 0; i + 1 < points.length; i += 2) {
      final a = points[i];
      final b = points[i + 1];
      final durationSec = ((b.minute - a.minute) * 60).round();
      if (durationSec <= 0) continue;

      if (isPercent) {
        // MRC: values are percentages of FTP.
        steps.add(_stepFromPercent(a.value, b.value, durationSec));
      } else {
        // ERG: values are absolute watts — store as percent with 100 = 100 W.
        // We treat 1 W = 1 % for ERG files. The WorkoutEngine can detect
        // source='erg' and skip FTP multiplication, or the caller normalizes
        // the values before use.
        steps.add(_stepFromPercent(a.value, b.value, durationSec));
      }
    }

    return Workout(
      id: '',
      name: name,
      steps: steps,
      source: isPercent ? 'mrc' : 'erg',
    );
  }

  // ---------------------------------------------------------------------------
  // serialize
  // ---------------------------------------------------------------------------

  @override
  Future<String> serialize(Workout workout) async {
    final buf = StringBuffer();
    buf.writeln('[COURSE HEADER]');
    buf.writeln('VERSION = 2');
    buf.writeln('DESCRIPTION = ${workout.name}');
    buf.writeln('MINUTES\tPERCENT');
    buf.writeln('[END COURSE HEADER]');
    buf.writeln('[COURSE DATA]');

    double minute = 0;
    for (final step in workout.steps) {
      final low = step.powerLowPercent ?? step.powerTargetPercent;
      final high = step.powerHighPercent ?? step.powerTargetPercent;
      buf.writeln('${minute.toStringAsFixed(2)}\t${low.toStringAsFixed(0)}');
      minute += step.durationSeconds / 60;
      buf.writeln('${minute.toStringAsFixed(2)}\t${high.toStringAsFixed(0)}');
    }

    buf.writeln('[END COURSE DATA]');
    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  /// Detects whether the file is MRC (PERCENT) rather than ERG (WATTS).
  bool _detectMrc(String content) {
    // Check the header for PERCENT keyword, or use file naming convention.
    final upper = content.toUpperCase();
    if (upper.contains('MINUTES\tPERCENT') ||
        upper.contains('MINUTES PERCENT')) {
      return true;
    }
    return false;
  }

  /// Creates a step from two percent values (start → end).
  WorkoutStep _stepFromPercent(
      double startPct, double endPct, int durationSec) {
    if ((startPct - endPct).abs() < 0.5) {
      // Plateau → steady state.
      return WorkoutStep(
        type: StepType.steadyState,
        durationSeconds: durationSec,
        powerTargetPercent: startPct,
      );
    } else {
      // Ramp.
      return WorkoutStep(
        type: StepType.ramp,
        durationSeconds: durationSec,
        powerTargetPercent: (startPct + endPct) / 2, // midpoint for display
        powerLowPercent: startPct,
        powerHighPercent: endPct,
      );
    }
  }
}

class _DataPoint {
  const _DataPoint(this.minute, this.value);
  final double minute;
  final double value;
}
