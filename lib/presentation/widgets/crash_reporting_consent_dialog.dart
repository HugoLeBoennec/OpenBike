import 'package:flutter/material.dart';

/// One-time post-onboarding prompt asking the user to opt in to crash
/// reporting (see docs/release/analytics.md). Shown at most once — callers
/// gate on [AppPreferences.hasAskedCrashReportingConsent] — but the choice
/// can always be changed later in Settings → About.
Future<bool> showCrashReportingConsentDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Help improve OpenBike'),
      content: const Text(
        'Send anonymous crash reports to help fix bugs? No ride data, '
        'location, or personal information is ever included. You can change '
        'this anytime in Settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No thanks'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Send crash reports'),
        ),
      ],
    ),
  );
  return result ?? false;
}
