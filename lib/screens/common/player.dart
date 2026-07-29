// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flixquest/models/tv_stream_metadata.dart';

import '../../models/movie_stream_metadata.dart';
import '../../models/provider_video_source.dart';
import '../../video_providers/names.dart';
import '../../video_providers/provider_loader.dart';
import '../../functions/video_utils.dart';
import '/constants/app_constants.dart';
import '/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:better_player_plus/better_player_plus.dart';
import '../../functions/function.dart';
import '../../provider/settings_provider.dart';
import '../../ui_components/app_ui_components.dart';
import 'player/player_data_management.dart';
import 'player/player_external_subtitles.dart';
import 'player/player_episode_selection.dart';
import 'player/player_movie_recommendations.dart';
import 'player/player_sheet_ui.dart';
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
      this.availableProviders, // Provider metadata for lazy loading
      this.currentProviderCode, // Current provider code
      this.initialPlaybackPosition, // For preserving position on provider switch
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
  final List<VideoProvider>?
      availableProviders; // Changed to VideoProvider list
  final String? currentProviderCode;
  final Duration? initialPlaybackPosition;

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
  final Map<String, ProviderVideoSource> _loadedProviders =
      {}; // Cache loaded providers
  final Set<String> _loadingProviders =
      {}; // Track which providers are being loaded
  final Map<String, String> _providerErrors = {};

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
        controlBarColor: Colors.black.withValues(alpha: 0.48),
        muteIcon: PhosphorIcons.speakerSimpleSlash(),
        unMuteIcon: PhosphorIcons.speakerHigh(),
        pauseIcon: PhosphorIcons.pause(),
        pipMenuIcon: PhosphorIcons.appWindow(),
        playIcon: PhosphorIcons.play(),
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
        skipForwardIcon: PhosphorIcons.arrowsClockwise(),
        skipBackIcon: PhosphorIcons.arrowsCounterClockwise(),
        fullscreenEnableIcon: PhosphorIcons.cornersOut(),
        fullscreenDisableIcon: PhosphorIcons.cornersIn(),
        overflowMenuIcon: PhosphorIcons.dotsThreeVertical(),
        overflowMenuIconsColor: widget.colors.first,
        overflowModalTextColor: widget.colors.first,
        overflowModalColor: widget.colors.last,
        subtitlesIcon: PhosphorIcons.closedCaptioning(),
        enableSubtitles: false,
        qualitiesIcon: PhosphorIcons.highDefinition(),
        enableAudioTracks: true,
        controlBarHeight: 56,
        watchingText: tr('watching_text'),
        playerTimeMode: settings.playerTimeDisplay,
        // Add custom overflow menu item for external subtitles
        overflowMenuCustomItems: [
          BetterPlayerOverflowMenuItem(
            PhosphorIcons.closedCaptioning(),
            tr('subtitle'),
            _showSubtitleSwitcher,
          ),
          BetterPlayerOverflowMenuItem(
            PhosphorIcons.closedCaptioning(),
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
          if (widget.availableProviders?.isNotEmpty == true)
            BetterPlayerOverflowMenuItem(
              PhosphorIcons.arrowsLeftRight(),
              tr('switch_provider'),
              _showProviderSwitcher,
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

    final resolutions = widget.sources.length > 1 ? widget.sources : null;
    final videoFormat = _inferVideoFormat(link);
    final headers = _inferHeaders(link);

    BetterPlayerDataSource dataSource =
        BetterPlayerDataSource(BetterPlayerDataSourceType.network, link,
            resolutions: resolutions,
            videoFormat: videoFormat,
            headers: headers,
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
      // If initial playback position provided (from provider switch), seek to it
      if (widget.initialPlaybackPosition != null) {
        _betterPlayerController.videoPlayerController!
            .seekTo(widget.initialPlaybackPosition!);
      } else {
        // Otherwise use the elapsed time from metadata
        _betterPlayerController.videoPlayerController!.seekTo(Duration(
            seconds: widget.mediaType == MediaType.movie
                ? widget.movieMetadata!.elapsed!
                : widget.tvMetadata!.elapsed!));
      }
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

  BetterPlayerVideoFormat? _inferVideoFormat(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(url);
    final path = uri?.path.toLowerCase() ?? url.toLowerCase();
    if (path.endsWith('.m3u8') || path.contains('/playlist/')) {
      return BetterPlayerVideoFormat.hls;
    }

    if (path.endsWith('.mpd')) {
      return BetterPlayerVideoFormat.dash;
    }

    return null;
  }

  Map<String, String>? _inferHeaders(String? url) {
    final host = Uri.tryParse(url ?? '')?.host.toLowerCase();
    if (host == null || !host.endsWith('vixsrc.to')) {
      return null;
    }

    return const {
      'accept': '*/*',
      'origin': 'https://vixsrc.to',
      'referer': 'https://vixsrc.to/',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
    };
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
          onSaveProgress: _handleContentSwitch,
          closePlayer: _closePlayer,
        );
      } else {
        // No next episode, show episode list
        _episodeSelection.showEpisodeSelectionBottomSheet(
          context: context,
          colors: widget.colors,
          tvMetadata: widget.tvMetadata!,
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

  void _showProviderSwitcher() {
    final providers = widget.availableProviders;
    if (providers == null || providers.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return FractionallySizedBox(
            heightFactor: .72,
            child: AppResponsiveContent(
              maxWidth: 680,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          PhosphorIcons.hardDrives(),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('select_provider'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${providers.length} ${tr('video_source')}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: Icon(PhosphorIcons.x()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: providers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final provider = providers[index];
                        final selected =
                            provider.codeName == _currentProviderCode;
                        final loading =
                            _loadingProviders.contains(provider.codeName);
                        final error = _providerErrors[provider.codeName];
                        return AppSelectionTile(
                          title: provider.fullName,
                          selected: selected,
                          subtitle: loading
                              ? tr('loading_video_sources')
                              : error ??
                                  (selected
                                      ? tr('currently_playing')
                                      : tr('video_source')),
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: loading
                                ? const Padding(
                                    padding: EdgeInsets.all(11),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    selected
                                        ? PhosphorIcons.playCircle(
                                            PhosphorIconsStyle.fill,
                                          )
                                        : PhosphorIcons.playCircle(),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                          ),
                          trailing: error == null
                              ? null
                              : Icon(
                                  PhosphorIcons.warningCircle(),
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          onTap: selected || loading || _isSwitchingProvider
                              ? () {}
                              : () => _switchToProvider(
                                    provider.codeName,
                                    sheetContext,
                                    setSheetState,
                                  ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _switchToProvider(
    String providerCode,
    BuildContext sheetContext,
    StateSetter setSheetState,
  ) async {
    if (_isSwitchingProvider || providerCode == _currentProviderCode) return;

    setState(() {
      _isSwitchingProvider = true;
      _loadingProviders.add(providerCode);
      _providerErrors.remove(providerCode);
    });
    setSheetState(() {});

    final position =
        _betterPlayerController.videoPlayerController?.value.position ??
            Duration.zero;
    try {
      await _betterPlayerController.pause();
      var source = _loadedProviders[providerCode];
      if (source == null) {
        final result = widget.mediaType == MediaType.movie
            ? await ProviderLoader.loadMovieFromProvider(
                providerCode: providerCode,
                movieId: widget.movieMetadata!.movieId!,
              )
            : await ProviderLoader.loadTVFromProvider(
                providerCode: providerCode,
                tvId: widget.tvMetadata!.tvId!,
                seasonNumber: widget.tvMetadata!.seasonNumber!,
                episodeNumber: widget.tvMetadata!.episodeNumber!,
              );
        if (!result.success || result.videoLinks?.isEmpty != false) {
          throw Exception(result.errorMessage ?? tr('movie_vid_404'));
        }

        final subtitles = <BetterPlayerSubtitlesSource>[
          for (final subtitle in result.subtitleLinks ?? const [])
            BetterPlayerSubtitlesSource(
              type: BetterPlayerSubtitlesSourceType.network,
              urls: [subtitle.url ?? ''],
              name: subtitle.language ?? tr('not_available'),
            ),
        ];
        final providerName = widget.availableProviders!
            .firstWhere((provider) => provider.codeName == providerCode)
            .fullName;
        source = ProviderVideoSource(
          providerCode: providerCode,
          providerName: providerName,
          videoSources: VideoUtils.reverseVideoQualityMap(
            VideoUtils.convertVideoLinksToMap(result.videoLinks!),
          ),
          subtitles: subtitles,
        );
        _loadedProviders[providerCode] = source;
      }

      if (!mounted) return;
      if (sheetContext.mounted) Navigator.pop(sheetContext);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerOne(
            sources: source!.videoSources,
            subs: source.subtitles,
            colors: widget.colors,
            settings: widget.settings,
            movieMetadata: widget.movieMetadata,
            tvMetadata: widget.tvMetadata,
            mediaType: widget.mediaType,
            subtitleStyle: widget.subtitleStyle,
            availableProviders: widget.availableProviders,
            currentProviderCode: providerCode,
            initialPlaybackPosition: position,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _providerErrors[providerCode] = error.toString());
      if (sheetContext.mounted) setSheetState(() {});
    } finally {
      if (mounted) {
        setState(() {
          _isSwitchingProvider = false;
          _loadingProviders.remove(providerCode);
        });
      }
      if (sheetContext.mounted) setSheetState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exitPlayer();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: SizedBox(
                child: BetterPlayer(
                  controller: _betterPlayerController,
                  key: _betterPlayerKey,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.small(
          tooltip: tr('video_source'),
          onPressed: _showExternalPlayerSheet,
          child: Icon(PhosphorIcons.arrowSquareOut()),
        ),
      ),
    );
  }

  void _exitPlayer() {
    Navigator.pop(
      context,
      _betterPlayerController.isVideoInitialized() == true
          ? widget.mediaType == MediaType.movie
              ? insertRecentMovieData
              : insertRecentEpisodeData
          : null,
    );
  }

  void _showExternalPlayerSheet() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => AppResponsiveContent(
        maxWidth: 680,
        padding: EdgeInsets.zero,
        child: ExternalPlay(
          videoSources: widget.sources,
          subtitleSources: widget.subs,
        ),
      ),
    );
  }

  void _showSubtitleSwitcher() {
    final subtitles = List<BetterPlayerSubtitlesSource>.of(
      _betterPlayerController.betterPlayerSubtitlesSourceList,
    );
    if (!subtitles.any(
      (source) => source.type == BetterPlayerSubtitlesSourceType.none,
    )) {
      subtitles.add(
        BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.none,
        ),
      );
    }
    final selected = _betterPlayerController.betterPlayerSubtitlesSource;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: .72,
        child: PlayerSheetScaffold(
          icon: PhosphorIcons.closedCaptioning(),
          title: tr('subtitle'),
          subtitle: tr('choose_subtitle_language'),
          actions: [
            IconButton(
              onPressed: () => Navigator.pop(sheetContext),
              icon: Icon(PhosphorIcons.x()),
            ),
          ],
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            itemCount: subtitles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final source = subtitles[index];
              final isOff = source.type == BetterPlayerSubtitlesSourceType.none;
              final isSelected = source == selected ||
                  (isOff &&
                      selected?.type == BetterPlayerSubtitlesSourceType.none);
              return PlayerChoiceCard(
                title: isOff
                    ? _betterPlayerController.translations.generalNone
                    : source.name ??
                        _betterPlayerController.translations.generalDefault,
                subtitle: isOff ? null : tr('subtitle'),
                selected: isSelected,
                thumbnail: PlayerThumbnail(
                  width: 48,
                  height: 48,
                  child: Icon(PhosphorIcons.closedCaptioning()),
                ),
                onTap: () async {
                  await _betterPlayerController.setupSubtitleSource(source);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
