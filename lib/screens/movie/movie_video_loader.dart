// ignore_for_file: use_build_context_synchronously
import 'package:flixquest/functions/function.dart';
import 'package:flixquest/functions/network.dart';
import 'package:flixquest/functions/video_utils.dart';
import 'package:flixquest/models/movie_stream_metadata.dart';
import 'package:flixquest/models/provider_video_source.dart';
import 'package:flixquest/models/provider_load_state.dart';
import 'package:flixquest/services/globle_method.dart';
import 'package:flixquest/video_providers/provider_loader.dart';
import 'package:flixquest/video_providers/scraper_api.dart';
import 'package:flixquest/widgets/provider_loading_widget.dart';
import '../../controllers/recently_watched_database_controller.dart';
import '../../provider/recently_watched_provider.dart';
import '../../video_providers/common.dart';
import '../../video_providers/names.dart';
import '/api/endpoints.dart';
import '/provider/app_dependency_provider.dart';
import '/provider/settings_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:better_player_plus/better_player.dart';
import '../../widgets/common_widgets.dart';
import 'package:flixquest/constants/app_constants.dart' show MediaType;

import 'package:flutter/material.dart';
import '../../screens/common/player.dart';
import '../../tv/player/tv_player_screen.dart';

class MovieVideoLoader extends StatefulWidget {
  const MovieVideoLoader(
      {required this.download,
      required this.metadata,
      this.useTvPlayer = false,
      this.onTvPlayerExit,
      super.key});

  final bool download;
  final MovieStreamMetadata metadata;
  final bool useTvPlayer;
  final VoidCallback? onTvPlayerExit;

  @override
  State<MovieVideoLoader> createState() => _MovieVideoLoaderState();
}

class _MovieVideoLoaderState extends State<MovieVideoLoader> {
  RecentlyWatchedMoviesController recentlyWatchedMoviesController =
      RecentlyWatchedMoviesController();

  List<RegularVideoLinks>? movieVideoLinks;
  List<RegularSubtitleLinks>? movieVideoSubs;

  late SettingsProvider settings =
      Provider.of<SettingsProvider>(context, listen: false);
  List<VideoProvider> videoProviders = [];
  List<ProviderLoadState> providerStates = [];
  int currentProviderIndex = 0;
  String _scraperApiUrl = '';

  Map<String, String> videos = {};
  List<BetterPlayerSubtitlesSource> subs = [];

  // Collect all working providers
  List<ProviderVideoSource> availableProviders = [];

  late int foundIndex;

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  Future<void> _loadProviders() async {
    _scraperApiUrl = Provider.of<AppDependencyProvider>(context, listen: false)
        .flixquestAPIURL;
    final providers = <VideoProvider>[];
    try {
      providers.addAll(await ScraperApi(_scraperApiUrl).getProviders());
    } catch (error) {
      debugPrint('Unable to load scraper providers: $error');
    }

    // Keep the app's existing VixSrc implementation as an independent source,
    // even if the scraper API also exposes a provider named "vixsrc".
    providers.add(VideoProvider.directVixSrc);
    if (!mounted) return;
    setState(() {
      videoProviders = providers;
      providerStates = providers
          .map(
            (provider) => ProviderLoadState(
              codeName: provider.codeName,
              fullName: provider.displayName,
              status: ProviderStatus.pending,
            ),
          )
          .toList();
    });
  }

