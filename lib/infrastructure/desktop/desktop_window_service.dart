import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

import '../preferences/app_preferences.dart';

/// Whether the running platform manages its window via [window_manager]
/// (i.e. a desktop build — mobile ignores window bounds entirely).
bool get isDesktopPlatform =>
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;

const _minimumSize = Size(1024, 700);
const _defaultSize = Size(1280, 800);

/// Sets up the native window on desktop platforms: minimum size, a
/// remembered size/position (falling back to a centered default on first
/// launch), and the app title. No-op on mobile.
///
/// Must run after `WidgetsFlutterBinding.ensureInitialized()` and before
/// `runApp`.
Future<void> initializeDesktopWindow(AppPreferences prefs) async {
  if (!isDesktopPlatform) return;

  await windowManager.ensureInitialized();

  final saved = prefs.windowBounds;
  final options = WindowOptions(
    size: saved != null ? Size(saved.width, saved.height) : _defaultSize,
    minimumSize: _minimumSize,
    center: saved == null,
    title: 'OpenBike',
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    if (saved != null) {
      await windowManager.setPosition(Offset(saved.x, saved.y));
    }
    await windowManager.show();
    await windowManager.focus();
  });

  windowManager.addListener(_BoundsPersistingWindowListener(prefs));
}

/// Persists the window's bounds a moment after the user stops resizing or
/// moving it, so the next launch reopens in the same place.
class _BoundsPersistingWindowListener with WindowListener {
  _BoundsPersistingWindowListener(this._prefs);

  final AppPreferences _prefs;
  Timer? _debounce;

  @override
  void onWindowResize() => _scheduleSave();

  @override
  void onWindowMove() => _scheduleSave();

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final bounds = await windowManager.getBounds();
      await _prefs.setWindowBounds(
        x: bounds.left,
        y: bounds.top,
        width: bounds.width,
        height: bounds.height,
      );
    });
  }
}
