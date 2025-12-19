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
    required String streamingServerDCVA,
    required String streamingServerZoro,
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

        case 'flixhqNew':
          return await _loadMovieNewFlixHQ(
            movieId: movieId,
            newFlixHQUrl: newFlixHQUrl,
            newFlixhqServer: newFlixhqServer,
          );

        case 'flixapi':
          return await _loadMovieFlixAPI(
            movieId: movieId,
            flixApiUrl: flixApiUrl,
          );

        case 'dramacool':
          return await _loadMovieDramacool(
            movieId: movieId,
            movieName: movieName,
            consumetUrl: consumetUrl,
            streamingServerDCVA: streamingServerDCVA,
          );

        case 'viewasian':
          return await _loadMovieViewasian(
            movieId: movieId,
            movieName: movieName,
            consumetUrl: consumetUrl,
            streamingServerDCVA: streamingServerDCVA,
          );

        case 'zoro':
          return await _loadMovieZoro(
            movieId: movieId,
            movieName: movieName,
            consumetUrl: consumetUrl,
            streamingServerZoro: streamingServerZoro,
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
    required String streamingServerDCVA,
    required String streamingServerZoro,
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

        case 'flixhqNew':
          return await _loadTVNewFlixHQ(
            tvId: tvId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            newFlixHQUrl: newFlixHQUrl,
            newFlixhqServer: newFlixhqServer,
          );

        case 'flixapi':
          return await _loadTVFlixAPI(
            tvId: tvId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            flixApiUrl: flixApiUrl,
          );

        case 'dramacool':
          return await _loadTVDramacool(
            tvId: tvId,
            seriesName: seriesName,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            consumetUrl: consumetUrl,
            streamingServerDCVA: streamingServerDCVA,
          );

        case 'viewasian':
          return await _loadTVViewasian(
            tvId: tvId,
            seriesName: seriesName,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            consumetUrl: consumetUrl,
            streamingServerDCVA: streamingServerDCVA,
          );

        case 'zoro':
          return await _loadTVZoro(
            tvId: tvId,
            seriesName: seriesName,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            consumetUrl: consumetUrl,
            streamingServerZoro: streamingServerZoro,
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

    if (episode != null &&
        episode.id != null &&
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

  static Future<ProviderLoaderResult> _loadMovieDramacool({
    required int movieId,
    required String movieName,
    required String consumetUrl,
    required String streamingServerDCVA,
  }) async {
    final movies = await fetchMovieTVForStreamDCVA(
      Endpoints.searchMovieTVForStreamDramacool(
        normalizeTitle(movieName).toLowerCase(),
        consumetUrl,
      ),
    );

    if (movies == null || movies.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    for (var movie in movies) {
      if (normalizeTitle(movie.title!)
              .toLowerCase()
              .contains(normalizeTitle(movieName).toLowerCase()) ||
          movie.title!.contains(movieName)) {
        final episodes = await getMovieTVStreamEpisodesDCVA(
          Endpoints.getMovieTVStreamInfoDramacool(movie.id!, consumetUrl),
        );

        if (episodes != null && episodes.isNotEmpty) {
          final sources = await getMovieTVStreamLinksAndSubsDCVA(
            Endpoints.getMovieTVStreamLinksDramacool(
              episodes[0].id!,
              movie.id!,
              consumetUrl,
              streamingServerDCVA,
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

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  static Future<ProviderLoaderResult> _loadMovieViewasian({
    required int movieId,
    required String movieName,
    required String consumetUrl,
    required String streamingServerDCVA,
  }) async {
    final movies = await fetchMovieTVForStreamDCVA(
      Endpoints.searchMovieTVForStreamViewasian(
        normalizeTitle(movieName).toLowerCase(),
        consumetUrl,
      ),
    );

    if (movies == null || movies.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    for (var movie in movies) {
      if (normalizeTitle(movie.title!)
              .toLowerCase()
              .contains(normalizeTitle(movieName).toLowerCase()) ||
          movie.title!.contains(movieName)) {
        final episodes = await getMovieTVStreamEpisodesDCVA(
          Endpoints.getMovieTVStreamInfoViewasian(movie.id!, consumetUrl),
        );

        if (episodes != null && episodes.isNotEmpty) {
          final sources = await getMovieTVStreamLinksAndSubsDCVA(
            Endpoints.getMovieTVStreamLinksViewasian(
              episodes[0].id!,
              movie.id!,
              consumetUrl,
              streamingServerDCVA,
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

    if (movies == null || movies.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    bool entryFound = false;
    for (var movie in movies) {
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

        if (episodes != null && episodes.isNotEmpty) {
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

  static Future<ProviderLoaderResult> _loadMovieZoro({
    required int movieId,
    required String movieName,
    required String consumetUrl,
    required String streamingServerZoro,
  }) async {
    final movies = await fetchMovieTVForStreamZoro(
      Endpoints.searchZoroMoviesTV(
        consumetUrl,
        normalizeTitle(movieName).toLowerCase(),
      ),
    );

    if (movies == null || movies.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    for (var movie in movies) {
      if ((normalizeTitle(movie.title!)
                  .toLowerCase()
                  .contains(movieName.toLowerCase()) ||
              movie.title!.contains(movieName)) &&
          movie.type == 'MOVIE') {
        final episodes = await getMovieTVStreamEpisodesZoro(
          Endpoints.getMovieTVInfoZoro(consumetUrl, movie.id!),
        );

        if (episodes != null && episodes.isNotEmpty) {
          final sources = await getMovieTVStreamLinksAndSubsZoro(
            Endpoints.getMovieTVStreamLinksZoro(
              episodes[0].id!,
              consumetUrl,
              streamingServerZoro,
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

  static Future<ProviderLoaderResult> _loadTVDramacool({
    required int tvId,
    required String seriesName,
    required int seasonNumber,
    required int episodeNumber,
    required String consumetUrl,
    required String streamingServerDCVA,
  }) async {
    final shows = await fetchMovieTVForStreamDCVA(
      Endpoints.searchMovieTVForStreamDramacool(
        normalizeTitle(seriesName),
        consumetUrl,
      ).toLowerCase(),
    );

    if (shows == null || shows.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    for (var show in shows) {
      if (normalizeTitle(show.title!)
              .toLowerCase()
              .contains(normalizeTitle(seriesName).toLowerCase()) ||
          show.title!.contains(seriesName)) {
        final episodes = await getMovieTVStreamEpisodesDCVA(
          Endpoints.getMovieTVStreamInfoDramacool(show.id!, consumetUrl),
        );

        if (episodes != null && episodes.isNotEmpty) {
          bool doesntExist = episodes
              .where((element) =>
                  element.episode == 'Episode ${episodeNumber.toString()}')
              .isEmpty;

          if (doesntExist) {
            return ProviderLoaderResult(
              success: false,
              errorMessage: 'Episode not found',
            );
          }

          final targetEpisode = episodes.firstWhere(
            (element) =>
                element.episode == 'Episode ${episodeNumber.toString()}',
          );

          final sources = await getMovieTVStreamLinksAndSubsDCVA(
            Endpoints.getMovieTVStreamLinksDramacool(
              targetEpisode.id!,
              show.id!,
              consumetUrl,
              streamingServerDCVA,
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

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  static Future<ProviderLoaderResult> _loadTVViewasian({
    required int tvId,
    required String seriesName,
    required int seasonNumber,
    required int episodeNumber,
    required String consumetUrl,
    required String streamingServerDCVA,
  }) async {
    final shows = await fetchMovieTVForStreamDCVA(
      Endpoints.searchMovieTVForStreamViewasian(
        normalizeTitle(seriesName).toLowerCase(),
        consumetUrl,
      ),
    );

    if (shows == null || shows.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    for (var show in shows) {
      if (normalizeTitle(show.title!)
              .toLowerCase()
              .contains(normalizeTitle(seriesName).toLowerCase()) ||
          show.title!.contains(seriesName)) {
        final episodes = await getMovieTVStreamEpisodesDCVA(
          Endpoints.getMovieTVStreamInfoViewasian(show.id!, consumetUrl),
        );

        if (episodes != null && episodes.isNotEmpty) {
          bool doesntExist = episodes
              .where((element) =>
                  element.episode == 'Episode ${episodeNumber.toString()}')
              .isEmpty;

          if (doesntExist) {
            return ProviderLoaderResult(
              success: false,
              errorMessage: 'Episode not found',
            );
          }

          final targetEpisode = episodes.firstWhere(
            (element) =>
                element.episode == 'Episode ${episodeNumber.toString()}',
          );

          final sources = await getMovieTVStreamLinksAndSubsDCVA(
            Endpoints.getMovieTVStreamLinksViewasian(
              targetEpisode.id!,
              show.id!,
              consumetUrl,
              streamingServerDCVA,
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

    if (shows == null || shows.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    bool entryFound = false;
    for (var show in shows) {
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
          for (var episode in tvInfo.episodes!) {
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
          for (var episode in tvInfo.episodes!) {
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

  static Future<ProviderLoaderResult> _loadTVZoro({
    required int tvId,
    required String seriesName,
    required int seasonNumber,
    required int episodeNumber,
    required String consumetUrl,
    required String streamingServerZoro,
  }) async {
    final shows = await fetchMovieTVForStreamZoro(
      Endpoints.searchZoroMoviesTV(
        consumetUrl,
        normalizeTitle(seriesName).toLowerCase(),
      ),
    );

    if (shows == null || shows.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    for (var show in shows) {
      if ((normalizeTitle(show.title!)
                  .toLowerCase()
                  .contains(seriesName.toLowerCase()) ||
              show.title!.contains(seriesName)) &&
          show.type == 'TV') {
        final episodes = await getMovieTVStreamEpisodesZoro(
          Endpoints.getMovieTVInfoZoro(consumetUrl, show.id!),
        );

        if (episodes != null && episodes.isNotEmpty) {
          bool doesntExist = episodes
              .where((element) => element.episode == episodeNumber.toString())
              .isEmpty;

          if (doesntExist) {
            return ProviderLoaderResult(
              success: false,
              errorMessage: 'Episode not found',
            );
          }

          final targetEpisode = episodes.firstWhere(
            (element) => element.episode == episodeNumber.toString(),
          );

          final sources = await getMovieTVStreamLinksAndSubsZoro(
            Endpoints.getMovieTVStreamLinksZoro(
              targetEpisode.id!,
              consumetUrl,
              streamingServerZoro,
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

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }
}
