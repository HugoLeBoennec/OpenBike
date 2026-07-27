import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/events/app_event.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/presentation/state/providers.dart';
import 'package:open_bike/presentation/widgets/connection_banner.dart';

const _trainer = TrainerDevice(
  id: 'trainer-1',
  name: 'Kickr',
  protocol: DeviceProtocol.bleFtms,
);

void main() {
  testWidgets(
      'TrainerEvent.disconnected shows the banner; connected hides it again',
      (tester) async {
    final eventBus = EventBus();
    addTearDown(eventBus.dispose);

    final paired = const PairedDevices().withRole(
      SensorRole.trainer,
      const PairedDevice(
        deviceId: 'trainer-1',
        name: 'Kickr',
        protocol: DeviceProtocol.bleFtms,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventBusProvider.overrideWithValue(eventBus),
          pairedDevicesProvider.overrideWith((ref) => paired),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ConnectionBanner()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Paired but never connected this session — warned about, but as
    // "not connected" since nothing is retrying it.
    expect(
      find.text('Trainer not connected — reconnect from Devices'),
      findsOneWidget,
    );

    eventBus.fire(const TrainerEvent.connected(_trainer));
    await tester.pumpAndSettle();
    expect(find.textContaining('not connected'), findsNothing);

    eventBus.fire(const TrainerEvent.disconnected('trainer-1'));
    await tester.pumpAndSettle();

    // A drop after a successful connect *is* auto-retried, so it gets the
    // "reconnecting" wording instead.
    expect(
      find.text('Trainer connection lost — reconnecting…'),
      findsOneWidget,
    );

    eventBus.fire(const TrainerEvent.connected(_trainer));
    await tester.pumpAndSettle();

    expect(find.textContaining('connection lost'), findsNothing);
  });

  testWidgets('shows both lines when one role dropped and another never came up',
      (tester) async {
    final eventBus = EventBus();
    addTearDown(eventBus.dispose);

    final paired = const PairedDevices()
        .withRole(
          SensorRole.trainer,
          const PairedDevice(
            deviceId: 'trainer-1',
            name: 'Kickr',
            protocol: DeviceProtocol.bleFtms,
          ),
        )
        .withRole(
          SensorRole.heartRate,
          const PairedDevice(
            deviceId: 'hrm-1',
            name: 'TICKR',
            protocol: DeviceProtocol.bleHr,
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventBusProvider.overrideWithValue(eventBus),
          pairedDevicesProvider.overrideWith((ref) => paired),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ConnectionBanner()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Trainer connects then drops; the HRM never connects at all.
    eventBus.fire(const TrainerEvent.connected(_trainer));
    await tester.pumpAndSettle();
    eventBus.fire(const TrainerEvent.disconnected('trainer-1'));
    await tester.pumpAndSettle();

    expect(
      find.text('Trainer connection lost — reconnecting…'),
      findsOneWidget,
    );
    expect(
      find.text('Heart Rate not connected — reconnect from Devices'),
      findsOneWidget,
    );
  });

  testWidgets('stays hidden for disconnects on devices not paired to a role',
      (tester) async {
    final eventBus = EventBus();
    addTearDown(eventBus.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventBusProvider.overrideWithValue(eventBus),
          pairedDevicesProvider.overrideWith((ref) => const PairedDevices()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ConnectionBanner()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    eventBus.fire(const TrainerEvent.disconnected('some-unpaired-device'));
    await tester.pumpAndSettle();

    expect(find.textContaining('connection lost'), findsNothing);
  });
}
