import '../entities/lap.dart';
import '../entities/ride.dart';
import '../entities/sensor_reading.dart';
import '../entities/user_profile.dart';
import '../entities/workout.dart';

abstract class StoragePort {
  // --- Rides ---

  Future<void> saveRide(Ride ride);
  Future<List<Ride>> getRides();
  Future<Ride?> getRide(String id);
  Future<void> deleteRide(String id);

  // --- Workouts ---

  Future<void> saveWorkout(Workout workout);
  Future<List<Workout>> getWorkouts();
  Future<void> deleteWorkout(String id);

  // --- Sensor readings ---

  Future<void> saveSensorReadings(String rideId, List<SensorReading> readings);
  Future<List<SensorReading>> getSensorReadings(String rideId);

  // --- Laps ---

  Future<void> saveLaps(String rideId, List<Lap> laps);
  Future<List<Lap>> getLaps(String rideId);

  // --- User profile ---

  Future<void> saveProfile(UserProfile profile);
  Future<UserProfile?> getProfile();
}
