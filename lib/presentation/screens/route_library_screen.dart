import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/application/services/route_library.dart';
import '../../core/domain/entities/entities.dart';
import '../models/route_sort.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/route_mini_profile.dart';
import '../widgets/route_preview_sheet.dart';

/// The rider's saved routes, and where GPX files are picked to ride.
class RouteLibraryScreen extends ConsumerStatefulWidget {
  const RouteLibraryScreen({super.key});

  @override
  ConsumerState<RouteLibraryScreen> createState() => _RouteLibraryScreenState();
}

class _RouteLibraryScreenState extends ConsumerState<RouteLibraryScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(savedRoutesProvider);
    final sort = ref.watch(routeSortProvider);
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routes'),
        actions: [
          IconButton(
            key: const Key('routeSortButton'),
            icon: Icon(Icons.sort, color: tokens.textTertiary),
            tooltip: 'Sort',
            onPressed: () => _showSortOptions(sort),
          ),
        ],
      ),
      body: routesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Couldn\'t load your routes: $e',
                  style: const TextStyle(color: Colors.red)),
              TextButton(
                onPressed: () => ref.invalidate(savedRoutesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (routes) => routes.isEmpty
            ? const _EmptyLibrary()
            : _buildList(routes, sort),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('importRouteFab'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        onPressed: _importRoute,
        icon: const Icon(Icons.file_open),
        label: const Text('Import GPX'),
      ),
    );
  }

  Widget _buildList(List<SavedRoute> routes, RouteSort sort) {
    final tokens = context.tokens;
    final shown = sortAndFilterRoutes(routes, sort, query: _search.text);
    final now = DateTime.now();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            key: const Key('routeSearchField'),
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search routes',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              filled: true,
              fillColor: tokens.surfaceTier2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? Center(
                  child: Text('No routes match “${_search.text.trim()}”.',
                      style: TextStyle(color: tokens.textTertiary)),
                )
              : ListView.builder(
                  // Room for the FAB under the last tile.
                  padding: const EdgeInsets.only(top: 4, bottom: 88),
                  itemCount: shown.length,
                  itemBuilder: (context, index) {
                    final route = shown[index];
                    return _RouteTile(
                      route: route,
                      usage: routeUsageLabel(route, now),
                      onTap: () => showSavedRoutePreview(context, route),
                      onLongPress: route.isEditable
                          ? () => _showRouteActions(route)
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _importRoute() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gpx'],
      // Guarantees `bytes` alongside `path` — on Android/iOS a file coming
      // from a cloud-backed provider (Google Drive, "Files" on-demand
      // downloads, etc.) isn't materialized on local disk, so `path` comes
      // back null and bytes are the only way to read it.
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;

    final content = await _readPickedFile(file);
    if (content == null) {
      _showMessage('Could not read the selected file');
      return;
    }

    final library = ref.read(routeLibraryProvider);
    final RouteDraft draft;
    try {
      draft = library.read(content, fileName: file.name);
    } on EmptyRouteException catch (e) {
      _showMessage(e.toString());
      return;
    } catch (_) {
      _showMessage('This file isn\'t a GPX route');
      return;
    }

    final saved = await ref.read(savedRoutesProvider.future);
    if (!mounted) return;
    await showImportedRoutePreview(
      context,
      draft: draft,
      duplicate: library.findDuplicate(draft, saved),
    );
  }

  Future<String?> _readPickedFile(PlatformFile file) async {
    try {
      final path = file.path;
      if (path != null) return await File(path).readAsString();
      final bytes = file.bytes;
      if (bytes != null) return utf8.decode(bytes);
      return null;
    } catch (_) {
      return null;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSortOptions(RouteSort current) {
    final tokens = context.tokens;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.surfaceTier2,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in RouteSort.values)
              ListTile(
                key: Key('routeSort-${option.name}'),
                title: Text(option.label,
                    style: TextStyle(color: tokens.textPrimary)),
                trailing: option == current
                    ? const Icon(Icons.check, color: Colors.deepOrange)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(routeSortProvider.notifier).state = option;
                  ref.read(appPreferencesProvider).setRouteSort(option.name);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showRouteActions(SavedRoute route) {
    final tokens = context.tokens;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.surfaceTier2,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('renameRouteTile'),
              leading: Icon(Icons.edit, color: tokens.textPrimary),
              title: Text('Rename',
                  style: TextStyle(color: tokens.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _renameRoute(route);
              },
            ),
            ListTile(
              key: const Key('deleteRouteTile'),
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteRoute(route);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renameRoute(SavedRoute route) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameRouteDialog(initialName: route.name),
    );
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty || trimmed == route.name) return;

    await ref.read(storageProvider).renameRoute(route.id, trimmed);
    ref.invalidate(savedRoutesProvider);
  }

  Future<void> _deleteRoute(SavedRoute route) async {
    final tokens = context.tokens;
    final rides = route.rideCount;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.surfaceTier2,
        title: Text('Delete “${route.name}”?',
            style: TextStyle(color: tokens.textPrimary)),
        content: Text(
          rides == 0
              ? 'Remove this route from your library?'
              : '$rides ${rides == 1 ? 'ride' : 'rides'} used this route. '
                  'They stay in your history but lose their link to it.',
          style: TextStyle(color: tokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(storageProvider).deleteRoute(route.id);
    ref.invalidate(savedRoutesProvider);
    ref.invalidate(rideHistoryProvider);
  }
}

/// Owns its text controller, which must outlive the dialog's closing
/// animation — disposing it as soon as the dialog's future completes is
/// too early.
class _RenameRouteDialog extends StatefulWidget {
  const _RenameRouteDialog({required this.initialName});

  final String initialName;

  @override
  State<_RenameRouteDialog> createState() => _RenameRouteDialogState();
}

class _RenameRouteDialogState extends State<_RenameRouteDialog> {
  late final _controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AlertDialog(
      backgroundColor: tokens.surfaceTier2,
      title: Text('Rename route', style: TextStyle(color: tokens.textPrimary)),
      content: TextField(
        key: const Key('renameRouteField'),
        controller: _controller,
        autofocus: true,
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.terrain, size: 48, color: tokens.textDisabled),
            const SizedBox(height: 16),
            Text(
              'No saved routes yet.\nImport a .gpx file to ride it — and keep '
              'it here to ride again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: tokens.textTertiary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteTile extends ConsumerWidget {
  const _RouteTile({
    required this.route,
    required this.usage,
    required this.onTap,
    this.onLongPress,
  });

  final SavedRoute route;
  final String usage;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(unitFormatterProvider);
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      // Material (not a coloured Container) so ListTile's ink splashes draw
      // on top of the background instead of being hidden behind it.
      child: Material(
        color: tokens.surfaceTier2,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: SizedBox(
            width: 56,
            height: 32,
            child: RouteMiniProfile(profile: route.profile),
          ),
          title: Text(
            route.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: tokens.textPrimary, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${formatter.distance(route.distance)}  •  '
            '↑${formatter.elevationM(route.ascent)}  •  $usage',
            style: TextStyle(color: tokens.textTertiary, fontSize: 12),
          ),
          trailing: Icon(Icons.chevron_right, color: tokens.textDisabled),
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
