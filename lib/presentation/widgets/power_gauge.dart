import 'package:flutter/material.dart';
import '../../core/domain/value_objects/value_objects.dart';

class PowerGauge extends StatelessWidget {
  final Watts power;
  final double maxPower;

  const PowerGauge({
    super.key,
    required this.power,
    this.maxPower = 500,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${power.value.round()}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            'watts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}
