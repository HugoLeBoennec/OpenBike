import '../../core/domain/entities/ride.dart';
import '../../core/domain/ports/export_port.dart';

class StravaClient implements ExportPort {
  // ignore: unused_field
  String? _accessToken;

  @override
  Future<void> authenticate() async {
    // TODO: Implement OAuth2 flow for Strava
  }

  @override
  Future<String> exportActivity(Ride ride, ExportFormat format) async {
    // TODO: POST to https://www.strava.com/api/v3/uploads
    return '';
  }

  @override
  Future<ExportStatus> checkStatus(String id) async {
    // TODO: Check upload status via Strava API
    return ExportStatus.pending;
  }
}
