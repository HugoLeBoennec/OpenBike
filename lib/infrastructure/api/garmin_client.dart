import '../../core/domain/entities/ride.dart';
import '../../core/domain/ports/export_port.dart';

class GarminClient implements ExportPort {
  String? _accessToken;

  @override
  String get serviceName => 'Garmin Connect';

  @override
  Future<bool> get isAuthenticated async => _accessToken != null;

  @override
  Future<bool> authenticate() async {
    // TODO: Implement OAuth2 flow for Garmin Connect
    return false;
  }

  @override
  Future<void> uploadRide(Ride ride) async {
    // TODO: Upload FIT file to Garmin Connect API
  }
}
