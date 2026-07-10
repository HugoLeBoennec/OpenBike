import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:open_bike/infrastructure/observability/crash_reporting_service.dart';

void main() {
  group('CrashReportingService.run — no DSN', () {
    test('runs appRunner directly without touching Sentry', () async {
      var ran = false;
      await CrashReportingService.run(
        dsn: '',
        isEnabled: () => true,
        appRunner: () {
          ran = true;
        },
      );

      expect(ran, isTrue);
    });

    test('propagates the value returned by appRunner completing', () async {
      // No DSN means the "opt-in build with Sentry disabled" acceptance
      // criterion from P9 — the whole point is that this path never
      // constructs a SentryFlutterOptions or calls SentryFlutter.init.
      var callCount = 0;
      await CrashReportingService.run(
        dsn: '',
        isEnabled: () => false,
        appRunner: () async {
          callCount++;
        },
      );

      expect(callCount, 1);
    });
  });

  group('CrashReportingService.redactEvent', () {
    test('strips breadcrumbs, extra, and user context', () {
      final event = SentryEvent(
        breadcrumbs: [Breadcrumb(message: 'started ride')],
        // ignore: deprecated_member_use
        extra: {'ftp': 250},
        user: SentryUser(id: 'rider-1', email: 'rider@example.com'),
      );

      final redacted = CrashReportingService.redactEvent(event);

      expect(redacted.breadcrumbs, isNull);
      // ignore: deprecated_member_use
      expect(redacted.extra, isNull);
      expect(redacted.user, isNull);
    });

    test('leaves an already-clean event untouched', () {
      final event = SentryEvent(message: SentryMessage('boom'));

      final redacted = CrashReportingService.redactEvent(event);

      expect(redacted.breadcrumbs, isNull);
      // ignore: deprecated_member_use
      expect(redacted.extra, isNull);
      expect(redacted.user, isNull);
      expect(redacted.message?.formatted, 'boom');
    });
  });
}