  void loadVideo() async {
    try {
      await _loadProviders();
      // Fetch movie recommendations first
      await _fetchMovieRecommendations();

      var isBookmarked = await recentlyWatchedMoviesController
          .contain(widget.metadata.movieId!);
      int elapsed = 0;
      if (isBookmarked) {
        var rMovies =
            Provider.of<RecentProvider>(context, listen: false).movies;
        int index = rMovies
            .indexWhere((element) => element.id == widget.metadata.movieId);
        setState(() {
          elapsed = rMovies[index].elapsed!;
        });
        widget.metadata.elapsed = elapsed;
      } else {
        widget.metadata.elapsed = 0;
      }

      if (widget.metadata.releaseDate != null &&
          !isReleased(widget.metadata.releaseDate!)) {
        GlobalMethods.showScaffoldMessage(
            tr('movie_may_not_be_available'), context);
      }

      if (mounted) {
        setState(() {
          for (var index = 0; index < providerStates.length; index++) {
            providerStates[index] = providerStates[index].copyWith(
              status: ProviderStatus.loading,
            );
          }
        });
      }

      // Start all sources together and use the first playable response.
      final selection = await ProviderLoader.loadFirstSuccessful(
        providers: videoProviders,
        load: (provider) {
          debugPrint(
            '[MovieVideoLoader] Request provider=${provider.displayName} '
            '(${provider.codeName}), tmdbId=${widget.metadata.movieId}',
          );
          return ProviderLoader.loadMovieFromProvider(
            provider: provider,
            movieId: widget.metadata.movieId!,
            scraperApiUrl: _scraperApiUrl,
          );
        },
        onResult: (index, provider, result) {
          debugPrint(
            '[MovieVideoLoader] Response provider=${provider.displayName} '
            'success=${result.success}, links=${result.videoLinks?.length ?? 0}, '
            'subtitles=${result.subtitleLinks?.length ?? 0}, error=${result.errorMessage}',
          );
          if (mounted) {
            setState(() {
              currentProviderIndex = index;
              providerStates[index] = providerStates[index].copyWith(
                status: result.success && result.videoLinks?.isNotEmpty == true
                    ? ProviderStatus.success
                    : ProviderStatus.failed,
                errorMessage: result.errorMessage,
              );
            });
          }
        },
      );

      final firstWorkingProviderCode = selection?.provider.codeName;
      if (selection != null) {
        final result = selection.result;
        videos = VideoUtils.convertVideoLinksToMap(result.videoLinks!);
        movieVideoLinks = result.videoLinks;
        movieVideoSubs = result.subtitleLinks;
        _addSubtitles(result.subtitleLinks);
      }

      // Check if we found a working provider
      if (firstWorkingProviderCode == null && mounted) {
        Navigator.pop(context);
        showModalBottomSheet(
            builder: (context) {
              return ReportErrorWidget(
                error: tr('movie_vid_404'),
                hideButton: false,
              );
            },
            context: context);
        return;
      }

      // Prepare final video map (reversed for quality ordering)
      Map<String, String> reversedVids =
          VideoUtils.reverseVideoQualityMap(videos);
      final videoFormats = VideoUtils.reverseVideoQualityMap(
        VideoUtils.convertVideoFormatsToMap(movieVideoLinks ?? const []),
      );
      final videoHeaders = VideoUtils.reverseVideoQualityMap(
        VideoUtils.convertVideoHeadersToMap(movieVideoLinks ?? const []),
      );

      if (firstWorkingProviderCode != null && mounted) {
        Provider.of<SettingsProvider>(context, listen: false)
            .analytics
            .trackMovieWatched(
              movieName: widget.metadata.movieName,
              movieId: widget.metadata.movieId,
              isAdult: widget.metadata.isAdult ?? 'unknown',
            );

        // Navigate to player with provider list for lazy loading
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              final player = PlayerOne(
                mediaType: MediaType.movie,
                sources: reversedVids,
                subs: subs,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.surface
                ],
                settings: settings,
                movieMetadata: widget.metadata,
                availableProviders:
                    videoProviders, // Pass provider list for lazy loading
                currentProviderCode:
                    firstWorkingProviderCode, // Current provider
                scraperApiUrl: _scraperApiUrl,
                videoFormats: videoFormats,
                videoHeaders: videoHeaders,
                prefetchedProviderResults: selection?.batchResults ?? const {},
                subtitleStyle:
                    Provider.of<SettingsProvider>(context).subtitleTextStyle,
                useTvControls: widget.useTvPlayer,
                onTvPlayerExit: widget.onTvPlayerExit,
              );
              return widget.useTvPlayer
                  ? TvPlayerScreen(child: player)
                  : player;
            },
          ),
        ).then((value) async {
          if (value != null) {
            Function callback = value;
            await callback.call();
          }
        });
      } else {
        if (mounted) {
          Navigator.pop(context);
          showModalBottomSheet(
              builder: (context) {
                return ReportErrorWidget(
                  error: tr('movie_vid_404'),
                  hideButton: false,
                );
              },
              context: context);
        }
      }
    } on Exception catch (e) {
      debugPrint('[MovieVideoLoader] Exception loading video: $e');
      if (mounted) {
        Navigator.pop(context);
        showModalBottomSheet(
            builder: (context) {
              return ReportErrorWidget(
                error: tr('movie_vid_404'),
                hideButton: false,
              );
            },
            context: context);
      }
    }
  }

  void _addSubtitles(List<RegularSubtitleLinks>? subtitleLinks) {
    if (subtitleLinks == null || subtitleLinks.isEmpty) return;
    final preferredLang = settings.defaultSubtitleLanguage.toLowerCase();

    for (final subLink in subtitleLinks) {
      final subLanguage = subLink.language ?? 'Unknown';
      final normalizedLanguage = subLanguage.toLowerCase();
      final isPreferred = preferredLang.isNotEmpty &&
          (normalizedLanguage.startsWith(preferredLang) ||
              normalizedLanguage == preferredLang ||
              (preferredLang == 'en' &&
                  normalizedLanguage.startsWith('english')));
      subs.add(
        BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.network,
          urls: [subLink.url ?? ''],
          name: subLanguage,
          selectedByDefault: isPreferred,
          headers: subLink.headers,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: .12),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ProviderLoadingWidget(
                providers: providerStates,
                currentIndex: currentProviderIndex,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchMovieRecommendations() async {
    try {
      if (widget.metadata.movieId != null) {
        final isProxyEnabled =
            Provider.of<SettingsProvider>(context, listen: false).enableProxy;
        final proxyUrl =
            Provider.of<AppDependencyProvider>(context, listen: false)
                .tmdbProxy;

        // Fetch movie recommendations
        await fetchMovies(
          Endpoints.getMovieRecommendations(
              widget.metadata.movieId!, 1, settings.appLanguage),
          isProxyEnabled,
          proxyUrl,
        ).then((movies) {
          debugPrint('Fetched ${movies.length} movie recommendations');
          if (movies.isNotEmpty) {
            setState(() {
              // Get top 10 recommendations
              final topRecommendations = movies.take(10).toList();
              widget.metadata.recommendations = topRecommendations
                  .map((movie) => MovieRecommendation.fromMovie(movie))
                  .toList();
              debugPrint(
                  'Set ${widget.metadata.recommendations?.length} recommendations in metadata');
            });
          }
        });

        // Set the movie change callback
        widget.metadata.onMovieChange = (int movieId) async {
          // This will be called from the player when user selects a movie
        };
      }
    } catch (e) {
      // If fetching recommendations fails, continue without them
      debugPrint('Failed to fetch movie recommendations: $e');
    }
  }
}
