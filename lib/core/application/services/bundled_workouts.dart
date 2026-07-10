import '../../domain/entities/workout.dart';
import '../../domain/ports/storage_port.dart';
import 'workout_builder.dart';

/// Public-domain workout *structures* (2×20 @ sweet spot, over-unders, VO2
/// intervals, etc.) plus the two bundled FTP test protocols, seeded into the
/// DB on first run.
///
/// Names/descriptions are generic — no branded workout names or copyrighted
/// plan text is copied from any commercial app.
class BundledWorkouts {
  BundledWorkouts._();

  /// Fixed ID for the ramp FTP test — used by the ride screen to flag the
  /// post-ride FTP-detection prompt (see `activeFtpTestProvider`).
  static const rampTestId = 'bundled-ftp-ramp-test';

  /// Fixed ID for the 20-minute FTP test.
  static const twentyMinTestId = 'bundled-ftp-20min-test';

  /// Inserts every bundled workout that isn't already present (by id).
  /// Idempotent — safe to call on every app start; never overwrites a
  /// workout a user has since edited under the same id.
  static Future<void> seedIfNeeded(StoragePort storage) async {
    final existingIds = (await storage.getWorkouts()).map((w) => w.id).toSet();
    for (final workout in all) {
      if (!existingIds.contains(workout.id)) {
        await storage.saveWorkout(workout);
      }
    }
  }

  static List<Workout> get all => [
        _recoverySpin,
        _enduranceBase,
        _tempo3x15,
        _sweetSpot3x12,
        _sweetSpot2x20,
        _threshold4x8,
        _overUnders,
        _vo2max5x3,
        _vo2max6x4,
        _anaerobic8x30,
        _hillRepeats6x5,
        _pyramid,
        rampTest,
        twentyMinTest,
      ];

  // ---------------------------------------------------------------------------
  // Endurance / recovery
  // ---------------------------------------------------------------------------

  static final _recoverySpin = WorkoutBuilder(
    'Recovery Spin',
    description: 'Easy 30-minute spin to flush the legs.',
  ).steady(duration: 1800, percent: 50, cadence: 90).build().copyWith(
        id: 'bundled-recovery-spin',
      );

  static final _enduranceBase = WorkoutBuilder(
    'Endurance Base',
    description: '60 minutes of steady zone-2 riding.',
  )
      .warmup(duration: 300, fromPercent: 40, toPercent: 65)
      .steady(duration: 3000, percent: 65, cadence: 88)
      .cooldown(duration: 300, fromPercent: 65, toPercent: 40)
      .build()
      .copyWith(id: 'bundled-endurance-base');

  static final _tempo3x15 = WorkoutBuilder(
    'Tempo 3x15',
    description: 'Three 15-minute tempo blocks with short recoveries.',
  )
      .warmup(duration: 600, fromPercent: 40, toPercent: 70)
      .intervals(
        repeat: 3,
        onDuration: 900,
        offDuration: 300,
        onPercent: 76,
        offPercent: 55,
      )
      .cooldown(duration: 300, fromPercent: 65, toPercent: 40)
      .build()
      .copyWith(id: 'bundled-tempo-3x15');

  // ---------------------------------------------------------------------------
  // Sweet spot / threshold
  // ---------------------------------------------------------------------------

  static final _sweetSpot3x12 = WorkoutBuilder(
    'Sweet Spot 3x12',
    description: 'Three 12-minute sweet-spot blocks, 5 minutes easy between.',
  )
      .warmup(duration: 600, fromPercent: 40, toPercent: 75)
      .intervals(
        repeat: 3,
        onDuration: 720,
        offDuration: 300,
        onPercent: 90,
        offPercent: 55,
      )
      .cooldown(duration: 300, fromPercent: 65, toPercent: 40)
      .build()
      .copyWith(id: 'bundled-sweet-spot-3x12');

  static final _sweetSpot2x20 = WorkoutBuilder(
    'Sweet Spot 2x20',
    description: 'Two 20-minute sweet-spot blocks with a short recovery.',
  )
      .warmup(duration: 600, fromPercent: 40, toPercent: 75)
      .steady(duration: 1200, percent: 90, cadence: 90)
      .steady(duration: 300, percent: 55)
      .steady(duration: 1200, percent: 90, cadence: 90)
      .cooldown(duration: 300, fromPercent: 65, toPercent: 40)
      .build()
      .copyWith(id: 'bundled-sweet-spot-2x20');

  static final _threshold4x8 = WorkoutBuilder(
    'Threshold 4x8',
    description: 'Four 8-minute blocks at FTP, 4 minutes easy between.',
  )
      .warmup(duration: 600, fromPercent: 40, toPercent: 80)
      .intervals(
        repeat: 4,
        onDuration: 480,
        offDuration: 240,
        onPercent: 100,
        offPercent: 55,
      )
      .cooldown(duration: 300, fromPercent: 65, toPercent: 40)
      .build()
      .copyWith(id: 'bundled-threshold-4x8');

