import 'package:flutter/material.dart';

/// The single source of truth for loading-state colors in the app.
///
/// Keep these values independent from the generated accent [ColorScheme]. That
/// prevents dynamic/occasional themes from turning neutral loading surfaces
/// into high-contrast or saturated flashes.
@immutable
class AppLoadingColors extends ThemeExtension<AppLoadingColors> {
  const AppLoadingColors({
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.cachedImagePlaceholder,
  });

  /// Soft loading colors for the light theme.
  static const light = AppLoadingColors(
    shimmerBase: Color(0xFFE5E8EC),
    shimmerHighlight: Color(0xFFF6F7F9),
    cachedImagePlaceholder: Color(0xFFE9ECEF),
  );

  /// Raised neutral loading colors for the dark theme.
  static const dark = AppLoadingColors(
    shimmerBase: Color(0xFF353A40),
    shimmerHighlight: Color(0xFF484E55),
    cachedImagePlaceholder: Color(0xFF30353A),
  );

  /// Low-glare loading colors that remain visible on a true-black background.
  static const amoled = AppLoadingColors(
    shimmerBase: Color(0xFF202429),
    shimmerHighlight: Color(0xFF343A40),
    cachedImagePlaceholder: Color(0xFF1A1E22),
  );

  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color cachedImagePlaceholder;

  static AppLoadingColors forThemeMode(String themeMode) {
    switch (themeMode.toLowerCase()) {
      case 'light':
        return light;
      case 'amoled':
        return amoled;
      case 'dark':
      default:
        return dark;
    }
  }

  static AppLoadingColors of(BuildContext context) =>
      Theme.of(context).extension<AppLoadingColors>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  @override
  AppLoadingColors copyWith({
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? cachedImagePlaceholder,
  }) {
    return AppLoadingColors(
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      cachedImagePlaceholder:
          cachedImagePlaceholder ?? this.cachedImagePlaceholder,
    );
  }

  @override
  AppLoadingColors lerp(
    covariant ThemeExtension<AppLoadingColors>? other,
    double t,
  ) {
    if (other is! AppLoadingColors) return this;
    return AppLoadingColors(
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight:
          Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      cachedImagePlaceholder: Color.lerp(
        cachedImagePlaceholder,
        other.cachedImagePlaceholder,
        t,
      )!,
    );
  }
}
