import 'package:freezed_annotation/freezed_annotation.dart';

import '../value_objects/value_objects.dart';

part 'ftp_history_entry.freezed.dart';

/// How an FTP value came to be recorded.
///
/// Distinguishing a measured test from a hand-typed number is what lets the
/// retest reminder key off "when did you last *test*" rather than "when did
/// this number last change" — editing FTP in Settings must not reset the
/// clock, or the reminder silently stops firing for anyone who tunes their
/// FTP by feel between tests.
enum FtpSource {
  /// Typed into Settings or onboarding by the user.
  manual,

  /// Detected from a completed ramp test.
  rampTest,

  /// Detected from a completed 20-minute test.
  twentyMinuteTest;

  bool get isTest => this != FtpSource.manual;

  /// Label for the FTP progression chart and history list.
  String get label => switch (this) {
        FtpSource.manual => 'Entered manually',
        FtpSource.rampTest => 'Ramp test',
        FtpSource.twentyMinuteTest => '20-minute test',
      };
}

/// A dated FTP value — recorded whenever the user profile's FTP changes so
/// past rides can keep being scored against the FTP that was actually in
/// effect on their date, regardless of later changes.
@freezed
class FtpHistoryEntry with _$FtpHistoryEntry {
  const factory FtpHistoryEntry({
    required DateTime effectiveDate,
    required Watts ftp,

    /// Defaults to [FtpSource.manual] so rows written before the source
    /// column existed (schema < 6) keep their existing meaning: a number
    /// that changed, with no evidence a test produced it.
    @Default(FtpSource.manual) FtpSource source,
  }) = _FtpHistoryEntry;
}
