import '../functions/network.dart';
import 'common.dart';

class VixSrcResult {
  const VixSrcResult({
    this.videoLinks,
    this.subtitleLinks,
    this.success = false,
    this.errorMessage,
  });

  final List<RegularVideoLinks>? videoLinks;
  final List<RegularSubtitleLinks>? subtitleLinks;
  final bool success;
  final String? errorMessage;
}

abstract final class VixSrc {
  static const String _baseUrl = 'https://vixsrc.to';

  static Future<VixSrcResult> loadMovie(int movieId) {
    return _load('$_baseUrl/api/movie/$movieId');
  }

  static Future<VixSrcResult> loadEpisode({
    required int tvId,
    required int seasonNumber,
    required int episodeNumber,
  }) {
    if (seasonNumber <= 0) {
      return Future.value(
        const VixSrcResult(
          errorMessage: 'Invalid season number',
        ),
      );
    }
    return _load(
      '$_baseUrl/api/tv/$tvId/$seasonNumber/$episodeNumber',
    );
  }

  static Future<VixSrcResult> _load(String apiUrl) async {
    try {
      String? embedHtml;
      for (var attempt = 0; attempt < 2; attempt++) {
        final embedSrc = await getVixSrcEmbedSrc(apiUrl);
        embedHtml = await getVixSrcEmbedHtml(_resolveUrl(embedSrc, _baseUrl));
        if (embedHtml != null) break;
      }

      if (embedHtml == null) {
        return const VixSrcResult(
          errorMessage: 'VixSrc embed token expired',
        );
      }

      final playlistUrl = _extractMasterPlaylist(embedHtml);
      if (playlistUrl == null) {
        return const VixSrcResult(
          errorMessage: 'VixSrc playlist metadata not found',
        );
      }

      final playlist = await getVixSrcPlaylist(playlistUrl);
      if (!_containsVideoStream(playlist)) {
        return const VixSrcResult(
          errorMessage: 'No VixSrc video sources found',
        );
      }

      return VixSrcResult(
        success: true,
        videoLinks: [
          RegularVideoLinks(
            url: playlistUrl,
            quality: 'auto',
            isM3U8: true,
          ),
        ],
        subtitleLinks: await _parseSubtitles(playlist, playlistUrl),
      );
    } catch (error) {
      return VixSrcResult(errorMessage: error.toString());
    }
  }

  static String _resolveUrl(String url, String baseUrl) {
    if (url.startsWith('//')) return 'https:$url';
    final uri = Uri.parse(url);
    if (uri.hasScheme) return url;
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return Uri.parse(normalizedBase).resolve(url).toString();
  }

  static String? _extractMasterPlaylist(String html) {
    final urlMatch = RegExp(
      r"""window\.masterPlaylist\s*=\s*\{[\s\S]*?url:\s*['"]([^'"]+)['"]""",
    ).firstMatch(html);
    final tokenMatch =
        RegExp(r"""['"]token['"]\s*:\s*['"]([^'"]+)['"]""").firstMatch(html);
    final expiresMatch =
        RegExp(r"""['"]expires['"]\s*:\s*['"]([^'"]+)['"]""").firstMatch(html);

    if (urlMatch == null || tokenMatch == null || expiresMatch == null) {
      return null;
    }

    final uri = Uri.parse(_resolveUrl(urlMatch.group(1)!, _baseUrl));
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'token': tokenMatch.group(1)!,
        'expires': expiresMatch.group(1)!,
        'h': '1',
        'lang': 'en',
      },
    ).toString();
  }

  static bool _containsVideoStream(String playlist) {
    return playlist
        .split(RegExp(r'\r?\n'))
        .any((line) => line.trim().startsWith('#EXT-X-STREAM-INF'));
  }

  static Future<List<RegularSubtitleLinks>> _parseSubtitles(
    String playlist,
    String playlistUrl,
  ) async {
    final subtitles = <RegularSubtitleLinks>[];
    for (final line in playlist.split(RegExp(r'\r?\n'))) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('#EXT-X-MEDIA') ||
          !trimmed.contains('TYPE=SUBTITLES')) {
        continue;
      }

      final attributes = _parseHlsAttributes(trimmed);
      final path = attributes['URI'];
      if (path == null || path.isEmpty) continue;

      subtitles.add(
        RegularSubtitleLinks(
          url: await _resolveSubtitleUrl(
            _resolveUrl(path, playlistUrl),
          ),
          language: attributes['NAME'] ?? attributes['LANGUAGE'] ?? 'Unknown',
        ),
      );
    }
    return subtitles;
  }

  static Future<String> _resolveSubtitleUrl(String url) async {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    if (path.endsWith('.vtt') || path.endsWith('.srt')) return url;

    try {
      final playlist = await getVixSrcPlaylist(url);
      for (final line in playlist.split(RegExp(r'\r?\n'))) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && !trimmed.startsWith('#')) {
          return _resolveUrl(trimmed, url);
        }
      }
    } catch (_) {
      return url;
    }
    return url;
  }

  static Map<String, String> _parseHlsAttributes(String line) {
    final attributes = <String, String>{};
    final text = line.substring(line.indexOf(':') + 1);
    final regex = RegExp(r'([A-Z0-9-]+)=("[^"]*"|[^,]*)');
    for (final match in regex.allMatches(text)) {
      var value = match.group(2) ?? '';
      if (value.startsWith('"') && value.endsWith('"') && value.length >= 2) {
        value = value.substring(1, value.length - 1);
      }
      attributes[match.group(1)!] = value;
    }
    return attributes;
  }
}
