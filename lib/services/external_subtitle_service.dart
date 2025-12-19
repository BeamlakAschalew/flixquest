import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:better_player_plus/better_player_plus.dart';
import 'package:retry/retry.dart';
import '../functions/function.dart';
import '../models/external_subtitles.dart';

class ExternalSubtitleService {
  static const String baseUrl = 'https://sub.wyzie.ru';

  /// Download subtitle file with proper encoding handling
  static Future<String> _downloadSubtitleWithEncoding(
      String url, String encoding) async {
    final retryOptions = RetryOptions(maxAttempts: 3);

    try {
      var response = await retryOptions.retry(
        () => http.get(Uri.parse(url)).timeout(const Duration(seconds: 15)),
        retryIf: (e) => e is SocketException,
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // Try to decode with the specified encoding
        try {
          // Handle different encodings
          Encoding decoder;
          switch (encoding.toUpperCase()) {
            case 'UTF-8':
            case 'UTF8':
              decoder = utf8;
              break;
            case 'LATIN1':
            case 'ISO-8859-1':
              decoder = latin1;
              break;
            case 'ASCII':
              decoder = ascii;
              break;
            default:
              // For unsupported encodings like GB18030, CP1252, etc., try UTF-8 first
              // If it fails, fall back to latin1 which accepts all byte values
              decoder = utf8;
              break;
          }

          String decoded;
          try {
            decoded = decoder.decode(bytes);
          } catch (e) {
            // If strict decoding fails, manually replace invalid sequences
            decoded =
                String.fromCharCodes(bytes.where((b) => b < 128).toList());
          }

          // Check if the decoded content looks valid (not starting with HTML)
          if (decoded.startsWith('<')) {
            return '';
          }

          return decoded;
        } catch (e) {
          // If the specified encoding fails, try latin1 as fallback (accepts all bytes)
          return latin1.decode(bytes);
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  /// Fetch external subtitles for a movie using TMDB ID
  static Future<List<ExternalSubtitle>> fetchMovieSubtitles(int tmdbId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?id=$tmdbId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ExternalSubtitle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load subtitles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching subtitles: $e');
    }
  }

  /// Fetch external subtitles for a TV episode using TMDB ID, season, and episode
  static Future<List<ExternalSubtitle>> fetchTVSubtitles(
    int tmdbId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/search?id=$tmdbId&season=$seasonNumber&episode=$episodeNumber',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ExternalSubtitle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load subtitles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching subtitles: $e');
    }
  }

  /// Download and convert ExternalSubtitle to BetterPlayerSubtitlesSource with parsed content
  static Future<BetterPlayerSubtitlesSource> convertToBetterPlayerSource(
    ExternalSubtitle subtitle, {
    int? subtitleNumber,
  }) async {
    // Download the subtitle file content with proper encoding
    final subtitleContent = await _downloadSubtitleWithEncoding(
      subtitle.url,
      subtitle.encoding,
    );

    // Process the content based on format
    String processedContent = subtitleContent;
    if (!subtitle.url.endsWith('srt') && subtitleContent.isNotEmpty) {
      // If it's VTT or other format, process timestamps
      processedContent = processVttFileTimestamps(subtitleContent);
    }

    // Create a unique name for the subtitle
    String subtitleName = subtitle.display;
    if (subtitleNumber != null) {
      subtitleName = '${subtitle.display} #$subtitleNumber';
    }
    if (subtitle.isHearingImpaired) {
      subtitleName += ' (HI)';
    }

    return BetterPlayerSubtitlesSource(
      type: BetterPlayerSubtitlesSourceType.memory,
      name: subtitleName,
      content: processedContent,
      selectedByDefault: false,
    );
  }
}
