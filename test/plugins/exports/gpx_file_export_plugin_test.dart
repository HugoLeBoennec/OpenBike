import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:open_bike/core/domain/entities/entities.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';
import 'package:open_bike/infrastructure/files/gpx_encoder.dart';
import 'package:open_bike/infrastructure/files/gpx_parser.dart';
import 'package:open_bike/plugins/exports/gpx_file_export_plugin.dart';
import 'package:open_bike/plugins/plugin_interfaces.dart';

/// About 1.1 km due north.
final _route = GpxRouteParser().parse(
  '<?xml version="1.0" encoding="UTF-8"?>'
  '<gpx version="1.1" creator="test" xmlns="http://www.topografix.com/GPX/1/1">'
  '<trk><name>Galibier</name><trkseg>'
  '${[
    for (var i = 0; i <= 10; i++)
      '<trkpt lat="${45.0 + 0.001 * i}" lon="6.0"><ele>${1000 + 5 * i}</ele></trkpt>'
  ].join()}'
  '</trkseg></trk></gpx>',
).copyWith(id: 'route-1');

/// Rode the whole route, 10 m a second.
Ride _ride({String? routeId = 'route-1'}) {
  final start = DateTime.utc(2026, 10, 23, 8);
  final seconds = (_route.totalDistance.meters / 10).ceil();
  return Ride(
    id: 'ride-123456789',
    startTime: start,
    endTime: start.add(Duration(seconds: seconds)),
    status: RideStatus.finished,
    routeId: routeId,
    readings: [
      for (var i = 0; i <= seconds; i++)
        SensorReading(
          timestamp: start.add(Duration(seconds: i)),
          power: const Watts(200),
          distance: Distance(
              (i * 10.0).clamp(0, _route.totalDistance.meters).toDouble()),
        ),
    ],
  );
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('gpx_export_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  GpxFileExportPlugin plugin({Route? route}) => GpxFileExportPlugin(
        loadRoute: (id) async => id == 'route-1' ? route ?? _route : null,
        exportDirectory: tempDir.path,
      );

  test('is a file export that only applies to route rides', () {
    final p = plugin();
    expect(p.manifest.id, 'gpx-file-export');
    expect(p.isFileExport, isTrue);
    expect(p.requiresRoute, isTrue);
    expect(p.canExport(_ride()), isTrue);
    expect(p.canExport(_ride(routeId: null)), isFalse);
  });

  test('writes a GPX file that traces the route', () async {
    final path = await plugin().export(_ride());

    expect(path, endsWith('2026-10-23_ride-123.gpx'));
    final exported = GpxRouteParser().parse(await File(path).readAsString());
    expect(exported.totalDistance.meters,
        closeTo(_route.totalDistance.meters, 5));
  });

  test('refuses a ride that followed no saved route', () async {
    expect(() => plugin().export(_ride(routeId: null)),
        throwsA(isA<GpxExportUnsupported>()));
  });

  test('refuses a ride whose route is no longer saved', () async {
    expect(() => plugin().export(_ride(routeId: 'deleted')),
        throwsA(isA<GpxExportUnsupported>()));
  });
}
