import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_bike/core/application/services/erg_cadence_guard.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/core/events/app_event.dart';
import 'package:open_bike/infrastructure/preferences/app_preferences.dart';
import 'package:open_bike/presentation/state/providers.dart';

class MockTrainerPort extends Mock implements TrainerPort {}

void main() {
  setUpAll(() => registerFallbackValue(Watts.zero));

  test('the workout engine and manual ERG go through one cadence guard',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = AppPreferences(await SharedPreferences.getInstance());
    final trainer = MockTrainerPort();
    final sent = <double>[];
    when(() => trainer.setTargetPower(any())).thenAnswer((inv) async {
      sent.add((inv.positionalArguments.single as Watts).value);
    });
    final container = ProviderContainer(overrides: [
      appPreferencesProvider.overrideWithValue(prefs),
    ]);
    addTearDown(container.dispose);
    container.read(activeTrainerPortProvider.notifier).state = trainer;

    final guard = container.read(ergCadenceGuardProvider);
    expect(guard, isA<ErgCadenceGuard>());
    expect(container.read(trainerPortProvider), same(guard));

    // Manual ERG, then the rider grinds to a halt: the guard eases the
    // target by itself, with nothing re-sending it.
    await container
        .read(trainerModeControllerProvider.notifier)
        .switchMode(ControlMode.erg, power: const Watts(280));
    final bus = container.read(eventBusProvider);
    for (var i = 0; i < 8; i++) {
      bus.fire(SensorEvent(
        reading: SensorReading(
          timestamp: DateTime.now(),
          cadence: const Cadence(30),
        ),
        deviceId: 'trainer',
      ));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    expect(sent, [280, 140]);
    expect(guard!.isEasing, isTrue);
  });
}
