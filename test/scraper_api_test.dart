import 'dart:convert';

import 'package:flixquest/video_providers/scraper_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ScraperApi', () {
    test('maps enabled API providers, aliases, and content metadata', () async {
      late Uri requestedUri;
      final api = ScraperApi(
        'https://scraper.example',
        client: MockClient((request) async {
          requestedUri = request.url;
          return http.Response(
            jsonEncode({
              'success': true,
              'providers': [
                {
                  'id': 'vidsrc',
                  'name': 'VidSrc upstream',
                  'alias': 'VidSrc',
                  'content': 'Hollywood: English | Anime: Japanese',
                  'enabled': true,
                },
                {
                  'id': 'disabled',
                  'name': 'Disabled',
                  'alias': 'Disabled',
                  'enabled': false,
                },
              ],
            }),
            200,
          );
        }),
      );

      final providers = await api.getProviders();

      expect(requestedUri.path, '/api/v2/providers');
      expect(providers, hasLength(1));
      expect(providers.single.apiId, 'vidsrc');
      expect(providers.single.codeName, 'scraper:vidsrc');
      expect(providers.single.displayName, 'VidSrc');
      expect(providers.single.content, 'Hollywood: English | Anime: Japanese');
    });

    test('normalizes movie links, subtitles, and proxy stream type', () async {
      late Uri requestedUri;
      final api = ScraperApi(
        'https://scraper.example/api/v2',
        client: MockClient((request) async {
          requestedUri = request.url;
          return http.Response(
            jsonEncode({
              'success': true,
              'provider': 'vidsrc',
              'links': [
                {
                  'url': 'https://scraper.example/proxy?token=first',
                  'quality': '1080p',
                  'isM3U8': true,
                  'isDASH': false,
                  'headers': {
                    'Referer': 'https://provider.example/',
                    'Origin': 'https://provider.example',
                  },
                  'subtitles': [
                    {
                      'file': 'https://subs.example/en.vtt',
                      'label': 'English',
                      'kind': 'captions',
                    },
                  ],
                },
                {
                  'url': 'https://scraper.example/proxy?token=second',
                  'quality': '720p',
                  'isM3U8': false,
                  'isDASH': true,
                  'subtitles': [
                    {
                      'file': 'https://subs.example/en.vtt',
                      'label': 'English',
                      'kind': 'captions',
                    },
                  ],
                },
              ],
            }),
            200,
          );
        }),
      );

      final result = await api.loadMovie(providerId: 'vidsrc', movieId: 42);

      expect(requestedUri.path, '/api/v2/stream-movie');
      expect(requestedUri.queryParameters, {
        'tmdbId': '42',
        'provider': 'vidsrc',
      });
      expect(result.success, isTrue);
      expect(result.videoLinks, hasLength(2));
      expect(result.videoLinks!.first.isM3U8, isTrue);
      expect(result.videoLinks!.first.headers, {
        'Referer': 'https://provider.example/',
        'Origin': 'https://provider.example',
      });
      expect(result.videoLinks!.last.isDash, isTrue);
      expect(result.subtitleLinks, hasLength(1));
      expect(result.subtitleLinks!.single.headers, {
        'Referer': 'https://provider.example/',
        'Origin': 'https://provider.example',
      });
    });

    test('uses the documented TV episode query parameters', () async {
      late Uri requestedUri;
      final api = ScraperApi(
        'https://scraper.example',
        client: MockClient((request) async {
          requestedUri = request.url;
          return http.Response(
            jsonEncode({
              'success': true,
              'provider': 'vidsrc',
              'links': [
                {
                  'url': 'https://scraper.example/proxy?token=tv',
                  'quality': 'auto',
                  'isM3U8': true,
                  'subtitles': [],
                },
              ],
            }),
            200,
          );
        }),
      );

      final result = await api.loadTVEpisode(
        providerId: 'vidsrc',
        tvId: 99,
        seasonNumber: 2,
        episodeNumber: 3,
      );

      expect(result.success, isTrue);
      expect(requestedUri.path, '/api/v2/stream-tv');
      expect(requestedUri.queryParameters, {
        'tmdbId': '99',
        'season': '2',
        'episode': '3',
        'provider': 'vidsrc',
      });
    });
  });
}
