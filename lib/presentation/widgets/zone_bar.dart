import 'package:flutter/material.dart';
import '../../core/domain/entities/power_zone.dart';
import '../../core/domain/value_objects/value_objects.dart';

class ZoneBar extends StatelessWidget {
  final Watts power;
  final List<PowerZone> zones;

  const ZoneBar({
    super.key,
    required this.power,
    required this.zones,
  });

  static const _zoneColors = [
    Colors.grey,      // Z1
    Colors.blue,      // Z2
    Colors.green,     // Z3
    Colors.yellow,    // Z4
    Colors.orange,    // Z5
    Colors.deepOrange, // Z6
    Colors.red,       // Z7
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: List.generate(zones.length, (i) {
          final zone = zones[i];
          final isActive = power >= zone.minWatts && power <= zone.maxWatts;
          final color = i < _zoneColors.length ? _zoneColors[i] : Colors.purple;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: isActive ? color : color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  'Z${zone.number}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Colors.white : Colors.white54,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
