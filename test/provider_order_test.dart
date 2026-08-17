import 'package:flixquest/video_providers/names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoProviderOrder', () {
    final alpha = VideoProvider.scraper(id: 'alpha', name: 'Alpha');
    final beta = VideoProvider.scraper(id: 'beta', name: 'Beta');
    final gamma = VideoProvider.scraper(id: 'gamma', name: 'Gamma');

    test('uses stable provider codes for the preferred order', () {
      final ordered = VideoProviderOrder.apply(
        [alpha, beta, VideoProvider.directVixSrc],
        ['direct:vixsrc', 'scraper:beta', 'scraper:alpha'],
      );

      expect(
        ordered.map((provider) => provider.codeName),
        ['direct:vixsrc', 'scraper:beta', 'scraper:alpha'],
      );
    });

    test('ignores removed providers and inserts new ones at API indexes', () {
      final ordered = VideoProviderOrder.apply(
        [alpha, gamma, VideoProvider.directVixSrc],
        ['scraper:removed', 'direct:vixsrc', 'scraper:alpha'],
      );

      expect(
        ordered.map((provider) => provider.codeName),
        ['direct:vixsrc', 'scraper:gamma', 'scraper:alpha'],
      );
    });

    test('keeps custom relative order around a newly added provider', () {
      final ordered = VideoProviderOrder.apply(
        [alpha, gamma, beta, VideoProvider.directVixSrc],
        ['direct:vixsrc', 'scraper:beta', 'scraper:alpha'],
      );

      expect(
        ordered.map((provider) => provider.codeName),
        [
          'direct:vixsrc',
          'scraper:gamma',
          'scraper:beta',
          'scraper:alpha',
        ],
      );
    });

    test('inserts multiple new providers in API order', () {
      final delta = VideoProvider.scraper(id: 'delta', name: 'Delta');
      final ordered = VideoProviderOrder.apply(
        [gamma, alpha, delta, beta],
        ['scraper:beta', 'scraper:alpha'],
      );

      expect(
        ordered.map((provider) => provider.codeName),
        [
          'scraper:gamma',
          'scraper:beta',
          'scraper:delta',
          'scraper:alpha',
        ],
      );
    });

    test('deduplicates catalog and preference entries', () {
      final ordered = VideoProviderOrder.apply(
        [alpha, alpha, beta],
        ['scraper:alpha', 'scraper:alpha'],
      );

      expect(
        ordered.map((provider) => provider.codeName),
        ['scraper:alpha', 'scraper:beta'],
      );
    });
  });
}
