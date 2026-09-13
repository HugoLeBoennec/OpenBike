import '../../domain/entities/ftp_history_entry.dart';
import '../../domain/value_objects/value_objects.dart';

/// Which bundled protocol a test used or should use.
enum FtpTestProtocol {
  ramp,
  twentyMinute;

  /// Maps a recorded history entry back to the protocol that produced it.
  static FtpTestProtocol? fromSource(FtpSource source) => switch (source) {
        FtpSource.rampTest => FtpTestProtocol.ramp,
        FtpSource.twentyMinuteTest => FtpTestProtocol.twentyMinute,
        FtpSource.manual => null,
      };

  FtpSource get source => switch (this) {
        FtpTestProtocol.ramp => FtpSource.rampTest,
        FtpTestProtocol.twentyMinute => FtpSource.twentyMinuteTest,
      };
}

/// Where the rider stands relative to their retest interval.
enum FtpTestStatus {
  /// No measured test on record — the profile FTP is a guess or a typed value.
  neverTested,

  /// Tested recently enough that another test would mostly cost training time.
  upToDate,

  /// Inside the final week before the interval elapses.
  dueSoon,

  /// The interval has elapsed.
  due,
}

/// The rider's FTP-testing state: when they last tested, whether another test
/// is warranted, which protocol suits them next, and how their FTP has moved.
class FtpTestPlan {
  const FtpTestPlan({
    required this.status,
    required this.recommendedProtocol,
    required this.intervalDays,
    required this.completedTests,
    this.lastTestDate,
    this.lastTestProtocol,
    this.lastTestedFtp,
    this.previousTestedFtp,
    this.daysSinceLastTest,
  });

  final FtpTestStatus status;

  /// The protocol to pre-select and badge as recommended.
  final FtpTestProtocol recommendedProtocol;

  /// The retest interval this plan was computed against, in days.
  final int intervalDays;

  /// How many measured tests are on record.
  final int completedTests;

  final DateTime? lastTestDate;
  final FtpTestProtocol? lastTestProtocol;
  final Watts? lastTestedFtp;

  /// FTP measured by the test *before* [lastTestedFtp], when one exists —
  /// the baseline for [changeSincePreviousTest].
  final Watts? previousTestedFtp;

  final int? daysSinceLastTest;

  bool get hasTested => completedTests > 0;

  /// True once a nudge is worth showing on the dashboard.
  bool get shouldPrompt =>
      status == FtpTestStatus.due || status == FtpTestStatus.neverTested;

  /// Whole days until the interval elapses; negative once overdue, null when
  /// the rider has never tested.
  int? get daysUntilDue =>
      daysSinceLastTest == null ? null : intervalDays - daysSinceLastTest!;

  /// Watts gained (or lost) between the last two measured tests.
  double? get changeSincePreviousTest {
    final last = lastTestedFtp;
    final previous = previousTestedFtp;
    if (last == null || previous == null) return null;
    return last.value - previous.value;
  }

  /// Percentage change between the last two measured tests.
  double? get percentChangeSincePreviousTest {
    final previous = previousTestedFtp;
    final change = changeSincePreviousTest;
    if (previous == null || change == null || previous.value == 0) return null;
    return change / previous.value * 100;
  }
}

/// Decides when a rider should retest their FTP and which protocol to steer
/// them toward.
///
/// The six-week default sits at the conservative end of the 4–6 week range
/// coaching guidance converges on: threshold adaptations need roughly three to
/// six weeks to show up as measurable power, and a maximal test costs one to
/// two days of quality training on either side, so testing more often mostly
/// buys noise. Riders who train in shorter blocks can shorten it in Settings.
class FtpTestPlanner {
  FtpTestPlanner._();

  /// Default retest interval — six weeks.
  static const int defaultIntervalDays = 42;

  /// Shortest interval the Settings slider allows (four weeks); below this a
  /// test measures day-to-day variation rather than fitness.
  static const int minIntervalDays = 28;

  /// Longest interval the slider allows (sixteen weeks). Even riders holding
  /// steady fitness are generally advised to test at least a few times a year.
  static const int maxIntervalDays = 112;

  /// How many days before the interval elapses to start warning.
  static const int dueSoonWindowDays = 7;

  /// Number of tests a newcomer does on the ramp protocol before being
  /// pointed at the 20-minute test. Ramp needs no pacing skill, which is the
  /// main thing that makes a first 20-minute effort misreport; by the third
  /// test the rider has enough of a feel for threshold to pace one.
  static const int rampTestsBeforeGraduating = 2;

  /// Builds a plan from the full FTP history (any order; only entries whose
  /// source is a measured test are considered).
  static FtpTestPlan plan({
    required List<FtpHistoryEntry> ftpHistory,
    required DateTime now,
    int intervalDays = defaultIntervalDays,
  }) {
    final tests = ftpHistory.where((e) => e.source.isTest).toList()
      ..sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));

    if (tests.isEmpty) {
      return FtpTestPlan(
        status: FtpTestStatus.neverTested,
        recommendedProtocol: FtpTestProtocol.ramp,
        intervalDays: intervalDays,
        completedTests: 0,
      );
    }

    final last = tests.last;
    final daysSince = _wholeDaysBetween(last.effectiveDate, now);

    return FtpTestPlan(
      status: _statusFor(daysSince, intervalDays),
      recommendedProtocol: tests.length >= rampTestsBeforeGraduating
          ? FtpTestProtocol.twentyMinute
          : FtpTestProtocol.ramp,
      intervalDays: intervalDays,
      completedTests: tests.length,
      lastTestDate: last.effectiveDate,
      lastTestProtocol: FtpTestProtocol.fromSource(last.source),
      lastTestedFtp: last.ftp,
      previousTestedFtp:
          tests.length >= 2 ? tests[tests.length - 2].ftp : null,
      daysSinceLastTest: daysSince,
    );
  }

  static FtpTestStatus _statusFor(int daysSince, int intervalDays) {
    if (daysSince >= intervalDays) return FtpTestStatus.due;
    if (daysSince >= intervalDays - dueSoonWindowDays) {
      return FtpTestStatus.dueSoon;
    }
    return FtpTestStatus.upToDate;
  }

  /// Whole days from [from] to [to], counted on calendar dates so a test taken
  /// late one evening and a check made early on the 42nd morning agree with
  /// what the rider would say. Never negative — a future-dated entry (clock
  /// change, restored backup) reads as "tested today" rather than producing a
  /// nonsensical negative age.
  static int _wholeDaysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    final days = toDate.difference(fromDate).inDays;
    return days < 0 ? 0 : days;
  }
}
