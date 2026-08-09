import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import 'subtitle_style.dart';

/// Builds a Better Player subtitle appearance from the persisted app settings.
BetterPlayerSubtitlesConfiguration buildPlayerSubtitleConfiguration({
  required String backgroundColor,
  required String foregroundColor,
  required int fontSize,
  required String textStyle,
}) {
  return BetterPlayerSubtitlesConfiguration(
    backgroundColor: parseStoredSubtitleColor(
      backgroundColor,
      fallback: Colors.black45,
    ),
    fontColor: parseStoredSubtitleColor(
      foregroundColor,
      fallback: Colors.white,
    ),
    fontFamily: subtitleFontFamily(textStyle),
    outlineEnabled: false,
    fontSize: normalizeSubtitleFontSize(fontSize).toDouble(),
  );
}
