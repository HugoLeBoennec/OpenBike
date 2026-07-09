import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/events/app_event.dart';
import 'package:open_bike/core/events/event_bus.dart';
import 'package:open_bike/presentation/state/providers.dart';

const _trainer = TrainerDevice(
  id: 'trainer-1',
  name: 'Kickr',
  protocol: DeviceProtocol.bleFtms,
);
const _hrm = TrainerDevice(
  id: 'hrm-1',
  name: 'TICKR',
  protocol: DeviceProtocol.bleHr,
);

ProviderContainer _makeContainer(EventBus eventBus, PairedDevices paired) {
  final container = ProviderContainer(overrides: [
    eventBusProvider.overrideWithValue(eventBus),
    pairedDevicesProvider.overrideWith((ref) => paired),
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  late EventBus eventBus;

  setUp(() {
    eventBus = EventBus();
  });

  tearDown(() {
    eventBus.dispose();
  });

  group('roleConnectionStatusProvider', () {
    test('has no entries before any TrainerEvent fires', () {
      final paired = const PairedDevices().withRole(
        SensorRole.trainer,
        const PairedDevice(
            deviceId: 'trainer-1', name: 'Kickr', protocol: DeviceProtocol.bleFtms),
      );
      final container = _makeContainer(eventBus, paired);

      expect(container.read(roleConnectionStatusProvider), isEmpty);
      expect(container.read(disconnectedPairedRolesProvider), isEmpty);
    });

    test('marks a role disconnected when its paired device disconnects',
        () async {
      final paired = const PairedDevices().withRole(
        SensorRole.trainer,
        const PairedDevice(
            deviceId: 'trainer-1', name: 'Kickr', protocol: DeviceProtocol.bleFtms),
      );
      final container = _makeContainer(eventBus, paired);
      container.read(roleConnectionStatusProvider); // start listening

      eventBus.fire(const TrainerEvent.disconnected('trainer-1'));
      await pumpEventQueue(); // EventBus listeners fire asynchronously

      expect(container.read(roleConnectionStatusProvider)[SensorRole.trainer],
          isFalse);
      expect(container.read(disconnectedPairedRolesProvider),
          [SensorRole.trainer]);
    });

    test('clears disconnected status once the device reconnects', () async {
      final paired = const PairedDevices().withRole(
        SensorRole.trainer,
        const PairedDevice(
            deviceId: 'trainer-1', name: 'Kickr', protocol: DeviceProtocol.bleFtms),
      );
      final container = _makeContainer(eventBus, paired);
      container.read(roleConnectionStatusProvider);

      eventBus.fire(const TrainerEvent.disconnected('trainer-1'));
      await pumpEventQueue();
      expect(container.read(disconnectedPairedRolesProvider),
          [SensorRole.trainer]);

      eventBus.fire(const TrainerEvent.connected(_trainer));
      await pumpEventQueue();
      expect(container.read(disconnectedPairedRolesProvider), isEmpty);
    });

    test('ignores events for device ids not paired to any role', () async {
      final paired = const PairedDevices();
      final container = _makeContainer(eventBus, paired);
      container.read(roleConnectionStatusProvider);

      eventBus.fire(const TrainerEvent.disconnected('unpaired-device'));
      await pumpEventQueue();

      expect(container.read(roleConnectionStatusProvider), isEmpty);
    });

    test('tracks multiple roles independently', () async {
      final paired = const PairedDevices()
          .withRole(SensorRole.trainer,
              const PairedDevice(deviceId: 'trainer-1', name: 'Kickr', protocol: DeviceProtocol.bleFtms))
          .withRole(SensorRole.heartRate,
              const PairedDevice(deviceId: 'hrm-1', name: 'TICKR', protocol: DeviceProtocol.bleHr));
      final container = _makeContainer(eventBus, paired);
      container.read(roleConnectionStatusProvider);

      eventBus.fire(const TrainerEvent.disconnected('trainer-1'));
      await pumpEventQueue();

      final disconnected = container.read(disconnectedPairedRolesProvider);
      expect(disconnected, [SensorRole.trainer]);
      expect(disconnected, isNot(contains(SensorRole.heartRate)));

      eventBus.fire(const TrainerEvent.disconnected('hrm-1'));
      await pumpEventQueue();
      expect(
        container.read(disconnectedPairedRolesProvider),
        containsAll([SensorRole.trainer, SensorRole.heartRate]),
      );

      eventBus.fire(const TrainerEvent.connected(_hrm));
      await pumpEventQueue();
      expect(container.read(disconnectedPairedRolesProvider),
          [SensorRole.trainer]);
    });
  });
}
