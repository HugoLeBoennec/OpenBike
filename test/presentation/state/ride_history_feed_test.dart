import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_bike/core/application/services/recording_engine.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/presentation/state/providers.dart';

class _MockRecordingEngine extends Mock implements RecordingEngine {}

/// The live chart and the 3s average follow the recording's samples. There
/// are no frames in a bare [ProviderContainer] — like a hidden window or a
/// locked phone — and the history must still fill.
void main() {
  late StreamController<SensorReading> samples;
  late ProviderContainer container;

  setUp(() {
    samples = StreamController<SensorReading>.broadcast();
    final recorder = _MockRecordingEngine();
    when(() => recorder.sampleStream).thenAnswer((_) => samples.stream);
    container = ProviderContainer(overrides: [
      recordingEngineProvider.overrideWithValue(recorder),
    ]);
    container.listen(powerHistoryUpdaterProvider, (_, __) {});
    container.listen(hrHistoryUpdaterProvider, (_, __) {});
  });

  tearDown(() async {
    container.dispose();
    await samples.close();
  });

  SensorReading reading(double watts, int bpm) => SensorReading(
        timestamp: DateTime.now(),
        power: Watts(watts),
        heartRate: HeartRate(bpm),
      );

  test('adds every recorded sample, however close together', () async {
    samples
      ..add(reading(200, 120))
      ..add(reading(210, 121))
      ..add(reading(220, 122));
    await Future<void>.delayed(Duration.zero);

    expect(container.read(powerHistoryProvider), [200, 210, 220]);
    expect(container.read(hrHistoryProvider), [120, 121, 122]);
    expect(container.read(threeSecondAvgPowerProvider), const Watts(210));
  });

  test('records a dropout as zero rather than skipping the second', () async {
    samples.add(SensorReading(timestamp: DateTime.now()));
    await Future<void>.delayed(Duration.zero);

    expect(container.read(powerHistoryProvider), [0]);
    expect(container.read(hrHistoryProvider), [0]);
  });
}
