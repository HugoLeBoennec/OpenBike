import 'dart:async';

/// Singleton-ready event bus backed by a broadcast [StreamController].
///
/// All events flow through a single stream. Use [on<T>()] to filter by type.
/// Call [dispose()] when the bus is no longer needed to close the controller
/// and prevent memory leaks.
class EventBus {
  final _controller = StreamController<Object>.broadcast();

  /// The raw stream of all events.
  Stream<Object> get stream => _controller.stream;

  /// Returns a filtered stream that only emits events of type [T].
  Stream<T> on<T>() => _controller.stream.where((e) => e is T).cast<T>();

  /// Emits an [event] to all listeners.
  void fire(Object event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  /// Whether the underlying controller has been closed.
  bool get isDisposed => _controller.isClosed;

  /// Closes the stream controller. No events can be fired after this.
  void dispose() => _controller.close();
}
