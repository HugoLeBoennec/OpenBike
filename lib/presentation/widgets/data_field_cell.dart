import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/data_field_type.dart';
import '../theme/app_theme.dart';

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
    final unit = fieldType.unitFor(ref);
    final tokens = context.tokens;

    return Semantics(
      label: '${fieldType.label}: $value $unit',
      child: Container(
        decoration: BoxDecoration(
          color: zoneColor != null
              ? zoneColor.withValues(alpha: 0.15)
              : tokens.rideSurface,
          border: Border.all(color: tokens.surfaceTier3Line, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              fieldType.label,
              style: tokens.dataFieldLabelStyle,
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
                    style: tokens.dataFieldValueStyle.copyWith(
                      fontSize: 32,
                      color: zoneColor ?? tokens.rideOnSurface,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 3),
                    Text(
                      unit,
                      style: tokens.dataFieldLabelStyle
                          .copyWith(fontSize: 11, letterSpacing: 0),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
