import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/ports/export_port.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../infrastructure/files/tcx_encoder.dart';
import '../plugin_interfaces.dart';
import '../plugin_manifest.dart';

/// TCX file export plugin — local file export, alongside the Garmin FIT
/// plugin.
///
/// Encodes the ride as a Training Center XML (TCX) file and saves it to the
/// app's documents/exports directory. The caller (UI layer) is responsible
/// for presenting a save/share dialog to the user — this plugin only
/// produces the file and returns its path.
class TcxFileExportPlugin implements ExportPlugin {
  TcxFileExportPlugin({
    TcxEncoder? tcxEncoder,
    String? exportDirectory,
  })  : _tcxEncoder = tcxEncoder ?? TcxEncoder(),
        _exportDirectory = exportDirectory;

  final TcxEncoder _tcxEncoder;
  final String? _exportDirectory;

  // ---------------------------------------------------------------------------
  // Manifest
  // ---------------------------------------------------------------------------

  @override
  PluginManifest get manifest => const PluginManifest(
        id: 'tcx-file-export',
        name: 'TCX File',
        version: '1.0.0',
        type: PluginType.export,
        author: 'OpenBike',
        description: 'Export ride as a TCX file',
        capabilities: ['file-export'],
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
    ExportFormat format = ExportFormat.tcx,
    Watts? ftp,
  }) async {
    final xmlContent = _tcxEncoder.encode(ride);

    final dir = _exportDirectory ?? await _defaultDirectory();
    final datePrefix = _datePrefix(ride.startTime);
    final shortId = ride.id.length > 8 ? ride.id.substring(0, 8) : ride.id;
    final filePath = '$dir/${datePrefix}_$shortId.tcx';

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
