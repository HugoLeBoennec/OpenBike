import '../entities/ftp_history_entry.dart';
import '../entities/lap.dart';
import '../entities/personal_record.dart';
import '../entities/ride.dart';
import '../entities/scheduled_workout.dart';
import '../entities/sensor_reading.dart';
import '../entities/user_profile.dart';
import '../entities/workout.dart';
import '../value_objects/value_objects.dart';

abstract class StoragePort {
  // --- Rides ---

  /// Saves [ride]. Pass [ftp] (the FTP in effect right now) to also compute
  /// and persist TSS / IF / the FTP-at-time snapshot for this ride — done on
  /// [RecordingEngine.stop], skipped for in-progress saves (start/autosave).
  Future<void> saveRide(Ride ride, {Watts? ftp});
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

  /// Saving a profile whose FTP differs from the last recorded value (or
  /// when no FTP history exists yet) also appends a dated entry to the FTP
  /// history so past rides keep scoring against the FTP in effect back then.
  Future<void> saveProfile(UserProfile profile);
  Future<UserProfile?> getProfile();

  // --- Scheduled workouts (training calendar) ---

  Future<void> saveScheduledWorkout(ScheduledWorkout scheduled);
  Future<List<ScheduledWorkout>> getScheduledWorkouts();
  Future<void> deleteScheduledWorkout(String id);

  /// Links a finished ride back to the scheduled entry it was started from.
  Future<void> linkCompletedRide(String scheduledWorkoutId, String rideId);

  // --- Personal records (mean-max power cache) ---

  Future<void> savePersonalRecords(List<PersonalRecord> records);
  Future<List<PersonalRecord>> getPersonalRecords();

  // --- FTP history ---

  Future<List<FtpHistoryEntry>> getFtpHistory();
}
