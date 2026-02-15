import '../../core/domain/entities/ride.dart';
import '../../core/domain/ports/export_port.dart';

class StravaClient implements ExportPort {
  String? _accessToken;

  @override
  String get serviceName => 'Strava';

  @override
  Future<bool> get isAuthenticated async => _accessToken != null;

  @override
  Future<bool> authenticate() async {
    // TODO: Implement OAuth2 flow for Strava
    return false;
  }

  @override
  Future<void> uploadRide(Ride ride) async {
    // TODO: POST to https://www.strava.com/api/v3/uploads
  }
}
