import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'common.dart';
import 'names.dart';

/// Client for the FlixQuest Scraper API v2 described in `openapi.json`.
///
/// The API proxies streams by default. This is intentional: the returned URL
/// can then be handed directly to Better Player without exposing provider
/// headers or anti-hotlink details in the app.
class ScraperApi {
  ScraperApi(this.baseUrl, {http.Client? client})
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  final String baseUrl;
  final http.Client _client;
  final bool _ownsClient;

  Future<List<VideoProvider>> getProviders() async {
    try {
      final uri = _endpoint('/providers');
      _logRequest(uri);
      final response = await _get(uri);
      _logResponse(uri, response);
      final body = _decodeObject(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ScraperApiException(_messageFrom(body, response.statusCode));
      }
      if (body['success'] != true) {
        throw ScraperApiException(_messageFrom(body, response.statusCode));
      }

      final providers = body['providers'];
      if (providers is! List) return const [];
      return providers
          .whereType<Map>()
          .map((provider) => Map<String, dynamic>.from(provider))
          .where((provider) => provider['enabled'] == true)
          .map(
            (provider) => VideoProvider.scraper(
              id: provider['id']?.toString() ?? '',
              name: provider['name']?.toString() ?? 'Unknown provider',
              alias: provider['alias']?.toString(),
            ),
          )
          .where((provider) => provider.apiId?.isNotEmpty == true)
          .toList(growable: false);
    } finally {
      if (_ownsClient) _client.close();
    }
  }

  Future<ProviderLoadResult> loadMovie({
    required String providerId,
    required int movieId,
  }) {
    return _loadStream(
      '/stream-movie',
      _buildQueryParams(providerId, {'tmdbId': '$movieId'}),
    );
  }

  Future<ProviderLoadResult> loadTVEpisode({
    required String providerId,
    required int tvId,
    required int seasonNumber,
    required int episodeNumber,
  }) {
    return _loadStream(
      '/stream-tv',
      _buildQueryParams(providerId, {
        'tmdbId': '$tvId',
        'season': '$seasonNumber',
        'episode': '$episodeNumber',
      }),
    );
  }

  Map<String, String> _buildQueryParams(
    String providerId,
    Map<String, String> baseParams,
  ) {
    return {
      ...baseParams,
      'provider': providerId,
    };
  }

  Future<ProviderLoadResult> _loadStream(
    String path,
    Map<String, String> queryParameters,
  ) async {
    try {
      final uri = _endpoint(path, queryParameters);
      _logRequest(uri);
      final response = await _get(uri, timeout: const Duration(minutes: 1));
      _logResponse(uri, response);
      final body = _decodeObject(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return ProviderLoadResult(
          errorMessage: _messageFrom(body, response.statusCode),
        );
      }
      if (body['success'] != true) {
        return ProviderLoadResult(
          errorMessage: _messageFrom(body, response.statusCode),
        );
      }

      final links = <RegularVideoLinks>[];
      final subtitles = <RegularSubtitleLinks>[];
      final seenSubtitles = <String>{};
      final rawLinks = body['links'];
      if (rawLinks is List) {
        for (final rawLink in rawLinks.whereType<Map>()) {
          final link = Map<String, dynamic>.from(rawLink);
          final url = link['url']?.toString();
          if (url == null || url.isEmpty) continue;
          final linkHeaders = _parseHeaders(link['headers']);
          links.add(
            RegularVideoLinks(
              url: url,
              quality: link['quality']?.toString() ?? 'unknown quality',
              isM3U8: link['isM3U8'] == true,
              isDash: link['isDASH'] == true,
              headers: linkHeaders,
            ),
          );

          final rawSubtitles = link['subtitles'];
          if (rawSubtitles is List) {
            for (final rawSubtitle in rawSubtitles.whereType<Map>()) {
              final subtitle = Map<String, dynamic>.from(rawSubtitle);
              final file = subtitle['file']?.toString();
              if (file == null || file.isEmpty) continue;
              final language = subtitle['label']?.toString() ?? 'Unknown';
              if (seenSubtitles.add('$file\u0000$language')) {
                subtitles.add(
                  RegularSubtitleLinks(
                    url: file,
                    language: language,
                    headers: _parseHeaders(subtitle['headers']) ?? linkHeaders,
                  ),
                );
              }
            }
          }
        }
      }

      if (links.isEmpty) {
        return ProviderLoadResult(
          errorMessage: _messageFrom(body, response.statusCode),
        );
      }
      return ProviderLoadResult(
        success: true,
        videoLinks: links,
        subtitleLinks: subtitles,
      );
    } on TimeoutException {
      return const ProviderLoadResult(
          errorMessage: 'Scraper request timed out');
    } catch (error) {
      return ProviderLoadResult(errorMessage: error.toString());
    } finally {
      if (_ownsClient) _client.close();
    }
  }

  Future<http.Response> _get(
    Uri uri, {
    Duration timeout = const Duration(seconds: 30),
  }) {
    return _client.get(uri).timeout(timeout);
  }

  void _logRequest(Uri uri) {
    if (!kDebugMode) return;
    debugPrint('[ScraperApi] GET $uri');
  }

  void _logResponse(Uri uri, http.Response response) {
    if (!kDebugMode) return;
    debugPrint(
      '[ScraperApi] RESPONSE ${response.statusCode} $uri\n${response.body}',
    );
  }

  Uri _endpoint(String path, [Map<String, String>? queryParameters]) {
    final normalized = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    if (normalized.isEmpty) {
      throw const ScraperApiException('Scraper API URL is not configured');
    }
    final root =
        normalized.endsWith('/api/v2') ? normalized : '$normalized/api/v2';
    return Uri.parse('$root$path').replace(queryParameters: queryParameters);
  }

  Map<String, dynamic> _decodeObject(String text) {
    try {
      final value = jsonDecode(text);
      return value is Map<String, dynamic> ? value : const {};
    } on FormatException {
      return const {};
    }
  }

  Map<String, String>? _parseHeaders(Object? value) {
    if (value is! Map) return null;
    final headers = <String, String>{};
    for (final entry in value.entries) {
      if (entry.value is String) {
        headers[entry.key.toString()] = entry.value as String;
      }
    }
    return headers.isEmpty ? null : headers;
  }

  String _messageFrom(Map<String, dynamic> body, int statusCode) {
    final error = body['error']?.toString();
    if (error != null && error.isNotEmpty) return error;
    final details = body['details']?.toString();
    if (details != null && details.isNotEmpty) return details;
    return 'Scraper request failed (HTTP $statusCode)';
  }
}

class ScraperApiException implements Exception {
  const ScraperApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
