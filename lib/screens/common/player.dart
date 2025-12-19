// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flixquest/models/tv_stream_metadata.dart';

import '../../models/movie_stream_metadata.dart';
import '../../models/provider_video_source.dart';
import '../../video_providers/names.dart';
import '../../video_providers/provider_loader.dart';
import '../../functions/video_utils.dart';
import '../../provider/app_dependency_provider.dart';
import '/constants/app_constants.dart';
import '/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:better_player_plus/better_player_plus.dart';
import '../../functions/function.dart';
import '../../provider/settings_provider.dart';
import 'player/player_data_management.dart';
import 'player/player_external_subtitles.dart';
import 'player/player_episode_selection.dart';
import 'player/player_movie_recommendations.dart';
import 'player/player_widgets.dart';

class PlayerOne extends StatefulWidget {
  const PlayerOne(
      {required this.sources,
      required this.subs,
      required this.colors,
      required this.settings,
      this.movieMetadata,
      this.tvMetadata,
      required this.mediaType,
      required this.subtitleStyle,
      this.onEpisodeChange, // Callback for when user selects a different episode
      this.tvRoute, // StreamRoute for TV shows (needed for loading new episodes)
      this.availableProviders, // Provider metadata for lazy loading
      this.currentProviderCode, // Current provider code
      super.key});
  final Map<String, String> sources;
  final List<BetterPlayerSubtitlesSource> subs;
  final List<Color> colors;
  final SettingsProvider settings;
  final MovieStreamMetadata? movieMetadata;
  final TVStreamMetadata? tvMetadata;
  final MediaType? mediaType;
  final String? subtitleStyle;
  final Function(int episodeId, int episodeNumber, int seasonNumber)?
      onEpisodeChange;
  final StreamRoute? tvRoute;
  final List<VideoProvider>?
      availableProviders; // Changed to VideoProvider list
  final String? currentProviderCode;

  @override
  State<PlayerOne> createState() => _PlayerOneState();
}

class _PlayerOneState extends State<PlayerOne> with WidgetsBindingObserver {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerControlsConfiguration betterPlayerControlsConfiguration;
  late BetterPlayerBufferingConfiguration betterPlayerBufferingConfiguration;
  final PlayerDataManagement _dataManagement = PlayerDataManagement();
  final PlayerExternalSubtitles _externalSubtitles = PlayerExternalSubtitles();
  late final PlayerEpisodeSelection _episodeSelection;
  final PlayerMovieRecommendations _movieRecommendations =
      PlayerMovieRecommendations();
  final PlayerNextEpisodeWidget _nextEpisodeWidget = PlayerNextEpisodeWidget();
  late int duration;

  final GlobalKey _betterPlayerKey = GlobalKey();

  int totalMinutesWatched = 0;
  bool isVideoPaused = false;

  int playbackDurationInSeconds = 0;
  Timer? _durationTimer;
  // ignore: unused_field
  Timer? _resetTimer;

  // For next episode button
  bool _showNextEpisodeButton = false;
  final bool _nextEpisodeButtonDismissed = false;
  Timer? _progressCheckTimer;
  OverlayEntry? _nextEpisodeOverlay;

  late SettingsProvider settings;

  // Provider switching
  bool _isSwitchingProvider = false;
  late String? _currentProviderCode; // Track current provider
  Map<String, ProviderVideoSource> _loadedProviders =
      {}; // Cache loaded providers
  Set<String> _loadingProviders = {}; // Track which providers are being loaded

