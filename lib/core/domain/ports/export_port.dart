import '../entities/ride.dart';

enum ExportFormat { fit, tcx, gpx }
enum ExportStatus { pending, processing, complete, error }

abstract class ExportPort {
  Future<void> authenticate();
  Future<String> exportActivity(Ride ride, ExportFormat format);
  Future<ExportStatus> checkStatus(String id);
}
