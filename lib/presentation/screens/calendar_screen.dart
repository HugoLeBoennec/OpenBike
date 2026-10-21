import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/start_ride_actions.dart';
import '../widgets/workout_mini_profile.dart';

/// Training calendar — month grid + day list, with the rides done on each
/// day alongside the plan: dots are green when done, red when a planned
/// workout was missed, blue when it's still ahead. Tap a day to schedule a
/// workout from the library; scheduled entries can be started directly or
/// show the ride they were completed with.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _monthCursor = _dateOnly(DateTime.now());
  DateTime _selectedDay = _dateOnly(DateTime.now());

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  Widget build(BuildContext context) {
    final scheduledAsync = ref.watch(scheduledWorkoutsProvider);
    final workouts = ref.watch(workoutListProvider);
    final ftp = ref.watch(ftpProvider);
    // Rides fill in once loaded; the plan doesn't wait for them.
    final rides = [
      for (final r in ref.watch(rideHistoryProvider).valueOrNull ?? const <Ride>[])
        if (r.status == RideStatus.finished) r,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: scheduledAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child:
                Text('Error: $e', style: const TextStyle(color: Colors.red))),
        data: (scheduled) {
          final byDay = <DateTime, List<ScheduledWorkout>>{};
          for (final s in scheduled) {
            final day = _dateOnly(s.date);
            byDay.putIfAbsent(day, () => []).add(s);
          }

          // A ride linked to a plan already shows as that plan's ✓.
          final linkedRideIds = {
            for (final s in scheduled)
              if (s.completedRideId != null) s.completedRideId!,
          };
          final ridesByDay = <DateTime, List<Ride>>{};
          for (final r in rides) {
            if (linkedRideIds.contains(r.id)) continue;
            ridesByDay.putIfAbsent(_dateOnly(r.startTime), () => []).add(r);
          }

          final today = _dateOnly(DateTime.now());
          final markersByDay = <DateTime, List<_PlanStatus>>{};
          byDay.forEach((day, entries) {
            markersByDay[day] = [
              for (final s in entries) _PlanStatus.of(s, today),
            ];
          });
          ridesByDay.forEach((day, dayRides) {
            markersByDay.putIfAbsent(day, () => []).addAll(
                List.filled(dayRides.length, _PlanStatus.done));
          });

          return Column(
            children: [
              _MonthHeader(
                month: _monthCursor,
                onPrev: () => setState(() {
                  _monthCursor =
                      DateTime(_monthCursor.year, _monthCursor.month - 1);
                }),
                onNext: () => setState(() {
                  _monthCursor =
                      DateTime(_monthCursor.year, _monthCursor.month + 1);
                }),
              ),
              _MonthGrid(
                month: _monthCursor,
                selectedDay: _selectedDay,
                markersByDay: markersByDay,
                onDayTap: (day) => setState(() => _selectedDay = day),
              ),
              Divider(color: context.tokens.surfaceTier3Line, height: 1),
              Expanded(
                child: _DayList(
                  day: _selectedDay,
                  isPast: _selectedDay.isBefore(today),
                  scheduled: byDay[_selectedDay] ?? const [],
                  rides: ridesByDay[_selectedDay] ?? const [],
                  ftp: ftp,
                  workouts: workouts,
                  onOpenRide: (id) => context.push('/history/$id'),
                  onStartNow: (s, workout) => startWorkoutRide(
                    context,
                    ref,
                    workout,
                    scheduledWorkoutId: s.id,
                  ),
                  onDelete: (id) =>
                      ref.read(storageProvider).deleteScheduledWorkout(id).then(
                            (_) => ref.invalidate(scheduledWorkoutsProvider),
                          ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('scheduleWorkoutFab'),
        backgroundColor: Colors.blue,
        onPressed: workouts.isEmpty ? null : () => _showScheduleSheet(context),
        child: Icon(Icons.add, color: context.tokens.textPrimary),
      ),
    );
  }

  void _showScheduleSheet(BuildContext context) {
    final workouts = ref.read(workoutListProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.tokens.surfaceTier2,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.6,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Schedule for ${_formatDate(_selectedDay)}',
                  style: TextStyle(
                      color: context.tokens.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final w = workouts[index];
                    return ListTile(
                      leading: SizedBox(
                        width: 40,
                        height: 28,
                        child: WorkoutMiniProfile(steps: w.steps),
                      ),
                      title: Text(w.name,
                          style: TextStyle(color: context.tokens.textPrimary)),
                      subtitle: Text(
                        '${w.totalDuration.inMinutes} min',
                        style: TextStyle(color: context.tokens.textTertiary),
                      ),
                      onTap: () async {
                        Navigator.pop(ctx);
                        await ref.read(storageProvider).saveScheduledWorkout(
                              ScheduledWorkout(
                                id: const Uuid().v4(),
                                workoutId: w.id,
                                date: _selectedDay,
                              ),
                            );
                        ref.invalidate(scheduledWorkoutsProvider);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

// ---------------------------------------------------------------------------
// Month header
// ---------------------------------------------------------------------------

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            key: const Key('prevMonthButton'),
            icon: Icon(Icons.chevron_left, color: context.tokens.textTertiary),
            onPressed: onPrev,
          ),
          Text(
            '${_months[month.month - 1]} ${month.year}',
            style: TextStyle(
                color: context.tokens.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          IconButton(
            key: const Key('nextMonthButton'),
            icon: Icon(Icons.chevron_right, color: context.tokens.textTertiary),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Month grid
// ---------------------------------------------------------------------------

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectedDay,
    required this.markersByDay,
    required this.onDayTap,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Map<DateTime, List<_PlanStatus>> markersByDay;
  final ValueChanged<DateTime> onDayTap;

  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    // Monday-start grid: weekday 1=Mon..7=Sun.
    final leadingBlanks = firstOfMonth.weekday - 1;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // One cell per day, plus leading blanks so the 1st lands on its weekday.
    final dayCells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const Expanded(child: SizedBox.shrink()),
      for (var day = 1; day <= daysInMonth; day++)
        Expanded(
          child: Builder(builder: (_) {
            final date = DateTime(month.year, month.month, day);
            return _DayCell(
              key: Key('calendarDay-${date.year}-${date.month}-${date.day}'),
              day: day,
              isSelected: date == selectedDay,
              isToday: date == todayOnly,
              markers: markersByDay[date] ?? const [],
              onTap: () => onDayTap(date),
            );
          }),
        ),
    ];

    // Split into fixed-height weeks (7 cells per row) — avoids GridView's
    // square-aspect-ratio default blowing up row height on wide screens.
    final weekRows = <Widget>[];
    for (var i = 0; i < dayCells.length; i += 7) {
      final week = dayCells.sublist(i, (i + 7).clamp(0, dayCells.length));
      while (week.length < 7) {
        week.add(const Expanded(child: SizedBox.shrink()));
      }
      weekRows.add(SizedBox(
        height: 40,
        child: Row(children: week),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: Row(
              children: [
                for (final label in _weekdayLabels)
                  Expanded(
                    child: Center(
                      child: Text(label,
                          style: TextStyle(color: context.tokens.textDisabled, fontSize: 11)),
                    ),
                  ),
              ],
            ),
          ),
          ...weekRows,
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.markers,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isToday;

  /// One dot per plan or ride on the day, up to three.
  final List<_PlanStatus> markers;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepOrange : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday && !isSelected
                ? Border.all(color: Colors.deepOrange, width: 1)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  color: isSelected ? context.tokens.textPrimary : context.tokens.textSecondary,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              if (markers.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final status in markers.take(3))
                      Container(
                        margin: const EdgeInsets.only(top: 1, left: 1, right: 1),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          // On the orange selection, white reads better than
                          // red or green.
                          color: isSelected
                              ? context.tokens.textPrimary
                              : status.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day list
// ---------------------------------------------------------------------------

class _DayList extends StatelessWidget {
  const _DayList({
    required this.day,
    required this.isPast,
    required this.scheduled,
    required this.rides,
    required this.ftp,
    required this.workouts,
    required this.onOpenRide,
    required this.onStartNow,
    required this.onDelete,
  });

  final DateTime day;

  /// Before today — a plan still open on such a day was missed.
  final bool isPast;
  final List<ScheduledWorkout> scheduled;

  /// Rides on the day that aren't the completion of one of [scheduled].
  final List<Ride> rides;
  final Watts ftp;
  final List<Workout> workouts;
  final ValueChanged<String> onOpenRide;
  final void Function(ScheduledWorkout scheduled, Workout workout) onStartNow;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    if (scheduled.isEmpty && rides.isEmpty) {
      return Center(
        child: Text(
          'Nothing scheduled.\nTap + to plan a workout.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.tokens.textDisabled, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: scheduled.length + rides.length,
      itemBuilder: (context, index) {
        if (index >= scheduled.length) {
          final ride = rides[index - scheduled.length];
          return _RideTile(
            ride: ride,
            ftp: ftp,
            onTap: () => onOpenRide(ride.id),
          );
        }
        final s = scheduled[index];
        Workout? workout;
        for (final w in workouts) {
          if (w.id == s.workoutId) {
            workout = w;
            break;
          }
        }
        return _ScheduledTile(
          scheduled: s,
          workout: workout,
          isMissed: isPast && s.completedRideId == null,
          onStartNow: workout == null ? null : () => onStartNow(s, workout!),
          onDelete: () => onDelete(s.id),
        );
      },
    );
  }
}

class _ScheduledTile extends StatelessWidget {
  const _ScheduledTile({
    required this.scheduled,
    required this.workout,
    required this.isMissed,
    required this.onStartNow,
    required this.onDelete,
  });

  final ScheduledWorkout scheduled;
  final Workout? workout;

  /// Planned for a day that has passed and never ridden.
  final bool isMissed;
  final VoidCallback? onStartNow;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDone = scheduled.completedRideId != null;
    return Container(
      key: Key('scheduledTile-${scheduled.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: context.tokens.surfaceTier2,
        borderRadius: BorderRadius.circular(12),
      ),
      // Transparent Material so ListTile's ink draws above this
      // container's background instead of being hidden by it.
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: workout == null
              ? Icon(Icons.fitness_center, color: context.tokens.textDisabled)
              : SizedBox(
                  width: 40,
                  height: 28,
                  child: WorkoutMiniProfile(steps: workout!.steps),
                ),
          title: Text(
            workout?.name ?? 'Unknown workout',
            style: TextStyle(color: context.tokens.textPrimary, fontWeight: FontWeight.w600),
          ),
          subtitle: scheduled.notes != null
              ? Text(scheduled.notes!,
                  style: TextStyle(color: context.tokens.textTertiary, fontSize: 12))
              : null,
          trailing: isDone
              ? GestureDetector(
                  onTap: () =>
                      context.push('/history/${scheduled.completedRideId}'),
                  child: const Icon(Icons.check_circle, color: Colors.green),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isMissed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _PlanStatus.missed.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Missed',
                          style: TextStyle(
                            color: _PlanStatus.missed.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else if (onStartNow != null)
                      FilledButton(
                        onPressed: onStartNow,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('Start', style: TextStyle(fontSize: 12)),
                      ),
                    IconButton(
                      icon: Icon(Icons.close, color: context.tokens.textDisabled, size: 18),
                      onPressed: onDelete,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plan status + ride tile
// ---------------------------------------------------------------------------

/// Where a day's plan stands — the color of its dot in the month grid.
enum _PlanStatus {
  done(Colors.green),
  missed(Colors.redAccent),
  planned(Colors.blue);

  const _PlanStatus(this.color);
  final Color color;

  static _PlanStatus of(ScheduledWorkout scheduled, DateTime today) {
    if (scheduled.completedRideId != null) return done;
    final day = DateTime(
        scheduled.date.year, scheduled.date.month, scheduled.date.day);
    return day.isBefore(today) ? missed : planned;
  }
}

/// A ride done on the day that wasn't one of its plans — opens the ride.
class _RideTile extends StatelessWidget {
  const _RideTile({required this.ride, required this.ftp, required this.onTap});

  final Ride ride;
  final Watts ftp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final start = ride.startTime;
    final time = '${start.hour.toString().padLeft(2, '0')}:'
        '${start.minute.toString().padLeft(2, '0')}';
    final minutes = ride.activeDuration.inMinutes;
    final tss = ride.tss(ftp).round();
    return Container(
      key: Key('calendarRide-${ride.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: context.tokens.surfaceTier2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(Icons.pedal_bike, color: _PlanStatus.done.color),
          title: Text(
            'Ride · $time',
            style: TextStyle(
                color: context.tokens.textPrimary, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '$minutes min · $tss TSS',
            style: TextStyle(color: context.tokens.textTertiary, fontSize: 12),
          ),
          trailing: Icon(Icons.chevron_right,
              color: context.tokens.textDisabled),
          onTap: onTap,
        ),
      ),
    );
  }
}