  @override
  void initState() {
    settings = Provider.of<SettingsProvider>(context, listen: false);
    _currentProviderCode = widget.currentProviderCode; // Initialize from widget
    super.initState();

    // Initialize episode selection with current season
    _episodeSelection = PlayerEpisodeSelection(widget.tvMetadata?.seasonNumber);

    String backgroundColorString = widget.settings.subtitleBackgroundColor;
    String foregroundColorString = widget.settings.subtitleForegroundColor;
    String hexColorBackground =
        backgroundColorString.replaceAll('Color(0x', '').replaceAll(')', '');
    String hexColorForeground =
        foregroundColorString.replaceAll('Color(0x', '').replaceAll(')', '');

    Color backgroundColor = Color(int.parse('0x$hexColorBackground'));
    Color foregroundColor = Color(int.parse('0x$hexColorForeground'));

    WidgetsBinding.instance.addObserver(this);
    betterPlayerBufferingConfiguration = BetterPlayerBufferingConfiguration(
      maxBufferMs: widget.settings.defaultMaxBufferDuration,
      minBufferMs: 15000,
    );
    betterPlayerControlsConfiguration = BetterPlayerControlsConfiguration(
        // Gesture controls configuration
        gestureConfiguration: BetterPlayerGestureConfiguration(
          enableVolumeSwipe: true,
          enableBrightnessSwipe: true,
          enableSeekSwipe: true,
          volumeSwipeSensitivity: 0.5,
          brightnessSwipeSensitivity: 0.5,
          seekSwipeSensitivity: 1.0,
        ),
        onFullScreenChange: () {
          widget.mediaType == MediaType.movie
              ? insertRecentMovieData()
              : insertRecentEpisodeData();
        },
        enableFullscreen: true,
        enableEpisodeSelection: widget.mediaType == MediaType.tvShow &&
            widget.tvMetadata?.seasonEpisodes != null &&
            widget.tvMetadata!.seasonEpisodes!.isNotEmpty,
        onEpisodeListTap: () {
          _episodeSelection.showEpisodeSelectionBottomSheet(
            context: context,
            colors: widget.colors,
            tvMetadata: widget.tvMetadata!,
            tvRoute: widget.tvRoute,
            onSaveProgress: _handleContentSwitch,
            closePlayer: () => Navigator.pop(context),
          );
        },
        enableMovieRecommendations: widget.mediaType == MediaType.movie &&
            widget.movieMetadata?.recommendations != null &&
            widget.movieMetadata!.recommendations!.isNotEmpty,
        onMovieRecommendationsTap: () {
          _movieRecommendations.showMovieRecommendationsBottomSheet(
            context: context,
            colors: widget.colors,
            movieMetadata: widget.movieMetadata!,
            onSaveProgress: _handleContentSwitch,
            closePlayer: () => Navigator.pop(context),
          );
        },
        enableNextEpisodeButton: widget.mediaType == MediaType.tvShow &&
            widget.settings.enableNextEpisodeButton,
        name: widget.mediaType == MediaType.movie
            ? '${widget.movieMetadata!.movieName!} (${widget.movieMetadata!.releaseYear!})'
            : '${widget.tvMetadata!.seriesName!} - ${widget.tvMetadata!.episodeName!} | ${episodeSeasonFormatter(widget.tvMetadata!.episodeNumber!, widget.tvMetadata!.seasonNumber!)}',
        backgroundColor: Colors.black,
        progressBarBackgroundColor: Colors.white,
        controlBarColor: Colors.black.withValues(alpha: 0.3),
        muteIcon: Icons.volume_off_rounded,
        unMuteIcon: Icons.volume_up_rounded,
        pauseIcon: Icons.pause_rounded,
        pipMenuIcon: Icons.picture_in_picture_rounded,
        playIcon: Icons.play_arrow_rounded,
        showControlsOnInitialize: false,
        loadingColor: widget.colors.first,
        iconsColor: widget.colors.first,
        backwardSkipTimeInMilliseconds:
            Duration(seconds: widget.settings.defaultSeekDuration)
                .inMilliseconds,
        forwardSkipTimeInMilliseconds:
            Duration(seconds: widget.settings.defaultSeekDuration)
                .inMilliseconds,
        progressBarPlayedColor: widget.colors.first,
        progressBarBufferedColor: Colors.black45,
        skipForwardIcon: FontAwesomeIcons.rotateRight,
        skipBackIcon: FontAwesomeIcons.rotateLeft,
        fullscreenEnableIcon: Icons.fullscreen_rounded,
        fullscreenDisableIcon: Icons.fullscreen_exit_rounded,
        overflowMenuIcon: Icons.menu_rounded,
        overflowMenuIconsColor: widget.colors.first,
        overflowModalTextColor: widget.colors.first,
        overflowModalColor: widget.colors.last,
        subtitlesIcon: Icons.closed_caption_rounded,
        qualitiesIcon: Icons.hd_rounded,
        enableAudioTracks: false,
        controlBarHeight: 50,
        watchingText: tr('watching_text'),
        playerTimeMode: settings.playerTimeDisplay,
        // Add custom overflow menu item for external subtitles
        overflowMenuCustomItems: [
          BetterPlayerOverflowMenuItem(
            Icons.subtitles_outlined,
            tr('external_subtitles'),
            () {
              _externalSubtitles.showExternalSubtitlesMenu(
                context: context,
                colors: widget.colors,
                mediaType: widget.mediaType,
                movieMetadata: widget.movieMetadata,
                tvMetadata: widget.tvMetadata,
                betterPlayerController: _betterPlayerController,
              );
            },
          ),
          // Add provider switcher if multiple providers are available
          if (widget.availableProviders != null &&
              widget.availableProviders!.length > 1)
            BetterPlayerOverflowMenuItem(
              Icons.swap_horiz_rounded,
              tr('switch_provider'),
              () {
                _showProviderSwitcher();
              },
            ),
        ]);
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
            autoDetectFullscreenDeviceOrientation: true,
            fullScreenByDefault: widget.settings.defaultViewMode,
            autoPlay: true,
            fit: BoxFit.contain,
            autoDispose: true,
            controlsConfiguration: betterPlayerControlsConfiguration,
            showPlaceholderUntilPlay: true,
            allowedScreenSleep: false,
            autoDetectFullscreenAspectRatio: true,
            subtitlesConfiguration: BetterPlayerSubtitlesConfiguration(
                backgroundColor: backgroundColor,
                fontFamily: widget.subtitleStyle == 'regular'
                    ? 'Figtree'
                    : widget.subtitleStyle == 'bold'
                        ? 'FigtreeSB'
                        : 'FigtreeLight',
                fontColor: foregroundColor,
                outlineEnabled: false,
                fontSize: widget.settings.subtitleFontSize.toDouble()));

