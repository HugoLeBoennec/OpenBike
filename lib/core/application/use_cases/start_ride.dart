import 'package:uuid/uuid.dart';
import '../../domain/entities/ride.dart';
import '../../domain/ports/storage_port.dart';

class StartRide {
  final StoragePort _storage;
  final Uuid _uuid;

  StartRide(this._storage, {Uuid? uuid}) : _uuid = uuid ?? Uuid();

  Future<Ride> call() async {
    final ride = Ride(
      id: _uuid.v4(),
      startTime: DateTime.now(),
      status: RideStatus.active,
    );
    await _storage.saveRide(ride);
    return ride;
  }
}
