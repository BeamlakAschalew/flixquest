import '../video_providers/scraper_api.dart';

/// Loads signed stream-size estimates in parallel without making an estimate a
/// prerequisite for selecting a resolution.
abstract final class StreamSizeEstimator {
  static const Duration timeout = Duration(seconds: 10);

  static Future<Map<String, int?>> load({
    required String scraperApiUrl,
    required Map<String, String> tokens,
    required Map<String, int?> cacheByToken,
  }) async {
    final pendingByToken = <String, Future<StreamSizeEstimate?>>{};

    for (final token in tokens.values) {
      if (token.trim().isEmpty ||
          cacheByToken.containsKey(token) ||
          pendingByToken.containsKey(token)) {
        continue;
      }
      pendingByToken[token] =
          ScraperApi(scraperApiUrl).estimateStreamSize(token);
    }

    final completed = <String, StreamSizeEstimate?>{};
    final requests = <Future<StreamSizeEstimate?>>[
      for (final entry in pendingByToken.entries)
        entry.value.then((estimate) {
          completed[entry.key] = estimate;
          return estimate;
        }),
    ];

    if (requests.isNotEmpty) {
      await Future.wait(requests).timeout(
        timeout,
        onTimeout: () => <StreamSizeEstimate?>[],
      );
    }

    for (final entry in tokens.entries) {
      if (!cacheByToken.containsKey(entry.value)) {
        cacheByToken[entry.value] = completed[entry.value]?.estimatedBytes;
      }
    }
    return {
      for (final entry in tokens.entries) entry.key: cacheByToken[entry.value],
    };
  }
}