    String keyToFind = widget.settings.defaultVideoResolution == 0
        ? 'auto'
        : widget.settings.defaultVideoResolution.toString();
    String? link;

    if (widget.sources.entries
        .where((entry) => entry.key == keyToFind)
        .isNotEmpty) {
      link = widget.sources.entries
          .where((entry) => entry.key == keyToFind)
          .map((entry) => entry.value)
          .first;
    } else {
      link = widget.sources.values.first;
    }

    BetterPlayerDataSource dataSource =
        BetterPlayerDataSource(BetterPlayerDataSourceType.network, link,
            resolutions: widget.sources,
            subtitles: widget.subs,
            cacheConfiguration: BetterPlayerCacheConfiguration(
              useCache: true,
              preCacheSize: 471859200 * 471859200,
              maxCacheSize: 1073741824 * 1073741824,
              maxCacheFileSize: 471859200 * 471859200,

              ///Android only option to use cached video between app sessions
              key: generateCacheKey(),
            ),
            bufferingConfiguration: betterPlayerBufferingConfiguration);
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource).then((value) {
      _betterPlayerController.videoPlayerController!.seekTo(Duration(
          seconds: widget.mediaType == MediaType.movie
              ? widget.movieMetadata!.elapsed!
              : widget.tvMetadata!.elapsed!));
      duration = _betterPlayerController
          .videoPlayerController!.value.duration!.inSeconds;
    });
    _betterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);

    // Add event listener for video finish detection
    _betterPlayerController.addEventsListener((BetterPlayerEvent event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        // Video finished, check if there's a next episode
        _handleVideoFinished();
      }
    });

    // Start checking progress for next episode button
    if (widget.mediaType == MediaType.tvShow) {
      _startProgressCheck();
    }

    // _betterPlayerController.addEventsListener((BetterPlayerEvent event) {
    //   if (event.betterPlayerEventType == BetterPlayerEventType.play ||
    //       event.betterPlayerEventType == BetterPlayerEventType.bufferingEnd) {
    //     startDurationTimer();
    //   } else if (event.betterPlayerEventType == BetterPlayerEventType.pause ||
    //       event.betterPlayerEventType == BetterPlayerEventType.bufferingStart) {
    //     pauseDurationTimer();
    //   } else if (event.betterPlayerEventType ==
    //       BetterPlayerEventType.finished) {
    //     resetDurationTimer();
    //   }
    // });
  }

  void _startProgressCheck() {
    _progressCheckTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_betterPlayerController.isVideoInitialized()! &&
          _betterPlayerController.videoPlayerController != null) {
        final position =
            _betterPlayerController.videoPlayerController!.value.position;
        final duration =
            _betterPlayerController.videoPlayerController!.value.duration;
        final isFullScreen = _betterPlayerController.isFullScreen;

        if (duration != null && duration.inSeconds > 0) {
          final progress = position.inSeconds / duration.inSeconds;

          // Show button at 95% progress if there's a next episode, in fullscreen, not manually dismissed, and feature is enabled
          if (progress >= 0.95 &&
              !_showNextEpisodeButton &&
              !_nextEpisodeButtonDismissed &&
              _hasNextEpisode() &&
              isFullScreen &&
              betterPlayerControlsConfiguration.enableNextEpisodeButton) {
            _showNextEpisodeButton = true;
            _showNextEpisodeOverlay();
          } else if ((progress < 0.95 || !isFullScreen) &&
              _showNextEpisodeButton) {
            _showNextEpisodeButton = false;
            _hideNextEpisodeOverlay();
          }
        }
      }
    });
  }

  bool _hasNextEpisode() {
    if (widget.tvMetadata?.seasonEpisodes == null ||
        widget.tvMetadata!.seasonEpisodes!.isEmpty) {
      return false;
    }

    final currentIndex = widget.tvMetadata!.seasonEpisodes!.indexWhere(
      (e) => e.episodeNumber == widget.tvMetadata!.episodeNumber,
    );

    return currentIndex != -1 &&
        currentIndex < widget.tvMetadata!.seasonEpisodes!.length - 1;
  }

  void _showNextEpisodeOverlay() {
    if (_nextEpisodeOverlay != null) return;

    _nextEpisodeOverlay = OverlayEntry(
      builder: (context) => _nextEpisodeWidget.buildNextEpisodeFloatingButton(
        context: context,
        tvMetadata: widget.tvMetadata!,
        showNextEpisodeButton: _showNextEpisodeButton,
        colors: widget.colors,
        onSaveProgress: _handleContentSwitch,
        closePlayer: () => Navigator.pop(context),
        tvRoute: widget.tvRoute,
      ),
    );

    Overlay.of(context).insert(_nextEpisodeOverlay!);
  }

  void _hideNextEpisodeOverlay() {
    _nextEpisodeOverlay?.remove();
    _nextEpisodeOverlay = null;
  }

  void startDurationTimer() {
    if (_durationTimer == null) {
      _durationTimer =
          Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        setState(() {
          playbackDurationInSeconds++;
        });
      });

      _resetTimer = Timer.periodic(const Duration(seconds: 60), (Timer timer) {
        resetDurationTimer();
      });
    }
  }

  void pauseDurationTimer() {
    updateAndLogTotalStreamingDuration(playbackDurationInSeconds);
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void resetDurationTimer() {
    setState(() {
      playbackDurationInSeconds = 0;
    });
  }

  Future<void> insertRecentMovieData() async {
    await _dataManagement.insertRecentMovieData(
      context: context,
      betterPlayerController: _betterPlayerController,
      duration: duration,
      movieMetadata: widget.movieMetadata!,
    );
  }

  Future<void> insertRecentEpisodeData() async {
    await _dataManagement.insertRecentEpisodeData(
      context: context,
      betterPlayerController: _betterPlayerController,
      duration: duration,
      tvMetadata: widget.tvMetadata!,
    );
  }

  /// Close the player (pop navigation)
  void _closePlayer() {
    Navigator.pop(context);
  }

  /// Handles saving progress and analytics before switching to a new episode/movie
  Future<void> _handleContentSwitch() async {
    await _dataManagement.handleContentSwitch(
      context: context,
      mediaType: widget.mediaType!,
      betterPlayerController: _betterPlayerController,
      duration: duration,
      playbackDurationInSeconds: playbackDurationInSeconds,
      movieMetadata: widget.movieMetadata,
      tvMetadata: widget.tvMetadata,
    );

    // Reset playback duration timer for next content
    playbackDurationInSeconds = 0;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final isInBackground = (state == AppLifecycleState.paused) ||
        (state == AppLifecycleState.inactive);
    if (isInBackground) {
      if (_betterPlayerController.isVideoInitialized()!) {
        widget.mediaType == MediaType.movie
            ? insertRecentMovieData()
            : insertRecentEpisodeData();
      }
    }
  }

  @override
  void dispose() {
    // _resetTimer?.cancel();
    _progressCheckTimer?.cancel();
    _hideNextEpisodeOverlay();

    // Restore original brightness before disposing
    BetterPlayerBrightnessManager.restoreOriginalBrightness();

    // Dispose the BetterPlayer controller to clean up resources
    _betterPlayerController.dispose();

    // Reset orientation to portrait when leaving the player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleVideoFinished() {
    if (widget.mediaType == MediaType.tvShow &&
        widget.tvMetadata?.seasonEpisodes != null &&
        widget.tvMetadata!.seasonEpisodes!.isNotEmpty) {
      // Find current episode index
      final currentIndex = widget.tvMetadata!.seasonEpisodes!.indexWhere(
        (e) => e.episodeNumber == widget.tvMetadata!.episodeNumber,
      );

      // Check if there's a next episode
      if (currentIndex != -1 &&
          currentIndex < widget.tvMetadata!.seasonEpisodes!.length - 1) {
        final nextEpisode =
            widget.tvMetadata!.seasonEpisodes![currentIndex + 1];

        // Show countdown dialog for next episode
        _nextEpisodeWidget.showNextEpisodeCountdown(
          context: context,
          nextEpisode: nextEpisode,
          colors: widget.colors,
          tvMetadata: widget.tvMetadata!,
          tvRoute: widget.tvRoute,
          onSaveProgress: _handleContentSwitch,
          closePlayer: _closePlayer,
        );
      } else {
        // No next episode, show episode list
        _episodeSelection.showEpisodeSelectionBottomSheet(
          context: context,
          colors: widget.colors,
          tvMetadata: widget.tvMetadata!,
          tvRoute: widget.tvRoute,
          onSaveProgress: _handleContentSwitch,
          closePlayer: _closePlayer,
        );
      }
    } else if (widget.mediaType == MediaType.movie) {
      debugPrint(
          'Movie finished. Recommendations: ${widget.movieMetadata?.recommendations?.length ?? 0}');
      if (widget.movieMetadata?.recommendations != null &&
          widget.movieMetadata!.recommendations!.isNotEmpty) {
        // Show recommended movie countdown
        _movieRecommendations.showRecommendedMovieCountdown(
          context: context,
          colors: widget.colors,
          movieMetadata: widget.movieMetadata!,
          onSaveProgress: _handleContentSwitch,
          closePlayer: _closePlayer,
        );
      } else {
        debugPrint('No recommendations available for this movie');
      }
    }
  }

  // Provider switching methods
  void _showProviderSwitcher() {
    if (widget.availableProviders == null ||
        widget.availableProviders!.length <= 1) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.3,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            tr('select_provider'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Flexible(
                          child: ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            itemCount: widget.availableProviders!.length,
                            itemBuilder: (context, index) {
                              final provider =
                                  widget.availableProviders![index];
                              final isCurrentProvider =
                                  _currentProviderCode == provider.codeName;

                              final isLoading =
                                  _loadingProviders.contains(provider.codeName);

                              return ListTile(
                                leading: Icon(
                                  isCurrentProvider
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: isCurrentProvider
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                                title: Text(
                                  provider.fullName,
                                  style: TextStyle(
                                    fontWeight: isCurrentProvider
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isCurrentProvider
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                                ),
                                subtitle: isCurrentProvider
                                    ? Text(
                                        tr('currently_playing'),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      )
                                    : null,
                                trailing: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : null,
                                onTap: isCurrentProvider ||
                                        _isSwitchingProvider ||
                                        isLoading
                                    ? null
                                    : () {
                                        _switchToProvider(
                                            provider.codeName, setModalState);
                                      },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _switchToProvider(String providerCode,
      [StateSetter? setModalState]) async {
    if (_isSwitchingProvider || _currentProviderCode == providerCode) {
      return;
    }

    setState(() {
      _isSwitchingProvider = true;
      _loadingProviders.add(providerCode);
    });

    // Also update modal state if provided
    setModalState?.call(() {
      _isSwitchingProvider = true;
      _loadingProviders.add(providerCode);
    });

    try {
      // Save current playback position
      final currentPosition =
          _betterPlayerController.videoPlayerController?.value.position ??
              Duration.zero;

      // Check if provider is already loaded
      ProviderVideoSource? providerSource = _loadedProviders[providerCode];

      // If not loaded, fetch it
      if (providerSource == null) {
        final appDep =
            Provider.of<AppDependencyProvider>(context, listen: false);

        // Load based on media type
        if (widget.mediaType == MediaType.movie) {
          final result = await ProviderLoader.loadMovieFromProvider(
            providerCode: providerCode,
            route: widget.tvRoute ?? StreamRoute.flixHQ,
            movieId: widget.movieMetadata!.movieId!,
            movieName: widget.movieMetadata!.movieName!,
            releaseYear: widget.movieMetadata!.releaseYear?.toString(),
            consumetUrl: appDep.consumetUrl,
            newFlixHQUrl: appDep.newFlixHQUrl,
            flixApiUrl: appDep.flixApiUrl,
            newFlixhqServer: appDep.newFlixhqServer,
            streamingServerFlixHQ: appDep.streamingServerFlixHQ,
            gokuServer: appDep.gokuServer,
            sflixServer: appDep.sflixServer,
            himoviesServer: appDep.himoviesServer,
            animekaiServer: appDep.animekaiServer,
            hianimeServer: appDep.hianimeServer,
          );

          if (!result.success ||
              result.videoLinks == null ||
              result.videoLinks!.isEmpty) {
            throw Exception(result.errorMessage ?? 'Failed to load video');
          }

          // Convert to ProviderVideoSource
          Map<String, String> providerVideos =
              VideoUtils.convertVideoLinksToMap(result.videoLinks!);
          List<BetterPlayerSubtitlesSource> providerSubs = [];

          if (result.subtitleLinks != null) {
            for (var subLink in result.subtitleLinks!) {
              providerSubs.add(
                BetterPlayerSubtitlesSource(
                  type: BetterPlayerSubtitlesSourceType.network,
                  urls: [subLink.url ?? ''],
                  name: subLink.language ?? 'Unknown',
                ),
              );
            }
          }

          providerSource = ProviderVideoSource(
            providerCode: providerCode,
            providerName: widget.availableProviders!
                .firstWhere((p) => p.codeName == providerCode)
                .fullName,
            videoSources: VideoUtils.reverseVideoQualityMap(providerVideos),
            subtitles: providerSubs,
          );
        } else {
          // TV Show
          final result = await ProviderLoader.loadTVFromProvider(
            providerCode: providerCode,
            route: widget.tvRoute ?? StreamRoute.flixHQ,
            tvId: widget.tvMetadata!.tvId!,
            seriesName: widget.tvMetadata!.seriesName!,
            seasonNumber: widget.tvMetadata!.seasonNumber!,
            episodeNumber: widget.tvMetadata!.episodeNumber!,
            consumetUrl: appDep.consumetUrl,
            newFlixHQUrl: appDep.newFlixHQUrl,
            flixApiUrl: appDep.flixApiUrl,
            newFlixhqServer: appDep.newFlixhqServer,
            streamingServerFlixHQ: appDep.streamingServerFlixHQ,
            appLanguage: settings.appLanguage,
            gokuServer: appDep.gokuServer,
            sflixServer: appDep.sflixServer,
            himoviesServer: appDep.himoviesServer,
            animekaiServer: appDep.animekaiServer,
            hianimeServer: appDep.hianimeServer,
          );

          if (!result.success ||
              result.videoLinks == null ||
              result.videoLinks!.isEmpty) {
            throw Exception(result.errorMessage ?? 'Failed to load video');
          }

          // Convert to ProviderVideoSource
          Map<String, String> providerVideos =
              VideoUtils.convertVideoLinksToMap(result.videoLinks!);
          List<BetterPlayerSubtitlesSource> providerSubs = [];

          if (result.subtitleLinks != null) {
            for (var subLink in result.subtitleLinks!) {
              providerSubs.add(
                BetterPlayerSubtitlesSource(
                  type: BetterPlayerSubtitlesSourceType.network,
                  urls: [subLink.url ?? ''],
                  name: subLink.language ?? 'Unknown',
                ),
              );
            }
          }

          providerSource = ProviderVideoSource(
            providerCode: providerCode,
            providerName: widget.availableProviders!
                .firstWhere((p) => p.codeName == providerCode)
                .fullName,
            videoSources: VideoUtils.reverseVideoQualityMap(providerVideos),
            subtitles: providerSubs,
          );
        }

        // Cache the loaded provider
        _loadedProviders[providerCode] = providerSource;
      }

      // Get the appropriate link based on quality setting
      String keyToFind = widget.settings.defaultVideoResolution == 0
          ? 'auto'
          : widget.settings.defaultVideoResolution.toString();
      String? link;

      if (providerSource.videoSources.entries
          .where((entry) => entry.key == keyToFind)
          .isNotEmpty) {
        link = providerSource.videoSources.entries
            .where((entry) => entry.key == keyToFind)
            .map((entry) => entry.value)
            .first;
      } else {
        link = providerSource.videoSources.values.first;
      }

      // Create new data source
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        link,
        resolutions: providerSource.videoSources,
        subtitles: providerSource.subtitles,
        cacheConfiguration: BetterPlayerCacheConfiguration(
          useCache: true,
          preCacheSize: 471859200 * 471859200,
          maxCacheSize: 1073741824 * 1073741824,
          maxCacheFileSize: 471859200 * 471859200,
          key: generateCacheKey(),
        ),
        bufferingConfiguration: betterPlayerBufferingConfiguration,
      );

      // Setup new data source
      await _betterPlayerController.setupDataSource(dataSource);

      // Seek to saved position
      await _betterPlayerController.videoPlayerController
          ?.seekTo(currentPosition);

      // Play if it was playing before
      if (_betterPlayerController.isPlaying() != true) {
        _betterPlayerController.play();
      }

      // Update current provider code
      setState(() {
        _currentProviderCode = providerCode;
      });

      // Also update modal state if provided
      setModalState?.call(() {
        _currentProviderCode = providerCode;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${tr('switched_to')} ${providerSource.providerName}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${tr('switch_provider_error')}: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isSwitchingProvider = false;
        _loadingProviders.remove(providerCode);
      });

      // Also update modal state if provided
      setModalState?.call(() {
        _isSwitchingProvider = false;
        _loadingProviders.remove(providerCode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_betterPlayerController.isVideoInitialized()!) {
          Navigator.pop(
              context,
              widget.mediaType == MediaType.movie
                  ? insertRecentMovieData
                  : insertRecentEpisodeData);
        } else {
          Navigator.pop(context);
        }

        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: BetterPlayer(
                  controller: _betterPlayerController,
                  key: _betterPlayerKey,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (mounted) {
                showModalBottomSheet(
                    builder: (context) {
                      return ExternalPlay(
                        videoSources: widget.sources,
                        subtitleSources: widget.subs,
                      );
                    },
                    context: context);
              }
            },
            child: const Icon(FontAwesomeIcons.arrowUpRightFromSquare)),
      ),
    );
  }
}
