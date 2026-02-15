import '../../domain/entities/power_zone.dart';
import '../../domain/value_objects/value_objects.dart';

class ZoneCalculator {
  /// Coggan 7-zone model based on FTP.
  List<PowerZone> calculateZones(Watts ftp) => PowerZone.coggan7(ftp);

  /// Returns the zone that contains the given power expressed as % FTP.
  PowerZone? currentZone(Watts power, Watts ftp, List<PowerZone> zones) {
    if (ftp.value == 0) return null;
    final percent = (power.value / ftp.value) * 100;
    for (final zone in zones) {
      if (zone.contains(percent)) return zone;
    }
    return null;
  }
}
