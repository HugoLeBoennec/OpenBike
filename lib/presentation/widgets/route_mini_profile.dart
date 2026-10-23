import 'dart:math';

import 'package:flutter/material.dart';

/// Compact elevation sparkline from a saved route's stored profile samples,
/// so the library can draw one per tile without loading any GPX.
class RouteMiniProfile extends StatelessWidget {
  const RouteMiniProfile({
    super.key,
    required this.profile,
    this.color = Colors.green,
    this.size = const Size(56, 32),
  });

  final List<double> profile;
  final Color color;
  final Size size;

  @override
  Widget build(BuildContext context) {
    if (profile.length < 2) return SizedBox.fromSize(size: size);
    return CustomPaint(
      painter: _SparklinePainter(profile, color),
      size: size,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.profile, this.color);

  final List<double> profile;
  final Color color;

  /// Height span drawn at least this tall, so a flat route looks flat
  /// rather than stretching a few metres of noise to the full height.
  static const _minSpanM = 150.0;

  @override
  void paint(Canvas canvas, Size size) {
    final low = profile.reduce(min);
    final high = profile.reduce(max);
    final span = max(high - low, _minSpanM);

    Offset at(int i) => Offset(
          size.width * i / (profile.length - 1),
          size.height * (1 - (profile[i] - low) / span),
        );

    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < profile.length; i++) {
      line.lineTo(at(i).dx, at(i).dy);
    }
    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.25));
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.profile != profile || old.color != color;
}
