import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/ports/storage_port.dart';
import '../../plugins/plugin_interfaces.dart';
import 'app_database.dart';

// ---------------------------------------------------------------------------
// Queue item model
// ---------------------------------------------------------------------------

class ExportQueueItem {
  final int id;
  final String rideId;
  final String target;
  final String status;
  final int retryCount;
  final DateTime? lastAttempt;
  final String? errorMessage;
  final DateTime createdAt;

  const ExportQueueItem({
    required this.id,
    required this.rideId,
    required this.target,
    required this.status,
    required this.retryCount,
    this.lastAttempt,
    this.errorMessage,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  bool get isUploading => status == 'uploading';
  bool get isSuccess => status == 'success';

  factory ExportQueueItem.fromRow(ExportQueueRow row) {
    return ExportQueueItem(
      id: row.id,
      rideId: row.rideId,
      target: row.target,
      status: row.status,
      retryCount: row.retryCount,
      lastAttempt: row.lastAttempt != null
          ? DateTime.fromMillisecondsSinceEpoch(row.lastAttempt!)
          : null,
      errorMessage: row.errorMessage,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    );
  }
}

// ---------------------------------------------------------------------------
// Export Queue Service
// ---------------------------------------------------------------------------

/// Persistent export queue backed by SQLite.
///
/// Manages the lifecycle of ride exports:
/// 1. Enqueue → mark pending
/// 2. Attempt upload immediately if online
/// 3. On failure → exponential backoff retry (max 5 attempts)
/// 4. On connectivity restored → resume pending/failed items
/// 5. On app start → call [processQueue] to pick up where we left off
class ExportQueueService {
  ExportQueueService({
    required AppDatabase db,
    required StoragePort storage,
    required Map<String, ExportPlugin> plugins,
    Connectivity? connectivity,
  })  : _db = db,
        _storage = storage,
        _plugins = plugins,
        _connectivity = connectivity ?? Connectivity();

  final AppDatabase _db;
  final StoragePort _storage;
  final Map<String, ExportPlugin> _plugins;
  final Connectivity _connectivity;

  static const int _maxRetries = 5;

  final _queueController =
      StreamController<List<ExportQueueItem>>.broadcast();
  StreamSubscription<ConnectivityResult>? _connectivitySub;
  bool _processing = false;
  bool _disposed = false;
  final List<Timer> _retryTimers = [];

  /// Live stream of queue items for the UI.
  Stream<List<ExportQueueItem>> get queueStream => _queueController.stream;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Call on app startup to resume pending exports and watch connectivity.
  void start() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((_) {
      processQueue();
    });
    processQueue();
  }

  void dispose() {
    _disposed = true;
    _connectivitySub?.cancel();
    for (final timer in _retryTimers) {
      timer.cancel();
    }
    _retryTimers.clear();
    _queueController.close();
  }

  // ---------------------------------------------------------------------------
  // Enqueue
  // ---------------------------------------------------------------------------

  /// Adds a new export to the queue and attempts it immediately.
  Future<void> enqueue(String rideId, String target) async {
    await _db.into(_db.exportQueue).insert(
          ExportQueueCompanion.insert(
            rideId: rideId,
            target: target,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    await _notifyListeners();
    await processQueue();
  }

  // ---------------------------------------------------------------------------
  // Queue processing
  // ---------------------------------------------------------------------------

  /// Processes all pending / retryable items in the queue.
  Future<void> processQueue() async {
    if (_processing || _disposed) return;
    _processing = true;

    try {
      final connectivity = await _connectivity.checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      final rows = await (_db.select(_db.exportQueue)
            ..where((t) =>
                t.status.isIn(['pending', 'failed']) &
                t.retryCount.isSmallerThanValue(_maxRetries))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

      for (final row in rows) {
        final item = ExportQueueItem.fromRow(row);
        final plugin = _plugins[item.target];

        if (plugin == null) {
          await _markFailed(item.id, 'No plugin registered for "${item.target}"');
          continue;
        }

        if (!plugin.isAuthenticated) {
          // Skip — the user hasn't authenticated this target yet.
          continue;
        }

        if (!isOnline) {
          // Skip — will retry when connectivity is restored.
          continue;
        }

        await _processItem(item, plugin);
      }
    } finally {
      _processing = false;
      await _notifyListeners();
    }
  }

  Future<void> _processItem(ExportQueueItem item, ExportPlugin plugin) async {
    // Mark as uploading.
    await (_db.update(_db.exportQueue)
          ..where((t) => t.id.equals(item.id)))
        .write(ExportQueueCompanion(
      status: const Value('uploading'),
      lastAttempt:
          Value(DateTime.now().millisecondsSinceEpoch),
    ));
    await _notifyListeners();

    try {
      // Load the full ride (with sensor readings).
      final ride = await _loadFullRide(item.rideId);
      if (ride == null) {
        await _markFailed(item.id, 'Ride not found: ${item.rideId}');
        return;
      }

      await plugin.export(ride);

      // Success!
      await (_db.update(_db.exportQueue)
            ..where((t) => t.id.equals(item.id)))
          .write(const ExportQueueCompanion(
        status: Value('success'),
      ));
    } catch (e) {
      final nextRetry = item.retryCount + 1;
      if (nextRetry >= _maxRetries) {
        await _markFailed(item.id, e.toString());
      } else {
        // Schedule retry with exponential backoff.
        await (_db.update(_db.exportQueue)
              ..where((t) => t.id.equals(item.id)))
            .write(ExportQueueCompanion(
          status: const Value('failed'),
          retryCount: Value(nextRetry),
          errorMessage: Value(e.toString()),
          lastAttempt: Value(DateTime.now().millisecondsSinceEpoch),
        ));

        // Backoff: 1s, 2s, 4s, 8s, 16s.
        final delay = Duration(seconds: pow(2, nextRetry - 1).toInt());
        final timer = Timer(delay, () => processQueue());
        _retryTimers.add(timer);
      }
    }
  }

  Future<void> _markFailed(int id, String error) async {
    await (_db.update(_db.exportQueue)
          ..where((t) => t.id.equals(id)))
        .write(ExportQueueCompanion(
      status: const Value('failed'),
      retryCount: const Value(_maxRetries),
      errorMessage: Value(error),
    ));
  }

  // ---------------------------------------------------------------------------
  // Query helpers
  // ---------------------------------------------------------------------------

  /// Returns all queue items, newest first.
  Future<List<ExportQueueItem>> getAll() async {
    final rows = await (_db.select(_db.exportQueue)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(ExportQueueItem.fromRow).toList();
  }

  /// Removes a completed or permanently failed item from the queue.
  Future<void> remove(int id) async {
    await (_db.delete(_db.exportQueue)
          ..where((t) => t.id.equals(id)))
        .go();
    await _notifyListeners();
  }

  /// Resets a failed item so it can be retried.
  Future<void> retry(int id) async {
    await (_db.update(_db.exportQueue)
          ..where((t) => t.id.equals(id)))
        .write(const ExportQueueCompanion(
      status: Value('pending'),
      retryCount: Value(0),
      errorMessage: Value(null),
    ));
    processQueue();
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<Ride?> _loadFullRide(String rideId) async {
    final ride = await _storage.getRide(rideId);
    if (ride == null) return null;
    final readings = await _storage.getSensorReadings(rideId);
    final laps = await _storage.getLaps(rideId);
    return ride.copyWith(readings: readings, laps: laps);
  }

  Future<void> _notifyListeners() async {
    if (_queueController.isClosed) return;
    final items = await getAll();
    _queueController.add(items);
  }
}
