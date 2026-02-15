import 'dart:ui' show Color;

import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/value_objects.dart';

part 'power_zone.freezed.dart';

@freezed
class PowerZone with _$PowerZone {
  const PowerZone._();

  const factory PowerZone({
    required String name,
    required double minPercent,
    required double maxPercent,
    required Color color,
  }) = _PowerZone;

  /// Standard Coggan 7-zone model (percentages of FTP).
  static List<PowerZone> coggan7(Watts ftp) {
    return const [
      PowerZone(
        name: 'Active Recovery',
        minPercent: 0,
        maxPercent: 55,
        color: Color(0xFF9E9E9E),
      ),
      PowerZone(
        name: 'Endurance',
        minPercent: 56,
        maxPercent: 75,
        color: Color(0xFF2196F3),
      ),
      PowerZone(
        name: 'Tempo',
        minPercent: 76,
        maxPercent: 90,
        color: Color(0xFF4CAF50),
      ),
      PowerZone(
        name: 'Threshold',
        minPercent: 91,
        maxPercent: 105,
        color: Color(0xFFFFEB3B),
      ),
      PowerZone(
        name: 'VO2max',
        minPercent: 106,
        maxPercent: 120,
        color: Color(0xFFFF9800),
      ),
      PowerZone(
        name: 'Anaerobic',
        minPercent: 121,
        maxPercent: 150,
        color: Color(0xFFF44336),
      ),
      PowerZone(
        name: 'Neuromuscular',
        minPercent: 151,
        maxPercent: 300,
        color: Color(0xFF9C27B0),
      ),
    ];
  }

  /// Returns the absolute watt range for a given FTP.
  Watts minWatts(Watts ftp) => Watts(ftp.value * minPercent / 100);
  Watts maxWatts(Watts ftp) => Watts(ftp.value * maxPercent / 100);

  /// Checks if a given power (as % FTP) falls within this zone.
  bool contains(double percent) =>
      percent >= minPercent && percent <= maxPercent;
}
