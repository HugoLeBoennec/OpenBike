import 'package:flutter/material.dart';

import '../../core/domain/entities/entities.dart';
import '../state/providers.dart';

/// Best mean-max power per duration bucket (5s/1min/5min/20min), all-time.
/// Shown on the History and Trends screens.
class PersonalRecordsPanel extends StatelessWidget {
  const PersonalRecordsPanel({super.key, required this.records});
  final List<PersonalRecord> records;

  static const _labels = {5: '5 SEC', 60: '1 MIN', 300: '5 MIN', 1200: '20 MIN'};

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No personal records yet — complete a ride to set some.',
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
      );
    }

    final best = bestPerDuration(records);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final duration in personalRecordDurations)
            _PrStat(
              label: _labels[duration] ?? '${duration}s',
              watts: best[duration]?.watts.value,
            ),
        ],
      ),
    );
  }
}

class _PrStat extends StatelessWidget {
  const _PrStat({required this.label, required this.watts});
  final String label;
  final double? watts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          watts != null ? '${watts!.round()}' : '—',
          style: const TextStyle(
              color: Colors.amber, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1)),
      ],
    );
  }
}
