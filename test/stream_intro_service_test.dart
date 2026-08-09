import 'package:flixquest/services/stream_intro_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('loads an enabled intro from an API URL without the v2 suffix',
      () async {
    late Uri requestedUri;
    final service = StreamIntroService(
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          '{"success":true,"intro":{"enabled":true,'
          '"url":"https://cdn.example.com/intro.mp4"}}',
          200,
        );
      }),
    );

    final config = await service.fetch('https://api.example.com/');

    expect(requestedUri.toString(), 'https://api.example.com/api/v2/intro');
    expect(config.enabled, isTrue);
    expect(config.url.toString(), 'https://cdn.example.com/intro.mp4');
  });

  test('accepts an API URL that already includes the v2 suffix', () async {
    late Uri requestedUri;
    final service = StreamIntroService(
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          '{"success":true,"intro":{"enabled":false,"url":null}}',
          200,
        );
      }),
    );

    final config = await service.fetch('https://api.example.com/api/v2');

    expect(requestedUri.toString(), 'https://api.example.com/api/v2/intro');
    expect(config.enabled, isFalse);
  });

  test('rejects a non-HTTP intro URL', () async {
    final service = StreamIntroService(
      client: MockClient(
        (_) async => http.Response(
          '{"success":true,"intro":{"enabled":true,'
          '"url":"file:///intro.mp4"}}',
          200,
        ),
      ),
    );

    expect(
      () => service.fetch('https://api.example.com'),
      throwsA(isA<StreamIntroException>()),
    );
  });
}
