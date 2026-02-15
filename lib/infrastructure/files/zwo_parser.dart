import 'package:xml/xml.dart';

import '../../core/domain/entities/workout.dart';
import '../../core/domain/entities/workout_step.dart';
import '../../plugins/plugin_interfaces.dart';
import '../../plugins/plugin_manifest.dart';

/// Parses and serializes Zwift `.zwo` workout files.
///
/// ZWO is XML with a `<workout_file>` root containing:
///   `<name>`, `<description>`, `<workout>` (steps), and `<textevent>`s.
///
/// Supported step elements:
///   `Warmup`, `Cooldown`, `SteadyState`, `IntervalsT`, `FreeRide`, `Ramp`.
///
/// Power values in ZWO are FTP fractions (e.g. `1.05` = 105 %).
class ZwoParser implements WorkoutFormatPlugin {
  @override
  PluginManifest get manifest => const PluginManifest(
        id: 'com.openbike.format.zwo',
        name: 'ZWO Parser',
        version: '1.0.0',
        type: PluginType.format,
        description: 'Zwift workout file parser (.zwo)',
      );

  @override
  List<String> get supportedExtensions => const ['.zwo'];

  // ---------------------------------------------------------------------------
  // parse
  // ---------------------------------------------------------------------------

  @override
  Future<Workout> parse(String content) async {
    final doc = XmlDocument.parse(content);

    // ZWO root is <workout_file> but some files just use <workout>.
    final workoutFiles = doc.findAllElements('workout_file');
    final root = workoutFiles.isEmpty
        ? doc.findAllElements('workout').first.parent!
        : workoutFiles.first;

    final names = root.findAllElements('name');
    final name = names.isEmpty ? 'Imported ZWO' : names.first.innerText;
    final descs = root.findAllElements('description');
    final description = descs.isEmpty ? null : descs.first.innerText;

    // Steps live under <workout>.
    final workoutEl = root.findAllElements('workout').first;

    final steps = <WorkoutStep>[];
    final textEvents = <TextEvent>[];

    // Running offset in seconds (used to map step-relative textevents to
    // absolute offsets).
    int cumulativeOffset = 0;

    for (final el in workoutEl.children.whereType<XmlElement>()) {
      // Collect text events attached to this step element.
      for (final te in el.findElements('textevent')) {
        final offset = _intAttr(te, 'timeoffset') ?? 0;
        final msg = te.getAttribute('message') ?? '';
        final dur = _intAttr(te, 'duration') ?? 10;
        if (msg.isNotEmpty) {
          textEvents.add(TextEvent(
            offsetSeconds: cumulativeOffset + offset,
            message: msg,
            durationSeconds: dur,
          ));
        }
      }

      final step = _parseStep(el);
      if (step != null) {
        steps.add(step);
        cumulativeOffset += step.totalDurationSeconds;
      }
    }

    // Also collect top-level <textevent> elements (outside <workout>).
    for (final te in root.findElements('textevent')) {
      final offset = _intAttr(te, 'timeoffset') ?? 0;
      final msg = te.getAttribute('message') ?? '';
      final dur = _intAttr(te, 'duration') ?? 10;
      if (msg.isNotEmpty) {
        textEvents.add(TextEvent(
          offsetSeconds: offset,
          message: msg,
          durationSeconds: dur,
        ));
      }
    }

    return Workout(
      id: '',
      name: name,
      description: description,
      steps: steps,
      source: 'zwo',
      textEvents: textEvents,
    );
  }

  // ---------------------------------------------------------------------------
  // serialize
  // ---------------------------------------------------------------------------

  @override
  Future<String> serialize(Workout workout) async {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('workout_file', nest: () {
      builder.element('name', nest: workout.name);
      if (workout.description != null) {
        builder.element('description', nest: workout.description);
      }
      builder.element('workout', nest: () {
        for (final step in workout.steps) {
          _serializeStep(builder, step);
        }
      });
    });
    return builder.buildDocument().toXmlString(pretty: true);
  }

  // ---------------------------------------------------------------------------
  // Step parsing
  // ---------------------------------------------------------------------------

  WorkoutStep? _parseStep(XmlElement el) {
    switch (el.name.local) {
      case 'Warmup':
        return _rampStep(el, StepType.warmup);
      case 'Cooldown':
        return _rampStep(el, StepType.cooldown);
      case 'Ramp':
        return _rampStep(el, StepType.ramp);
      case 'SteadyState':
        return _steadyStep(el);
      case 'IntervalsT':
        return _intervalsStep(el);
      case 'FreeRide':
        return _freeRideStep(el);
      default:
        return null; // Unknown element — skip.
    }
  }

