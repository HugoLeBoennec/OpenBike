import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/plugins/exports/tcx_file_export_plugin.dart';
import 'package:open_bike/plugins/plugin_manifest.dart';
import 'package:open_bike/plugins/plugin_registry.dart';

Ride _rideWithReadings(int count) {
  final start = DateTime.utc(2026, 1, 1, 8);
  return Ride(
    id: 'ride-123456789',
    startTime: start,
    endTime: start.add(Duration(seconds: count)),
    status: RideStatus.finished,
    readings: [
      for (var i = 0; i < count; i++)
        SensorReading(
          timestamp: start.add(Duration(seconds: i)),
          power: Watts(150 + i.toDouble()),
          cadence: const Cadence(85),
          heartRate: const HeartRate(140),
          speed: const Speed(8.0),
          distance: Distance(i * 8.0),
        ),
    ],
  );
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tcx_export_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('TcxFileExportPlugin', () {
    test('manifest identifies the plugin as a file export', () {
      final plugin = TcxFileExportPlugin();
      expect(plugin.manifest.id, 'tcx-file-export');
      expect(plugin.manifest.type, PluginType.export);
      expect(plugin.isAuthenticated, isTrue);
    });

    test('export writes a valid XML file with the expected trackpoint count',
        () async {
      final plugin = TcxFileExportPlugin(exportDirectory: tempDir.path);
      final ride = _rideWithReadings(5);

      final path = await plugin.export(ride);
      final file = File(path);

      expect(await file.exists(), isTrue);
      expect(path, endsWith('.tcx'));

      final content = await file.readAsString();
      final doc = XmlDocument.parse(content); // throws if not valid XML

      final trackpoints = doc.findAllElements('Trackpoint');
      expect(trackpoints.length, 5);

      final activity = doc.findAllElements('Activity').single;
      expect(activity.getAttribute('Sport'), 'Biking');
    });

    test('export creates the target directory if missing', () async {
      final nestedDir = '${tempDir.path}/nested/exports';
      final plugin = TcxFileExportPlugin(exportDirectory: nestedDir);
      final ride = _rideWithReadings(1);

      final path = await plugin.export(ride);

      expect(await File(path).exists(), isTrue);
    });

    test('registers in PluginRegistry.allManifests', () {
      final registry = PluginRegistry();
      registry.registerExport(TcxFileExportPlugin());

      expect(
        registry.allManifests.map((m) => m.id),
        contains('tcx-file-export'),
      );
    });
  });
}
