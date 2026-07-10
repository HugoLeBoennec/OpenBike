import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/application/services/ftp_estimator.dart';
import '../../core/domain/entities/user_profile.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../state/providers.dart';

/// Invisible widget that watches for a finished FTP-test ride and prompts
/// the user to update their profile with the detected FTP.
///
/// Mount once on [RideSummaryScreen]. [activeFtpTestProvider] is set by
/// [RideScreen] when the ride was started from one of the two bundled FTP
/// test workouts (see `BundledWorkouts`); this widget consumes it exactly
/// once (clearing it immediately) the moment the finished ride's readings
/// load, so it survives rebuilds without re-prompting.
class FtpTestPrompt extends ConsumerWidget {
  const FtpTestPrompt({super.key, required this.rideId});

  final String rideId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(rideDetailProvider(rideId), (previous, next) {
      final testType = ref.read(activeFtpTestProvider);
      if (testType == null) return;

      final ride = next.valueOrNull;
      if (ride == null || ride.readings.isEmpty) return;

      // Clear immediately — this consumes the pending test exactly once.
      ref.read(activeFtpTestProvider.notifier).state = null;

      final estimated = testType == FtpTestType.ramp
          ? FtpEstimator.estimateFromRamp(ride.readings)
          : FtpEstimator.estimateFrom20Min(ride.readings);
      if (estimated.value <= 0) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) _showPrompt(context, ref, estimated);
      });
    });

    return const SizedBox.shrink();
  }

  void _showPrompt(BuildContext context, WidgetRef ref, Watts estimated) {
    final rounded = estimated.value.round();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('FTP test complete'),
        content: Text('New FTP: $rounded W — update profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Not now'),
          ),
          TextButton(
            key: const Key('updateFtpButton'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _updateProfile(ref, Watts(rounded.toDouble()));
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _updateProfile(WidgetRef ref, Watts newFtp) {
    final current = ref.read(userProfileProvider) ?? _defaultProfile();
    final updated = current.copyWith(ftp: newFtp);
    ref.read(userProfileProvider.notifier).state = updated;
    ref.read(storageProvider).saveProfile(updated);
  }

  UserProfile _defaultProfile() {
    return const UserProfile(
      ftp: Watts(200),
      weight: 75,
      height: 178,
      restingHr: HeartRate(60),
      maxHr: HeartRate(190),
      name: '',
    );
  }
}
