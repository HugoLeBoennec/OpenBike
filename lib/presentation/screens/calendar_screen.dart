import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/domain/entities/entities.dart';
import '../models/ride_extra.dart';
import '../state/providers.dart';
import '../widgets/workout_mini_profile.dart';

/// Training calendar — month grid + day list. Tap a day to schedule a
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.black,
      ),
      body: scheduledAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white30)),
        error: (e, _) => Center(
            child:
                Text('Error: $e', style: const TextStyle(color: Colors.red))),
        data: (scheduled) {
          final byDay = <DateTime, List<ScheduledWorkout>>{};
          for (final s in scheduled) {
            final day = _dateOnly(s.date);
            byDay.putIfAbsent(day, () => []).add(s);
          }

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
                scheduledByDay: byDay,
                onDayTap: (day) => setState(() => _selectedDay = day),
              ),
              const Divider(color: Color(0xFF222222), height: 1),
              Expanded(
                child: _DayList(
                  day: _selectedDay,
                  scheduled: byDay[_selectedDay] ?? const [],
                  workouts: workouts,
                  onStartNow: (s, workout) => _startNow(context, s, workout),
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _startNow(BuildContext context, ScheduledWorkout scheduled, Workout workout) {
    context.go(
      '/ride',
      extra: RideExtra(workout: workout, scheduledWorkoutId: scheduled.id),
    );
  }

  void _showScheduleSheet(BuildContext context) {
    final workouts = ref.read(workoutListProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
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
                  style: const TextStyle(
                      color: Colors.white,
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
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        '${w.totalDuration.inMinutes} min',
                        style: const TextStyle(color: Colors.white54),
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
            icon: const Icon(Icons.chevron_left, color: Colors.white54),
            onPressed: onPrev,
          ),
          Text(
            '${_months[month.month - 1]} ${month.year}',
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          IconButton(
            key: const Key('nextMonthButton'),
            icon: const Icon(Icons.chevron_right, color: Colors.white54),
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
    required this.scheduledByDay,
    required this.onDayTap,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Map<DateTime, List<ScheduledWorkout>> scheduledByDay;
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
              day: day,
              isSelected: date == selectedDay,
              isToday: date == todayOnly,
              hasScheduled: scheduledByDay.containsKey(date),
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
                          style: const TextStyle(color: Colors.white38, fontSize: 11)),
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
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasScheduled,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool hasScheduled;
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
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              if (hasScheduled)
                Container(
                  margin: const EdgeInsets.only(top: 1),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.blue,
                    shape: BoxShape.circle,
                  ),
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
    required this.scheduled,
    required this.workouts,
    required this.onStartNow,
    required this.onDelete,
  });

  final DateTime day;
  final List<ScheduledWorkout> scheduled;
  final List<Workout> workouts;
  final void Function(ScheduledWorkout scheduled, Workout workout) onStartNow;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    if (scheduled.isEmpty) {
      return const Center(
        child: Text(
          'Nothing scheduled.\nTap + to plan a workout.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: scheduled.length,
      itemBuilder: (context, index) {
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
    required this.onStartNow,
    required this.onDelete,
  });

  final ScheduledWorkout scheduled;
  final Workout? workout;
  final VoidCallback? onStartNow;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDone = scheduled.completedRideId != null;
    return Container(
      key: Key('scheduledTile-${scheduled.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: workout == null
            ? const Icon(Icons.fitness_center, color: Colors.white24)
            : SizedBox(
                width: 40,
                height: 28,
                child: WorkoutMiniProfile(steps: workout!.steps),
              ),
        title: Text(
          workout?.name ?? 'Unknown workout',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: scheduled.notes != null
            ? Text(scheduled.notes!,
                style: const TextStyle(color: Colors.white54, fontSize: 12))
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
                  if (onStartNow != null)
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
                    icon: const Icon(Icons.close, color: Colors.white24, size: 18),
                    onPressed: onDelete,
                  ),
                ],
              ),
      ),
    );
  }
}
