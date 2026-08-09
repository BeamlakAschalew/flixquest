import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class StreamIntroConfig {
  const StreamIntroConfig({required this.enabled, this.url});

  const StreamIntroConfig.disabled() : this(enabled: false);

  final bool enabled;
  final Uri? url;
}

class StreamIntroService {
  StreamIntroService({http.Client? client})
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  Future<StreamIntroConfig> fetch(String baseUrl) async {
    final response = await _client
        .get(_endpoint(baseUrl))
        .timeout(const Duration(seconds: 4));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StreamIntroException(
        'Intro configuration request failed (HTTP ${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map || decoded['success'] != true) {
      throw const StreamIntroException('Invalid intro configuration response');
    }
    final intro = decoded['intro'];
    if (intro is! Map || intro['enabled'] != true) {
      return const StreamIntroConfig.disabled();
    }

    final rawUrl = intro['url']?.toString().trim() ?? '';
    final url = Uri.tryParse(rawUrl);
    if (url == null ||
        url.host.isEmpty ||
        (url.scheme != 'http' && url.scheme != 'https')) {
      throw const StreamIntroException('Intro video URL is invalid');
    }
    return StreamIntroConfig(enabled: true, url: url);
  }

  Uri _endpoint(String baseUrl) {
    final normalized = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    if (normalized.isEmpty) {
      throw const StreamIntroException('Scraper API URL is not configured');
    }
    final root =
        normalized.endsWith('/api/v2') ? normalized : '$normalized/api/v2';
    return Uri.parse('$root/intro');
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}

class StreamIntroException implements Exception {
  const StreamIntroException(this.message);

  final String message;

  @override
  String toString() => message;
}
