import '../../core/domain/entities/ride.dart';
import '../../core/domain/ports/export_port.dart';

class GarminClient implements ExportPort {
  // ignore: unused_field
  String? _accessToken;

  @override
  Future<void> authenticate() async {
    // TODO: Implement OAuth2 flow for Garmin Connect
  }

  @override
  Future<String> exportActivity(Ride ride, ExportFormat format) async {
    // TODO: Upload FIT file to Garmin Connect API
    return '';
  }

  @override
  Future<ExportStatus> checkStatus(String id) async {
    // TODO: Check upload status via Garmin API
    return ExportStatus.pending;
  }
}
