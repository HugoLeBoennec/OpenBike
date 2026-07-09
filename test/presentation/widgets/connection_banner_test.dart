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

    expect(find.textContaining('connection lost'), findsNothing);

    eventBus.fire(const TrainerEvent.disconnected('trainer-1'));
    await tester.pumpAndSettle();

    expect(
      find.text('Trainer connection lost — reconnecting…'),
      findsOneWidget,
    );

    eventBus.fire(const TrainerEvent.connected(_trainer));
    await tester.pumpAndSettle();

    expect(find.textContaining('connection lost'), findsNothing);
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
