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
    shimmerBase: Color(0xFFE9EBEE),
    shimmerHighlight: Color(0xFFEFF1F3),
    cachedImagePlaceholder: Color(0xFFF1F2F4),
  );

  /// Raised neutral loading colors for the dark theme.
  static const dark = AppLoadingColors(
    shimmerBase: Color(0xFF292D31),
    shimmerHighlight: Color(0xFF30353A),
    cachedImagePlaceholder: Color(0xFF23272B),
  );

  /// Low-glare loading colors that remain visible on a true-black background.
  static const amoled = AppLoadingColors(
    shimmerBase: Color(0xFF171A1D),
    shimmerHighlight: Color(0xFF1E2226),
    cachedImagePlaceholder: Color(0xFF111416),
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
