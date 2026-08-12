import 'package:flutter_test/flutter_test.dart';

import 'package:flixquest/services/daddylive_service.dart';

void main() {
  test('turns API and client details into concise connection copy', () {
    final message = friendlyLiveTvError(
      Exception(
        'ClientException: Failed host lookup: https://api.example.test/v2',
      ),
    );

    expect(message, contains('Couldn’t connect to Live TV'));
    expect(message, isNot(contains('api.example.test')));
  });

  test('preserves a friendly DaddyLive API message', () {
    expect(
      friendlyLiveTvError(
        const DaddyLiveException('The channel returned no playable stream.'),
      ),
      'The channel returned no playable stream.',
    );
  });

  test('uses a useful message for timeouts', () {
    expect(
      friendlyLiveTvError(Exception('Request timed out after 60 seconds')),
      'Live TV is taking too long to respond. Please try again.',
    );
  });
}
