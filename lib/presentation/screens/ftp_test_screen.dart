import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/application/services/bundled_workouts.dart';
import '../../core/application/services/ftp_test_planner.dart';
import '../../core/domain/entities/entities.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../models/ride_extra.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';

/// Guided FTP testing — explains what the test measures, recommends a
/// protocol, walks through preparation, launches the test ride, and charts
/// the results over time.
///
/// FTP drives every workout target in the app, so a rider who never sets it
/// trains against the 200 W default forever. Beginners are the ones most
/// likely to be in that position and least likely to go looking for a test
/// buried in the workout list, which is why this is a destination of its own
/// rather than two more rows under Workouts.
class FtpTestScreen extends ConsumerStatefulWidget {
  const FtpTestScreen({super.key});

  @override
  ConsumerState<FtpTestScreen> createState() => _FtpTestScreenState();
}

class _FtpTestScreenState extends ConsumerState<FtpTestScreen> {
  /// Null until the rider picks — falls back to the plan's recommendation so
  /// the screen renders a selection before any interaction.
  FtpTestProtocol? _selected;

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(ftpTestPlanProvider);
    final historyAsync = ref.watch(ftpHistoryProvider);
    final ftp = ref.watch(ftpProvider);
    final tokens = context.tokens;

    final recommended = plan?.recommendedProtocol ?? FtpTestProtocol.ramp;
    final selected = _selected ?? recommended;

    return Scaffold(
      appBar: AppBar(title: const Text('FTP Test')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusCard(plan: plan, currentFtp: ftp),
          SizedBox(height: tokens.spacingLg),

          const _WhatIsFtpCard(),
          SizedBox(height: tokens.spacingLg),

          const _SectionLabel('CHOOSE A PROTOCOL'),
          SizedBox(height: tokens.spacingSm),
          for (final protocol in FtpTestProtocol.values) ...[
            _ProtocolCard(
              protocol: protocol,
              selected: protocol == selected,
              recommended: protocol == recommended,
              onTap: () => setState(() => _selected = protocol),
            ),
            SizedBox(height: tokens.spacingSm),
          ],
          SizedBox(height: tokens.spacingMd),

          const _PrepChecklist(),
          SizedBox(height: tokens.spacingLg),

          FilledButton.icon(
            key: const Key('startFtpTestButton'),
            onPressed: () => _startTest(selected),
            icon: const Icon(Icons.play_arrow),
            label: Text('Start ${selected.displayName}'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          SizedBox(height: tokens.spacingXl),

          const _SectionLabel('FTP OVER TIME'),
          SizedBox(height: tokens.spacingSm),
          historyAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Text(
              'Couldn\'t load FTP history: $e',
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
            data: (history) => _FtpProgression(history: history, plan: plan),
          ),
        ],
      ),
    );
  }

  Future<void> _startTest(FtpTestProtocol protocol) async {
    // The ramp holds you at a prescribed watt target that steps up every
    // minute — without trainer control there is nothing to drive those steps,
    // so the protocol simply doesn't work. The 20-minute test is a self-paced
    // free ride and only needs a power source.
    if (protocol == FtpTestProtocol.ramp &&
        ref.read(activeTrainerPortProvider) == null) {
      final connect = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Connect a trainer'),
          content: const Text(
            'The ramp test drives your trainer to a new target every minute, '
            'so it needs a smart trainer. With a power meter only, use the '
            '20-minute test instead — you set the pace yourself.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Connect Device'),
            ),
          ],
        ),
      );
      if (connect == true && mounted) context.push('/scan');
      return;
    }

    final workout = _workoutFor(protocol);
    if (!mounted) return;
    context.go('/ride', extra: RideExtra(workout: workout));
  }

  /// Prefers the saved copy so an edited protocol is honoured, falling back to
  /// the bundled definition when the list hasn't loaded (or the row was
  /// deleted). Either way the id matches, which is what makes [RideScreen] arm
  /// post-ride FTP detection.
  Workout _workoutFor(FtpTestProtocol protocol) {
    final id = protocol.workoutId;
    final saved = ref.read(workoutListProvider).where((w) => w.id == id);
    if (saved.isNotEmpty) return saved.first;
    return protocol == FtpTestProtocol.ramp
        ? BundledWorkouts.rampTest
        : BundledWorkouts.twentyMinTest;
  }
}

// ---------------------------------------------------------------------------
// Protocol presentation
// ---------------------------------------------------------------------------

extension _ProtocolDisplay on FtpTestProtocol {
  String get displayName => switch (this) {
        FtpTestProtocol.ramp => 'Ramp Test',
        FtpTestProtocol.twentyMinute => '20-Minute Test',
      };

  String get workoutId => switch (this) {
        FtpTestProtocol.ramp => BundledWorkouts.rampTestId,
        FtpTestProtocol.twentyMinute => BundledWorkouts.twentyMinTestId,
      };

  String get duration => switch (this) {
        FtpTestProtocol.ramp => '~20-25 min',
        FtpTestProtocol.twentyMinute => '~35 min',
      };

