import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_bike/core/application/services/erg_cadence_guard.dart';
import 'package:open_bike/core/domain/entities/sensor_reading.dart';
import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/app_event.dart';
import 'package:open_bike/core/events/event_bus.dart';

class MockTrainerPort extends Mock implements TrainerPort {}

void main() {
  late EventBus eventBus;
  late MockTrainerPort trainer;
  late DateTime now;
  late ErgCadenceGuard guard;
  late List<double> sent;

  setUpAll(() {
    registerFallbackValue(Watts.zero);
    registerFallbackValue(const Grade(0));
  });

  setUp(() {
    eventBus = EventBus();
    trainer = MockTrainerPort();
    now = DateTime(2026, 10, 22, 18);
    sent = [];
    when(() => trainer.setTargetPower(any())).thenAnswer((inv) async {
      sent.add((inv.positionalArguments.single as Watts).value);
    });
    when(() => trainer.setResistance(any())).thenAnswer((_) async {});
    when(() => trainer.setSimulationParams(any(), any(), any(), any()))
        .thenAnswer((_) async {});
    guard = ErgCadenceGuard(
      trainer: trainer,
      eventBus: eventBus,
      clock: () => now,
    );
  });

  tearDown(() {
    guard.dispose();
    eventBus.dispose();
  });

  /// One second of riding at [rpm].
  Future<void> ride(double? rpm, {int seconds = 1}) async {
    for (var i = 0; i < seconds; i++) {
      eventBus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: now,
          power: const Watts(250),
          cadence: rpm == null ? null : Cadence(rpm),
        ),
        deviceId: 'trainer',
      ));
      await Future<void>.delayed(Duration.zero);
      now = now.add(const Duration(seconds: 1));
    }
  }

  test('passes ERG targets through while cadence holds', () async {
    await guard.setTargetPower(const Watts(280));
    await ride(85, seconds: 10);
    await guard.setTargetPower(const Watts(300));

    expect(sent, [280, 300]);
    expect(guard.isEasing, isFalse);
  });

  test('halves the target after 3 s under 50 rpm, then keeps it eased',
      () async {
    await guard.setTargetPower(const Watts(280));
    await ride(45, seconds: 3);
    expect(sent, [280]);

    await ride(45);
    expect(sent, [280, 140]);
    expect(guard.isEasing, isTrue);

    // The workout engine re-sends its target every second.
    await guard.setTargetPower(const Watts(285));
    expect(sent.last, 143);
  });

  test('gives the full target back after 3 s at 60 rpm or more', () async {
    await guard.setTargetPower(const Watts(280));
    await ride(40, seconds: 4);
    expect(guard.isEasing, isTrue);

    // Between the two thresholds it stays eased.
    await ride(55, seconds: 10);
    expect(guard.isEasing, isTrue);

    await ride(65, seconds: 3);
    expect(guard.isEasing, isTrue);
    await ride(65);
    expect(guard.isEasing, isFalse);
    expect(sent.last, 280);
  });

  test('a dip shorter than 3 s leaves the target alone', () async {
    await guard.setTargetPower(const Watts(280));
    await ride(45, seconds: 3);
    await ride(80);
    await ride(45, seconds: 3);

    expect(sent, [280]);
  });

  test('resistance and SIM stand it down', () async {
    await guard.setTargetPower(const Watts(280));
    await guard.setResistance(3);
    await ride(30, seconds: 10);
    expect(sent, [280]);

    await guard.setTargetPower(const Watts(200));
    await ride(30, seconds: 4);
    expect(guard.isEasing, isTrue);
    await guard.setSimulationParams(0, const Grade(2), 0.004, 0.51);
    expect(guard.isEasing, isFalse);
  });

  test('readings without cadence are left out', () async {
    await guard.setTargetPower(const Watts(280));
    await ride(null, seconds: 10);

    expect(sent, [280]);
  });

  test('reports when easing starts and ends', () async {
    final states = <bool>[];
    guard.easingStream.listen(states.add);

    await guard.setTargetPower(const Watts(280));
    await ride(40, seconds: 4);
    await ride(70, seconds: 4);

    expect(states, [true, false]);
  });
}
