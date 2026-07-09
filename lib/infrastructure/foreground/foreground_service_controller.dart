import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Thin seam over [FlutterForegroundTask] so [BackgroundRecordingService]'s
/// lifecycle logic (start on recording, stop on idle) can be unit tested
/// without a real Android foreground service.
abstract class ForegroundServiceController {
  /// Starts the foreground service with the given notification content.
  Future<void> start({required String title, required String text});

  /// Updates the running service's notification content.
  Future<void> update({String? title, String? text});

  /// Stops the foreground service.
  Future<void> stop();
}

/// No-op controller for platforms that don't need (or don't support) a
/// foreground service: iOS relies on the `bluetooth-central` background
/// mode instead, and desktop/web don't background the process the same way.
class NoopForegroundServiceController implements ForegroundServiceController {
  const NoopForegroundServiceController();

  @override
  Future<void> start({required String title, required String text}) async {}

  @override
  Future<void> update({String? title, String? text}) async {}

  @override
  Future<void> stop() async {}
}

/// Android implementation backed by `flutter_foreground_task`.
///
/// Declares the service as `connectedDevice` type (interactions with a
/// Bluetooth-connected trainer/sensor while backgrounded) — see the
/// `FOREGROUND_SERVICE_CONNECTED_DEVICE` permission and `<service>` tag in
/// `AndroidManifest.xml`.
class FlutterForegroundTaskController implements ForegroundServiceController {
  bool _initialized = false;

  void _ensureInitialized() {
    if (_initialized) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'openbike_recording',
        channelName: 'Ride recording',
        channelDescription:
            'Shows elapsed time and power while a ride is recording.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWifiLock: false,
      ),
    );
    _initialized = true;
  }

  @override
  Future<void> start({required String title, required String text}) async {
    _ensureInitialized();
    await FlutterForegroundTask.startService(
      serviceTypes: const [ForegroundServiceTypes.connectedDevice],
      notificationTitle: title,
      notificationText: text,
    );
  }

  @override
  Future<void> update({String? title, String? text}) async {
    await FlutterForegroundTask.updateService(
      notificationTitle: title,
      notificationText: text,
    );
  }

  @override
  Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }
}