  String get summary => switch (this) {
        FtpTestProtocol.ramp =>
          'The trainer raises the target every minute. Hold on as long as you '
              'can, then stop — there is no pace to judge.',
        FtpTestProtocol.twentyMinute =>
          'Warm up, then ride 20 minutes as hard as you can hold. Your FTP is '
              '95% of that average.',
      };

  /// The honest trade-off, stated plainly — the ramp's convenience costs
  /// accuracy for riders with a big sprint, and pacing is exactly what a
  /// first-timer cannot yet do.
  String get tradeoff => switch (this) {
        FtpTestProtocol.ramp =>
          'Easy to execute and very repeatable. Can read high if you have a '
              'strong sprint.',
        FtpTestProtocol.twentyMinute =>
          'The more accurate result, but you have to pace it. Go out too hard '
              'and the number lands low.',
      };
}

class _ProtocolCard extends StatelessWidget {
  const _ProtocolCard({
    required this.protocol,
    required this.selected,
    required this.recommended,
    required this.onTap,
  });

  final FtpTestProtocol protocol;
  final bool selected;
  final bool recommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return InkWell(
      key: Key('protocol-${protocol.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tokens.surfaceTier2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.deepOrange : tokens.surfaceTier3Line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected ? Colors.deepOrange : tokens.textTertiary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    protocol.displayName,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  protocol.duration,
                  style: TextStyle(color: tokens.textTertiary, fontSize: 12),
                ),
              ],
            ),
            if (recommended) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'RECOMMENDED FOR YOU',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              protocol.summary,
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              protocol.tradeoff,
              style: TextStyle(
                color: tokens.textTertiary,
                fontSize: 12,
                height: 1.35,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status
// ---------------------------------------------------------------------------

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.plan, required this.currentFtp});

  final FtpTestPlan? plan;
  final Watts currentFtp;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final accent = _accent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surfaceTier2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${currentFtp.value.round()}',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'W',
                  style: TextStyle(color: tokens.textTertiary, fontSize: 16),
                ),
              ),
              const Spacer(),
              Icon(_icon, color: accent, size: 22),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'CURRENT FTP',
            style: TextStyle(
              color: tokens.textTertiary,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _headline,
            style: TextStyle(
              color: accent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _detail,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Color get _accent => switch (plan?.status) {
        FtpTestStatus.due => Colors.orangeAccent,
        FtpTestStatus.dueSoon => Colors.amberAccent,
        FtpTestStatus.upToDate => Colors.greenAccent,
        FtpTestStatus.neverTested || null => Colors.blueAccent,
      };

  IconData get _icon => switch (plan?.status) {
        FtpTestStatus.due => Icons.notifications_active,
        FtpTestStatus.dueSoon => Icons.schedule,
        FtpTestStatus.upToDate => Icons.check_circle,
        FtpTestStatus.neverTested || null => Icons.info_outline,
      };

  String get _headline => switch (plan?.status) {
        FtpTestStatus.due => 'Time to retest',
        FtpTestStatus.dueSoon => 'Retest coming up',
        FtpTestStatus.upToDate => 'Up to date',
        FtpTestStatus.neverTested || null => 'Not tested yet',
      };

  String get _detail {
    final plan = this.plan;
    if (plan == null || plan.status == FtpTestStatus.neverTested) {
      return 'This number sets the target for every workout in the app. '
          'Testing it once replaces the default estimate with your real '
          'threshold.';
    }

    final days = plan.daysSinceLastTest ?? 0;
    final last = '${_agoLabel(days)} on the '
        '${plan.lastTestProtocol?.displayName.toLowerCase() ?? 'test'}';

    return switch (plan.status) {
      FtpTestStatus.due =>
        'Last tested $last. Fitness has had time to move — retest to '
            'resync your zones.',
      FtpTestStatus.dueSoon =>
        'Last tested $last. Due in ${plan.daysUntilDue} '
            '${plan.daysUntilDue == 1 ? 'day' : 'days'}.',
      _ => 'Last tested $last. Next one due in ${plan.daysUntilDue} days — '
          'testing sooner mostly measures how fresh you are.',
    };
  }

  /// Weeks carry all the way to 17, past the longest retest interval on
  /// offer, because training blocks are counted in weeks — "9 weeks ago" tells
  /// a rider where they are in a block in a way "2 months ago" does not.
  static String _agoLabel(int days) => switch (days) {
        0 => 'today',
        1 => 'yesterday',
        < 14 => '$days days ago',
        < 119 => '${(days / 7).round()} weeks ago',
        _ => '${(days / 30).round()} months ago',
      };
}

// ---------------------------------------------------------------------------
// Explainer & prep
// ---------------------------------------------------------------------------

class _WhatIsFtpCard extends StatelessWidget {
  const _WhatIsFtpCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: tokens.surfaceTier2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'What is FTP?',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Functional Threshold Power is roughly the highest power you '
              'could hold for about an hour. It is the anchor for your '
              'training zones: every workout in the app prescribes its '
              'targets as a percentage of it.\n\n'
              'Nobody rides an hour flat out to find it. Instead you do a '
              'shorter maximal effort and scale the result — that is all an '
              'FTP test is.\n\n'
              'Set it too low and workouts feel pointless; too high and you '
              'fail them and read it as a lack of fitness. Both are fixed by '
              'measuring rather than guessing.',
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrepChecklist extends StatelessWidget {
  const _PrepChecklist();

  /// Conditions that move a threshold result by more than the fitness change
  /// you are trying to detect. The point is less "do all of these" than
  /// "do the same ones every time" — a test is only useful against its
  /// predecessors, so consistency beats optimisation.
  static const _items = [
    (
      Icons.bedtime_outlined,
      'Arrive fresh',
      'Easy day or rest day beforehand. Testing tired measures your fatigue, '
          'not your threshold.',
    ),
    (
      Icons.air,
      'Set up a fan',
      'Overheating indoors costs real watts. Run the same fan every test.',
    ),
    (
      Icons.schedule_outlined,
      'Keep it repeatable',
      'Same time of day, similar food and caffeine, same trainer setup as '
          'last time.',
    ),
    (
      Icons.trending_flat,
      'Do not sprint the start',
      'Especially on the 20-minute test — settle into an effort you can hold '
          'to the end.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('BEFORE YOU START'),
        SizedBox(height: tokens.spacingSm),
        for (final (icon, title, body) in _items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: tokens.textTertiary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        body,
                        style: TextStyle(
                          color: tokens.textTertiary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Progression
// ---------------------------------------------------------------------------

class _FtpProgression extends StatelessWidget {
  const _FtpProgression({required this.history, required this.plan});

  final List<FtpHistoryEntry> history;
  final FtpTestPlan? plan;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final tests = history.where((e) => e.source.isTest).toList()
      ..sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));

    if (tests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: tokens.surfaceTier2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Your tested FTP will be charted here. Complete a test to set the '
          'first data point.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: tokens.textDisabled,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tests.length >= 2) ...[
          SizedBox(
            height: 180,
            child: _FtpChart(tests: tests),
          ),
          SizedBox(height: tokens.spacingMd),
        ],
        if (plan?.changeSincePreviousTest != null) ...[
          _ChangeSummary(plan: plan!),
          SizedBox(height: tokens.spacingMd),
        ],
        for (final entry in tests.reversed)
          _HistoryRow(entry: entry, tests: tests),
      ],
    );
  }
}

class _FtpChart extends StatelessWidget {
  const _FtpChart({required this.tests});

  final List<FtpHistoryEntry> tests;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spots = <FlSpot>[
      for (var i = 0; i < tests.length; i++)
        FlSpot(i.toDouble(), tests[i].ftp.value),
    ];
    final values = tests.map((t) => t.ftp.value);
    final lowest = values.reduce((a, b) => a < b ? a : b);
    final highest = values.reduce((a, b) => a > b ? a : b);
    // Padding proportional to the spread, with a 10 W floor — otherwise a
    // history where every test landed on the same watt collapses the line
    // onto the chart edge.
    final pad = (highest - lowest).clamp(10.0, double.infinity) * 0.25;

    return LineChart(
      LineChartData(
        minY: lowest - pad,
        maxY: highest + pad,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: tokens.surfaceTier3Line, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (value, _) => Text(
                value.round().toString(),
                style: TextStyle(color: tokens.textDisabled, fontSize: 10),
              ),
            ),
          ),
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Colors.deepOrange,
            barWidth: 2,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.deepOrange.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
      duration: Duration.zero,
    );
  }
}

