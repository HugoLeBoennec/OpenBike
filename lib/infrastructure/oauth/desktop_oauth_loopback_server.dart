import 'dart:async';
import 'dart:io';

/// Local HTTP server used to complete OAuth2 authorization-code flows on
/// desktop (Windows/macOS/Linux), where custom URL schemes (`openbike://`)
/// are not reliably routed back into a running app.
///
/// Usage:
/// ```dart
/// final server = DesktopOAuthLoopbackServer();
/// final redirectUri = await server.start();
/// // ... register redirectUri with the OAuth provider, open the browser ...
/// final callback = await server.waitForCallback();
/// await server.close();
/// ```
class DesktopOAuthLoopbackServer {
  HttpServer? _server;
  final _completer = Completer<Uri>();

  /// Binds to a random free port on the loopback interface and starts
  /// listening. Returns the redirect URI to register with the OAuth
  /// provider, e.g. `http://127.0.0.1:53214/callback`.
  Future<Uri> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server = server;
    server.listen(_handleRequest);
    return Uri(
      scheme: 'http',
      host: InternetAddress.loopbackIPv4.address,
      port: server.port,
      path: '/callback',
    );
  }

  Future<void> _handleRequest(HttpRequest request) async {
    request.response
      ..statusCode = 200
      ..headers.contentType = ContentType.html
      ..write('<html><body>'
          '<h3>OpenBike connected</h3>'
          '<p>You can close this window and return to the app.</p>'
          '</body></html>');
    await request.response.close();

    if (!_completer.isCompleted) {
      _completer.complete(request.requestedUri);
    }
  }

  /// Completes with the full callback URI once the OAuth provider redirects
  /// the browser back to the loopback server.
  Future<Uri> waitForCallback({Duration timeout = const Duration(minutes: 5)}) {
    return _completer.future.timeout(timeout);
  }

  /// Stops listening. Safe to call multiple times.
  Future<void> close() async {
    await _server?.close(force: true);
    _server = null;
  }
}
