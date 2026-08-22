import 'package:flixquest/services/introdb_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('requests movie timings with duration and parses all segment types',
      () async {
    late Uri requestedUri;
    final service = IntroDbService(
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          '{"tmdb_id":42,'
          '"intro":[{"start_ms":null,"end_ms":90000}],'
          '"recap":[{"start_ms":1000,"end_ms":12000}],'
          '"credits":[{"start_ms":600000,"end_ms":null}],'
          '"preview":[{"start_ms":610000,"end_ms":620000}]}',
          200,
        );
      }),
    );

    final timings = await service.fetch(
      tmdbId: 42,
      isTv: false,
      durationMs: 630000,
    );

    expect(requestedUri.origin, 'https://api.theintrodb.org');
    expect(requestedUri.path, '/v3/media');
    expect(requestedUri.queryParameters, {
      'tmdb_id': '42',
      'duration_ms': '630000',
    });
    expect(timings.segments, hasLength(4));
    expect(timings.segments.first.startMs, 0);
    expect(timings.segments.last.type, IntroDbSegmentType.preview);
  });

  test('adds TV coordinates and treats 404 as no timings', () async {
    late Uri requestedUri;
    final service = IntroDbService(
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response('{}', 404);
      }),
    );

    final timings = await service.fetch(
      tmdbId: 7,
      isTv: true,
      season: 2,
      episode: 3,
    );

    expect(requestedUri.queryParameters['season'], '2');
    expect(requestedUri.queryParameters['episode'], '3');
    expect(timings.segments, isEmpty);
  });

  test('merges overlapping ranges of the same type', () async {
    final service = IntroDbService(
      client: MockClient(
        (_) async => http.Response(
          '{"intro":['
          '{"start_ms":1000,"end_ms":5000},'
          '{"start_ms":4000,"end_ms":9000},'
          '{"start_ms":12000,"end_ms":null},'
          '{"start_ms":13000,"end_ms":15000}]}',
          200,
        ),
      ),
    );

    final timings = await service.fetch(tmdbId: 1, isTv: false);

    expect(timings.segments, hasLength(2));
    expect(timings.segments[0].startMs, 1000);
    expect(timings.segments[0].endMs, 9000);
    expect(timings.segments[1].startMs, 12000);
    expect(timings.segments[1].endMs, isNull);
  });
}
