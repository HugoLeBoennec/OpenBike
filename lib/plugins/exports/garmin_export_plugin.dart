import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/ports/export_port.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../infrastructure/files/fit_encoder.dart';
import '../plugin_interfaces.dart';
import '../plugin_manifest.dart';

/// Garmin Connect export plugin — **MVP: local file export**.
///
/// Garmin Connect has no public activity-upload API. For the MVP we:
///   1. Generate a conformant FIT file
///   2. Save it to the device's documents directory
///   3. Return the file path so the UI can show sharing options
///
/// The user can then import the file manually via
/// <https://connect.garmin.com/modern/import-data> or the Garmin Connect
/// mobile app.
///
/// Future work: integrate the Garmin Health API (requires a partnership
/// agreement) or use the Connect IQ SDK for direct push.
class GarminConnectExportPlugin implements ExportPlugin {
  GarminConnectExportPlugin({
    FitEncoder? fitEncoder,
    String? exportDirectory,
  })  : _fitEncoder = fitEncoder ?? FitEncoder(),
        _exportDirectory = exportDirectory;

  final FitEncoder _fitEncoder;
  final String? _exportDirectory;

  // ---------------------------------------------------------------------------
  // Manifest
  // ---------------------------------------------------------------------------

  @override
  PluginManifest get manifest => const PluginManifest(
        id: 'garmin-connect-export',
        name: 'Garmin Connect',
        version: '1.0.0',
        type: PluginType.export,
        author: 'OpenBike',
        description: 'Export FIT file for manual import into Garmin Connect',
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
    ExportFormat format = ExportFormat.fit,
    Watts? ftp,
  }) async {
    final bytes = _fitEncoder.encode(ride, ftp: ftp);

    final dir = _exportDirectory ?? await _defaultDirectory();
    final datePrefix = _datePrefix(ride.startTime);
    final shortId = ride.id.length > 8 ? ride.id.substring(0, 8) : ride.id;
    final filePath = '$dir/${datePrefix}_$shortId.fit';

    final file = File(filePath);
    await file.writeAsBytes(bytes);

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