  static final _overUnders = WorkoutBuilder(
    'Over-Unders 12x4',
    description:
        '12 x (2 min just above FTP, 2 min just below) to build threshold resilience.',
  )
      .warmup(duration: 600, fromPercent: 40, toPercent: 85)
      .intervals(
        repeat: 12,
        onDuration: 120,
        offDuration: 120,
        onPercent: 105,
        offPercent: 88,
      )
      .cooldown(duration: 300, fromPercent: 65, toPercent: 40)
      .build()
      .copyWith(id: 'bundled-over-unders-12x4');

  // ---------------------------------------------------------------------------
  // VO2 / anaerobic
  // ---------------------------------------------------------------------------

  static final _vo2max5x3 = WorkoutBuilder(
    'VO2 Max 5x3',
    description: 'Five 3-minute intervals at VO2max, 3 minutes easy between.',
  )
      .warmup(duration: 600, fromPercent: 40, toPercent: 85)
      .intervals(
        repeat: 5,
        onDuration: 180,
        offDuration: 180,
        onPercent: 120,
        offPercent: 50,
      )
      .cooldown(duration: 300, fromPercent: 65, toPercent: 40)
      .build()
      .copyWith(id: 'bundled-vo2max-5x3');

  static final _vo2max6x4 = WorkoutBuilder(
    'VO2 Max 6x4',
    description: 'Six 4-minute intervals at VO2max, 4 minutes easy between.',
  )
      .warmup(duration: 600, fromPercent: 40, toPercent: 85)
      .intervals(
        repeat: 6,
        onDuration: 240,
        offDuration: 240,
        onPercent: 115,
        offPercent: 50,
      )
      .cooldown(duration: 300, fromPercent: 65, toPercent: 40)
      .build()
      .copyWith(id: 'bundled-vo2max-6x4');

  static final _anaerobic8x30 = WorkoutBuilder(
    'Anaerobic Capacity 8x30s',
    description: 'Eight 30-second all-out efforts, 90 seconds easy between.',
  )
      .warmup(duration: 600, fromPercent: 40, toPercent: 85)
      .intervals(
        repeat: 8,
        onDuration: 30,
        offDuration: 90,
        onPercent: 150,
        offPercent: 40,
      )
      .cooldown(duration: 300, fromPercent: 65, toPercent: 40)
      .build()
      .copyWith(id: 'bundled-anaerobic-8x30');

  static final _hillRepeats6x5 = WorkoutBuilder(
    'Hill Repeats 6x5min',
    description: 'Six 5-minute hard efforts simulating climbs, 3 minutes easy between.',
  )
      .warmup(duration: 600, fromPercent: 40, toPercent: 80)
      .intervals(
        repeat: 6,
        onDuration: 300,
        offDuration: 180,
        onPercent: 95,
        offPercent: 50,
        cadence: 70,
      )
      .cooldown(duration: 300, fromPercent: 65, toPercent: 40)
      .build()
      .copyWith(id: 'bundled-hill-repeats-6x5');

  static final _pyramid = WorkoutBuilder(
    'Pyramid',
    description: 'Ascending then descending steady blocks through the zones.',
  )
      .warmup(duration: 300, fromPercent: 40, toPercent: 65)
      .steady(duration: 180, percent: 70)
      .steady(duration: 180, percent: 80)
      .steady(duration: 180, percent: 90)
      .steady(duration: 180, percent: 100)
      .steady(duration: 180, percent: 90)
      .steady(duration: 180, percent: 80)
      .steady(duration: 180, percent: 70)
      .cooldown(duration: 300, fromPercent: 65, toPercent: 40)
      .build()
      .copyWith(id: 'bundled-pyramid');

  // ---------------------------------------------------------------------------
  // FTP tests
  // ---------------------------------------------------------------------------

  /// Ramp test: ~1-minute steps rising by a fixed increment until failure.
  ///
  /// The spec is stated in absolute terms (start 100 W, +20 W/min) — since
  /// [WorkoutStep] targets are %FTP, the steps below express that same ramp
  /// relative to the app's default 200 W FTP fallback (50% start, +10%/min);
  /// at any other current FTP the ramp scales proportionally, which is the
  /// expected behavior for an ERG target expressed as %FTP. 25 one-minute
  /// steps (up to 290%) comfortably outlasts any rider — they stop the ride
  /// when they fail, and post-ride FTP detection uses their best 1-minute
  /// power regardless of which step they reached.
  static final Workout rampTest = () {
    var builder = WorkoutBuilder(
      'Ramp Test',
      description: 'Steps up every minute until you can no longer hold cadence.',
    );
    for (var i = 0; i < 25; i++) {
      builder = builder.steady(duration: 60, percent: 50 + i * 10);
    }
    return builder.build().copyWith(id: rampTestId);
  }();

  static final Workout twentyMinTest = WorkoutBuilder(
    '20-Minute Test',
    description: 'Warm up, then a maximal 20-minute steady effort.',
  )
      .warmup(duration: 600, fromPercent: 40, toPercent: 75)
      .freeRide(duration: 1200)
      .cooldown(duration: 300, fromPercent: 65, toPercent: 40)
      .build()
      .copyWith(id: twentyMinTestId);
}
