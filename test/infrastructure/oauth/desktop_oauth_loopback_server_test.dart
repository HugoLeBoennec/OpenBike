import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:open_bike/infrastructure/oauth/desktop_oauth_loopback_server.dart';

void main() {
  group('DesktopOAuthLoopbackServer', () {
    test('start() returns a loopback redirect URI', () async {
      final server = DesktopOAuthLoopbackServer();
      final uri = await server.start();

      expect(uri.scheme, 'http');
      expect(uri.host, '127.0.0.1');
      expect(uri.path, '/callback');
      expect(uri.port, greaterThan(0));

      await server.close();
    });

    test('waitForCallback resolves with the query params from the redirect',
        () async {
      final server = DesktopOAuthLoopbackServer();
      final redirectUri = await server.start();

      final callbackFuture = server.waitForCallback();
      final response = await http.get(redirectUri.replace(queryParameters: {
        'code': 'test-auth-code',
        'state': 'xyz',
      }));
      expect(response.statusCode, 200);

      final callback = await callbackFuture;
      expect(callback.queryParameters['code'], 'test-auth-code');
      expect(callback.queryParameters['state'], 'xyz');

      await server.close();
    });

    test('waitForCallback times out if no request arrives', () async {
      final server = DesktopOAuthLoopbackServer();
      await server.start();

      expect(
        server.waitForCallback(timeout: const Duration(milliseconds: 50)),
        throwsA(isA<TimeoutException>()),
      );

      await server.close();
    });

    test('close() is safe to call twice', () async {
      final server = DesktopOAuthLoopbackServer();
      await server.start();
      await server.close();
      await server.close();
    });
  });
}
