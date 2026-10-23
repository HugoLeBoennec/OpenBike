import '../entities/ftp_history_entry.dart';
import '../entities/lap.dart';
import '../entities/personal_record.dart';
import '../entities/ride.dart';
import '../entities/saved_route.dart';
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
  ///
  /// Leaves [Ride.routeId] as stored: only [linkRideToRoute] sets it, so a
  /// later save of the engine's copy (which never has one) can't clear it.
  Future<void> saveRide(Ride ride, {Watts? ftp});
  Future<List<Ride>> getRides();
  Future<Ride?> getRide(String id);
  Future<void> deleteRide(String id);

  // --- Workouts ---

  Future<void> saveWorkout(Workout workout);
  Future<List<Workout>> getWorkouts();
  Future<void> deleteWorkout(String id);

  // --- Sensor readings ---

  /// Appends [readings] to the ride's. A reading at a timestamp the ride
  /// already has is skipped, so saving the same reading twice keeps one copy.
  Future<void> saveSensorReadings(String rideId, List<SensorReading> readings);
  Future<List<SensorReading>> getSensorReadings(String rideId);

  // --- Laps ---

  Future<void> saveLaps(String rideId, List<Lap> laps);
  Future<List<Lap>> getLaps(String rideId);

  // --- User profile ---

  /// Saving a profile whose FTP differs from the last recorded value (or
  /// when no FTP history exists yet) also appends a dated entry to the FTP
  /// history so past rides keep scoring against the FTP in effect back then.
  ///
  /// [ftpSource] tags that history entry with where the number came from; it
  /// defaults to [FtpSource.manual], so only callers that actually measured
  /// an FTP (the post-test prompt) reset the retest clock.
  Future<void> saveProfile(
    UserProfile profile, {
    FtpSource ftpSource = FtpSource.manual,
  });
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

  /// Removes the entry recorded at [effectiveDate] — a test result the rider
  /// doesn't trust. The profile FTP is the caller's to restore.
  Future<void> deleteFtpHistoryEntry(DateTime effectiveDate);

  // --- Saved routes (route library) ---

  /// Saves [route] with its GPX file, replacing a route with the same id.
  Future<void> saveRoute(SavedRoute route, String gpx);

  /// Every saved route, without GPX text, with [SavedRoute.rideCount] and
  /// [SavedRoute.lastRiddenAt] taken from the rides linked to it.
  Future<List<SavedRoute>> getSavedRoutes();

  /// The GPX file of the route [id], or null if there is no such route.
  Future<String?> getRouteGpx(String id);

  Future<void> renameRoute(String id, String name);

  /// Deletes the route [id]. Rides that followed it are kept and lose their
  /// link to it.
  Future<void> deleteRoute(String id);

  /// Records that the ride [rideId] followed the saved route [routeId].
  Future<void> linkRideToRoute(String rideId, String routeId);
}
