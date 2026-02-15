import 'package:xml/xml.dart';

import '../../core/domain/entities/entities.dart';

/// Encodes a [Ride] into TCX (Training Center XML) format.
///
/// Produces a valid TCX file with:
/// - `<Activity Sport="Biking">` with `<Lap>` and `<Track>` elements
/// - Trackpoints with Time, HeartRateBpm, Cadence, DistanceMeters
/// - Garmin ActivityExtension/v2 for power (Watts) and speed
/// - Multiple laps if the Ride contains them; single auto-lap otherwise
class TcxEncoder {
  static const String _nsActivity =
      'http://www.garmin.com/xmlschemas/ActivityExtension/v2';

  String encode(Ride ride) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');

    builder.element('TrainingCenterDatabase', nest: () {
      builder.attribute('xmlns',
          'http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2');
      builder.attribute('xmlns:ns3', _nsActivity);

      builder.element('Activities', nest: () {
        builder.element('Activity', nest: () {
          builder.attribute('Sport', 'Biking');
          builder.element('Id', nest: ride.startTime.toUtc().toIso8601String());

          if (ride.laps.isNotEmpty) {
            for (final lap in ride.laps) {
              _writeLap(builder, ride, lap);
            }
          } else {
            _writeAutoLap(builder, ride);
          }
        });
      });
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }

  // ---------------------------------------------------------------------------
  // Lap from Ride.laps
  // ---------------------------------------------------------------------------

  void _writeLap(XmlBuilder b, Ride ride, Lap lap) {
    final lapReadings = ride.readings.sublist(
      lap.startIndex,
      (lap.endIndex + 1).clamp(0, ride.readings.length),
    );
    final startTime = lap.startTime;

    b.element('Lap', nest: () {
      b.attribute('StartTime', startTime.toUtc().toIso8601String());
      b.element('TotalTimeSeconds', nest: lap.duration.inSeconds.toString());
      _writeDistanceMeters(b, lapReadings);
      b.element('Intensity', nest: 'Active');
      b.element('TriggerMethod', nest: 'Manual');
      _writeTrack(b, lapReadings);
    });
  }

  // ---------------------------------------------------------------------------
  // Auto-generated single lap
  // ---------------------------------------------------------------------------

  void _writeAutoLap(XmlBuilder b, Ride ride) {
    b.element('Lap', nest: () {
      b.attribute('StartTime', ride.startTime.toUtc().toIso8601String());
      b.element('TotalTimeSeconds',
          nest: ride.activeDuration.inSeconds.toString());
      _writeDistanceMeters(b, ride.readings);
      b.element('Intensity', nest: 'Active');
      b.element('TriggerMethod', nest: 'Manual');
      _writeTrack(b, ride.readings);
    });
  }

  // ---------------------------------------------------------------------------
  // Track (list of Trackpoints)
  // ---------------------------------------------------------------------------

  void _writeTrack(XmlBuilder b, List<SensorReading> readings) {
    b.element('Track', nest: () {
      for (final r in readings) {
        _writeTrackpoint(b, r);
      }
    });
  }

  void _writeTrackpoint(XmlBuilder b, SensorReading r) {
    b.element('Trackpoint', nest: () {
      b.element('Time', nest: r.timestamp.toUtc().toIso8601String());

      if (r.distance != null) {
        b.element('DistanceMeters',
            nest: r.distance!.meters.toStringAsFixed(2));
      }

      if (r.heartRate != null) {
        b.element('HeartRateBpm', nest: () {
          b.element('Value', nest: r.heartRate!.bpm.toString());
        });
      }

      if (r.cadence != null) {
        b.element('Cadence', nest: r.cadence!.rpm.round().toString());
      }

      // Extensions: power and speed via Garmin ActivityExtension/v2
      final hasPower = r.power != null;
      final hasSpeed = r.speed != null;
      if (hasPower || hasSpeed) {
        b.element('Extensions', nest: () {
          b.element('ns3:TPX', nest: () {
            if (hasSpeed) {
              b.element('ns3:Speed',
                  nest: r.speed!.mps.toStringAsFixed(4));
            }
            if (hasPower) {
              b.element('ns3:Watts',
                  nest: r.power!.value.round().toString());
            }
          });
        });
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _writeDistanceMeters(XmlBuilder b, List<SensorReading> readings) {
    final withDist = readings.where((r) => r.distance != null).toList();
    if (withDist.isNotEmpty) {
      b.element('DistanceMeters',
          nest: withDist.last.distance!.meters.toStringAsFixed(2));
    } else {
      b.element('DistanceMeters', nest: '0.00');
    }
  }
}