class _ChangeSummary extends StatelessWidget {
  const _ChangeSummary({required this.plan});

  final FtpTestPlan plan;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final change = plan.changeSincePreviousTest!;
    final percent = plan.percentChangeSincePreviousTest;
    final gained = change > 0;
    final color = change == 0
        ? tokens.textSecondary
        : (gained ? Colors.greenAccent : Colors.orangeAccent);

    final label = change == 0
        ? 'Unchanged since your previous test'
        : '${gained ? '+' : '−'}${change.abs().round()} W since your '
            'previous test'
            '${percent == null ? '' : ' (${gained ? '+' : '−'}'
                '${percent.abs().toStringAsFixed(1)}%)'}';

    return Row(
      children: [
        Icon(
          change == 0
              ? Icons.remove
              : (gained ? Icons.trending_up : Icons.trending_down),
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.tests});

  final FtpHistoryEntry entry;
  final List<FtpHistoryEntry> tests;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final index = tests.indexOf(entry);
    final previous = index > 0 ? tests[index - 1] : null;
    final delta =
        previous == null ? null : entry.ftp.value - previous.ftp.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(
              '${entry.ftp.value.round()} W',
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              entry.source.label,
              style: TextStyle(color: tokens.textTertiary, fontSize: 12),
            ),
          ),
          if (delta != null && delta != 0)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                '${delta > 0 ? '+' : '−'}${delta.abs().round()}',
                style: TextStyle(
                  color: delta > 0 ? Colors.greenAccent : Colors.orangeAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Text(
            _formatDate(entry.effectiveDate),
            style: TextStyle(color: tokens.textDisabled, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.tokens.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }
}
