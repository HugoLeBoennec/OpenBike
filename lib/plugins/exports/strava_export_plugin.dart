import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../core/domain/entities/entities.dart';
import '../../core/domain/ports/export_port.dart';
import '../../infrastructure/files/fit_encoder.dart';
import '../plugin_interfaces.dart';
import '../plugin_manifest.dart';

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

/// Strava API configuration. Load from environment / config file — never
/// hard-code client secrets.
class StravaConfig {
  final String clientId;
  final String clientSecret;
  final String redirectUri;

  const StravaConfig({
    required this.clientId,
    required this.clientSecret,
    this.redirectUri = 'openbike://strava/callback',
  });
}

// ---------------------------------------------------------------------------
// Plugin
// ---------------------------------------------------------------------------

class StravaExportPlugin implements ExportPlugin {
  StravaExportPlugin({
    required StravaConfig config,
    FlutterSecureStorage? secureStorage,
    http.Client? httpClient,
    FitEncoder? fitEncoder,
  })  : _config = config,
        _storage = secureStorage ?? const FlutterSecureStorage(),
        _http = httpClient ?? http.Client(),
        _fitEncoder = fitEncoder ?? FitEncoder();

  final StravaConfig _config;
  final FlutterSecureStorage _storage;
  final http.Client _http;
  final FitEncoder _fitEncoder;

  // OAuth tokens (cached in memory).
  String? _accessToken;
  String? _refreshToken;
  DateTime? _expiresAt;
  String? _athleteName;

  // Secure storage keys.
  static const _keyAccessToken = 'strava_access_token';
  static const _keyRefreshToken = 'strava_refresh_token';
  static const _keyExpiresAt = 'strava_expires_at';
  static const _keyAthleteName = 'strava_athlete_name';

  // API endpoints.
  static const _authorizeUrl = 'https://www.strava.com/oauth/authorize';
  static const _tokenUrl = 'https://www.strava.com/oauth/token';
  static const _uploadUrl = 'https://www.strava.com/api/v3/uploads';

  // Rate limits: 200/15min, 2000/day — tracked for informational purposes.
  static const _maxPer15Min = 200;
  int _requestCount15Min = 0;
  DateTime _windowStart = DateTime.now();

  // ---------------------------------------------------------------------------
  // Manifest
  // ---------------------------------------------------------------------------

  @override
  PluginManifest get manifest => const PluginManifest(
        id: 'strava-export',
        name: 'Strava',
        version: '1.0.0',
        type: PluginType.export,
        author: 'OpenBike',
        description: 'Upload activities to Strava',
        capabilities: ['oauth2', 'upload-fit'],
      );

  // ---------------------------------------------------------------------------
  // Auth state
  // ---------------------------------------------------------------------------

  @override
  bool get isAuthenticated =>
      _accessToken != null &&
      (_expiresAt == null || _expiresAt!.isAfter(DateTime.now()));

  @override
  String? get athleteName => _athleteName;

  /// Loads previously stored tokens from secure storage.
  Future<void> restoreSession() async {
    _accessToken = await _storage.read(key: _keyAccessToken);
    _refreshToken = await _storage.read(key: _keyRefreshToken);
    final expiresStr = await _storage.read(key: _keyExpiresAt);
    if (expiresStr != null) {
      _expiresAt =
          DateTime.fromMillisecondsSinceEpoch(int.parse(expiresStr));
    }
    _athleteName = await _storage.read(key: _keyAthleteName);
  }

  // ---------------------------------------------------------------------------
  // OAuth2 flow
  // ---------------------------------------------------------------------------

  @override
  Future<void> authenticate() async {
    final uri = Uri.parse(_authorizeUrl).replace(queryParameters: {
      'client_id': _config.clientId,
      'redirect_uri': _config.redirectUri,
      'response_type': 'code',
      'scope': 'activity:write',
      'approval_prompt': 'auto',
    });

    if (!await canLaunchUrl(uri)) {
      throw Exception('Cannot launch Strava authorization URL');
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Called when the app receives the deep link callback.
  ///
  /// [callbackUri] is the full URI: `pedalhub://strava/callback?code=XXX`.
  Future<void> handleCallback(Uri callbackUri) async {
    final code = callbackUri.queryParameters['code'];
    if (code == null) {
      throw Exception(
        'Strava callback missing authorization code: $callbackUri',
      );
    }
    await _exchangeCode(code);
  }

  Future<void> _exchangeCode(String code) async {
    final response = await _post(_tokenUrl, body: {
      'client_id': _config.clientId,
      'client_secret': _config.clientSecret,
      'code': code,
      'grant_type': 'authorization_code',
    });

    if (response.statusCode != 200) {
      throw Exception('Strava token exchange failed: ${response.body}');
    }

    await _parseAndStoreTokens(response.body);
  }

  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available — re-authenticate');
    }

    final response = await _post(_tokenUrl, body: {
      'client_id': _config.clientId,
      'client_secret': _config.clientSecret,
      'refresh_token': _refreshToken!,
      'grant_type': 'refresh_token',
    });

    if (response.statusCode != 200) {
      // Refresh failed — clear tokens so isAuthenticated returns false.
      await disconnect();
      throw Exception('Strava token refresh failed: ${response.body}');
    }

    await _parseAndStoreTokens(response.body);
  }

