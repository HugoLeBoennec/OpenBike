import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// ⓘ next to CTL/ATL/TSB that explains them in a dialog. A tap rather than a
/// hover tooltip: on phones a tooltip needs a long-press nobody finds.
class FitnessInfoButton extends StatelessWidget {
  const FitnessInfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('fitnessInfoButton'),
      icon: Icon(Icons.info_outline, size: 18, color: context.tokens.textTertiary),
      tooltip: 'What do CTL, ATL and TSB mean?',
      visualDensity: VisualDensity.compact,
      onPressed: () => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Fitness, fatigue and form'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Term(
                color: Colors.blueAccent,
                name: 'CTL — Fitness',
                meaning: 'Your training load over the last ~6 weeks. It rises '
                    'slowly as you train consistently.',
              ),
              _Term(
                color: Colors.orangeAccent,
                name: 'ATL — Fatigue',
                meaning: 'Your training load over the last week. It jumps '
                    'after hard days and drops quickly with rest.',
              ),
              _Term(
                color: Colors.purpleAccent,
                name: 'TSB — Form',
                meaning: 'Fitness minus fatigue. Negative means tired, which '
                    'is normal while building; positive means fresh, good '
                    'before a test or an event.',
              ),
              Text(
                'All three come from the training stress score (TSS) of '
                'each ride.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Term extends StatelessWidget {
  const _Term({required this.color, required this.name, required this.meaning});

  final Color color;
  final String name;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(meaning),
        ],
      ),
    );
  }
}
