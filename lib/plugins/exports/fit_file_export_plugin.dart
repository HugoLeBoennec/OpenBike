import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/ports/export_port.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../../infrastructure/files/fit_encoder.dart';
import '../plugin_interfaces.dart';
import '../plugin_manifest.dart';

/// FIT file export plugin — local file export, alongside the TCX plugin.
///
/// FIT is the standard activity format, so one file covers Garmin Connect
/// (which has no public activity-upload API), Strava, TrainingPeaks,
/// intervals.icu and most other training sites. We:
///   1. Generate a conformant FIT file
///   2. Save it to the device's documents directory
///   3. Return the file path so the UI can show sharing options
///
/// The user then uploads it on the service's website, e.g.
/// <https://connect.garmin.com/modern/import-data>.
///
/// Future work: integrate the Garmin Health API (requires a partnership
/// agreement) or use the Connect IQ SDK for direct push.
class FitFileExportPlugin implements ExportPlugin {
  FitFileExportPlugin({
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
        // Pre-rename id, kept: it's stored in export-queue rows and
        // auto-upload preferences on existing installs.
        id: 'garmin-connect-export',
        name: 'FIT File',
        version: '1.0.0',
        type: PluginType.export,
        author: 'OpenBike',
        description: 'Export ride as a FIT file for Garmin Connect, Strava '
            'and other training sites',
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
