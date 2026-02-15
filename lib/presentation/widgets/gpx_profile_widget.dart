import 'package:flutter/material.dart';
import '../../core/domain/entities/route_point.dart';

/// Displays the elevation profile of a GPX route.
class GpxProfileWidget extends StatelessWidget {
  final List<RoutePoint> points;
  final int? currentPointIndex;

  const GpxProfileWidget({
    super.key,
    required this.points,
    this.currentPointIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text('No route loaded'));
    }

    return CustomPaint(
      painter: _ElevationPainter(
        points: points,
        currentPointIndex: currentPointIndex,
        color: Theme.of(context).colorScheme.primary,
      ),
      size: Size.infinite,
    );
  }
}

class _ElevationPainter extends CustomPainter {
  final List<RoutePoint> points;
  final int? currentPointIndex;
  final Color color;

  _ElevationPainter({
    required this.points,
    required this.currentPointIndex,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final totalDist = points.last.distanceFromStart;
    if (totalDist <= 0) return;

    final minElev =
        points.map((p) => p.smoothedElevation).reduce((a, b) => a < b ? a : b);
    final maxElev =
        points.map((p) => p.smoothedElevation).reduce((a, b) => a > b ? a : b);
    final elevRange = (maxElev - minElev).clamp(1.0, double.infinity);

    final fillPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final linePath = Path();

    path.moveTo(0, size.height);
    for (var i = 0; i < points.length; i++) {
      final x = (points[i].distanceFromStart / totalDist) * size.width;
      final y = size.height -
          ((points[i].smoothedElevation - minElev) / elevRange * size.height);
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(linePath, linePaint);

    // Position marker.
    if (currentPointIndex != null && currentPointIndex! < points.length) {
      final pt = points[currentPointIndex!];
      final cx = (pt.distanceFromStart / totalDist) * size.width;
      final cy = size.height -
          ((pt.smoothedElevation - minElev) / elevRange * size.height);
      canvas.drawCircle(Offset(cx, cy), 5, Paint()..color = Colors.red);

      // Stats text.
      final grade = pt.grade.percent;
      final distRemaining =
          (points.last.distanceFromStart - pt.distanceFromStart) / 1000;
      final text = '${grade.toStringAsFixed(1)}%  '
          '${distRemaining.toStringAsFixed(1)} km left';
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(color: color, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx + 8, cy - 6));
    }
  }

  @override
  bool shouldRepaint(covariant _ElevationPainter old) =>
      currentPointIndex != old.currentPointIndex ||
      points.length != old.points.length;
}
