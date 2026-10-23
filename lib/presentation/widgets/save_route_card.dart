import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../theme/app_theme.dart';

/// Ride summary card offering to keep the route of ride [rideId] when it
/// was ridden without saving it. Saving also links the ride to the route.
/// Shows nothing for any other ride.
class SaveRouteCard extends ConsumerStatefulWidget {
  const SaveRouteCard({super.key, required this.rideId});

  final String rideId;

  @override
  ConsumerState<SaveRouteCard> createState() => _SaveRouteCardState();
}

class _SaveRouteCardState extends ConsumerState<SaveRouteCard> {
  bool _saving = false;

  Future<void> _save() async {
    final unsaved = ref.read(unsavedRouteRideProvider);
    if (unsaved == null) return;
    setState(() => _saving = true);
    try {
      final library = ref.read(routeLibraryProvider);
      // Saved since from somewhere else? Link to that copy rather than
      // keeping the route twice.
      final existing = library.findDuplicate(
        unsaved.draft,
        await ref.read(savedRoutesProvider.future),
      );
      final saved = existing ?? await library.save(unsaved.draft);
      await ref.read(storageProvider).linkRideToRoute(unsaved.rideId, saved.id);

      ref.read(unsavedRouteRideProvider.notifier).state = null;
      ref.invalidate(savedRoutesProvider);
      ref.invalidate(rideHistoryProvider);
      ref.invalidate(rideDetailProvider(unsaved.rideId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('“${saved.name}” is in your library.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn\'t save the route: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unsaved = ref.watch(unsavedRouteRideProvider);
    if (unsaved == null || unsaved.rideId != widget.rideId) {
      return const SizedBox.shrink();
    }
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        key: const Key('saveRouteCard'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.deepOrange.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.terrain, color: Colors.deepOrange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(unsaved.draft.route.name,
                      style: TextStyle(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w600)),
                  Text('Keep this route to ride it again',
                      style:
                          TextStyle(color: tokens.textTertiary, fontSize: 12)),
                ],
              ),
            ),
            TextButton(
              key: const Key('saveRouteFromRideButton'),
              onPressed: _saving ? null : _save,
              child: const Text('Save to library'),
            ),
          ],
        ),
      ),
    );
  }
}
