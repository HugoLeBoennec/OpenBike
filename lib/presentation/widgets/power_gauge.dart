import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/entities/power_zone.dart';
import '../../core/domain/value_objects/value_objects.dart';
import '../state/providers.dart';

/// Circular arc gauge (270°) colored by power zone with a needle indicator.
class PowerGauge extends ConsumerWidget {
  const PowerGauge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final power = ref.watch(livePowerProvider);
    final ftp = ref.watch(ftpProvider);
    final zones = ref.watch(powerZonesProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _PowerGaugePainter(
                power: power.value,
                ftp: ftp.value,
                maxPower: ftp.value * 2,
                zones: zones,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${power.value.round()}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'watts',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _PowerGaugePainter extends CustomPainter {
  _PowerGaugePainter({
    required this.power,
    required this.ftp,
    required this.maxPower,
    required this.zones,
  });

  final double power;
  final double ftp;
  final double maxPower;
  final List<PowerZone> zones;

  static const _startAngle = 135.0 * pi / 180;
  static const _sweepAngle = 270.0 * pi / 180;
  static const _strokeWidth = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - _strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background arc
    canvas.drawArc(
      rect,
      _startAngle,
      _sweepAngle,
      false,
      Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Zone-colored segments
    if (zones.isNotEmpty && maxPower > 0) {
      final ftpWatts = Watts(ftp);
      for (final zone in zones) {
        final zoneMinW = zone.minWatts(ftpWatts).value.clamp(0.0, maxPower);
        final zoneMaxW = zone.maxWatts(ftpWatts).value.clamp(0.0, maxPower);
        final start = _startAngle + (zoneMinW / maxPower) * _sweepAngle;
        final sweep = ((zoneMaxW - zoneMinW) / maxPower) * _sweepAngle;
        canvas.drawArc(
          rect,
          start,
          sweep,
          false,
          Paint()
            ..color = zone.color.withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = _strokeWidth,
        );
      }
    }

    // Needle
    if (maxPower > 0) {
      final clampedPower = power.clamp(0.0, maxPower);
      final needleAngle =
          _startAngle + (clampedPower / maxPower) * _sweepAngle;
      final needleEnd = Offset(
        center.dx + (radius + 4) * cos(needleAngle),
        center.dy + (radius + 4) * sin(needleAngle),
      );
      final needleStart = Offset(
        center.dx + (radius * 0.55) * cos(needleAngle),
        center.dy + (radius * 0.55) * sin(needleAngle),
      );
      canvas.drawLine(
        needleStart,
        needleEnd,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    // FTP tick mark
    if (ftp > 0 && maxPower > 0) {
      final ftpAngle = _startAngle + (ftp / maxPower) * _sweepAngle;
      final tickOuter = Offset(
        center.dx + (radius + _strokeWidth / 2 + 4) * cos(ftpAngle),
        center.dy + (radius + _strokeWidth / 2 + 4) * sin(ftpAngle),
      );
      final tickInner = Offset(
        center.dx + (radius - _strokeWidth / 2 - 4) * cos(ftpAngle),
        center.dy + (radius - _strokeWidth / 2 - 4) * sin(ftpAngle),
      );
      canvas.drawLine(
        tickInner,
        tickOuter,
        Paint()
          ..color = Colors.yellow
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PowerGaugePainter old) =>
      power != old.power || ftp != old.ftp;
}
