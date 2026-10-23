import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/ports/export_port.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../infrastructure/files/gpx_encoder.dart';
import '../plugin_interfaces.dart';
import '../plugin_manifest.dart';

/// GPX file export plugin — local file export, alongside FIT and TCX.
///
/// A ride holds no positions of its own: [GpxEncoder] places its readings on
/// the route it followed, so this only exports rides linked to a saved route
/// (`requires-route`), loading that route through [loadRoute]. Like the
/// other file exports, it only produces the file and returns its path.
class GpxFileExportPlugin implements ExportPlugin {
  GpxFileExportPlugin({
    required Future<Route?> Function(String routeId) loadRoute,
    GpxEncoder? gpxEncoder,
    String? exportDirectory,
  })  : _loadRoute = loadRoute,
        _gpxEncoder = gpxEncoder ?? GpxEncoder(),
        _exportDirectory = exportDirectory;

  final Future<Route?> Function(String routeId) _loadRoute;
  final GpxEncoder _gpxEncoder;
  final String? _exportDirectory;

  // ---------------------------------------------------------------------------
  // Manifest
  // ---------------------------------------------------------------------------

  @override
  PluginManifest get manifest => const PluginManifest(
        id: 'gpx-file-export',
        name: 'GPX File',
        version: '1.0.0',
        type: PluginType.export,
        author: 'OpenBike',
        description: 'Export a route ride as a GPX file',
        capabilities: ['file-export', 'requires-route'],
      );

  // ---------------------------------------------------------------------------
  // Auth — no-op for file export
  // ---------------------------------------------------------------------------

  @override
  bool get isAuthenticated => true;

  @override
  Future<void> authenticate() async {
    // No authentication needed for local file export.
  }

  @override
  Future<void> disconnect() async {
    // Nothing to disconnect.
  }

  // ---------------------------------------------------------------------------
  // Export
  // ---------------------------------------------------------------------------

  @override
  Future<String> export(
    Ride ride, {
    ExportFormat format = ExportFormat.gpx,
    Watts? ftp,
  }) async {
    final routeId = ride.routeId;
    if (routeId == null) {
      throw GpxExportUnsupported('This ride didn\'t follow a saved route.');
    }
    final route = await _loadRoute(routeId);
    if (route == null) {
      throw GpxExportUnsupported(
          'The route this ride followed is no longer saved.');
    }
    final xmlContent = _gpxEncoder.encode(ride, route);

    final dir = _exportDirectory ?? await _defaultDirectory();
    final datePrefix = _datePrefix(ride.startTime);
    final shortId = ride.id.length > 8 ? ride.id.substring(0, 8) : ride.id;
    final filePath = '$dir/${datePrefix}_$shortId.gpx';

    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(xmlContent);

    return filePath;
  }

  Future<String> _defaultDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir.path;
  }

  String _datePrefix(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}
