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

    test('ignores removed providers and appends new providers', () {
      final ordered = VideoProviderOrder.apply(
        [alpha, gamma, VideoProvider.directVixSrc],
        ['scraper:removed', 'direct:vixsrc', 'scraper:alpha'],
      );

      expect(
        ordered.map((provider) => provider.codeName),
        ['direct:vixsrc', 'scraper:alpha', 'scraper:gamma'],
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

    test('can keep direct VixSrc after all scraper providers', () {
      final ordered = VideoProviderOrder.directVixSrcLast([
        VideoProvider.directVixSrc,
        beta,
        alpha,
      ]);

      expect(
        ordered.map((provider) => provider.codeName),
        ['scraper:beta', 'scraper:alpha', 'direct:vixsrc'],
      );
    });
  });
}
