import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/live_tv.dart';

class DaddyLiveException implements Exception {
  const DaddyLiveException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DaddyLiveCatalog {
  const DaddyLiveCatalog({
    required this.channels,
    required this.epg,
    required this.categories,
  });

  final List<Channel> channels;
  final DaddyLiveEpg epg;
  final List<String> categories;
}

class DaddyLiveService {
  DaddyLiveService({required String baseUrl, http.Client? client})
      : _baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), ''),
        _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$_baseUrl$path').replace(queryParameters: query);

  Future<DaddyLiveCatalog> getCatalog({bool refresh = false}) async {
    final results = await Future.wait<dynamic>(<Future<dynamic>>[
      getChannels(refresh: refresh),
      getEpg(refresh: refresh),
    ]);
    final channels = results[0] as List<Channel>;
    final epg = results[1] as DaddyLiveEpg;
    final categoriesByChannel = <String, Set<String>>{};
    final categories = <String>{};
    for (final day in epg.days) {
      for (final category in day.categories) {
        categories.add(category.name);
        for (final event in category.events) {
          for (final channel in event.channels) {
            categoriesByChannel
                .putIfAbsent(channel.id, () => <String>{})
                .add(category.name);
          }
        }
      }
    }
    final enriched = channels
        .map(
          (channel) => channel.copyWith(
            categories: (categoriesByChannel[channel.id] ?? const <String>{})
                .toList(growable: false)
              ..sort(),
          ),
        )
        .toList(growable: false);
    final sortedCategories = categories.toList()..sort();
    return DaddyLiveCatalog(
      channels: enriched,
      epg: epg,
      categories: sortedCategories,
    );
  }

  Future<List<Channel>> getChannels({bool refresh = false}) async {
    final json = await _getJson(
      _uri('/api/v2/dlhd/channels', <String, String>{
        if (refresh) 'refresh': 'true',
      }),
    );
    return Channels.fromJson(json).channels;
  }

  Future<DaddyLiveEpg> getEpg({bool refresh = false}) async {
    final json = await _getJson(
      _uri('/api/v2/dlhd/epg', <String, String>{
        if (refresh) 'refresh': 'true',
      }),
    );
    return DaddyLiveEpg.fromJson(json);
  }

  Future<DaddyLiveStream> getStream(String channelId) async {
    final json = await _getJson(
      _uri('/api/v2/dlhd/channels/${Uri.encodeComponent(channelId)}/stream'),
    );
    final stream = DaddyLiveStream.fromJson(json);
    if (stream.url.isEmpty) {
      throw const DaddyLiveException(
          'The channel returned no playable stream.');
    }
    return stream;
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response =
        await _client.get(uri).timeout(const Duration(seconds: 60));
    final dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const DaddyLiveException(
          'The live TV service returned invalid data.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString() ?? decoded['error']?.toString()
          : null;
      throw DaddyLiveException(
          message ?? 'Live TV request failed (${response.statusCode}).');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const DaddyLiveException(
          'The live TV service returned an unexpected response.');
    }
    if (decoded['success'] == false) {
      throw DaddyLiveException(
          decoded['message']?.toString() ?? 'Live TV request failed.');
    }
    return decoded;
  }

  void close() => _client.close();
}
