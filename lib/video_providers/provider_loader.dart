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
    required String gokuServer,
    required String sflixServer,
    required String himoviesServer,
    required String animekaiServer,
    required String hianimeServer,
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
          return await _loadMovieFlixAPIMulti(
            movieId: movieId,
            flixApiUrl: flixApiUrl,
            provider: 'pstream',
          );

        case 'goku':
          return await _loadMovieGoku(
            movieId: movieId,
            movieName: movieName,
            releaseYear: releaseYear,
            consumetUrl: consumetUrl,
            gokuServer: gokuServer,
          );

        case 'sflix':
          return await _loadMovieSflix(
            movieId: movieId,
            movieName: movieName,
            releaseYear: releaseYear,
            consumetUrl: consumetUrl,
            sflixServer: sflixServer,
          );

        case 'himovies':
          return await _loadMovieHimovies(
            movieId: movieId,
            movieName: movieName,
            releaseYear: releaseYear,
            consumetUrl: consumetUrl,
            himoviesServer: himoviesServer,
          );

        case 'vixsrc':
          return await _loadMovieFlixAPIMulti(
            movieId: movieId,
            flixApiUrl: flixApiUrl,
            provider: 'vixsrc',
          );

        case 'showbox':
          return await _loadMovieFlixAPIMulti(
            movieId: movieId,
            flixApiUrl: flixApiUrl,
            provider: 'showbox',
          );

        case 'animekai':
          return await _loadAnimeKai(
            animeName: movieName,
            episodeNumber: 1,
            consumetUrl: consumetUrl,
            animekaiServer: animekaiServer,
          );

        case 'animepahe':
          return await _loadAnimePahe(
            animeName: movieName,
            episodeNumber: 1,
            consumetUrl: consumetUrl,
          );

        case 'hianime':
          return await _loadHiAnime(
            animeName: movieName,
            episodeNumber: 1,
            consumetUrl: consumetUrl,
            hianimeServer: hianimeServer,
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
    required String gokuServer,
    required String sflixServer,
    required String himoviesServer,
    required String animekaiServer,
    required String hianimeServer,
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
          return await _loadTVFlixAPIMulti(
            tvId: tvId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            flixApiUrl: flixApiUrl,
            provider: 'pstream',
          );

        case 'goku':
          return await _loadTVGoku(
            tvId: tvId,
            seriesName: seriesName,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            consumetUrl: consumetUrl,
            gokuServer: gokuServer,
            appLanguage: appLanguage,
          );

        case 'sflix':
          return await _loadTVSflix(
            tvId: tvId,
            seriesName: seriesName,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            consumetUrl: consumetUrl,
            sflixServer: sflixServer,
            appLanguage: appLanguage,
          );

        case 'himovies':
          return await _loadTVHimovies(
            tvId: tvId,
            seriesName: seriesName,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            consumetUrl: consumetUrl,
            himoviesServer: himoviesServer,
            appLanguage: appLanguage,
          );

        case 'vixsrc':
          return await _loadTVFlixAPIMulti(
            tvId: tvId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            flixApiUrl: flixApiUrl,
            provider: 'vixsrc',
          );

        case 'showbox':
          return await _loadTVFlixAPIMulti(
            tvId: tvId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            flixApiUrl: flixApiUrl,
            provider: 'showbox',
          );

        case 'animekai':
          return await _loadAnimeKai(
            animeName: seriesName,
            episodeNumber: episodeNumber,
            consumetUrl: consumetUrl,
            animekaiServer: animekaiServer,
          );

        case 'animepahe':
          return await _loadAnimePahe(
            animeName: seriesName,
            episodeNumber: episodeNumber,
            consumetUrl: consumetUrl,
          );

        case 'hianime':
          return await _loadHiAnime(
            animeName: seriesName,
            episodeNumber: episodeNumber,
            consumetUrl: consumetUrl,
            hianimeServer: hianimeServer,
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

  /// Load movie from FlixAPI Multi-provider (vixsrc, pstream, showbox)
  static Future<ProviderLoaderResult> _loadMovieFlixAPIMulti({
    required int movieId,
    required String flixApiUrl,
    required String provider,
  }) async {
    final sources = await getStreamLinksFlixAPIMulti(
      Endpoints.getMovieStreamLinkFlixAPIMulti(flixApiUrl, provider, movieId),
    );

    if (sources.success && sources.links != null && sources.links!.isNotEmpty) {
      final firstLink = sources.links!.first;

      final videoLinks = [
        RegularVideoLinks(
          url: firstLink.url,
          isM3U8: firstLink.isM3U8 ?? firstLink.url?.endsWith('.m3u8') ?? false,
        ),
      ];

      final subtitleLinks = firstLink.subtitles
          ?.map((subtitle) => RegularSubtitleLinks(
                url: subtitle.file,
                language: subtitle.label,
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

  /// Load TV from FlixAPI Multi-provider (vixsrc, pstream, showbox)
  static Future<ProviderLoaderResult> _loadTVFlixAPIMulti({
    required int tvId,
    required int seasonNumber,
    required int episodeNumber,
    required String flixApiUrl,
    required String provider,
  }) async {
    final sources = await getStreamLinksFlixAPIMulti(
      Endpoints.getTVStreamLinkFlixAPIMulti(
        flixApiUrl,
        provider,
        tvId,
        episodeNumber,
        seasonNumber,
      ),
    );

    if (sources.success && sources.links != null && sources.links!.isNotEmpty) {
      final firstLink = sources.links!.first;

      final videoLinks = [
        RegularVideoLinks(
          url: firstLink.url,
          isM3U8: firstLink.isM3U8 ?? firstLink.url?.endsWith('.m3u8') ?? false,
        ),
      ];

      final subtitleLinks = firstLink.subtitles
          ?.map((subtitle) => RegularSubtitleLinks(
                url: subtitle.file,
                language: subtitle.label,
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

  // ==================== GOKU PROVIDER METHODS ====================

  static Future<ProviderLoaderResult> _loadMovieGoku({
    required int movieId,
    required String movieName,
    required String? releaseYear,
    required String consumetUrl,
    required String gokuServer,
  }) async {
    final movies = await fetchMoviesForStreamGoku(
      Endpoints.searchMovieTVForStreamGoku(
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

        final episodes = await getMovieStreamEpisodesGoku(
          Endpoints.getMovieTVStreamInfoGoku(movie.id!, consumetUrl),
        );

        if (episodes.isNotEmpty) {
          final sources = await getMovieStreamLinksAndSubsGoku(
            Endpoints.getMovieTVStreamLinksGoku(
              episodes[0].id!,
              movie.id!,
              consumetUrl,
              gokuServer,
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

  static Future<ProviderLoaderResult> _loadTVGoku({
    required int tvId,
    required String seriesName,
    required int seasonNumber,
    required int episodeNumber,
    required String consumetUrl,
    required String gokuServer,
    required String appLanguage,
  }) async {
    final isProxyEnabled = false;
    final proxyUrl = '';

    final tvDetails = await fetchTVDetails(
      Endpoints.tvDetailsUrl(tvId, appLanguage),
      isProxyEnabled,
      proxyUrl,
    );

    final totalSeasons = tvDetails.numberOfSeasons!;
    print('[GOKU TV] Looking for: $seriesName with $totalSeasons seasons');

    final shows = await fetchTVForStreamGoku(
      Endpoints.searchMovieTVForStreamGoku(
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

    print('[GOKU TV] Found ${shows.length} shows in search results');
    bool entryFound = false;
    for (final show in shows) {
      print(
          '[GOKU TV] Checking: ${show.title} (${show.releaseDate}) - Type: ${show.type}, Seasons: ${show.seasons}');

      // Check type first
      if (show.type != 'TV Series') {
        print('[GOKU TV] Skipping - not a TV Series');
        continue;
      }

      // Check title match
      final normalizedShowTitle = normalizeTitle(show.title!).toLowerCase();
      final normalizedSeriesName = normalizeTitle(seriesName).toLowerCase();
      final titleMatches = normalizedShowTitle.contains(normalizedSeriesName) ||
          show.title!.toLowerCase().contains(seriesName.toLowerCase());

      if (!titleMatches) {
        print('[GOKU TV] Skipping - title does not match');
        continue;
      }

      // Check seasons match (if seasons data is available)
      final seasonsMatch = show.seasons == null ||
          show.seasons == totalSeasons ||
          show.seasons == (totalSeasons - 1);

      if (!seasonsMatch) {
        print(
            '[GOKU TV] Skipping - seasons mismatch (show has ${show.seasons}, expected $totalSeasons)');
        continue;
      }

      print('[GOKU TV] ✓ Match found! Using: ${show.title} (${show.id})');
      entryFound = true;

      final tvInfo = await getTVStreamEpisodesGoku(
        Endpoints.getMovieTVStreamInfoGoku(show.id!, consumetUrl),
      );

      if (tvInfo.episodes != null && tvInfo.episodes!.isNotEmpty) {
        for (final episode in tvInfo.episodes!) {
          if (episode.episode == episodeNumber &&
              episode.season == seasonNumber) {
            final sources = await getTVStreamLinksAndSubsGoku(
              Endpoints.getMovieTVStreamLinksGoku(
                episode.id!,
                show.id!,
                consumetUrl,
                gokuServer,
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

    if (!entryFound) {
      throw NotFoundException();
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  // ==================== SFLIX PROVIDER METHODS ====================

  static Future<ProviderLoaderResult> _loadMovieSflix({
    required int movieId,
    required String movieName,
    required String? releaseYear,
    required String consumetUrl,
    required String sflixServer,
  }) async {
    final movies = await fetchMoviesForStreamSflix(
      Endpoints.searchMovieTVForStreamSflix(
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

        final episodes = await getMovieStreamEpisodesSflix(
          Endpoints.getMovieTVStreamInfoSflix(movie.id!, consumetUrl),
        );

        if (episodes.isNotEmpty) {
          final sources = await getMovieStreamLinksAndSubsSflix(
            Endpoints.getMovieTVStreamLinksSflix(
              episodes[0].id!,
              movie.id!,
              consumetUrl,
              sflixServer,
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

  static Future<ProviderLoaderResult> _loadTVSflix({
    required int tvId,
    required String seriesName,
    required int seasonNumber,
    required int episodeNumber,
    required String consumetUrl,
    required String sflixServer,
    required String appLanguage,
  }) async {
    final isProxyEnabled = false;
    final proxyUrl = '';

    final tvDetails = await fetchTVDetails(
      Endpoints.tvDetailsUrl(tvId, appLanguage),
      isProxyEnabled,
      proxyUrl,
    );

    final totalSeasons = tvDetails.numberOfSeasons!;
    print('[SFLIX TV] Looking for: $seriesName with $totalSeasons seasons');

    final shows = await fetchTVForStreamSflix(
      Endpoints.searchMovieTVForStreamSflix(
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

    print('[SFLIX TV] Found ${shows.length} shows in search results');
    bool entryFound = false;
    for (final show in shows) {
      print(
          '[SFLIX TV] Checking: ${show.title} (${show.releaseDate}) - Type: ${show.type}, Seasons: ${show.seasons}');

      // Check type first
      if (show.type != 'TV Series') {
        print('[SFLIX TV] Skipping - not a TV Series');
        continue;
      }

      // Check title match
      final normalizedShowTitle = normalizeTitle(show.title!).toLowerCase();
      final normalizedSeriesName = normalizeTitle(seriesName).toLowerCase();
      final titleMatches = normalizedShowTitle.contains(normalizedSeriesName) ||
          show.title!.toLowerCase().contains(seriesName.toLowerCase());

      if (!titleMatches) {
        print('[SFLIX TV] Skipping - title does not match');
        continue;
      }

      // Check seasons match (if seasons data is available)
      final seasonsMatch = show.seasons == null ||
          show.seasons == totalSeasons ||
          show.seasons == (totalSeasons - 1);

      if (!seasonsMatch) {
        print(
            '[SFLIX TV] Skipping - seasons mismatch (show has ${show.seasons}, expected $totalSeasons)');
        continue;
      }

      print('[SFLIX TV] ✓ Match found! Using: ${show.title} (${show.id})');
      entryFound = true;

      final tvInfo = await getTVStreamEpisodesSflix(
        Endpoints.getMovieTVStreamInfoSflix(show.id!, consumetUrl),
      );

      if (tvInfo.episodes != null && tvInfo.episodes!.isNotEmpty) {
        for (final episode in tvInfo.episodes!) {
          if (episode.episode == episodeNumber &&
              episode.season == seasonNumber) {
            final sources = await getTVStreamLinksAndSubsSflix(
              Endpoints.getMovieTVStreamLinksSflix(
                episode.id!,
                show.id!,
                consumetUrl,
                sflixServer,
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

    if (!entryFound) {
      throw NotFoundException();
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  // ==================== HIMOVIES PROVIDER METHODS ====================

  static Future<ProviderLoaderResult> _loadMovieHimovies({
    required int movieId,
    required String movieName,
    required String? releaseYear,
    required String consumetUrl,
    required String himoviesServer,
  }) async {
    final movies = await fetchMoviesForStreamHimovies(
      Endpoints.searchMovieTVForStreamHimovies(
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

        final episodes = await getMovieStreamEpisodesHimovies(
          Endpoints.getMovieTVStreamInfoHimovies(movie.id!, consumetUrl),
        );

        if (episodes.isNotEmpty) {
          final sources = await getMovieStreamLinksAndSubsHimovies(
            Endpoints.getMovieTVStreamLinksHimovies(
              episodes[0].id!,
              movie.id!,
              consumetUrl,
              himoviesServer,
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

  static Future<ProviderLoaderResult> _loadTVHimovies({
    required int tvId,
    required String seriesName,
    required int seasonNumber,
    required int episodeNumber,
    required String consumetUrl,
    required String himoviesServer,
    required String appLanguage,
  }) async {
    final isProxyEnabled = false;
    final proxyUrl = '';

    final tvDetails = await fetchTVDetails(
      Endpoints.tvDetailsUrl(tvId, appLanguage),
      isProxyEnabled,
      proxyUrl,
    );

    final totalSeasons = tvDetails.numberOfSeasons!;

    final shows = await fetchTVForStreamHimovies(
      Endpoints.searchMovieTVForStreamHimovies(
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
      if ((show.seasons == totalSeasons ||
              show.seasons == (totalSeasons - 1)) &&
          show.type == 'TV Series' &&
          (normalizeTitle(show.title!)
                  .toLowerCase()
                  .contains(normalizeTitle(seriesName).toLowerCase()) ||
              show.title!.contains(seriesName))) {
        entryFound = true;

        final tvInfo = await getTVStreamEpisodesHimovies(
          Endpoints.getMovieTVStreamInfoHimovies(show.id!, consumetUrl),
        );

        if (tvInfo.episodes != null && tvInfo.episodes!.isNotEmpty) {
          for (final episode in tvInfo.episodes!) {
            if (episode.episode == episodeNumber &&
                episode.season == seasonNumber) {
              final sources = await getTVStreamLinksAndSubsHimovies(
                Endpoints.getMovieTVStreamLinksHimovies(
                  episode.id!,
                  show.id!,
                  consumetUrl,
                  himoviesServer,
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

  // ==================== ANIME PROVIDER METHODS ====================

  /// Load anime from AnimeKai
  static Future<ProviderLoaderResult> _loadAnimeKai({
    required String animeName,
    required int episodeNumber,
    required String consumetUrl,
    required String animekaiServer,
  }) async {
    final animeList = await fetchAnimeForStreamAnimeKai(
      Endpoints.searchAnimeKai(
        consumetUrl,
        Uri.encodeComponent(normalizeTitle(animeName).toLowerCase()),
      ),
    );

    if (animeList.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    // Try to find a matching anime
    for (final anime in animeList) {
      final info = await getAnimeInfoAnimeKai(
        Endpoints.getAnimeInfoAnimeKai(consumetUrl, anime.id!),
      );

      if (info.episodes != null && info.episodes!.isNotEmpty) {
        // Find the episode
        for (final episode in info.episodes!) {
          if (episode.number == episodeNumber) {
            final sources = await getAnimeStreamAnimeKai(
              Endpoints.getAnimeStreamAnimeKai(
                consumetUrl,
                episode.id!,
                animekaiServer,
              ),
            );

            if (sources.videoLinks != null && sources.videoLinks!.isNotEmpty) {
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
      // Only try the first result
      break;
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  /// Load anime from AnimePahe
  static Future<ProviderLoaderResult> _loadAnimePahe({
    required String animeName,
    required int episodeNumber,
    required String consumetUrl,
  }) async {
    final animeList = await fetchAnimeForStreamAnimePahe(
      Endpoints.searchAnimePahe(
        consumetUrl,
        Uri.encodeComponent(normalizeTitle(animeName).toLowerCase()),
      ),
    );

    if (animeList.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    // Try to find a matching anime
    for (final anime in animeList) {
      final info = await getAnimeInfoAnimePahe(
        Endpoints.getAnimeInfoAnimePahe(consumetUrl, anime.id!),
      );

      if (info.episodes != null && info.episodes!.isNotEmpty) {
        // Find the episode
        for (final episode in info.episodes!) {
          if (episode.number == episodeNumber) {
            final sources = await getAnimeStreamAnimePahe(
              Endpoints.getAnimeStreamAnimePahe(consumetUrl, episode.id!),
            );

            if (sources.videoLinks != null && sources.videoLinks!.isNotEmpty) {
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
      // Only try the first result
      break;
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }

  /// Load anime from HiAnime
  static Future<ProviderLoaderResult> _loadHiAnime({
    required String animeName,
    required int episodeNumber,
    required String consumetUrl,
    required String hianimeServer,
  }) async {
    final animeList = await fetchAnimeForStreamHiAnime(
      Endpoints.searchHiAnime(
        consumetUrl,
        Uri.encodeComponent(normalizeTitle(animeName).toLowerCase()),
      ),
    );

    if (animeList.isEmpty) {
      return ProviderLoaderResult(
        success: false,
        errorMessage: 'No results found',
      );
    }

    // Try to find a matching anime
    for (final anime in animeList) {
      final info = await getAnimeInfoHiAnime(
        Endpoints.getAnimeInfoHiAnime(consumetUrl, anime.id!),
      );

      if (info.episodes != null && info.episodes!.isNotEmpty) {
        // Find the episode
        for (final episode in info.episodes!) {
          if (episode.number == episodeNumber) {
            final sources = await getAnimeStreamHiAnime(
              Endpoints.getAnimeStreamHiAnime(
                consumetUrl,
                episode.id!,
                hianimeServer,
              ),
            );

            if (sources.videoLinks != null && sources.videoLinks!.isNotEmpty) {
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
      // Only try the first result
      break;
    }

    return ProviderLoaderResult(
      success: false,
      errorMessage: 'No video sources found',
    );
  }
}
