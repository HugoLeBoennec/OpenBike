import 'package:flutter_test/flutter_test.dart';
import 'package:open_bike/infrastructure/observability/crash_reporting_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  group('CrashReportingService lifecycle', () {
    late int inits;
    late int closes;
    late SentryFlutterOptions? lastOptions;

    setUp(() {
      inits = 0;
      closes = 0;
      lastOptions = null;
      CrashReportingService.initializer = (configure) async {
        inits++;
        final options = SentryFlutterOptions();
        await configure(options);
        lastOptions = options;
      };
      CrashReportingService.closer = () async => closes++;
    });

    tearDown(() async {
      await CrashReportingService.stop();
    });

    test('start with an empty DSN never initialises Sentry', () async {
      await CrashReportingService.start(dsn: '', isEnabled: () => true);

      expect(inits, 0);
    });

    test('apply(enabled: false) never initialises Sentry', () async {
      await CrashReportingService.apply(enabled: false);

      expect(inits, 0);
      expect(closes, 0);
    });

    test('start initialises once and stop closes once', () async {
      await CrashReportingService.start(
        dsn: 'https://k@o.example/1',
        isEnabled: () => true,
      );
      await CrashReportingService.start(
        dsn: 'https://k@o.example/1',
        isEnabled: () => true,
      );
      expect(inits, 1);

      await CrashReportingService.stop();
      await CrashReportingService.stop();
      expect(closes, 1);

      await CrashReportingService.start(
        dsn: 'https://k@o.example/1',
        isEnabled: () => true,
      );
      expect(inits, 2);
    });

    test('configures crash-data-only options', () async {
      await CrashReportingService.start(
        dsn: 'https://k@o.example/1',
        isEnabled: () => true,
      );

      final o = lastOptions!;
      expect(o.sendDefaultPii, isFalse);
      expect(o.enableAutoSessionTracking, isFalse);
      expect(o.enableAppHangTracking, isFalse);
      expect(o.enableWatchdogTerminationTracking, isFalse);
      expect(o.enableNativeCrashHandling, isFalse);
      expect(o.sendClientReports, isFalse);
    });

    test('beforeSend drops events once isEnabled turns false', () async {
      var enabled = true;
      await CrashReportingService.start(
        dsn: 'https://k@o.example/1',
        isEnabled: () => enabled,
      );

      final beforeSend = lastOptions!.beforeSend!;
      final event = SentryEvent(message: SentryMessage('boom'));
      expect(await beforeSend(event, Hint()), isNotNull);

      enabled = false;
      expect(await beforeSend(event, Hint()), isNull);
    });
  });

  group('CrashReportingService.redactEvent', () {
    test('strips breadcrumbs, extra, user context and device hash', () {
      final event = SentryEvent(
        breadcrumbs: [Breadcrumb(message: 'started ride')],
        // ignore: deprecated_member_use
        extra: {'ftp': 250},
        user: SentryUser(id: 'rider-1', email: 'rider@example.com'),
      );
      event.contexts.app = SentryApp(name: 'OpenBike', deviceAppHash: 'abc123');

      final redacted = CrashReportingService.redactEvent(event);

      expect(redacted.breadcrumbs, isNull);
      // ignore: deprecated_member_use
      expect(redacted.extra, isNull);
      expect(redacted.user, isNull);
      expect(redacted.contexts.app?.deviceAppHash, isNull);
      expect(redacted.contexts.app?.name, 'OpenBike');
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
