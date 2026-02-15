import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/value_objects.dart';

part 'user_profile.freezed.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required Watts ftp,
    required double weight,
    required double height,
    required HeartRate restingHr,
    required HeartRate maxHr,
    required String name,
  }) = _UserProfile;
}
