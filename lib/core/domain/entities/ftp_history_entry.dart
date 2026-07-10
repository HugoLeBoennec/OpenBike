import 'package:freezed_annotation/freezed_annotation.dart';

import '../value_objects/value_objects.dart';

part 'ftp_history_entry.freezed.dart';

/// A dated FTP value — recorded whenever the user profile's FTP changes so
/// past rides can keep being scored against the FTP that was actually in
/// effect on their date, regardless of later changes.
@freezed
class FtpHistoryEntry with _$FtpHistoryEntry {
  const factory FtpHistoryEntry({
    required DateTime effectiveDate,
    required Watts ftp,
  }) = _FtpHistoryEntry;
}
