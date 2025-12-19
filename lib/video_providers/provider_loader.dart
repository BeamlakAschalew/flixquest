import 'package:flixquest/api/endpoints.dart';
import 'package:flixquest/functions/function.dart';
import 'package:flixquest/functions/network.dart';
import 'package:flixquest/models/custom_exceptions.dart';
import 'package:flixquest/video_providers/common.dart';
import 'package:flixquest/constants/app_constants.dart' show StreamRoute;

class ProviderLoaderResult {
  final List<RegularVideoLinks>? videoLinks;
  final List<RegularSubtitleLinks>? subtitleLinks;
  final bool success;
  final String? errorMessage;

  ProviderLoaderResult({
    this.videoLinks,
    this.subtitleLinks,
    this.success = false,
    this.errorMessage,
  });
}

class ProviderLoader {
  /// Load movie from a specific provider
  static Future<ProviderLoaderResult> loadMovieFromProvider({
    required String providerCode,
    required StreamRoute route,
    required int movieId,
    required String movieName,
    required String? releaseYear,
    required String consumetUrl,
    required String newFlixHQUrl,
    required String flixApiUrl,
    required String newFlixhqServer,
    required String streamingServerFlixHQ,
  }) async {
    try {
      switch (providerCode) {
        case 'flixhq':
          if (route == StreamRoute.flixHQ) {
            return await _loadMovieFlixHQNormalRoute(
              movieId: movieId,
              movieName: movieName,
              releaseYear: releaseYear,
              consumetUrl: consumetUrl,
              streamingServerFlixHQ: streamingServerFlixHQ,
            );
          } else {
            return await _loadMovieFlixHQTMDBRoute(
              movieId: movieId,
              consumetUrl: consumetUrl,
              streamingServerFlixHQ: streamingServerFlixHQ,
            );
          }

        case 'myflixerz':
          return await _loadMovieNewFlixHQ(
            movieId: movieId,
            newFlixHQUrl: newFlixHQUrl,
            newFlixhqServer: newFlixhqServer,
          );

        case 'pstream':
          return await _loadMovieFlixAPI(
            movieId: movieId,
            flixApiUrl: flixApiUrl,
          );

        default:
          return ProviderLoaderResult(
            success: false,
            errorMessage: 'Unknown provider: $providerCode',
          );
      }
    } catch (e) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load TV show from a specific provider
  static Future<ProviderLoaderResult> loadTVFromProvider({
    required String providerCode,
    required StreamRoute route,
    required int tvId,
    required String seriesName,
    required int seasonNumber,
    required int episodeNumber,
    required String consumetUrl,
    required String newFlixHQUrl,
    required String flixApiUrl,
    required String newFlixhqServer,
    required String streamingServerFlixHQ,
    required String appLanguage,
  }) async {
    try {
      switch (providerCode) {
        case 'flixhq':
          if (route == StreamRoute.flixHQ) {
            return await _loadTVFlixHQNormalRoute(
              tvId: tvId,
              seriesName: seriesName,
              seasonNumber: seasonNumber,
              episodeNumber: episodeNumber,
              consumetUrl: consumetUrl,
              streamingServerFlixHQ: streamingServerFlixHQ,
              appLanguage: appLanguage,
            );
          } else {
            return await _loadTVFlixHQTMDBRoute(
              tvId: tvId,
              seasonNumber: seasonNumber,
              episodeNumber: episodeNumber,
              consumetUrl: consumetUrl,
              streamingServerFlixHQ: streamingServerFlixHQ,
            );
          }

        case 'myflixerz':
          return await _loadTVNewFlixHQ(
            tvId: tvId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            newFlixHQUrl: newFlixHQUrl,
            newFlixhqServer: newFlixhqServer,
          );

        case 'pstream':
          return await _loadTVFlixAPI(
            tvId: tvId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            flixApiUrl: flixApiUrl,
          );

        default:
          return ProviderLoaderResult(
            success: false,
            errorMessage: 'Unknown provider: $providerCode',
          );
      }
    } catch (e) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ==================== MOVIE PROVIDER METHODS ====================

  static Future<ProviderLoaderResult> _loadMovieFlixHQTMDBRoute({
    required int movieId,
    required String consumetUrl,
    required String streamingServerFlixHQ,
  }) async {
    final episode = await getMovieStreamEpisodesTMDB(
      Endpoints.getMovieTVStreamInfoTMDB(
          movieId.toString(), 'movie', consumetUrl),
    );

    if (episode.id != null &&
        episode.id!.isNotEmpty &&
        episode.episodeId != null &&
        episode.episodeId!.isNotEmpty) {
      final sources = await getMovieStreamLinksAndSubsFlixHQ(
        Endpoints.getMovieTVStreamLinksTMDB(
          consumetUrl,
          episode.episodeId!,
          episode.id!,
          streamingServerFlixHQ,
        ),
      );

      if (sources.messageExists == null &&
          sources.videoLinks != null &&
          sources.videoLinks!.isNotEmpty) {
        return ProviderLoaderResult(
          success: true,
          videoLinks: sources.videoLinks,
          subtitleLinks: sources.videoSubtitles,
        );
      }
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  static Future<ProviderLoaderResult> _loadMovieNewFlixHQ({
    required int movieId,
    required String newFlixHQUrl,
    required String newFlixhqServer,
  }) async {
    final sources = await getMovieStreamLinksAndSubsFlixHQNew(
      Endpoints.getMovieStreamLinkFlixhqNew(
        newFlixHQUrl,
        movieId,
        newFlixhqServer,
      ),
    );

    if (sources.messageExists == null &&
        sources.videoLinks != null &&
        sources.videoLinks!.isNotEmpty) {
      return ProviderLoaderResult(
        success: true,
        videoLinks: sources.videoLinks,
        subtitleLinks: sources.videoSubtitles,
      );
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  static Future<ProviderLoaderResult> _loadMovieFlixAPI({
    required int movieId,
    required String flixApiUrl,
  }) async {
    final sources = await getMovieTVStreamLinksAndSubsFlixAPI(
      Endpoints.getMovieStreamLinkFlixAPI(flixApiUrl, movieId),
    );

    if (sources.success &&
        sources.stream != null &&
        sources.stream!.playlist != null) {
      final videoLinks = [
        RegularVideoLinks(
          url: sources.stream!.playlist,
          isM3U8: sources.stream!.playlist!.endsWith('.m3u8'),
        ),
      ];

      final subtitleLinks = sources.stream!.captions
          ?.map((caption) => RegularSubtitleLinks(
                url: caption.url,
                language: caption.language,
              ))
          .toList();

      return ProviderLoaderResult(
        success: true,
        videoLinks: videoLinks,
        subtitleLinks: subtitleLinks,
      );
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  static Future<ProviderLoaderResult> _loadMovieFlixHQNormalRoute({
    required int movieId,
    required String movieName,
    required String? releaseYear,
    required String consumetUrl,
    required String streamingServerFlixHQ,
  }) async {
    final movies = await fetchMoviesForStreamFlixHQ(
      Endpoints.searchMovieTVForStreamFlixHQ(
        normalizeTitle(movieName).toLowerCase(),
        consumetUrl,
      ),
    );

    if (movies.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    bool entryFound = false;
    for (final movie in movies) {
      if (movie.releaseDate == releaseYear.toString() &&
          movie.type == 'Movie' &&
          (normalizeTitle(movie.title!)
                  .toLowerCase()
                  .contains(normalizeTitle(movieName).toLowerCase()) ||
              movie.title!.contains(movieName))) {
        entryFound = true;

        final episodes = await getMovieStreamEpisodesFlixHQ(
          Endpoints.getMovieTVStreamInfoFlixHQ(movie.id!, consumetUrl),
        );

        if (episodes.isNotEmpty) {
          final sources = await getMovieStreamLinksAndSubsFlixHQ(
            Endpoints.getMovieTVStreamLinksFlixHQ(
              episodes[0].id!,
              movie.id!,
              consumetUrl,
              streamingServerFlixHQ,
            ),
          );

          if (sources.messageExists == null &&
              sources.videoLinks != null &&
              sources.videoLinks!.isNotEmpty) {
            return ProviderLoaderResult(
              success: true,
              videoLinks: sources.videoLinks,
              subtitleLinks: sources.videoSubtitles,
            );
          }
        }
        break;
      }
    }

    if (!entryFound) {
      throw NotFoundException();
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  // ==================== TV SHOW PROVIDER METHODS ====================

  static Future<ProviderLoaderResult> _loadTVFlixHQTMDBRoute({
    required int tvId,
    required int seasonNumber,
    required int episodeNumber,
    required String consumetUrl,
    required String streamingServerFlixHQ,
  }) async {
    final tvInfo = await getTVStreamEpisodesTMDB(
      Endpoints.getMovieTVStreamInfoTMDB(tvId.toString(), 'tv', consumetUrl),
    );

    if (seasonNumber != 0 &&
        tvInfo.id != null &&
        tvInfo.seasons != null &&
        tvInfo.seasons![seasonNumber - 1].episodes![episodeNumber - 1].id !=
            null) {
      final sources = await getTVStreamLinksAndSubsFlixHQ(
        Endpoints.getMovieTVStreamLinksTMDB(
          consumetUrl,
          tvInfo.seasons![seasonNumber - 1].episodes![episodeNumber - 1].id!,
          tvInfo.id!,
          streamingServerFlixHQ,
        ),
      );

      if (sources.messageExists == null &&
          sources.videoLinks != null &&
          sources.videoLinks!.isNotEmpty) {
        return ProviderLoaderResult(
          success: true,
          videoLinks: sources.videoLinks,
          subtitleLinks: sources.videoSubtitles,
        );
      }
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  static Future<ProviderLoaderResult> _loadTVNewFlixHQ({
    required int tvId,
    required int seasonNumber,
    required int episodeNumber,
    required String newFlixHQUrl,
    required String newFlixhqServer,
  }) async {
    if (seasonNumber != 0) {
      final sources = await getTVStreamLinksAndSubsFlixHQNew(
        Endpoints.getTVStreamLinkFlixhqNew(
          newFlixHQUrl,
          tvId,
          episodeNumber,
          seasonNumber,
          newFlixhqServer,
        ),
      );

      if (sources.messageExists == null &&
          sources.videoLinks != null &&
          sources.videoLinks!.isNotEmpty) {
        return ProviderLoaderResult(
          success: true,
          videoLinks: sources.videoLinks,
          subtitleLinks: sources.videoSubtitles,
        );
      }
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  static Future<ProviderLoaderResult> _loadTVFlixAPI({
    required int tvId,
    required int seasonNumber,
    required int episodeNumber,
    required String flixApiUrl,
  }) async {
    final sources = await getMovieTVStreamLinksAndSubsFlixAPI(
      Endpoints.getTVStreamLinkFlixAPI(
        flixApiUrl,
        tvId,
        episodeNumber,
        seasonNumber,
      ),
    );

    if (sources.success &&
        sources.stream != null &&
        sources.stream!.playlist != null) {
      final videoLinks = [
        RegularVideoLinks(
          url: sources.stream!.playlist,
          isM3U8: sources.stream!.playlist!.endsWith('.m3u8'),
        ),
      ];

      final subtitleLinks = sources.stream!.captions
          ?.map((caption) => RegularSubtitleLinks(
                url: caption.url,
                language: caption.language,
              ))
          .toList();

      return ProviderLoaderResult(
        success: true,
        videoLinks: videoLinks,
        subtitleLinks: subtitleLinks,
      );
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  static Future<ProviderLoaderResult> _loadTVFlixHQNormalRoute({
    required int tvId,
    required String seriesName,
    required int seasonNumber,
    required int episodeNumber,
    required String consumetUrl,
    required String streamingServerFlixHQ,
    required String appLanguage,
  }) async {
    // Import network and endpoints for fetching TV details
    final isProxyEnabled =
        false; // This should be passed as parameter if needed
    final proxyUrl = '';

    final tvDetails = await fetchTVDetails(
      Endpoints.tvDetailsUrl(tvId, appLanguage),
      isProxyEnabled,
      proxyUrl,
    );

    final totalSeasons = tvDetails.numberOfSeasons!;

    final shows = await fetchTVForStreamFlixHQ(
      Endpoints.searchMovieTVForStreamFlixHQ(
        normalizeTitle(seriesName).toLowerCase(),
        consumetUrl,
      ),
    );

    if (shows.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    bool entryFound = false;
    for (final show in shows) {
      if (show.seasons == totalSeasons &&
          show.type == 'TV Series' &&
          (normalizeTitle(show.title!)
                  .toLowerCase()
                  .contains(normalizeTitle(seriesName).toLowerCase()) ||
              show.title!.contains(seriesName))) {
        entryFound = true;

        final tvInfo = await getTVStreamEpisodesFlixHQ(
          Endpoints.getMovieTVStreamInfoFlixHQ(show.id!, consumetUrl),
        );

        if (tvInfo.episodes != null && tvInfo.episodes!.isNotEmpty) {
          // Find the matching episode
          for (final episode in tvInfo.episodes!) {
            if (episode.episode == episodeNumber &&
                episode.season == seasonNumber) {
              final sources = await getTVStreamLinksAndSubsFlixHQ(
                Endpoints.getMovieTVStreamLinksFlixHQ(
                  episode.id!,
                  show.id!,
                  consumetUrl,
                  streamingServerFlixHQ,
                ),
              );

              if (sources.messageExists == null &&
                  sources.videoLinks != null &&
                  sources.videoLinks!.isNotEmpty) {
                return ProviderLoaderResult(
                  success: true,
                  videoLinks: sources.videoLinks,
                  subtitleLinks: sources.videoSubtitles,
                );
              }
              break;
            }
          }
        }
        break;
      }

      if (show.seasons == (totalSeasons - 1) && show.type == 'TV Series') {
        entryFound = true;

        final tvInfo = await getTVStreamEpisodesFlixHQ(
          Endpoints.getMovieTVStreamInfoFlixHQ(show.id!, consumetUrl),
        );

        if (tvInfo.episodes != null && tvInfo.episodes!.isNotEmpty) {
          // Find the matching episode
          for (final episode in tvInfo.episodes!) {
            if (episode.episode == episodeNumber &&
                episode.season == seasonNumber) {
              final sources = await getTVStreamLinksAndSubsFlixHQ(
                Endpoints.getMovieTVStreamLinksFlixHQ(
                  episode.id!,
                  show.id!,
                  consumetUrl,
                  streamingServerFlixHQ,
                ),
              );

              if (sources.messageExists == null &&
                  sources.videoLinks != null &&
                  sources.videoLinks!.isNotEmpty) {
                return ProviderLoaderResult(
                  success: true,
                  videoLinks: sources.videoLinks,
                  subtitleLinks: sources.videoSubtitles,
                );
              }
              break;
            }
          }
        }
        break;
      }
    }

    if (!entryFound) {
      throw NotFoundException();
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }
}
