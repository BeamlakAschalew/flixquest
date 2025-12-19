import 'package:flixquest/video_providers/common.dart';
import 'package:better_player_plus/better_player.dart';

class VideoUtils {
  /// Convert video links to a map format for the player
  static Map<String, String> convertVideoLinksToMap(
      List<RegularVideoLinks> vids) {
    Map<String, String> videos = {};
    for (int k = 0; k < vids.length; k++) {
      if (vids[k].quality! == 'unknown quality') {
        videos.addAll({
          '${vids[k].quality!} $k': vids[k].url!,
        });
      } else {
        videos.addAll({
          vids[k].quality!: vids[k].url!,
        });
      }
    }
    return videos;
  }

  /// Process VTT file timestamps to fix formatting issues
  static String processVttFileTimestamps(String vttContent) {
    final lines = vttContent.split('\n');
    final processedLines = <String>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('-->') && line.trim().length == 23) {
        String endTimeModifiedString =
            '${line.trim().substring(0, line.trim().length - 9)}00:${line.trim().substring(line.trim().length - 9)}';
        String finalStr = '00:$endTimeModifiedString';
        processedLines.add(finalStr);
      } else {
        processedLines.add(line);
      }
    }

    return processedLines.join('\n');
  }

  /// Parse and create BetterPlayer subtitle sources from subtitle links
  static Future<List<BetterPlayerSubtitlesSource>> parseSubtitles({
    required List<RegularSubtitleLinks> subtitles,
    required String defaultLanguage,
    required bool fetchAllLanguages,
    required Future<String> Function(String) getVttContent,
  }) async {
    List<BetterPlayerSubtitlesSource> subs = [];

    if (subtitles.isEmpty) {
      return subs;
    }

    // If no specific language preference, fetch all
    if (defaultLanguage.isEmpty) {
      for (int i = 0; i < subtitles.length; i++) {
        try {
          final content = await getVttContent(subtitles[i].url!);
          subs.add(
            BetterPlayerSubtitlesSource(
              name: subtitles[i].language!,
              selectedByDefault: _isDefaultEnglish(subtitles[i].language!),
              content: subtitles[i].url!.endsWith('srt')
                  ? content
                  : processVttFileTimestamps(content),
              type: BetterPlayerSubtitlesSourceType.memory,
            ),
          );
        } catch (e) {
          // Skip failed subtitle
          continue;
        }
      }
    } else {
      // Check if preferred language exists
      final hasPreferredLanguage = subtitles.any((sub) =>
          sub.language!
              .toLowerCase()
              .startsWith(defaultLanguage.toLowerCase()) ||
          sub.language == defaultLanguage);

      if (hasPreferredLanguage) {
        if (fetchAllLanguages) {
          // Fetch all languages but prioritize preferred
          for (int i = 0; i < subtitles.length; i++) {
            try {
              final content = await getVttContent(subtitles[i].url!);
              final isPreferred = subtitles[i]
                      .language!
                      .toLowerCase()
                      .startsWith(defaultLanguage.toLowerCase()) ||
                  subtitles[i].language == defaultLanguage;

              subs.add(
                BetterPlayerSubtitlesSource(
                  name: subtitles[i].language!,
                  selectedByDefault: isPreferred,
                  content: subtitles[i].url!.endsWith('srt')
                      ? content
                      : processVttFileTimestamps(content),
                  type: BetterPlayerSubtitlesSourceType.memory,
                ),
              );
            } catch (e) {
              continue;
            }
          }
        } else {
          // Fetch only preferred language (first match)
          for (int i = 0; i < subtitles.length; i++) {
            if (subtitles[i]
                    .language!
                    .toLowerCase()
                    .startsWith(defaultLanguage.toLowerCase()) ||
                subtitles[i].language == defaultLanguage) {
              try {
                final content = await getVttContent(subtitles[i].url!);
                subs.add(
                  BetterPlayerSubtitlesSource(
                    name: subtitles[i].language!,
                    selectedByDefault: true,
                    content: subtitles[i].url!.endsWith('srt')
                        ? content
                        : processVttFileTimestamps(content),
                    type: BetterPlayerSubtitlesSourceType.memory,
                  ),
                );
                break;
              } catch (e) {
                continue;
              }
            }
          }
        }
      }
    }

    return subs;
  }

  /// Check if language should be default English
  static bool _isDefaultEnglish(String language) {
    return language == 'English' ||
        language == 'English - English' ||
        language == 'English - SDH' ||
        language == 'English 1' ||
        language == 'English - English [CC]' ||
        language == 'en';
  }

  /// Reverse video quality map for player (highest quality first)
  static Map<String, String> reverseVideoQualityMap(
      Map<String, String> videos) {
    List<MapEntry<String, String>> reversedVideoList =
        videos.entries.toList().reversed.toList();
    return Map.fromEntries(reversedVideoList);
  }
}
