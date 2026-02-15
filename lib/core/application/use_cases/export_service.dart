import 'dart:io';
import 'dart:typed_data';

import '../../domain/entities/entities.dart';
import '../../domain/ports/export_port.dart';
import '../../../infrastructure/files/fit_encoder.dart';
import '../../../infrastructure/files/tcx_encoder.dart';

/// Local file export service.
///
/// Encodes a [Ride] into the requested format and writes it to the given
/// [baseDirectory] (typically the app's documents directory).
class ExportService {
  final FitEncoder _fitEncoder;
  final TcxEncoder _tcxEncoder;

  ExportService({
    FitEncoder? fitEncoder,
    TcxEncoder? tcxEncoder,
  })  : _fitEncoder = fitEncoder ?? FitEncoder(),
        _tcxEncoder = tcxEncoder ?? TcxEncoder();

  /// Exports [ride] to a file in [baseDirectory].
  ///
  /// Returns the created [File]. The filename is derived from the ride's
  /// start time and id (e.g. `2025-01-15_abc123.fit`).
  Future<File> exportToFile(
    Ride ride,
    ExportFormat format, {
    required String baseDirectory,
  }) async {
    final datePrefix = _datePrefix(ride.startTime);
    final shortId = ride.id.length > 8 ? ride.id.substring(0, 8) : ride.id;

    switch (format) {
      case ExportFormat.fit:
        final bytes = encodeFit(ride);
        final file = File('$baseDirectory/${datePrefix}_$shortId.fit');
        await file.writeAsBytes(bytes);
        return file;

      case ExportFormat.tcx:
        final xml = encodeTcx(ride);
        final file = File('$baseDirectory/${datePrefix}_$shortId.tcx');
        await file.writeAsString(xml);
        return file;

      case ExportFormat.gpx:
        throw UnimplementedError(
          'GPX export is not yet implemented. '
          'Use FIT or TCX for indoor rides.',
        );
    }
  }

  /// Encodes [ride] to FIT binary.
  Uint8List encodeFit(Ride ride) => _fitEncoder.encode(ride);

  /// Encodes [ride] to TCX XML string.
  String encodeTcx(Ride ride) => _tcxEncoder.encode(ride);

  String _datePrefix(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
