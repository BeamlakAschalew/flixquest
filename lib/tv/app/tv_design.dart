import 'package:flutter/material.dart';

class TvShellMetrics {
  const TvShellMetrics({
    required this.compact,
    required this.safeInset,
    required this.railWidth,
    required this.railGap,
    required this.contentPadding,
    required this.navItemHeight,
    required this.navItemGap,
    required this.mediaCardWidth,
  });

  factory TvShellMetrics.fromConstraints(BoxConstraints constraints) {
    final compact = constraints.maxHeight < 700 || constraints.maxWidth < 1200;
    final safeInset = compact ? 22.0 : 42.0;
    final railWidth = compact ? 88.0 : 210.0;
    final railGap = compact ? 22.0 : 38.0;
    final contentWidth =
        constraints.maxWidth - (safeInset * 2) - railWidth - railGap;
    final mediaCardWidth =
        (contentWidth / (compact ? 3.25 : 4.15)).clamp(190.0, 286.0);

    return TvShellMetrics(
      compact: compact,
      safeInset: safeInset,
      railWidth: railWidth,
      railGap: railGap,
      contentPadding: compact ? 18 : 30,
      navItemHeight: compact ? 46 : 52,
      navItemGap: compact ? 3 : 7,
      mediaCardWidth: mediaCardWidth,
    );
  }

  final bool compact;
  final double safeInset;
  final double railWidth;
  final double railGap;
  final double contentPadding;
  final double navItemHeight;
  final double navItemGap;
  final double mediaCardWidth;
}

abstract final class TvDesign {
  static const pageBackground = Color(0xff101110);
  static const surface = Color(0xff1b1c1b);
  static const raisedSurface = Color(0xff252625);
  static const mutedText = Color(0xffb8bab8);
  static const focusOutset = 16.0;
  static const cardRadius = 14.0;

  static Color surfaceFor(BuildContext context, {double emphasis = 0}) {
    final theme = Theme.of(context);
    final base = theme.brightness == Brightness.dark
        ? theme.scaffoldBackgroundColor
        : theme.colorScheme.surface;
    return Color.alphaBlend(
      theme.colorScheme.primary.withValues(alpha: 0.035 + emphasis),
      base,
    );
  }
}
