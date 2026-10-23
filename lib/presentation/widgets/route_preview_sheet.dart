import 'dart:math';

import 'package:flutter/material.dart' hide Route;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/application/services/route_library.dart';
import '../../core/domain/entities/entities.dart';
import '../models/ride_extra.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import 'gpx_profile_widget.dart';
import 'ride_summary_widgets.dart';
import 'start_ride_actions.dart';

/// Opens the preview of a GPX file the rider just picked: name, profile,
/// "Save to library" switch and Start ride. [duplicate] is the saved route
/// it matches, if any — then there's nothing to save, and riding it rides
/// the saved copy.
Future<void> showImportedRoutePreview(
  BuildContext context, {
  required RouteDraft draft,
  SavedRoute? duplicate,
}) {
  return _show(context, RoutePreviewSheet(draft: draft, duplicate: duplicate));
}

/// Opens the preview of a route already in the library.
Future<void> showSavedRoutePreview(BuildContext context, SavedRoute route) {
  return _show(context, RoutePreviewSheet(saved: route));
}

Future<void> _show(BuildContext context, Widget sheet) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.tokens.surfaceTier2,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => sheet,
  );
}

/// Shared preview for a picked file ([draft]) and a saved route ([saved]).
class RoutePreviewSheet extends ConsumerStatefulWidget {
  const RoutePreviewSheet({super.key, this.draft, this.duplicate, this.saved})
      : assert((draft == null) != (saved == null));

  final RouteDraft? draft;
  final SavedRoute? duplicate;
  final SavedRoute? saved;

  @override
  ConsumerState<RoutePreviewSheet> createState() => _RoutePreviewSheetState();
}

class _RoutePreviewSheetState extends ConsumerState<RoutePreviewSheet> {
  late final TextEditingController _name;

  /// The route to ride: the picked file's at once, a saved one once loaded.
  Route? _route;
  bool _routeMissing = false;

  /// The library copy, once there is one: the saved route opened, the one
  /// the picked file duplicates, or the one just saved from it.
  SavedRoute? _inLibrary;
  bool _justSaved = false;
  bool _busy = false;

  bool get _isImport => widget.draft != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.draft?.route.name ?? '');
    _inLibrary = widget.saved ?? widget.duplicate;
    final draft = widget.draft;
    if (draft != null) {
      _route = draft.route;
    } else {
      ref.read(routeLibraryProvider).load(widget.saved!).then((route) {
        if (!mounted) return;
        setState(() {
          _route = route;
          _routeMissing = route == null;
        });
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      final saved = await ref
          .read(routeLibraryProvider)
          .save(widget.draft!, name: _name.text);
      ref.invalidate(savedRoutesProvider);
      if (!mounted) return;
      setState(() {
        _inLibrary = saved;
        _justSaved = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn\'t save the route: $e')),
        );
      }
    }
  }

  Future<void> _saveOnly() async {
    setState(() => _busy = true);
    await _save();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _startRide() async {
    final route = _route;
    if (route == null) return;
    setState(() => _busy = true);
    try {
      // Saved first, so the route is kept even if no trainer is paired yet.
      if (_isImport && _inLibrary == null && ref.read(saveImportedRoutesProvider)) {
        await _save();
        if (_inLibrary == null) return;
      }
      if (!mounted) return;
      final connected = await ensureTrainerConnected(
        context,
        ref,
        reason: 'Route simulation drives your trainer\'s resistance to match '
            'the terrain — pair a trainer first.',
      );
      if (!connected || !mounted) return;

      final saved = _inLibrary;
      final extra = saved != null
          ? RideExtra(
              route: route.copyWith(id: saved.id, name: saved.name),
              savedRouteId: saved.id,
            )
          : RideExtra(route: route, routeDraft: widget.draft);
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      router.go('/ride', extra: extra);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final saveSwitch = ref.watch(saveImportedRoutesProvider);
    final editingName = _isImport && _inLibrary == null;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: tokens.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (editingName)
            TextField(
              key: const Key('routeNameField'),
              controller: _name,
              enabled: saveSwitch,
              decoration: const InputDecoration(labelText: 'Name'),
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Text(
              _inLibrary?.name ?? _route?.name ?? '',
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: _routeMissing
                ? Center(
                    child: Text('This route is no longer in your library.',
                        style: TextStyle(color: tokens.textTertiary)),
                  )
                : _route == null
                    ? const Center(child: CircularProgressIndicator())
                    : GpxProfileWidget(points: _route!.points),
          ),
          const SizedBox(height: 16),
          _StatsRow(route: _route, saved: _inLibrary),
          const SizedBox(height: 16),
          if (_isImport) ...[
            if (_inLibrary != null)
              _LibraryNotice(
                text: _justSaved
                    ? 'Saved to your library.'
                    : 'Already in your library as “${_inLibrary!.name}”.',
              )
            else
              SwitchListTile(
                key: const Key('saveRouteSwitch'),
                contentPadding: EdgeInsets.zero,
                title: Text('Save to library',
                    style: TextStyle(color: tokens.textPrimary)),
                subtitle: Text('Keep it here to ride again',
                    style: TextStyle(color: tokens.textTertiary, fontSize: 12)),
                value: saveSwitch,
                onChanged: (value) {
                  ref.read(saveImportedRoutesProvider.notifier).state = value;
                  ref.read(appPreferencesProvider).setSaveImportedRoutes(value);
                },
              ),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            key: const Key('startRouteRideButton'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _route == null || _busy ? null : _startRide,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start ride',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          if (editingName && saveSwitch) ...[
            const SizedBox(height: 4),
            TextButton(
              key: const Key('saveRouteOnlyButton'),
              onPressed: _busy ? null : _saveOnly,
              child: const Text('Save without riding'),
            ),
          ],
          if (!_isImport) ...[
            const SizedBox(height: 24),
            _RouteRides(route: widget.saved!),
          ],
        ],
      ),
    );
  }
}

