import 'dart:io';
import 'dart:typed_data';

import '../../domain/entities/entities.dart';
import '../../domain/ports/export_port.dart';
import '../../domain/value_objects/value_objects.dart';
import '../../../infrastructure/files/fit_encoder.dart';
import '../../../infrastructure/files/gpx_encoder.dart';
import '../../../infrastructure/files/tcx_encoder.dart';

export '../../../infrastructure/files/gpx_encoder.dart' show GpxExportUnsupported;

/// Local file export service.
///
/// Encodes a [Ride] into the requested format and writes it to the given
/// [baseDirectory] (typically the app's documents directory).
class ExportService {
  final FitEncoder _fitEncoder;
  final TcxEncoder _tcxEncoder;
  final GpxEncoder _gpxEncoder;

  ExportService({
    FitEncoder? fitEncoder,
    TcxEncoder? tcxEncoder,
    GpxEncoder? gpxEncoder,
  })  : _fitEncoder = fitEncoder ?? FitEncoder(),
        _tcxEncoder = tcxEncoder ?? TcxEncoder(),
        _gpxEncoder = gpxEncoder ?? GpxEncoder();

  /// Exports [ride] to a file in [baseDirectory].
  ///
  /// Returns the created [File]. The filename is derived from the ride's
  /// start time and id (e.g. `2025-01-15_abc123.fit`).
  ///
  /// [route] is required for [ExportFormat.gpx] — GPX track points need a
  /// position, which for indoor OpenBike rides only exists when the ride
  /// followed a simulated route. Throws [GpxExportUnsupported] if omitted
  /// or if the ride/route can't be placed on a track.
  Future<File> exportToFile(
    Ride ride,
    ExportFormat format, {
    required String baseDirectory,
    Watts? ftp,
    Route? route,
  }) async {
    final datePrefix = _datePrefix(ride.startTime);
    final shortId = ride.id.length > 8 ? ride.id.substring(0, 8) : ride.id;

    switch (format) {
      case ExportFormat.fit:
        final bytes = encodeFit(ride, ftp: ftp);
        final file = File('$baseDirectory/${datePrefix}_$shortId.fit');
        await file.writeAsBytes(bytes);
        return file;

      case ExportFormat.tcx:
        final xml = encodeTcx(ride);
        final file = File('$baseDirectory/${datePrefix}_$shortId.tcx');
        await file.writeAsString(xml);
        return file;

      case ExportFormat.gpx:
        if (route == null) {
          throw GpxExportUnsupported(
            'GPX export requires route data — only available for simulated '
            'route rides. Use FIT or TCX for indoor rides without a route.',
          );
        }
        final xml = encodeGpx(ride, route);
        final file = File('$baseDirectory/${datePrefix}_$shortId.gpx');
        await file.writeAsString(xml);
        return file;
    }
  }

  /// Encodes [ride] to FIT binary.
  Uint8List encodeFit(Ride ride, {Watts? ftp}) =>
      _fitEncoder.encode(ride, ftp: ftp);

  /// Encodes [ride] to TCX XML string.
  String encodeTcx(Ride ride) => _tcxEncoder.encode(ride);

  /// Encodes [ride] to GPX XML string, placing readings on [route]'s geometry.
  String encodeGpx(Ride ride, Route route) => _gpxEncoder.encode(ride, route);

  String _datePrefix(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
