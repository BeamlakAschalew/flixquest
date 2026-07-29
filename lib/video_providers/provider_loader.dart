import 'common.dart';
import 'names.dart';
import 'scraper_api.dart';
import 'vixsrc.dart';

typedef ProviderLoaderResult = ProviderLoadResult;
typedef ProviderResultCallback = void Function(
  int index,
  VideoProvider provider,
  ProviderLoadResult result,
);

class ProviderSelection {
  const ProviderSelection({
    required this.index,
    required this.provider,
    required this.result,
    required this.batchResults,
  });

  final int index;
  final VideoProvider provider;
  final ProviderLoadResult result;
  final Map<String, Future<ProviderLoadResult>> batchResults;
}

/// Single loading boundary for direct and API-backed stream providers.
abstract final class ProviderLoader {
  /// Starts providers in groups of three while resolving their results in the
  /// configured order. A fast lower-priority result is retained until every
  /// provider before it has failed; the next group only starts if the current
  /// group has no playable result.
  static Future<ProviderSelection?> loadFirstSuccessful({
    required List<VideoProvider> providers,
    required Future<ProviderLoadResult> Function(VideoProvider provider) load,
    ProviderResultCallback? onResult,
  }) async {
    for (var batchStart = 0; batchStart < providers.length; batchStart += 3) {
      final batchEnd =
          batchStart + 3 < providers.length ? batchStart + 3 : providers.length;
      final requests = <Future<ProviderLoadResult>>[];
      final batchResults = <String, Future<ProviderLoadResult>>{};

      // Creating every future before awaiting any of them starts the batch
      // concurrently while keeping ordered resolution below.
      for (var index = batchStart; index < batchEnd; index++) {
        final provider = providers[index];
        final request = () async {
          ProviderLoadResult result;
          try {
            result = await load(provider);
          } catch (error) {
            result = ProviderLoadResult(errorMessage: error.toString());
          }

          onResult?.call(index, provider, result);
          return result;
        }();
        requests.add(request);
        batchResults[provider.codeName] = request;
      }

      for (var offset = 0; offset < requests.length; offset++) {
        final result = await requests[offset];
        if (result.success && result.videoLinks?.isNotEmpty == true) {
          final index = batchStart + offset;
          return ProviderSelection(
            index: index,
            provider: providers[index],
            result: result,
            batchResults: batchResults,
          );
        }
      }
    }
    return null;
  }

  static Future<ProviderLoaderResult> loadMovieFromProvider({
    required VideoProvider provider,
    required int movieId,
    required String scraperApiUrl,
  }) {
    switch (provider.type) {
      case VideoProviderType.directVixSrc:
        return VixSrc.loadMovie(movieId);
      case VideoProviderType.scraperApi:
        final providerId = provider.apiId;
        if (providerId == null || providerId.isEmpty) {
          return Future.value(
            const ProviderLoadResult(errorMessage: 'Provider ID is missing'),
          );
        }
        return ScraperApi(scraperApiUrl).loadMovie(
          providerId: providerId,
          movieId: movieId,
        );
    }
  }

  static Future<ProviderLoaderResult> loadTVFromProvider({
    required VideoProvider provider,
    required int tvId,
    required int seasonNumber,
    required int episodeNumber,
    required String scraperApiUrl,
  }) {
    switch (provider.type) {
      case VideoProviderType.directVixSrc:
        return VixSrc.loadEpisode(
          tvId: tvId,
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
        );
      case VideoProviderType.scraperApi:
        final providerId = provider.apiId;
        if (providerId == null || providerId.isEmpty) {
          return Future.value(
            const ProviderLoadResult(errorMessage: 'Provider ID is missing'),
          );
        }
        return ScraperApi(scraperApiUrl).loadTVEpisode(
          providerId: providerId,
          tvId: tvId,
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
        );
    }
  }
}
