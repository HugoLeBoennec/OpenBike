import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:open_bike/plugins/exports/strava_export_plugin.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockHttpClient httpClient;
  late MockSecureStorage storage;
  late StravaExportPlugin plugin;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
    registerFallbackValue(<String, String>{});
  });

  setUp(() {
    httpClient = MockHttpClient();
    storage = MockSecureStorage();

    // Default: no cached session unless a test overrides a specific key.
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((_) async {});
    when(() => storage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});

    plugin = StravaExportPlugin(
      config: const StravaConfig(clientId: 'client-id', clientSecret: 'secret'),
      secureStorage: storage,
      httpClient: httpClient,
    );
  });

  Map<String, dynamic> tokenResponseBody({
    DateTime? expiresAt,
    String accessToken = 'access-123',
    String refreshToken = 'refresh-456',
  }) {
    final expiry = expiresAt ?? DateTime.now().add(const Duration(hours: 6));
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiry.millisecondsSinceEpoch ~/ 1000,
    };
  }

  void stubTokenExchange({Map<String, dynamic>? body, int status = 200}) {
    when(() => httpClient.post(any(), body: any(named: 'body'))).thenAnswer(
      (_) async => http.Response(jsonEncode(body ?? tokenResponseBody()), status),
    );
  }

  void stubAthlete({Map<String, dynamic>? body, int status = 200}) {
    when(() => httpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(
              jsonEncode(body ?? {'firstname': 'Jane', 'lastname': 'Doe'}),
              status,
            ));
  }

  group('isAuthenticated', () {
    test('false before any authentication', () {
      expect(plugin.isAuthenticated, isFalse);
    });
  });

  group('handleCallback', () {
    test('throws when the callback has no authorization code', () {
      expect(
        () => plugin.handleCallback(Uri.parse('openbike://strava/callback')),
        throwsA(isA<Exception>()),
      );
    });

    test('exchanges the code for tokens and becomes authenticated', () async {
      stubTokenExchange();
      stubAthlete();

      await plugin
          .handleCallback(Uri.parse('openbike://strava/callback?code=abc123'));

      expect(plugin.isAuthenticated, isTrue);
      verify(() => storage.write(key: 'strava_access_token', value: 'access-123'))
          .called(1);
      verify(() =>
              storage.write(key: 'strava_refresh_token', value: 'refresh-456'))
          .called(1);
    });

    test('fetches and caches the athlete display name', () async {
      stubTokenExchange();
      stubAthlete();

      await plugin
          .handleCallback(Uri.parse('openbike://strava/callback?code=abc123'));

      expect(plugin.athleteName, 'Jane Doe');
      verify(() => storage.write(key: 'strava_athlete_name', value: 'Jane Doe'))
          .called(1);
    });

    test('connection still succeeds if the athlete fetch fails', () async {
      stubTokenExchange();
      stubAthlete(status: 500);

      await plugin
          .handleCallback(Uri.parse('openbike://strava/callback?code=abc123'));

      expect(plugin.isAuthenticated, isTrue);
      expect(plugin.athleteName, isNull);
    });

    test('throws when token exchange fails', () async {
      stubTokenExchange(body: {'error': 'invalid_grant'}, status: 400);

      await expectLater(
        plugin.handleCallback(Uri.parse('openbike://strava/callback?code=bad')),
        throwsA(isA<Exception>()),
      );
      expect(plugin.isAuthenticated, isFalse);
    });
  });

  group('restoreSession', () {
    test('restores cached tokens and athlete name', () async {
      final future =
          DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch;
      when(() => storage.read(key: 'strava_access_token'))
          .thenAnswer((_) async => 'cached-access');
      when(() => storage.read(key: 'strava_refresh_token'))
          .thenAnswer((_) async => 'cached-refresh');
      when(() => storage.read(key: 'strava_expires_at'))
          .thenAnswer((_) async => future.toString());
      when(() => storage.read(key: 'strava_athlete_name'))
          .thenAnswer((_) async => 'Jane Doe');

      await plugin.restoreSession();

      expect(plugin.isAuthenticated, isTrue);
      expect(plugin.athleteName, 'Jane Doe');
    });

    test('isAuthenticated is false when the cached token has expired',
        () async {
      final past = DateTime.now()
          .subtract(const Duration(days: 1))
          .millisecondsSinceEpoch;
      when(() => storage.read(key: 'strava_access_token'))
          .thenAnswer((_) async => 'cached-access');
      when(() => storage.read(key: 'strava_expires_at'))
          .thenAnswer((_) async => past.toString());

      await plugin.restoreSession();

      expect(plugin.isAuthenticated, isFalse);
    });

    test('no-op when nothing was cached', () async {
      await plugin.restoreSession();
      expect(plugin.isAuthenticated, isFalse);
      expect(plugin.athleteName, isNull);
    });
  });

  group('disconnect', () {
    test('clears in-memory and stored tokens', () async {
      stubTokenExchange();
      stubAthlete();
      await plugin
          .handleCallback(Uri.parse('openbike://strava/callback?code=abc123'));
      expect(plugin.isAuthenticated, isTrue);

      await plugin.disconnect();

      expect(plugin.isAuthenticated, isFalse);
      expect(plugin.athleteName, isNull);
      verify(() => storage.delete(key: 'strava_access_token')).called(1);
      verify(() => storage.delete(key: 'strava_refresh_token')).called(1);
      verify(() => storage.delete(key: 'strava_expires_at')).called(1);
      verify(() => storage.delete(key: 'strava_athlete_name')).called(1);
    });
  });
}