/// Whether [ride] covered [route] to the end — within 1 %, as trainers and
/// the simulator measure distance a little differently.
bool isRouteFinished(Ride ride, SavedRoute route) =>
    ride.totalDistance.meters >= route.distance.meters * 0.99;

/// The rides done on [route], newest first, with the fastest finished one
/// marked.
class _RouteRides extends ConsumerWidget {
  const _RouteRides({required this.route});

  final SavedRoute route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final rides = [
      for (final ride in ref.watch(rideHistoryProvider).valueOrNull ?? const [])
        if (ride.routeId == route.id) ride,
    ];
    if (rides.isEmpty) {
      return Text('Not ridden yet',
          style: TextStyle(color: tokens.textTertiary, fontSize: 13));
    }
    final finished = rides.where((r) => isRouteFinished(r, route));
    final best = finished.isEmpty
        ? null
        : finished.reduce(
            (a, b) => a.activeDuration <= b.activeDuration ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('YOUR RIDES ON THIS ROUTE'),
        const SizedBox(height: 8),
        for (final ride in rides)
          _RouteRideRow(
            ride: ride,
            finished: isRouteFinished(ride, route),
            best: ride.id == best?.id,
          ),
      ],
    );
  }
}

class _RouteRideRow extends StatelessWidget {
  const _RouteRideRow({
    required this.ride,
    required this.finished,
    required this.best,
  });

  final Ride ride;
  final bool finished;
  final bool best;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final highlight = best ? Colors.amber : tokens.textPrimary;

    return InkWell(
      key: Key('routeRide-${ride.id}'),
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        router.push('/history/${ride.id}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(formatDate(ride.startTime),
                  style: TextStyle(color: tokens.textSecondary)),
            ),
            Text(formatDuration(ride.activeDuration),
                style: TextStyle(
                    color: highlight,
                    fontWeight: best ? FontWeight.w700 : FontWeight.w500)),
            const SizedBox(width: 16),
            SizedBox(
              width: 56,
              child: Text('${ride.averagePower.value.round()} W',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: tokens.textSecondary)),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 24,
              child: best
                  ? const Tooltip(
                      message: 'Best time',
                      child: Icon(Icons.emoji_events,
                          color: Colors.amber, size: 18),
                    )
                  : finished
                      ? Tooltip(
                          message: 'Finished',
                          child: Icon(Icons.check_circle,
                              color: tokens.textTertiary, size: 18),
                        )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  const _StatsRow({required this.route, required this.saved});

  final Route? route;
  final SavedRoute? saved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(unitFormatterProvider);
    final route = this.route;
    final distance = route?.totalDistance ?? saved?.distance;
    final ascent = route?.totalAscent ?? saved?.ascent;
    final maxGrade = route == null || route.points.isEmpty
        ? null
        : route.points.map((p) => p.grade.percent).reduce(max);

    return Row(
      children: [
        _Stat(
          label: 'Distance',
          value: distance == null ? '–' : formatter.distance(distance),
        ),
        _Stat(
          label: 'Climbing',
          value: ascent == null ? '–' : formatter.elevationM(ascent),
        ),
        _Stat(
          label: 'Max grade',
          value: maxGrade == null ? '–' : '${maxGrade.toStringAsFixed(1)} %',
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  color: context.tokens.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          Text(label,
              style:
                  TextStyle(color: context.tokens.textTertiary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _LibraryNotice extends StatelessWidget {
  const _LibraryNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('routeLibraryNotice'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark_added, color: Colors.deepOrange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(color: context.tokens.textSecondary)),
          ),
        ],
      ),
    );
  }
}
