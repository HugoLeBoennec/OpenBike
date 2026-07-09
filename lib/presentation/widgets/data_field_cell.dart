import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/data_field_type.dart';

/// Single data field cell for the ride screen grid.
///
/// Displays a small label, large value, and unit. Power-type fields get a
/// tinted background matching the current power zone.
class DataFieldCell extends ConsumerWidget {
  final DataFieldType fieldType;

  const DataFieldCell({super.key, required this.fieldType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = fieldType.resolveValue(ref);
    final zoneColor = fieldType.resolveZoneColor(ref);

    return Container(
      decoration: BoxDecoration(
        color: zoneColor != null
            ? zoneColor.withValues(alpha: 0.15)
            : const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF333333), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            fieldType.label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: zoneColor ?? Colors.white,
                  ),
                ),
                if (fieldType.unit.isNotEmpty) ...[
                  const SizedBox(width: 3),
                  Text(
                    fieldType.unit,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