  /// Warmup / Cooldown / Ramp: has `Duration`, `PowerLow`, `PowerHigh`.
  WorkoutStep _rampStep(XmlElement el, StepType type) {
    return WorkoutStep(
      type: type,
      durationSeconds: _intAttr(el, 'Duration') ?? 0,
      powerTargetPercent: 0, // Not used for ramp; low/high are used.
      powerLowPercent: _pct(el, 'PowerLow'),
      powerHighPercent: _pct(el, 'PowerHigh'),
      cadenceTarget: _intAttr(el, 'Cadence'),
    );
  }

  /// SteadyState: has `Duration`, `Power`.
  WorkoutStep _steadyStep(XmlElement el) {
    return WorkoutStep(
      type: StepType.steadyState,
      durationSeconds: _intAttr(el, 'Duration') ?? 0,
      powerTargetPercent: _pct(el, 'Power') ?? 0,
      cadenceTarget: _intAttr(el, 'Cadence'),
    );
  }

  /// IntervalsT: `Repeat`, `OnDuration`, `OffDuration`, `OnPower`, `OffPower`.
  WorkoutStep _intervalsStep(XmlElement el) {
    return WorkoutStep(
      type: StepType.interval,
      durationSeconds: _intAttr(el, 'OnDuration') ?? 0,
      offDurationSeconds: _intAttr(el, 'OffDuration'),
      powerTargetPercent: _pct(el, 'OnPower') ?? 100,
      powerLowPercent: _pct(el, 'OffPower'),
      repeat: _intAttr(el, 'Repeat') ?? 1,
      cadenceTarget: _intAttr(el, 'Cadence'),
      cadenceResting: _intAttr(el, 'CadenceResting'),
    );
  }

  /// FreeRide: only `Duration`.
  WorkoutStep _freeRideStep(XmlElement el) {
    return WorkoutStep(
      type: StepType.freeRide,
      durationSeconds: _intAttr(el, 'Duration') ?? 0,
      powerTargetPercent: 0,
    );
  }

  // ---------------------------------------------------------------------------
  // Step serialization
  // ---------------------------------------------------------------------------

  void _serializeStep(XmlBuilder builder, WorkoutStep step) {
    switch (step.type) {
      case StepType.warmup:
        _serializeRamp(builder, 'Warmup', step);
        break;
      case StepType.cooldown:
        _serializeRamp(builder, 'Cooldown', step);
        break;
      case StepType.ramp:
        _serializeRamp(builder, 'Ramp', step);
        break;
      case StepType.steadyState:
        builder.element('SteadyState', attributes: {
          'Duration': '${step.durationSeconds}',
          'Power': _frac(step.powerTargetPercent),
          if (step.cadenceTarget != null)
            'Cadence': '${step.cadenceTarget}',
        });
        break;
      case StepType.interval:
        builder.element('IntervalsT', attributes: {
          'Repeat': '${step.repeat ?? 1}',
          'OnDuration': '${step.durationSeconds}',
          'OffDuration': '${step.offDurationSeconds ?? step.durationSeconds}',
          'OnPower': _frac(step.powerTargetPercent),
          'OffPower': _frac(step.powerLowPercent ?? step.powerTargetPercent),
          if (step.cadenceTarget != null)
            'Cadence': '${step.cadenceTarget}',
          if (step.cadenceResting != null)
            'CadenceResting': '${step.cadenceResting}',
        });
        break;
      case StepType.freeRide:
        builder.element('FreeRide', attributes: {
          'Duration': '${step.durationSeconds}',
        });
        break;
    }
  }

  void _serializeRamp(XmlBuilder builder, String tag, WorkoutStep step) {
    builder.element(tag, attributes: {
      'Duration': '${step.durationSeconds}',
      'PowerLow': _frac(step.powerLowPercent ?? 0),
      'PowerHigh': _frac(step.powerHighPercent ?? 0),
      if (step.cadenceTarget != null) 'Cadence': '${step.cadenceTarget}',
    });
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Reads an integer attribute (ZWO sometimes uses float strings like "60.0").
  static int? _intAttr(XmlElement el, String name) {
    final raw = el.getAttribute(name);
    if (raw == null) return null;
    return double.tryParse(raw)?.round();
  }

  /// Reads a ZWO power fraction (e.g. `"1.05"`) and converts to percent
  /// (→ `105.0`).
  static double? _pct(XmlElement el, String attr) {
    final raw = el.getAttribute(attr);
    if (raw == null) return null;
    final d = double.tryParse(raw);
    if (d == null) return null;
    return d * 100;
  }

  /// Converts percent back to ZWO fraction string.
  static String _frac(double percent) =>
      (percent / 100).toStringAsFixed(2);
}
