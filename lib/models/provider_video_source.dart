import 'package:better_player_plus/better_player_plus.dart';

/// Model to hold video sources from a specific provider
class ProviderVideoSource {
  final String providerCode;
  final String providerName;
  final Map<String, String> videoSources; // Quality -> URL
  final List<BetterPlayerSubtitlesSource> subtitles;

  ProviderVideoSource({
    required this.providerCode,
    required this.providerName,
    required this.videoSources,
    required this.subtitles,
  });
}
