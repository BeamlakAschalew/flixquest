import 'package:better_player_plus/better_player_plus.dart';

/// Model to hold video sources from a specific provider
class ProviderVideoSource {
  final String providerCode;
  final String providerName;
  final Map<String, String> videoSources; // Quality -> URL
  final Map<String, BetterPlayerVideoFormat?> videoFormats;
  final Map<String, Map<String, String>> videoHeaders;
  final List<BetterPlayerSubtitlesSource> subtitles;

  ProviderVideoSource({
    required this.providerCode,
    required this.providerName,
    required this.videoSources,
    required this.videoFormats,
    required this.videoHeaders,
    required this.subtitles,
  });
}
