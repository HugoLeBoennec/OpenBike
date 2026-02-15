import '../../domain/entities/ride.dart';
import '../../domain/ports/storage_port.dart';

class StopRide {
  final StoragePort _storage;

  StopRide(this._storage);

  Future<Ride> call(Ride ride) async {
    final stopped = ride.copyWith(
      status: RideStatus.finished,
      endTime: DateTime.now(),
    );
    await _storage.saveRide(stopped);
    return stopped;
  }
}
