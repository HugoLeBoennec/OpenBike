import '../../core/domain/entities/ride.dart';
import '../../core/domain/ports/export_port.dart';

class TrainingPeaksClient implements ExportPort {
  // ignore: unused_field
  String? _accessToken;

  @override
  Future<void> authenticate() async {
    // TODO: Implement OAuth2 flow for TrainingPeaks
  }

  @override
  Future<String> exportActivity(Ride ride, ExportFormat format) async {
    // TODO: Upload to TrainingPeaks API
    return '';
  }

  @override
  Future<ExportStatus> checkStatus(String id) async {
    // TODO: Check upload status via TrainingPeaks API
    return ExportStatus.pending;
  }
}
