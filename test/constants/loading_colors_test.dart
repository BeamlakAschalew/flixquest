import 'package:flixquest/constants/loading_colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLoadingColors', () {
    test('selects a distinct palette for every supported theme', () {
      expect(AppLoadingColors.forThemeMode('light'), AppLoadingColors.light);
      expect(AppLoadingColors.forThemeMode('dark'), AppLoadingColors.dark);
      expect(AppLoadingColors.forThemeMode('amoled'), AppLoadingColors.amoled);

      final bases = <int>{
        AppLoadingColors.light.shimmerBase.toARGB32(),
        AppLoadingColors.dark.shimmerBase.toARGB32(),
        AppLoadingColors.amoled.shimmerBase.toARGB32(),
      };
      expect(bases, hasLength(3));
    });

    test('uses dark as the safe fallback for unknown legacy values', () {
      expect(AppLoadingColors.forThemeMode('unknown'), AppLoadingColors.dark);
    });

    test('keeps cached image and shimmer colors independently configurable',
        () {
      expect(
        AppLoadingColors.amoled.cachedImagePlaceholder,
        isNot(AppLoadingColors.amoled.shimmerBase),
      );
    });

    test('keeps the shimmer sweep low contrast in every theme', () {
      for (final colors in <AppLoadingColors>[
        AppLoadingColors.light,
        AppLoadingColors.dark,
        AppLoadingColors.amoled,
      ]) {
        final contrastDelta = (colors.shimmerHighlight.computeLuminance() -
                colors.shimmerBase.computeLuminance())
            .abs();
        expect(contrastDelta, lessThan(0.08));
      }
    });
  });
}
