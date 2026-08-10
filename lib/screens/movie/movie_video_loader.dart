// ignore_for_file: use_build_context_synchronously
import 'package:flixquest/functions/function.dart';
import 'package:flixquest/functions/network.dart';
import 'package:flixquest/functions/video_utils.dart';
import 'package:flixquest/models/movie_stream_metadata.dart';
import 'package:flixquest/models/offline_download.dart';
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
import '/constants/api_constants.dart';
import '/provider/offline_download_provider.dart';
import '/provider/app_dependency_provider.dart';
import '/provider/settings_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:better_player_plus/better_player.dart';
import '../../widgets/common_widgets.dart';
import 'package:flixquest/constants/app_constants.dart' show MediaType;

import 'package:flutter/material.dart';
import '../../screens/common/player.dart';
import '../../screens/common/download_selection_sheets.dart';
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
  final Map<String, Stopwatch> _providerStopwatches = {};
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
    final orderedProviders = settings.orderStreamProviders(providers);
    if (!mounted) return;
    setState(() {
      videoProviders = orderedProviders;
      providerStates = orderedProviders
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
      VideoProvider? selectedDownloadProvider;
      if (widget.download) {
        if (!mounted) return;
        selectedDownloadProvider = await DownloadSelectionSheets.showProvider(
          context,
          providers: videoProviders,
        );
        if (!mounted) return;
        if (selectedDownloadProvider == null) {
          settings.analytics.trackDownload(
            action: 'provider_selection',
            mediaType: 'movie',
            outcome: 'cancelled',
          );
          Navigator.pop(context, false);
          return;
        }
        setState(() {
          currentProviderIndex = videoProviders.indexWhere(
            (provider) =>
                provider.codeName == selectedDownloadProvider!.codeName,
          );
        });
      }
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
              status: selectedDownloadProvider == null ||
                      providerStates[index].codeName ==
                          selectedDownloadProvider.codeName
                  ? ProviderStatus.loading
                  : ProviderStatus.pending,
            );
          }
        });
      }

      // Start all sources together and use the first playable response.
      final selection = await ProviderLoader.loadFirstSuccessful(
        providers: selectedDownloadProvider == null
            ? videoProviders
            : [selectedDownloadProvider],
        load: (provider) {
          _providerStopwatches[provider.codeName] = Stopwatch()..start();
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
          final durationMs = _providerStopwatches
                  .remove(provider.codeName)
                  ?.elapsedMilliseconds ??
              0;
          final providerSucceeded =
              result.success && result.videoLinks?.isNotEmpty == true;
          settings.analytics.trackProviderAttempt(
            mediaType: 'movie',
            provider: provider.displayName,
            purpose: widget.download ? 'download' : 'playback',
            success: providerSucceeded,
            durationMs: durationMs,
            sourceCount: result.videoLinks?.length ?? 0,
            subtitleCount: result.subtitleLinks?.length ?? 0,
            error: result.errorMessage,
          );
          final providerIndex = videoProviders.indexWhere(
            (candidate) => candidate.codeName == provider.codeName,
          );
          debugPrint(
            '[MovieVideoLoader] Response provider=${provider.displayName} '
            'success=${result.success}, links=${result.videoLinks?.length ?? 0}, '
            'subtitles=${result.subtitleLinks?.length ?? 0}, error=${result.errorMessage}',
          );
          if (mounted) {
            setState(() {
              currentProviderIndex = providerIndex;
              providerStates[providerIndex] =
                  providerStates[providerIndex].copyWith(
                status: providerSucceeded
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
        _showErrorSheet(tr('movie_vid_404'));
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
        if (widget.download) {
          await _enqueueDownload(
            sources: reversedVids,
            videoFormats: videoFormats,
            videoHeaders: videoHeaders,
            providerName: selection?.provider.displayName,
          );
          return;
        }
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
          _showErrorSheet(tr('movie_vid_404'));
        }
      }
    } on Exception catch (e) {
      debugPrint('[MovieVideoLoader] Exception loading video: $e');
      if (mounted) {
        _showErrorSheet(tr('movie_vid_404'));
      }
    }
  }

  /// Leaves the loader screen and reports the failure in a bottom sheet that
  /// can push a fresh loader when the user retries.
  void _showErrorSheet(String message) {
    final navigator = Navigator.of(context);
    final metadata = widget.metadata;
    final download = widget.download;
    final useTvPlayer = widget.useTvPlayer;
    final onTvPlayerExit = widget.onTvPlayerExit;
    navigator.pop();
    ReportErrorWidget.show(
      navigator.context,
      error: message,
      onRetry: () => navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => MovieVideoLoader(
            metadata: metadata,
            download: download,
            useTvPlayer: useTvPlayer,
            onTvPlayerExit: onTvPlayerExit,
          ),
        ),
      ),
    );
  }

  Future<void> _enqueueDownload({
    required Map<String, String> sources,
    required Map<String, BetterPlayerVideoFormat?> videoFormats,
    required Map<String, Map<String, String>> videoHeaders,
    String? providerName,
  }) async {
    final quality = await DownloadSelectionSheets.showResolution(
      context,
      resolutions: sources.keys.toList(),
      providerName: providerName,
    );
    if (!mounted) return;
    if (quality == null) {
      settings.analytics.trackDownload(
        action: 'resolution_selection',
        mediaType: 'movie',
        outcome: 'cancelled',
        provider: providerName,
      );
      Navigator.pop(context, false);
      return;
    }
    final url = sources[quality]!;
    final declaredFormat = videoFormats[quality];
    final format = declaredFormat == BetterPlayerVideoFormat.dash
        ? 'dash'
        : declaredFormat == BetterPlayerVideoFormat.hls
            ? 'hls'
            : url.toLowerCase().contains('.mpd')
                ? 'dash'
                : 'hls';
    final posterPath = widget.metadata.posterPath;
    final subtitleTrack = _preferredSubtitle(movieVideoSubs);
    try {
      await context.read<OfflineDownloadProvider>().enqueue(
            OfflineDownloadRequest(
              id: 'movie_${widget.metadata.movieId}',
              url: url,
              format: format,
              title: widget.metadata.movieName ?? 'Movie',
              subtitle: providerName == null ? null : 'From $providerName',
              mediaType: 'movie',
              quality: quality,
              posterUrl: posterPath == null
                  ? null
                  : '${TMDB_BASE_IMAGE_URL}w500$posterPath',
              maxVideoHeight: _qualityHeight(quality),
              headers: videoHeaders[quality] ??
                  VideoUtils.inferVideoHeaders(url) ??
                  const {},
              contentId: widget.metadata.movieId,
              subtitleTrackUrl: subtitleTrack?.url,
              subtitleTrackName: subtitleTrack?.language,
              subtitleTrackHeaders: subtitleTrack?.headers ?? const {},
            ),
          );
      settings.analytics.trackDownload(
        action: 'enqueue',
        mediaType: 'movie',
        outcome: 'success',
        provider: providerName,
        quality: quality,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      settings.analytics.trackDownload(
        action: 'enqueue',
        mediaType: 'movie',
        outcome: 'error',
        provider: providerName,
        quality: quality,
        error: error.toString(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start download: $error')),
      );
      Navigator.pop(context, false);
    }
  }

  int? _qualityHeight(String quality) {
    final match = RegExp(r'(\d{3,4})').firstMatch(quality);
    return int.tryParse(match?.group(1) ?? '');
  }

  RegularSubtitleLinks? _preferredSubtitle(
    List<RegularSubtitleLinks>? subtitles,
  ) {
    if (subtitles == null || subtitles.isEmpty) return null;
    final preferred = settings.defaultSubtitleLanguage.toLowerCase();
    for (final subtitle in subtitles) {
      final language = subtitle.language?.toLowerCase() ?? '';
      if (subtitle.url?.isNotEmpty == true &&
          preferred.isNotEmpty &&
          (language == preferred ||
              language.startsWith(preferred) ||
              (preferred == 'en' && language.startsWith('english')))) {
        return subtitle;
      }
    }
    return subtitles.cast<RegularSubtitleLinks?>().firstWhere(
          (subtitle) => subtitle?.url?.isNotEmpty == true,
          orElse: () => null,
        );
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
