import 'vixsrc.dart';

typedef ProviderLoaderResult = VixSrcResult;

/// Compatibility boundary for the player while VixSrc is the sole in-app
/// streaming source.
abstract final class ProviderLoader {
  static Future<ProviderLoaderResult> loadMovieFromProvider({
    required String providerCode,
    required int movieId,
  }) {
    if (providerCode != 'vixsrc') {
      return Future.value(
        VixSrcResult(errorMessage: 'Unsupported provider: $providerCode'),
      );
    }
    return VixSrc.loadMovie(movieId);
  }

  static Future<ProviderLoaderResult> loadTVFromProvider({
    required String providerCode,
    required int tvId,
    required int seasonNumber,
    required int episodeNumber,
  }) {
    if (providerCode != 'vixsrc') {
      return Future.value(
        VixSrcResult(errorMessage: 'Unsupported provider: $providerCode'),
      );
    }
    return VixSrc.loadEpisode(
      tvId: tvId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
    );
  }
}