  Future<void> _parseAndStoreTokens(String responseBody) async {
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    _accessToken = json['access_token'] as String;
    _refreshToken = json['refresh_token'] as String;
    final expiresAtEpoch = json['expires_at'] as int; // Unix seconds
    _expiresAt =
        DateTime.fromMillisecondsSinceEpoch(expiresAtEpoch * 1000);

    final athlete = json['athlete'] as Map<String, dynamic>?;
    if (athlete != null) {
      final first = athlete['firstname'] as String? ?? '';
      final last = athlete['lastname'] as String? ?? '';
      _athleteName = '$first $last'.trim();
      if (_athleteName!.isNotEmpty) {
        await _storage.write(key: _keyAthleteName, value: _athleteName);
      }
    }

    await _storage.write(key: _keyAccessToken, value: _accessToken);
    await _storage.write(key: _keyRefreshToken, value: _refreshToken);
    await _storage.write(
      key: _keyExpiresAt,
      value: _expiresAt!.millisecondsSinceEpoch.toString(),
    );
  }

  /// Ensures we have a valid (non-expired) access token.
  Future<void> _ensureValidToken() async {
    if (_accessToken == null) {
      throw Exception('Not authenticated with Strava');
    }
    if (_expiresAt != null && _expiresAt!.isBefore(DateTime.now())) {
      await _refreshAccessToken();
    }
  }

  @override
  Future<void> disconnect() async {
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;
    _athleteName = null;
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyExpiresAt);
    await _storage.delete(key: _keyAthleteName);
  }

  // ---------------------------------------------------------------------------
  // Upload
  // ---------------------------------------------------------------------------

  @override
  Future<String> export(
    Ride ride, {
    ExportFormat format = ExportFormat.fit,
  }) async {
    await _ensureValidToken();
    _checkRateLimit();

    // 1. Encode ride to FIT binary
    final Uint8List fitBytes = _fitEncoder.encode(ride);

    // 2. Upload via multipart POST
    final uploadId = await _uploadFit(fitBytes, ride);

    // 3. Poll until processing is complete
    return _pollUploadStatus(uploadId);
  }

  Future<int> _uploadFit(Uint8List fitBytes, Ride ride) async {
    final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
    request.headers['Authorization'] = 'Bearer $_accessToken';

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fitBytes,
      filename: '${ride.id}.fit',
    ));
    request.fields['data_type'] = 'fit';
    request.fields['activity_type'] = 'VirtualRide';

    final name = 'Indoor Ride — '
        '${ride.startTime.day}/${ride.startTime.month}/${ride.startTime.year}';
    request.fields['name'] = name;

    final streamedResponse = await _http.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    _requestCount15Min++;

    if (response.statusCode != 201) {
      throw Exception('Strava upload failed (${response.statusCode}): '
          '${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['id'] as int;
  }

  /// Polls `GET /api/v3/uploads/{id}` until the upload is processed.
  ///
  /// Returns the Strava activity ID as a string.
  Future<String> _pollUploadStatus(int uploadId) async {
    const maxAttempts = 10;
    const delay = Duration(seconds: 3);

    for (var i = 0; i < maxAttempts; i++) {
      await Future<void>.delayed(delay);
      await _ensureValidToken();
      _checkRateLimit();

      final response = await _get('$_uploadUrl/$uploadId');
      _requestCount15Min++;

      if (response.statusCode != 200) continue;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = json['status'] as String?;
      final activityId = json['activity_id'];

      if (status == 'Your activity is ready.' && activityId != null) {
        return activityId.toString();
      }
      if (json['error'] != null) {
        throw Exception('Strava processing error: ${json['error']}');
      }
    }

    throw Exception(
      'Strava upload $uploadId still processing after $maxAttempts polls',
    );
  }

  // ---------------------------------------------------------------------------
  // Rate limiting
  // ---------------------------------------------------------------------------

  void _checkRateLimit() {
    final now = DateTime.now();
    if (now.difference(_windowStart).inMinutes >= 15) {
      _requestCount15Min = 0;
      _windowStart = now;
    }
    if (_requestCount15Min >= _maxPer15Min) {
      throw Exception(
        'Strava rate limit reached ($_maxPer15Min requests / 15 min). '
        'Try again later.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // HTTP helpers
  // ---------------------------------------------------------------------------

  Future<http.Response> _post(String url, {Map<String, String>? body}) {
    return _http.post(Uri.parse(url), body: body);
  }

  Future<http.Response> _get(String url) {
    return _http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
  }
}
