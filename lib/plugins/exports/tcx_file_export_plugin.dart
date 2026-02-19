import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/ports/export_port.dart';
import '../../infrastructure/files/tcx_encoder.dart';
import '../plugin_interfaces.dart';
import '../plugin_manifest.dart';

/// TCX file export plugin.
///
/// Encodes the ride as a Training Center XML (TCX) file and saves it to the
/// temp directory. The caller (UI layer) is responsible for presenting a
/// save/share dialog to the user — this plugin only produces the file and
/// returns its path.
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
        name: 'Exporter TCX',
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
  String? get athleteName => null;

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
    ExportFormat format = ExportFormat.fit,
  }) async {
    final xmlContent = _tcxEncoder.encode(ride);

    // Save to temp directory so the UI layer can present a save/share dialog.
    final dir = _exportDirectory ?? (await getTemporaryDirectory()).path;
    final datePrefix = _datePrefix(ride.startTime);
    final shortId = ride.id.length > 8 ? ride.id.substring(0, 8) : ride.id;
    final filePath = '$dir/${datePrefix}_$shortId.tcx';

    final file = File(filePath);
    await file.writeAsString(xmlContent);

    return filePath;
  }

  String _datePrefix(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}
