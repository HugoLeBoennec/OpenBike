import '../../core/domain/entities/ride.dart';
import '../../core/domain/ports/export_port.dart';

class TrainingPeaksClient implements ExportPort {
  String? _accessToken;

  @override
  String get serviceName => 'TrainingPeaks';

  @override
  Future<bool> get isAuthenticated async => _accessToken != null;

  @override
  Future<bool> authenticate() async {
    // TODO: Implement OAuth2 flow for TrainingPeaks
    return false;
  }

  @override
  Future<void> uploadRide(Ride ride) async {
    // TODO: Upload to TrainingPeaks API
  }
}
