import 'package:flutter/material.dart';
import '../../core/domain/value_objects/value_objects.dart';

/// A simple real-time line chart for power / HR / cadence.
class LiveChart extends StatelessWidget {
  final List<double> dataPoints;
  final Color color;
  final double maxValue;

  const LiveChart({
    super.key,
    required this.dataPoints,
    this.color = Colors.blue,
    this.maxValue = 500,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LiveChartPainter(
        dataPoints: dataPoints,
        color: color,
        maxValue: maxValue,
      ),
      size: Size.infinite,
    );
  }
}

class _LiveChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;
  final double maxValue;

  _LiveChartPainter({
    required this.dataPoints,
    required this.color,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final dx = size.width / (dataPoints.length - 1);

    for (var i = 0; i < dataPoints.length; i++) {
      final x = i * dx;
      final y = size.height - (dataPoints[i] / maxValue * size.height).clamp(0, size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LiveChartPainter old) =>
      dataPoints.length != old.dataPoints.length ||
      (dataPoints.isNotEmpty && dataPoints.last != old.dataPoints.last);
}
