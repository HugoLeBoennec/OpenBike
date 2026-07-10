import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../theme/app_theme.dart';

/// Horizontal zone indicator bar — highlights the active Coggan power zone.
class ZoneBar extends ConsumerWidget {
  const ZoneBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(powerZonesProvider);
    final power = ref.watch(livePowerProvider);
    final ftp = ref.watch(ftpProvider);

    if (zones.isEmpty) return const SizedBox.shrink();

    final activeIndex = zones.indexWhere(
      (zone) => power >= zone.minWatts(ftp) && power <= zone.maxWatts(ftp),
    );
    final activeZone = activeIndex >= 0 ? zones[activeIndex] : null;

    return Semantics(
      label: 'Power zone',
      value: activeZone != null
          ? 'Zone ${activeIndex + 1}, ${activeZone.name}'
          : 'No active zone',
      container: true,
      excludeSemantics: true,
      child: SizedBox(
        height: 28,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: List.generate(zones.length, (i) {
              final zone = zones[i];
              final isActive = i == activeIndex;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: isActive
                        ? zone.color
                        : zone.color.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      'Z${i + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                        // Active label sits on the zone's full-opacity fill,
                        // so pick black/white per-zone for WCAG contrast
                        // (a fixed white fails on the brighter zones).
                        color: isActive
                            ? contrastingTextColor(zone.color)
                            : context.tokens.rideOnSurfaceMuted,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
