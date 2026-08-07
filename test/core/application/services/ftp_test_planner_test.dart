import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/core/application/services/ftp_test_planner.dart';
import 'package:open_bike/core/domain/entities/ftp_history_entry.dart';
import 'package:open_bike/core/domain/value_objects/value_objects.dart';

FtpHistoryEntry _entry(
  DateTime date,
  double ftp, {
  FtpSource source = FtpSource.rampTest,
}) =>
    FtpHistoryEntry(effectiveDate: date, ftp: Watts(ftp), source: source);

void main() {
  final now = DateTime(2026, 8, 7);

  group('status', () {
    test('reports neverTested when no history exists', () {
      final plan = FtpTestPlanner.plan(ftpHistory: const [], now: now);

      expect(plan.status, FtpTestStatus.neverTested);
      expect(plan.hasTested, isFalse);
      expect(plan.completedTests, 0);
      expect(plan.daysSinceLastTest, isNull);
      expect(plan.daysUntilDue, isNull);
      expect(plan.shouldPrompt, isTrue);
    });

    test('ignores manual entries when deciding whether a test has happened',
        () {
      // Typing an FTP into Settings must not read as a measurement — a rider
      // who has only ever guessed still needs the first-test prompt.
      final plan = FtpTestPlanner.plan(
        ftpHistory: [
          _entry(now.subtract(const Duration(days: 3)), 250,
              source: FtpSource.manual),
        ],
        now: now,
      );

      expect(plan.status, FtpTestStatus.neverTested);
      expect(plan.completedTests, 0);
    });

    test('is upToDate well inside the interval', () {
      final plan = FtpTestPlanner.plan(
        ftpHistory: [_entry(now.subtract(const Duration(days: 10)), 250)],
        now: now,
      );

      expect(plan.status, FtpTestStatus.upToDate);
      expect(plan.daysSinceLastTest, 10);
      expect(plan.daysUntilDue, 32);
      expect(plan.shouldPrompt, isFalse);
    });

    test('is dueSoon in the final week before the interval elapses', () {
      final plan = FtpTestPlanner.plan(
        ftpHistory: [_entry(now.subtract(const Duration(days: 36)), 250)],
        now: now,
      );

      expect(plan.status, FtpTestStatus.dueSoon);
      expect(plan.daysUntilDue, 6);
      // A warning is not yet a prompt — the dashboard badge stays off.
      expect(plan.shouldPrompt, isFalse);
    });

    test('is due exactly on the interval boundary', () {
      final plan = FtpTestPlanner.plan(
        ftpHistory: [_entry(now.subtract(const Duration(days: 42)), 250)],
        now: now,
      );

      expect(plan.status, FtpTestStatus.due);
      expect(plan.daysUntilDue, 0);
      expect(plan.shouldPrompt, isTrue);
    });

    test('reports a negative daysUntilDue once overdue', () {
      final plan = FtpTestPlanner.plan(
        ftpHistory: [_entry(now.subtract(const Duration(days: 60)), 250)],
        now: now,
      );

      expect(plan.status, FtpTestStatus.due);
      expect(plan.daysUntilDue, -18);
    });

    test('honours a custom interval', () {
      final history = [_entry(now.subtract(const Duration(days: 30)), 250)];

      expect(
        FtpTestPlanner.plan(ftpHistory: history, now: now, intervalDays: 28)
            .status,
        FtpTestStatus.due,
      );
      expect(
        FtpTestPlanner.plan(ftpHistory: history, now: now, intervalDays: 56)
            .status,
        FtpTestStatus.upToDate,
      );
    });

    test('treats a future-dated entry as tested today rather than negative',
        () {
      // Clock changes and restored backups can date an entry ahead of now;
      // a negative age would render as nonsense in the UI.
      final plan = FtpTestPlanner.plan(
        ftpHistory: [_entry(now.add(const Duration(days: 5)), 250)],
        now: now,
      );

      expect(plan.daysSinceLastTest, 0);
      expect(plan.status, FtpTestStatus.upToDate);
    });
  });

  group('protocol recommendation', () {
    test('recommends the ramp test to a rider who has never tested', () {
      final plan = FtpTestPlanner.plan(ftpHistory: const [], now: now);

      expect(plan.recommendedProtocol, FtpTestProtocol.ramp);
    });

    test('still recommends the ramp after a single test', () {
      final plan = FtpTestPlanner.plan(
        ftpHistory: [_entry(now.subtract(const Duration(days: 45)), 250)],
        now: now,
      );

      expect(plan.recommendedProtocol, FtpTestProtocol.ramp);
    });

    test('graduates to the 20-minute test after two tests', () {
      final plan = FtpTestPlanner.plan(
        ftpHistory: [
          _entry(now.subtract(const Duration(days: 90)), 240),
          _entry(now.subtract(const Duration(days: 45)), 250),
        ],
        now: now,
      );

      expect(plan.recommendedProtocol, FtpTestProtocol.twentyMinute);
    });
  });

  group('progression', () {
    test('surfaces the last test\'s protocol and value', () {
      final plan = FtpTestPlanner.plan(
        ftpHistory: [
          _entry(now.subtract(const Duration(days: 90)), 240),
          _entry(now.subtract(const Duration(days: 45)), 262,
              source: FtpSource.twentyMinuteTest),
        ],
        now: now,
      );

      expect(plan.lastTestProtocol, FtpTestProtocol.twentyMinute);
      expect(plan.lastTestedFtp, const Watts(262));
      expect(plan.previousTestedFtp, const Watts(240));
      expect(plan.completedTests, 2);
    });

    test('computes the change between the last two tests', () {
      final plan = FtpTestPlanner.plan(
        ftpHistory: [
          _entry(now.subtract(const Duration(days: 90)), 200),
          _entry(now.subtract(const Duration(days: 45)), 220),
        ],
        now: now,
      );

      expect(plan.changeSincePreviousTest, 20);
      expect(plan.percentChangeSincePreviousTest, closeTo(10.0, 0.001));
    });

    test('reports a loss as a negative change', () {
      final plan = FtpTestPlanner.plan(
        ftpHistory: [
          _entry(now.subtract(const Duration(days: 90)), 250),
          _entry(now.subtract(const Duration(days: 45)), 240),
        ],
        now: now,
      );

      expect(plan.changeSincePreviousTest, -10);
      expect(plan.percentChangeSincePreviousTest, closeTo(-4.0, 0.001));
    });

    test('has no change to report after a single test', () {
      final plan = FtpTestPlanner.plan(
        ftpHistory: [_entry(now.subtract(const Duration(days: 45)), 250)],
        now: now,
      );

      expect(plan.previousTestedFtp, isNull);
      expect(plan.changeSincePreviousTest, isNull);
      expect(plan.percentChangeSincePreviousTest, isNull);
    });

    test('compares tests to each other, skipping manual edits in between', () {
      // A rider who nudges FTP by hand between tests should still see their
      // progress measured test-to-test, not against the hand-typed number.
      final plan = FtpTestPlanner.plan(
        ftpHistory: [
          _entry(now.subtract(const Duration(days: 90)), 200),
          _entry(now.subtract(const Duration(days: 60)), 215,
              source: FtpSource.manual),
          _entry(now.subtract(const Duration(days: 45)), 220),
        ],
        now: now,
      );

      expect(plan.previousTestedFtp, const Watts(200));
      expect(plan.changeSincePreviousTest, 20);
    });

    test('sorts unordered history before picking the latest test', () {
      final plan = FtpTestPlanner.plan(
        ftpHistory: [
          _entry(now.subtract(const Duration(days: 10)), 260),
          _entry(now.subtract(const Duration(days: 90)), 240),
        ],
        now: now,
      );

      expect(plan.lastTestedFtp, const Watts(260));
      expect(plan.previousTestedFtp, const Watts(240));
      expect(plan.daysSinceLastTest, 10);
    });
  });
}
