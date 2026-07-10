import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/ports/export_port.dart';
import 'package:open_bike/core/domain/ports/trainer_port.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/plugins/plugin_interfaces.dart';
import 'package:open_bike/plugins/plugin_manifest.dart';
import 'package:open_bike/plugins/plugin_registry.dart';
import 'package:open_bike/plugins/private_plugins.dart';

// ---------------------------------------------------------------------------
// Stand-in for a private-package plugin (Records/OpenCoach) to prove the
// hook mechanism works without any private code in this repo.
// ---------------------------------------------------------------------------

class FakeRecordsPlugin implements ExportPlugin {
  @override
  PluginManifest get manifest => const PluginManifest(
        id: 'records-export',
        name: 'Records',
        version: '1.0.0',
        type: PluginType.export,
        capabilities: ['oauth2'],
      );

  @override
  bool get isAuthenticated => false;

  @override
  Future<void> authenticate() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<String> export(Ride ride,
          {ExportFormat format = ExportFormat.fit, Watts? ftp}) async =>
      'exported';
}

class FakeOpenCoachDevicePlugin implements DevicePlugin {
  @override
  PluginManifest get manifest => const PluginManifest(
        id: 'opencoach-device',
        name: 'OpenCoach Device',
        version: '1.0.0',
        type: PluginType.device,
      );

  @override
  bool canHandle(TrainerDevice device) => false;

  @override
  Future<List<TrainerDevice>> scan(Duration timeout) async => [];

  @override
  Future<TrainerPort> connect(TrainerDevice device) =>
      throw UnimplementedError('not exercised in this test');
}

void main() {
  group('registerPrivatePlugins', () {
    test('is a no-op against the public repo stub', () {
      final registry = PluginRegistry();
      registerPrivatePlugins(registry);
      expect(registry.allManifests, isEmpty);
    });

    test('registers export plugins returned by a fake hook', () {
      final registry = PluginRegistry();
      registerPrivatePlugins(
        registry,
        extraExportPlugins: () => [FakeRecordsPlugin()],
      );

      expect(registry.getExportPlugins(), hasLength(1));
      expect(registry.allManifests.map((m) => m.id), contains('records-export'));
    });

    test('registers device plugins returned by a fake hook', () {
      final registry = PluginRegistry();
      registerPrivatePlugins(
        registry,
        extraDevicePlugins: () => [FakeOpenCoachDevicePlugin()],
      );

      expect(registry.getDevicePlugins(), hasLength(1));
      expect(registry.allManifests.map((m) => m.id), contains('opencoach-device'));
    });
  });
}
