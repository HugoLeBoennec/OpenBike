import 'package:flutter/material.dart';
import '../../core/domain/value_objects/value_objects.dart';

class DataFieldGrid extends StatelessWidget {
  final Watts power;
  final Cadence cadence;
  final HeartRate heartRate;
  final Speed speed;

  const DataFieldGrid({
    super.key,
    required this.power,
    required this.cadence,
    required this.heartRate,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _DataField(label: 'Power', value: '${power.value.round()}', unit: 'W'),
        _DataField(label: 'Cadence', value: '${cadence.rpm}', unit: 'rpm'),
        _DataField(label: 'Heart Rate', value: '${heartRate.bpm}', unit: 'bpm'),
        _DataField(label: 'Speed', value: speed.kmh.toStringAsFixed(1), unit: 'km/h'),
      ],
    );
  }
}

class _DataField extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _DataField({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 4),
                Text(unit, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
