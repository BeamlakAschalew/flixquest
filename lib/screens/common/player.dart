// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flixquest/models/tv_stream_metadata.dart';
import 'package:flixquest/models/offline_download.dart';

import '../../models/movie_stream_metadata.dart';
import '../../models/provider_video_source.dart';
import '../../video_providers/names.dart';
import '../../video_providers/provider_loader.dart';
import '../../functions/video_utils.dart';
import '../../functions/player_subtitle_configuration.dart';
import '/constants/app_constants.dart';
import '/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:better_player_plus/better_player_plus.dart';
import '../../functions/function.dart';
import '../../provider/settings_provider.dart';
import '../../provider/offline_download_provider.dart';
import '../../provider/app_dependency_provider.dart';
import '../../constants/api_constants.dart';
import '../../ui_components/app_ui_components.dart';
import '../../services/stream_intro_service.dart';
import '../movie/movie_video_loader.dart';
import '../tv/tv_video_loader.dart';
import 'player/player_data_management.dart';
import 'player/player_external_subtitles.dart';
import 'player/player_local_subtitles.dart';
import 'player/player_episode_selection.dart';
import 'player/player_movie_recommendations.dart';
import 'player/player_sheet_ui.dart';
import 'player/player_widgets.dart';
import 'download_selection_sheets.dart';

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
      this.scraperApiUrl = '',
      this.videoFormats,
      this.videoHeaders = const {},
      this.prefetchedProviderResults = const {},
      this.useTvControls = false,
      this.onTvPlayerExit,
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
  final String scraperApiUrl;
  final Map<String, BetterPlayerVideoFormat?>? videoFormats;
  final Map<String, Map<String, String>> videoHeaders;
  final Map<String, Future<ProviderLoaderResult>> prefetchedProviderResults;
  final bool useTvControls;
  final VoidCallback? onTvPlayerExit;

  @override
  State<PlayerOne> createState() => _PlayerOneState();
}

class _PlayerOneState extends State<PlayerOne> with WidgetsBindingObserver {
  static const int _tvMaxBufferDurationMs = 120000;
  static const int _mobileBackBufferDurationMs = 120000;
  static const int _tvBackBufferDurationMs = 30000;
  static const int _bufferForPlaybackMs = 6000;
  static const int _bufferForPlaybackAfterRebufferMs = 12000;

  late BetterPlayerController _betterPlayerController;
  final StreamIntroService _introService = StreamIntroService();
  final BetterPlayerTvControlsController _tvControlsController =
      BetterPlayerTvControlsController();
  late BetterPlayerControlsConfiguration betterPlayerControlsConfiguration;
  late BetterPlayerBufferingConfiguration betterPlayerBufferingConfiguration;
  final PlayerDataManagement _dataManagement = PlayerDataManagement();
  final PlayerExternalSubtitles _externalSubtitles = PlayerExternalSubtitles();
  final PlayerLocalSubtitles _localSubtitles = PlayerLocalSubtitles();
  late final PlayerEpisodeSelection _episodeSelection;
  final PlayerMovieRecommendations _movieRecommendations =
      PlayerMovieRecommendations();
  final PlayerNextEpisodeWidget _nextEpisodeWidget = PlayerNextEpisodeWidget();
  int duration = 0;

  final GlobalKey _betterPlayerKey = GlobalKey();

  int totalMinutesWatched = 0;
  bool isVideoPaused = false;

  int playbackDurationInSeconds = 0;
  Timer? _durationTimer;
  // ignore: unused_field
  Timer? _resetTimer;

  // For next episode button
  bool _showNextEpisodeButton = false;
  bool _nextEpisodeButtonDismissed = false;
  bool _preRollActive = false;
  Timer? _progressCheckTimer;
  OverlayEntry? _nextEpisodeOverlay;
  Timer? _tvNextEpisodeTimer;
  EpisodeMetadata? _tvNextEpisode;
  int? _tvNextEpisodeCountdown;
  _TvPlayerMenuData? _tvMenu;

  late SettingsProvider settings;

  // Provider switching
  bool _isSwitchingProvider = false;
  late String? _currentProviderCode; // Track current provider
  final Map<String, ProviderVideoSource> _loadedProviders =
      {}; // Cache loaded providers
  late final Map<String, Future<ProviderLoaderResult>> _providerResults;
  late Map<String, String> _activeSources;
  late List<BetterPlayerSubtitlesSource> _activeSubtitles;
  late Map<String, BetterPlayerVideoFormat?>? _activeVideoFormats;
  late Map<String, Map<String, String>> _activeVideoHeaders;
  final Set<String> _loadingProviders =
      {}; // Track which providers are being loaded
  final Map<String, String> _providerErrors = {};
  late final DateTime _analyticsSessionStartedAt;
  late final String _analyticsSessionId;
  DateTime? _analyticsPlayingStartedAt;
  DateTime? _analyticsBufferingStartedAt;
  int _analyticsWatchedMs = 0;
  int _analyticsBufferingMs = 0;
  int _analyticsBufferCount = 0;
  int _analyticsProviderSwitchCount = 0;
  int _analyticsInitializationCount = 0;
  bool _analyticsWasPlayingBeforeBuffering = false;
  String? _lastAnalyticsError;
  DateTime? _lastAnalyticsErrorAt;
  late final AppDependencyProvider _appDependencies;
  int? _occasionalEffectsSuppressionId;

  @override
  void initState() {
    settings = Provider.of<SettingsProvider>(context, listen: false);
    _currentProviderCode = widget.currentProviderCode; // Initialize from widget
    _providerResults = Map.of(widget.prefetchedProviderResults);
    _activeSources = Map.of(widget.sources);
    _activeSubtitles = List.of(widget.subs);
    _activeVideoFormats =
        widget.videoFormats == null ? null : Map.of(widget.videoFormats!);
    _activeVideoHeaders = Map.of(widget.videoHeaders);
    super.initState();
    _appDependencies =
        Provider.of<AppDependencyProvider>(context, listen: false);
    _occasionalEffectsSuppressionId =
        _appDependencies.suppressOccasionalEffects();
    _analyticsSessionStartedAt = DateTime.now();
    _analyticsSessionId =
        '${_analyticsSessionStartedAt.microsecondsSinceEpoch}-${identityHashCode(this)}';

    // Initialize episode selection with current season
    _episodeSelection = PlayerEpisodeSelection(widget.tvMetadata?.seasonNumber);

    WidgetsBinding.instance.addObserver(this);
    final configuredMaxBufferMs = widget.settings.defaultMaxBufferDuration;
    final maxBufferMs =
        widget.useTvControls && configuredMaxBufferMs > _tvMaxBufferDurationMs
            ? _tvMaxBufferDurationMs
            : configuredMaxBufferMs;
    betterPlayerBufferingConfiguration = BetterPlayerBufferingConfiguration(
      maxBufferMs: maxBufferMs,
      minBufferMs: 15000,
      bufferForPlaybackMs: _bufferForPlaybackMs,
      bufferForPlaybackAfterRebufferMs: _bufferForPlaybackAfterRebufferMs,
      backBufferDurationMs: widget.useTvControls
          ? _tvBackBufferDurationMs
          : _mobileBackBufferDurationMs,
      retainBackBufferFromKeyframe: !widget.useTvControls,
    );
    betterPlayerControlsConfiguration = BetterPlayerControlsConfiguration(
        // Gesture controls configuration
        gestureConfiguration: BetterPlayerGestureConfiguration(
          enableVolumeSwipe: !widget.useTvControls,
          enableBrightnessSwipe: !widget.useTvControls,
          enableSeekSwipe: !widget.useTvControls,
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
          if (widget.useTvControls) {
            _showTvEpisodeMenu();
          } else {
            _episodeSelection.showEpisodeSelectionBottomSheet(
              context: context,
              colors: widget.colors,
              tvMetadata: widget.tvMetadata!,
              onSaveProgress: _handleContentSwitch,
              closePlayer: () => Navigator.pop(context),
            );
          }
        },
        enableMovieRecommendations: widget.mediaType == MediaType.movie &&
            widget.movieMetadata?.recommendations != null &&
            widget.movieMetadata!.recommendations!.isNotEmpty,
        onMovieRecommendationsTap: () {
          if (widget.useTvControls) {
            _showTvMovieRecommendationsMenu();
          } else {
            _movieRecommendations.showMovieRecommendationsBottomSheet(
              context: context,
              colors: widget.colors,
              movieMetadata: widget.movieMetadata!,
              onSaveProgress: _handleContentSwitch,
              closePlayer: () => Navigator.pop(context),
            );
          }
        },
        enableNextEpisodeButton: widget.mediaType == MediaType.tvShow &&
            widget.settings.enableNextEpisodeButton,
        enableCast: !widget.useTvControls,
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
        showControlsOnInitialize: widget.useTvControls,
        controlsHideTime: widget.useTvControls
            ? const Duration(seconds: 5)
            : const Duration(milliseconds: 300),
        playerTheme: widget.useTvControls ? BetterPlayerTheme.custom : null,
        customControlsBuilder: widget.useTvControls
            ? (controller, onVisibilityChanged) => BetterPlayerTvControls(
                  controller: controller,
                  controlsController: _tvControlsController,
                  onControlsVisibilityChanged: onVisibilityChanged,
                  accentColor: widget.colors.first,
                  onExit: _exitPlayer,
                )
            : null,
        loadingColor: widget.colors.first,
        loadingWidget: SizedBox(
          width: 60,
          height: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 3,
              color: widget.colors.first,
              backgroundColor: widget.colors.first.withValues(alpha: .24),
            ),
          ),
        ),
        iconsColor: widget.colors.first,
        backwardSkipTimeInMilliseconds:
            Duration(seconds: widget.settings.defaultSeekDuration)
                .inMilliseconds,
        forwardSkipTimeInMilliseconds:
            Duration(seconds: widget.settings.defaultSeekDuration)
                .inMilliseconds,
        progressBarPlayedColor: widget.colors.first,
        progressBarBufferedColor: Colors.black45,
        skipForwardIcon: PhosphorIcons.fastForward(),
        skipBackIcon: PhosphorIcons.rewind(),
        fullscreenEnableIcon: PhosphorIcons.cornersOut(),
        fullscreenDisableIcon: PhosphorIcons.cornersIn(),
        overflowMenuIcon: PhosphorIcons.dotsThreeVertical(),
        overflowMenuIconsColor: widget.colors.first,
        overflowModalTextColor: widget.colors.first,
        overflowModalColor: widget.colors.last,
        subtitlesIcon: PhosphorIcons.closedCaptioning(),
        enableSubtitles: widget.useTvControls,
        qualitiesIcon: PhosphorIcons.highDefinition(),
        enableAudioTracks: true,
        controlBarHeight: 56,
        watchingText: tr('watching_text'),
        playerTimeMode: settings.playerTimeDisplay,
        // Add custom overflow menu item for external subtitles
        overflowMenuCustomItems: widget.useTvControls
            ? [
                BetterPlayerOverflowMenuItem(
                  PhosphorIcons.fileArrowUp(),
                  tr('upload_subtitles'),
                  () {
                    _localSubtitles.showLocalSubtitlesUpload(
                      context: context,
                      colors: widget.colors,
                      betterPlayerController: _betterPlayerController,
                    );
                  },
                ),
                if (widget.availableProviders?.isNotEmpty == true)
                  BetterPlayerOverflowMenuItem(
                    PhosphorIcons.arrowsLeftRight(),
                    tr('switch_provider'),
                    _showTvProviderMenu,
                  ),
              ]
            : [
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
                BetterPlayerOverflowMenuItem(
                  PhosphorIcons.fileArrowUp(),
                  tr('upload_subtitles'),
                  () {
                    _localSubtitles.showLocalSubtitlesUpload(
                      context: context,
                      colors: widget.colors,
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
                BetterPlayerOverflowMenuItem(
                  PhosphorIcons.downloadSimple(),
                  'Download',
                  _downloadFromCurrentProvider,
                ),
              ]);
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
            autoDetectFullscreenDeviceOrientation: !widget.useTvControls,
            fullScreenByDefault:
                widget.useTvControls ? false : widget.settings.defaultViewMode,
            autoPlay: true,
            fit: BoxFit.contain,
            autoDispose: true,
            controlsConfiguration: betterPlayerControlsConfiguration,
            showPlaceholderUntilPlay: true,
            allowedScreenSleep: false,
            autoDetectFullscreenAspectRatio: !widget.useTvControls,
            errorBuilder: (context, errorMessage) =>
                _buildCustomPlayerErrorWidget(context, errorMessage),
            subtitlesConfiguration: buildPlayerSubtitleConfiguration(
              backgroundColor: widget.settings.subtitleBackgroundColor,
              foregroundColor: widget.settings.subtitleForegroundColor,
              fontSize: widget.settings.subtitleFontSize,
              textStyle:
                  widget.subtitleStyle ?? widget.settings.subtitleTextStyle,
            ));

    final dataSource = _buildDataSource(
      sources: _activeSources,
      subtitles: _activeSubtitles,
      videoFormats: _activeVideoFormats,
      videoHeaders: _activeVideoHeaders,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);
    _betterPlayerController.addEventsListener(_onAnalyticsPlayerEvent);
    // Attach listeners before setup so native initialization and pre-roll
    // transition events cannot race the first platform callback.
    unawaited(_setupInitialDataSource(dataSource));

    // Preserve the original TV-only next-episode progress check. Movies and
    // completion handling continue to use Better Player's native events.
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

  Future<void> _setupInitialDataSource(
      BetterPlayerDataSource dataSource) async {
    final initialPosition = widget.initialPlaybackPosition ??
        Duration(
          seconds: widget.mediaType == MediaType.movie
              ? widget.movieMetadata!.elapsed!
              : widget.tvMetadata!.elapsed!,
        );
    try {
      StreamIntroConfig intro = const StreamIntroConfig.disabled();
      try {
        intro = await _introService.fetch(widget.scraperApiUrl);
      } catch (error) {
        debugPrint('[Player] Branded intro unavailable: $error');
      }

      if (intro.enabled && intro.url != null) {
        _preRollActive = true;
        await _betterPlayerController.setupDataSourceWithPreRoll(
          preRollDataSource: _buildIntroDataSource(intro.url!),
          betterPlayerDataSource: dataSource,
          contentStartPosition: initialPosition,
        );
      } else {
        _preRollActive = false;
        await _betterPlayerController.setupDataSource(dataSource);
        await _betterPlayerController.seekTo(initialPosition);
      }
      if (!mounted) return;
      _applyPreferredAdaptiveQuality();
      duration = _betterPlayerController
              .videoPlayerController?.value.duration?.inSeconds ??
          0;
    } catch (error) {
      _preRollActive = false;
      debugPrint('[Player] Initial stream setup failed: $error');
    }
  }

  BetterPlayerDataSource _buildIntroDataSource(Uri url) {
    return BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url.toString(),
      cacheConfiguration: const BetterPlayerCacheConfiguration(
        useCache: true,
        maxCacheSize: 50 * 1024 * 1024,
        maxCacheFileSize: 20 * 1024 * 1024,
      ),
    );
  }

  String get _analyticsMediaType =>
      widget.mediaType == MediaType.movie ? 'movie' : 'tv';

  dynamic get _analyticsContentId => widget.mediaType == MediaType.movie
      ? widget.movieMetadata?.movieId
      : widget.tvMetadata?.tvId;

  String? get _analyticsContentTitle => widget.mediaType == MediaType.movie
      ? widget.movieMetadata?.movieName
      : widget.tvMetadata?.seriesName;

  String get _analyticsSurface => widget.useTvControls ? 'tv' : 'standard';

  int get _analyticsElapsedMs =>
      DateTime.now().difference(_analyticsSessionStartedAt).inMilliseconds;

  void _onAnalyticsPlayerEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        duration = _betterPlayerController
                .videoPlayerController?.value.duration?.inSeconds ??
            duration;
        _analyticsInitializationCount++;
        _trackPlaybackEvent(
          _analyticsInitializationCount == 1 ? 'initialized' : 'reinitialized',
          startupMs:
              _analyticsInitializationCount == 1 ? _analyticsElapsedMs : null,
        );
        break;
      case BetterPlayerEventType.preRollEnded:
        _preRollActive = false;
        duration = _betterPlayerController
                .videoPlayerController?.value.duration?.inSeconds ??
            duration;
        _trackPlaybackEvent('pre_roll_ended');
        break;
      case BetterPlayerEventType.play:
        _analyticsPlayingStartedAt ??= DateTime.now();
        _trackPlaybackEvent('play');
        break;
      case BetterPlayerEventType.pause:
        _analyticsWasPlayingBeforeBuffering = false;
        _stopAnalyticsWatchClock();
        _trackPlaybackEvent('pause');
        break;
      case BetterPlayerEventType.bufferingStart:
        _analyticsWasPlayingBeforeBuffering =
            _analyticsPlayingStartedAt != null;
        _stopAnalyticsWatchClock();
        _analyticsBufferingStartedAt ??= DateTime.now();
        _analyticsBufferCount++;
        _trackPlaybackEvent('buffering_started');
        break;
      case BetterPlayerEventType.bufferingEnd:
        final startedAt = _analyticsBufferingStartedAt;
        final bufferingMs = startedAt == null
            ? 0
            : DateTime.now().difference(startedAt).inMilliseconds;
        _analyticsBufferingMs += bufferingMs;
        _analyticsBufferingStartedAt = null;
        if (_analyticsWasPlayingBeforeBuffering) {
          _analyticsPlayingStartedAt = DateTime.now();
        }
        _analyticsWasPlayingBeforeBuffering = false;
        _trackPlaybackEvent('buffering_ended', bufferingMs: bufferingMs);
        break;
      case BetterPlayerEventType.exception:
        final error = event.parameters?['exception']?.toString() ??
            'Unknown player error';
        final now = DateTime.now();
        if (error != _lastAnalyticsError ||
            _lastAnalyticsErrorAt == null ||
            now.difference(_lastAnalyticsErrorAt!).inSeconds >= 10) {
          _lastAnalyticsError = error;
          _lastAnalyticsErrorAt = now;
          _trackPlaybackEvent('error', error: error);
        }
        break;
      case BetterPlayerEventType.finished:
        _stopAnalyticsWatchClock();
        _trackPlaybackEvent('finished');
        _handleVideoFinished();
        break;
      case BetterPlayerEventType.changedResolution:
        final name = event.parameters?['name']?.toString();
        settings.analytics.trackQualityChanged(quality: name ?? 'automatic');
        _trackPlaybackEvent('quality_changed', value: name ?? 'automatic');
        break;
      case BetterPlayerEventType.changedTrack:
        final height = event.parameters?['height'];
        final quality = height == null ? 'automatic' : '${height}p';
        settings.analytics.trackQualityChanged(quality: quality);
        _trackPlaybackEvent('quality_changed', value: quality);
        break;
      case BetterPlayerEventType.changedSubtitles:
        final source = _betterPlayerController.betterPlayerSubtitlesSource;
        final language = source?.type == BetterPlayerSubtitlesSourceType.none
            ? 'off'
            : source?.name ?? 'default';
        settings.analytics.trackSubtitleLanguageChanged(language: language);
        _trackPlaybackEvent('subtitle_changed', value: language);
        break;
      default:
        break;
    }
  }

  void _stopAnalyticsWatchClock() {
    final startedAt = _analyticsPlayingStartedAt;
    if (startedAt == null) return;
    _analyticsWatchedMs += DateTime.now().difference(startedAt).inMilliseconds;
    _analyticsPlayingStartedAt = null;
  }

  void _trackPlaybackEvent(
    String event, {
    int? startupMs,
    int? bufferingMs,
    String? value,
    String? error,
  }) {
    settings.analytics.trackPlaybackEvent(
      mediaType: _analyticsMediaType,
      contentId: _analyticsContentId,
      contentTitle: _analyticsContentTitle,
      surface: _analyticsSurface,
      sessionId: _analyticsSessionId,
      event: event,
      sessionElapsedMs: _analyticsElapsedMs,
      provider: _currentProviderCode,
      startupMs: startupMs,
      bufferingMs: bufferingMs,
      bufferCount: _analyticsBufferCount,
      value: value,
      error: error,
    );
  }

  void _startProgressCheck() {
    _progressCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_betterPlayerController.isVideoInitialized() == true &&
          _betterPlayerController.videoPlayerController != null) {
        final position =
            _betterPlayerController.videoPlayerController!.value.position;
        final duration =
            _betterPlayerController.videoPlayerController!.value.duration;
        final isFullScreen = _betterPlayerController.isFullScreen;

        if (duration != null && duration.inSeconds > 0) {
          final progress = position.inSeconds / duration.inSeconds;

          // Native Android/iOS players emit preRollEnded only after advancing
          // to the main content item. When no pre-roll is configured this flag
          // is false, leaving the original TV progress behavior untouched.
          if (_preRollActive) return;

          // Surface the next episode near the end. TV playback already owns the
          // full screen route, so Better Player's internal fullscreen flag is
          // intentionally false there.
          if (progress >= 0.95 &&
              !_showNextEpisodeButton &&
              !_nextEpisodeButtonDismissed &&
              _hasNextEpisode() &&
              (widget.useTvControls || isFullScreen) &&
              betterPlayerControlsConfiguration.enableNextEpisodeButton) {
            _showNextEpisodeButton = true;
            if (widget.useTvControls) {
              _showTvNextEpisodePrompt(startCountdown: false);
            } else {
              _showNextEpisodeOverlay();
            }
          } else if ((progress < 0.95 ||
                  (!widget.useTvControls && !isFullScreen)) &&
              _showNextEpisodeButton) {
            _showNextEpisodeButton = false;
            _nextEpisodeButtonDismissed = false;
            if (widget.useTvControls) {
              _clearTvNextEpisodePrompt(showControls: false);
            } else {
              _hideNextEpisodeOverlay();
            }
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

    Overlay.of(context, rootOverlay: true).insert(_nextEpisodeOverlay!);
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

  BetterPlayerDataSource _buildDataSource({
    required Map<String, String> sources,
    required List<BetterPlayerSubtitlesSource> subtitles,
    required Map<String, BetterPlayerVideoFormat?>? videoFormats,
    required Map<String, Map<String, String>> videoHeaders,
  }) {
    final selectedSource = VideoUtils.preferredVideoSource(
      sources,
      widget.settings.defaultVideoResolution,
    )!;
    final link = selectedSource.value;
    final suppliedHeaders = videoHeaders[selectedSource.key];
    final resolvedHeaders = suppliedHeaders?.isNotEmpty == true
        ? suppliedHeaders!
        : VideoUtils.inferVideoHeaders(link) ?? const <String, String>{};

    return BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      link,
      resolutions: sources.length > 1 ? sources : null,
      selectedResolution: selectedSource.key,
      videoFormat: videoFormats?[selectedSource.key] ?? _inferVideoFormat(link),
      headers: resolvedHeaders,
      castConfiguration: widget.useTvControls
          ? null
          : BetterPlayerCastConfiguration(
              title: widget.mediaType == MediaType.movie
                  ? widget.movieMetadata?.movieName
                  : widget.tvMetadata?.seriesName,
              subtitle: widget.mediaType == MediaType.movie
                  ? widget.movieMetadata?.releaseYear?.toString()
                  : 'S${widget.tvMetadata?.seasonNumber ?? 0} '
                      'E${widget.tvMetadata?.episodeNumber ?? 0} · '
                      '${widget.tvMetadata?.episodeName ?? ''}',
              imageUrl: _castArtworkUrl(),
              contentType: _castContentType(
                videoFormats?[selectedSource.key] ?? _inferVideoFormat(link),
              ),
              requestHeaders: resolvedHeaders,
              customData: <String, Object?>{
                'mediaType':
                    widget.mediaType == MediaType.movie ? 'movie' : 'tv',
                'mediaId': widget.mediaType == MediaType.movie
                    ? widget.movieMetadata?.movieId
                    : widget.tvMetadata?.tvId,
                if (widget.tvMetadata != null)
                  'seasonNumber': widget.tvMetadata!.seasonNumber,
                if (widget.tvMetadata != null)
                  'episodeNumber': widget.tvMetadata!.episodeNumber,
              },
            ),
      subtitles: [
        ...subtitles,
        ..._localSubtitles.appliedSubtitles,
        ..._externalSubtitles.appliedSubtitles,
      ],
      // Streaming already has a bounded in-memory buffer. A persistent media
      // cache can fill the limited internal storage available on Android TVs.
      cacheConfiguration: const BetterPlayerCacheConfiguration(useCache: false),
      bufferingConfiguration: betterPlayerBufferingConfiguration,
    );
  }

  String? _castArtworkUrl() {
    final path = widget.mediaType == MediaType.movie
        ? widget.movieMetadata?.backdropPath ?? widget.movieMetadata?.posterPath
        : widget.tvMetadata?.backdropPath ?? widget.tvMetadata?.posterPath;
    return path == null || path.isEmpty
        ? null
        : '${TMDB_BASE_IMAGE_URL}w780$path';
  }

  String _castContentType(BetterPlayerVideoFormat? format) => switch (format) {
        BetterPlayerVideoFormat.hls => 'application/x-mpegURL',
        BetterPlayerVideoFormat.dash => 'application/dash+xml',
        _ => 'video/mp4',
      };

  void _applyPreferredAdaptiveQuality() {
    final preferredHeight = widget.settings.defaultVideoResolution;
    if (preferredHeight == 0) return;

    final tracks = _betterPlayerController.betterPlayerAsmsTracks
        .where((track) => (track.height ?? 0) > 0)
        .toList();
    if (tracks.isEmpty) return;

    final exact = tracks.where((track) => track.height == preferredHeight);
    if (exact.isNotEmpty) {
      _betterPlayerController.setTrack(exact.first);
      return;
    }

    final atOrBelow = tracks.where(
      (track) => track.height! <= preferredHeight,
    );
    if (atOrBelow.isNotEmpty) {
      _betterPlayerController.setTrack(
        atOrBelow.reduce(
          (best, track) => track.height! > best.height! ? track : best,
        ),
      );
      return;
    }
    _betterPlayerController.setTrack(
      tracks.reduce(
        (best, track) => track.height! < best.height! ? track : best,
      ),
    );
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
    final suppressionId = _occasionalEffectsSuppressionId;
    if (suppressionId != null) {
      _appDependencies.releaseOccasionalEffectsSuppression(suppressionId);
      _occasionalEffectsSuppressionId = null;
    }
    // _resetTimer?.cancel();
    _progressCheckTimer?.cancel();
    _tvNextEpisodeTimer?.cancel();
    _hideNextEpisodeOverlay();

    // Restore original brightness before disposing
    BetterPlayerBrightnessManager.restoreOriginalBrightness();

    _betterPlayerController.removeEventsListener(_onAnalyticsPlayerEvent);
    _stopAnalyticsWatchClock();
    final bufferingStartedAt = _analyticsBufferingStartedAt;
    if (bufferingStartedAt != null) {
      _analyticsBufferingMs +=
          DateTime.now().difference(bufferingStartedAt).inMilliseconds;
    }
    settings.analytics.trackPlaybackSessionEnded(
      mediaType: _analyticsMediaType,
      contentId: _analyticsContentId,
      contentTitle: _analyticsContentTitle,
      surface: _analyticsSurface,
      sessionId: _analyticsSessionId,
      durationMs: _analyticsElapsedMs,
      watchedMs: _analyticsWatchedMs,
      bufferingMs: _analyticsBufferingMs,
      bufferCount: _analyticsBufferCount,
      providerSwitchCount: _analyticsProviderSwitchCount,
      provider: _currentProviderCode,
    );

    // Dispose the BetterPlayer controller to clean up resources
    _betterPlayerController.dispose();
    _introService.close();

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

        if (widget.useTvControls) {
          if (_nextEpisodeButtonDismissed) {
            _showTvEpisodeMenu();
          } else {
            _showTvNextEpisodePrompt(startCountdown: true);
          }
        } else {
          // Show countdown dialog for next episode
          _nextEpisodeWidget.showNextEpisodeCountdown(
            context: context,
            nextEpisode: nextEpisode,
            colors: widget.colors,
            tvMetadata: widget.tvMetadata!,
            onSaveProgress: _handleContentSwitch,
            closePlayer: _closePlayer,
          );
        }
      } else {
        // No next episode, show episode list
        if (widget.useTvControls) {
          _showTvEpisodeMenu();
        } else {
          _episodeSelection.showEpisodeSelectionBottomSheet(
            context: context,
            colors: widget.colors,
            tvMetadata: widget.tvMetadata!,
            onSaveProgress: _handleContentSwitch,
            closePlayer: _closePlayer,
          );
        }
      }
    } else if (widget.mediaType == MediaType.movie) {
      debugPrint(
          'Movie finished. Recommendations: ${widget.movieMetadata?.recommendations?.length ?? 0}');
      if (widget.movieMetadata?.recommendations != null &&
          widget.movieMetadata!.recommendations!.isNotEmpty) {
        if (widget.useTvControls) {
          _showTvMovieRecommendationsMenu();
        } else {
          // Show recommended movie countdown
          _movieRecommendations.showRecommendedMovieCountdown(
            context: context,
            colors: widget.colors,
            movieMetadata: widget.movieMetadata!,
            onSaveProgress: _handleContentSwitch,
            closePlayer: _closePlayer,
          );
        }
      } else {
        debugPrint('No recommendations available for this movie');
      }
    }
  }

  void _openTvMenu(String title, List<BetterPlayerTvMenuItem> items) {
    if (!mounted || !widget.useTvControls || items.isEmpty) return;
    _tvNextEpisodeTimer?.cancel();
    setState(() {
      _tvNextEpisode = null;
      _tvNextEpisodeCountdown = null;
      _tvMenu = _TvPlayerMenuData(title, items);
    });
    _tvControlsController.hide(preserveFocus: true);
  }

  void _closeTvMenu({bool showControls = true}) {
    if (!mounted || _tvMenu == null) return;
    setState(() => _tvMenu = null);
    if (showControls) {
      _tvControlsController.show(restorePreviousFocus: true);
    }
  }

  bool _handleTvOverlayBack() {
    if (_tvMenu != null) {
      _closeTvMenu();
      return true;
    }
    if (_tvNextEpisode != null) {
      _dismissTvNextEpisodePrompt();
      return true;
    }
    return false;
  }

  void _showTvEpisodeMenu() {
    final metadata = widget.tvMetadata;
    final episodes = metadata?.seasonEpisodes;
    if (metadata == null || episodes == null || episodes.isEmpty) return;
    final season = episodes.first.seasonNumber;
    final items = <BetterPlayerTvMenuItem>[
      if ((metadata.allSeasons?.length ?? 0) > 1)
        BetterPlayerTvMenuItem(
          label: tr('select_season'),
          subtitle: tr('season_episodes', namedArgs: {'season': '$season'}),
          icon: PhosphorIcons.stack(),
          showsNext: true,
          onSelected: _showTvSeasonMenu,
        ),
      ...episodes.map(
        (episode) => BetterPlayerTvMenuItem(
          label: '${episode.episodeNumber}. ${episode.episodeName}',
          subtitle: [
            if (episode.runtime != null) '${episode.runtime}m',
            if (episode.voteAverage != null && episode.voteAverage! > 0)
              '★ ${episode.voteAverage!.toStringAsFixed(1)}',
          ].join('  •  '),
          icon: episode.episodeNumber == metadata.episodeNumber &&
                  episode.seasonNumber == metadata.seasonNumber
              ? PhosphorIcons.playCircle(PhosphorIconsStyle.fill)
              : PhosphorIcons.playCircle(),
          selected: episode.episodeNumber == metadata.episodeNumber &&
              episode.seasonNumber == metadata.seasonNumber,
          onSelected: () => _playTvEpisode(episode),
        ),
      ),
    ];
    _openTvMenu(
      tr('season_episodes', namedArgs: {'season': '$season'}),
      items,
    );
  }

  void _showTvSeasonMenu() {
    final metadata = widget.tvMetadata;
    final seasons = metadata?.allSeasons;
    if (metadata == null || seasons == null || seasons.isEmpty) return;
    final browsedSeason = metadata.seasonEpisodes?.isNotEmpty == true
        ? metadata.seasonEpisodes!.first.seasonNumber
        : metadata.seasonNumber;
    _openTvMenu(
      tr('select_season'),
      seasons
          .map(
            (season) => BetterPlayerTvMenuItem(
              label: season.seasonName,
              subtitle: tr(
                'episodes_count',
                namedArgs: {'count': '${season.episodeCount}'},
              ),
              icon: PhosphorIcons.stack(),
              selected: season.seasonNumber == browsedSeason,
              showsNext: true,
              onSelected: () => unawaited(
                _loadTvSeasonEpisodes(season.seasonNumber),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> _loadTvSeasonEpisodes(int seasonNumber) async {
    final metadata = widget.tvMetadata;
    if (metadata == null) return;
    _openTvMenu(
      tr('select_season'),
      [
        BetterPlayerTvMenuItem(
          label: 'Loading episodes…',
          icon: PhosphorIcons.spinnerGap(),
          enabled: false,
          onSelected: () {},
        ),
      ],
    );
    final loaded = await _episodeSelection.fetchEpisodesForSeason(
      context,
      seasonNumber,
      metadata,
      widget.colors,
    );
    if (!mounted || _tvMenu == null) return;
    if (loaded) {
      _showTvEpisodeMenu();
    } else {
      _showTvSeasonMenu();
    }
  }

  void _showTvMovieRecommendationsMenu() {
    final metadata = widget.movieMetadata;
    final recommendations = metadata?.recommendations;
    if (metadata == null ||
        recommendations == null ||
        recommendations.isEmpty) {
      return;
    }
    _openTvMenu(
      tr('recommended_movies'),
      recommendations
          .map(
            (movie) => BetterPlayerTvMenuItem(
              label: movie.title,
              subtitle: [
                if (movie.releaseDate?.isNotEmpty == true)
                  movie.releaseDate!.split('-').first,
                if (movie.voteAverage != null && movie.voteAverage! > 0)
                  '★ ${movie.voteAverage!.toStringAsFixed(1)}',
              ].join('  •  '),
              icon: PhosphorIcons.filmSlate(),
              onSelected: () => _playTvMovie(movie),
            ),
          )
          .toList(growable: false),
    );
  }

  void _showTvProviderMenu() {
    final providers = widget.availableProviders;
    if (providers == null || providers.isEmpty) return;
    _openTvMenu(
      tr('select_provider'),
      providers.map(
        (provider) {
          final selected = provider.codeName == _currentProviderCode;
          final loading = _loadingProviders.contains(provider.codeName);
          final error = _providerErrors[provider.codeName];
          return BetterPlayerTvMenuItem(
            label: provider.displayName,
            subtitle: loading
                ? tr('loading_video_sources')
                : error ??
                    (selected ? tr('currently_playing') : tr('video_source')),
            icon: error != null
                ? PhosphorIcons.warningCircle()
                : selected
                    ? PhosphorIcons.playCircle(PhosphorIconsStyle.fill)
                    : PhosphorIcons.hardDrives(),
            selected: selected,
            enabled: !loading && !_isSwitchingProvider,
            onSelected: selected
                ? _closeTvMenu
                : () => _switchToProvider(
                      provider.codeName,
                      refreshMenu: () {
                        if (_tvMenu != null) {
                          _showTvProviderMenu();
                        }
                      },
                      closeMenu: _closeTvMenu,
                    ),
          );
        },
      ).toList(growable: false),
    );
  }

  EpisodeMetadata? get _nextTvEpisode {
    final metadata = widget.tvMetadata;
    final episodes = metadata?.seasonEpisodes;
    if (metadata == null || episodes == null || episodes.isEmpty) return null;
    final currentIndex = episodes.indexWhere(
      (episode) =>
          episode.episodeNumber == metadata.episodeNumber &&
          episode.seasonNumber == metadata.seasonNumber,
    );
    if (currentIndex < 0 || currentIndex >= episodes.length - 1) return null;
    return episodes[currentIndex + 1];
  }

  void _showTvNextEpisodePrompt({required bool startCountdown}) {
    final nextEpisode = _nextTvEpisode;
    if (!mounted || nextEpisode == null) return;
    _tvNextEpisodeTimer?.cancel();
    setState(() {
      _tvMenu = null;
      _tvNextEpisode = nextEpisode;
      _tvNextEpisodeCountdown = startCountdown ? 10 : null;
    });
    _tvControlsController.hide(preserveFocus: true);
    if (!startCountdown) return;
    _tvNextEpisodeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _tvNextEpisode == null) {
        timer.cancel();
        return;
      }
      final countdown = _tvNextEpisodeCountdown ?? 0;
      if (countdown <= 1) {
        timer.cancel();
        unawaited(_playTvEpisode(nextEpisode));
      } else {
        setState(() => _tvNextEpisodeCountdown = countdown - 1);
      }
    });
  }

  void _clearTvNextEpisodePrompt({bool showControls = true}) {
    _tvNextEpisodeTimer?.cancel();
    _tvNextEpisodeTimer = null;
    if (!mounted || _tvNextEpisode == null) return;
    setState(() {
      _tvNextEpisode = null;
      _tvNextEpisodeCountdown = null;
    });
    if (showControls) {
      _tvControlsController.show(restorePreviousFocus: true);
    }
  }

  void _dismissTvNextEpisodePrompt() {
    _nextEpisodeButtonDismissed = true;
    _showNextEpisodeButton = false;
    _clearTvNextEpisodePrompt();
  }

  Future<void> _playTvEpisode(EpisodeMetadata episode) async {
    _tvNextEpisodeTimer?.cancel();
    if (mounted) {
      setState(() {
        _tvMenu = null;
        _tvNextEpisode = null;
        _tvNextEpisodeCountdown = null;
      });
    }
    await _handleContentSwitch();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TVVideoLoader(
          download: false,
          useTvPlayer: true,
          onTvPlayerExit: widget.onTvPlayerExit,
          metadata: _metadataForTvEpisode(episode),
        ),
      ),
    );
  }

  Future<void> _playTvMovie(MovieRecommendation movie) async {
    if (mounted) setState(() => _tvMenu = null);
    await _handleContentSwitch();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => MovieVideoLoader(
          download: false,
          useTvPlayer: true,
          onTvPlayerExit: widget.onTvPlayerExit,
          metadata: MovieStreamMetadata(
            movieId: movie.movieId,
            movieName: movie.title,
            posterPath: movie.posterPath,
            backdropPath: movie.backdropPath,
            releaseDate: movie.releaseDate,
            releaseYear: movie.releaseDate == null
                ? null
                : DateTime.tryParse(movie.releaseDate!)?.year,
            isAdult: false,
            elapsed: 0,
          ),
        ),
      ),
    );
  }

  TVStreamMetadata _metadataForTvEpisode(EpisodeMetadata episode) {
    final current = widget.tvMetadata!;
    return TVStreamMetadata(
      elapsed: null,
      episodeId: episode.episodeId,
      episodeName: episode.episodeName,
      episodeNumber: episode.episodeNumber,
      posterPath: current.posterPath,
      backdropPath: episode.stillPath ?? current.backdropPath,
      seasonNumber: episode.seasonNumber,
      seriesName: current.seriesName,
      tvId: current.tvId,
      airDate: episode.airDate,
      seasonEpisodes: current.seasonEpisodes,
      allSeasons: current.allSeasons,
    );
  }

  void _showProviderSwitcher() {
    final providers = widget.availableProviders;
    if (providers == null || providers.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: .72,
            minChildSize: .45,
            maxChildSize: .96,
            snap: true,
            builder: (context, scrollController) => AppResponsiveContent(
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
                      controller: scrollController,
                      itemCount: providers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final provider = providers[index];
                        final selected =
                            provider.codeName == _currentProviderCode;
                        final loading =
                            _loadingProviders.contains(provider.codeName);
                        final error = _providerErrors[provider.codeName];
                        return AppSelectionTile(
                          title: provider.displayName,
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
                                    refreshMenu: () {
                                      if (sheetContext.mounted) {
                                        setSheetState(() {});
                                      }
                                    },
                                    closeMenu: () {
                                      if (sheetContext.mounted) {
                                        Navigator.pop(sheetContext);
                                      }
                                    },
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
    String providerCode, {
    required VoidCallback refreshMenu,
    required VoidCallback closeMenu,
  }) async {
    if (_isSwitchingProvider || providerCode == _currentProviderCode) return;
    final analyticsStopwatch = Stopwatch()..start();

    setState(() {
      _isSwitchingProvider = true;
      _loadingProviders.add(providerCode);
      _providerErrors.remove(providerCode);
    });
    refreshMenu();

    final position =
        _betterPlayerController.videoPlayerController?.value.position ??
            Duration.zero;
    final wasPlaying =
        _betterPlayerController.videoPlayerController?.value.isPlaying == true;
    final previousDataSource = _betterPlayerController.betterPlayerDataSource;
    var replacementStarted = false;
    var switched = false;
    try {
      await _betterPlayerController.pause();
      var source = _loadedProviders[providerCode];
      if (source == null) {
        final provider = widget.availableProviders!.firstWhere(
          (candidate) => candidate.codeName == providerCode,
        );
        final resultFuture = _providerResults[providerCode] ??=
            widget.mediaType == MediaType.movie
                ? ProviderLoader.loadMovieFromProvider(
                    provider: provider,
                    movieId: widget.movieMetadata!.movieId!,
                    scraperApiUrl: widget.scraperApiUrl,
                  )
                : ProviderLoader.loadTVFromProvider(
                    provider: provider,
                    tvId: widget.tvMetadata!.tvId!,
                    seasonNumber: widget.tvMetadata!.seasonNumber!,
                    episodeNumber: widget.tvMetadata!.episodeNumber!,
                    scraperApiUrl: widget.scraperApiUrl,
                  );
        final result = await resultFuture;
        if (!result.success || result.videoLinks?.isEmpty != false) {
          // Failed futures are not cached, allowing a later explicit retry.
          _providerResults.remove(providerCode);
          throw Exception(result.errorMessage ?? tr('movie_vid_404'));
        }

        final subtitles = <BetterPlayerSubtitlesSource>[
          for (final subtitle in result.subtitleLinks ?? const [])
            BetterPlayerSubtitlesSource(
              type: BetterPlayerSubtitlesSourceType.network,
              urls: [subtitle.url ?? ''],
              name: subtitle.language ?? tr('not_available'),
              headers: subtitle.headers,
            ),
        ];
        source = ProviderVideoSource(
          providerCode: providerCode,
          providerName: provider.displayName,
          videoSources: VideoUtils.reverseVideoQualityMap(
            VideoUtils.convertVideoLinksToMap(result.videoLinks!),
          ),
          videoFormats: VideoUtils.reverseVideoQualityMap(
            VideoUtils.convertVideoFormatsToMap(result.videoLinks!),
          ),
          videoHeaders: VideoUtils.reverseVideoQualityMap(
            VideoUtils.convertVideoHeadersToMap(result.videoLinks!),
          ),
          subtitles: subtitles,
        );
        _loadedProviders[providerCode] = source;
      }

      if (!mounted) return;
      final nextSource = source;
      replacementStarted = true;
      _preRollActive = false;
      await _betterPlayerController.setupDataSource(
        _buildDataSource(
          sources: nextSource.videoSources,
          subtitles: nextSource.subtitles,
          videoFormats: nextSource.videoFormats,
          videoHeaders: nextSource.videoHeaders,
        ),
      );
      _applyPreferredAdaptiveQuality();
      await _betterPlayerController.seekTo(position);
      if (!wasPlaying) await _betterPlayerController.pause();

      if (!mounted) return;
      setState(() {
        _currentProviderCode = providerCode;
        _activeSources = Map.of(nextSource.videoSources);
        _activeSubtitles = List.of(nextSource.subtitles);
        _activeVideoFormats = Map.of(nextSource.videoFormats);
        _activeVideoHeaders = Map.of(nextSource.videoHeaders);
        final switchedDuration = _betterPlayerController
            .videoPlayerController?.value.duration?.inSeconds;
        if (switchedDuration != null) duration = switchedDuration;
      });
      _analyticsProviderSwitchCount++;
      settings.analytics.trackStreamServerChanged(
        mediaType: _analyticsMediaType,
        serverName: nextSource.providerName,
      );
      settings.analytics.trackProviderAttempt(
        mediaType: _analyticsMediaType,
        provider: nextSource.providerName,
        purpose: 'provider_switch',
        success: true,
        durationMs: analyticsStopwatch.elapsedMilliseconds,
        sourceCount: nextSource.videoSources.length,
        subtitleCount: nextSource.subtitles.length,
      );
      _trackPlaybackEvent(
        'provider_switch_succeeded',
        value: nextSource.providerName,
      );
      switched = true;
    } catch (error) {
      settings.analytics.trackProviderAttempt(
        mediaType: _analyticsMediaType,
        provider: providerCode,
        purpose: 'provider_switch',
        success: false,
        durationMs: analyticsStopwatch.elapsedMilliseconds,
        sourceCount: 0,
        subtitleCount: 0,
        error: error.toString(),
      );
      _trackPlaybackEvent(
        'provider_switch_failed',
        value: providerCode,
        error: error.toString(),
      );
      debugPrint(
        '[Player] Provider switch failed for $providerCode: $error',
      );
      if (!mounted) return;
      if (replacementStarted && previousDataSource != null) {
        try {
          await _betterPlayerController.setupDataSource(previousDataSource);
          await _betterPlayerController.seekTo(position);
          if (!wasPlaying) await _betterPlayerController.pause();
        } catch (restoreError) {
          debugPrint('Unable to restore provider after switch: $restoreError');
        }
      } else if (wasPlaying) {
        await _betterPlayerController.play();
      }
      // Provider errors are intentionally kept in debug logs only. Scraper and
      // platform exceptions can contain URLs, native class names, and complete
      // stack traces that should never be rendered in either player UI.
      setState(
        () => _providerErrors[providerCode] = tr('switch_provider_error'),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSwitchingProvider = false;
          _loadingProviders.remove(providerCode);
        });
        if (switched) {
          closeMenu();
        } else {
          refreshMenu();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (widget.useTvControls && _handleTvOverlayBack()) return;
          if (widget.useTvControls && _tvControlsController.handleBack()) {
            return;
          }
          _exitPlayer();
        }
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
            if (_tvMenu case final menu?)
              Positioned.fill(
                child: BetterPlayerTvMenu(
                  title: menu.title,
                  items: menu.items,
                  onClose: _closeTvMenu,
                  accentColor: widget.colors.first,
                ),
              ),
            if (_tvNextEpisode case final nextEpisode?)
              Positioned.fill(
                child: _TvNextEpisodeOverlay(
                  episode: nextEpisode,
                  countdown: _tvNextEpisodeCountdown,
                  accentColor: widget.colors.first,
                  onCancel: _dismissTvNextEpisodePrompt,
                  onPlay: () => _playTvEpisode(nextEpisode),
                ),
              ),
          ],
        ),
        floatingActionButton: widget.useTvControls
            ? null
            : FloatingActionButton.small(
                tooltip: tr('video_source'),
                onPressed: _showExternalPlayerSheet,
                child: Icon(PhosphorIcons.arrowSquareOut()),
              ),
      ),
    );
  }

  void _exitPlayer() {
    final playerRoute = ModalRoute.of(context);
    final onTvPlayerExit = widget.onTvPlayerExit;
    Navigator.pop(
      context,
      _betterPlayerController.isVideoInitialized() == true
          ? widget.mediaType == MediaType.movie
              ? insertRecentMovieData
              : insertRecentEpisodeData
          : null,
    );
    if (onTvPlayerExit == null) return;
    if (playerRoute == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onTvPlayerExit());
      return;
    }
    unawaited(playerRoute.completed.then((_) => onTvPlayerExit()));
  }

  void _showExternalPlayerSheet() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => AppResponsiveContent(
        maxWidth: 680,
        padding: EdgeInsets.zero,
        child: ExternalPlay(
          videoSources: _activeSources,
          subtitleSources: _activeSubtitles,
        ),
      ),
    );
  }

  Future<void> _downloadFromCurrentProvider() async {
    if (_activeSources.isEmpty) return;
    final providerName = _currentProviderName();
    final sources = Map<String, String>.of(_activeSources);
    final formats = _activeVideoFormats == null
        ? <String, BetterPlayerVideoFormat?>{}
        : Map<String, BetterPlayerVideoFormat?>.of(_activeVideoFormats!);
    final headers = Map<String, Map<String, String>>.of(_activeVideoHeaders);
    final resolution = await DownloadSelectionSheets.showResolution(
      context,
      resolutions: sources.keys.toList(),
      providerName: providerName,
    );
    if (!mounted || resolution == null) return;

    final url = sources[resolution];
    if (url == null) return;
    final declaredFormat = formats[resolution];
    final format = declaredFormat == BetterPlayerVideoFormat.dash
        ? 'dash'
        : declaredFormat == BetterPlayerVideoFormat.hls
            ? 'hls'
            : url.toLowerCase().contains('.mpd')
                ? 'dash'
                : 'hls';
    final movie = widget.movieMetadata;
    final episode = widget.tvMetadata;
    final isMovie = widget.mediaType == MediaType.movie;
    final season = episode?.seasonNumber ?? 0;
    final episodeNumber = episode?.episodeNumber ?? 0;
    final posterPath = isMovie ? movie?.posterPath : episode?.posterPath;
    final subtitleTrack = _originalSubtitleTrack();

    try {
      await context.read<OfflineDownloadProvider>().enqueue(
            OfflineDownloadRequest(
              id: isMovie
                  ? 'movie_${movie!.movieId}'
                  : 'tv_${episode!.tvId}_s${season}_e$episodeNumber',
              url: url,
              format: format,
              title: isMovie
                  ? movie?.movieName ?? 'Movie'
                  : episode?.seriesName ?? 'TV episode',
              subtitle: isMovie
                  ? 'From $providerName'
                  : 'S${season.toString().padLeft(2, '0')} • '
                      'E${episodeNumber.toString().padLeft(2, '0')} '
                      '${episode?.episodeName ?? ''} • $providerName',
              mediaType: isMovie ? 'movie' : 'episode',
              quality: resolution,
              posterUrl: posterPath == null
                  ? null
                  : '${TMDB_BASE_IMAGE_URL}w500$posterPath',
              maxVideoHeight: _downloadResolutionHeight(resolution),
              headers: headers[resolution] ??
                  VideoUtils.inferVideoHeaders(url) ??
                  const {},
              contentId: isMovie ? movie?.movieId : episode?.tvId,
              seasonNumber: isMovie ? null : season,
              episodeNumber: isMovie ? null : episodeNumber,
              subtitleTrackUrl: subtitleTrack?.urls!.first,
              subtitleTrackName: subtitleTrack?.name,
              subtitleTrackHeaders: subtitleTrack?.headers ?? const {},
            ),
          );
      settings.analytics.trackDownload(
        action: 'enqueue_from_player',
        mediaType: _analyticsMediaType,
        outcome: 'success',
        provider: providerName,
        quality: resolution,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$resolution download added from $providerName'),
        ),
      );
    } catch (error) {
      settings.analytics.trackDownload(
        action: 'enqueue_from_player',
        mediaType: _analyticsMediaType,
        outcome: 'error',
        provider: providerName,
        quality: resolution,
        error: error.toString(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start download: $error')),
      );
    }
  }

  String _currentProviderName() {
    final code = _currentProviderCode;
    final loadedName =
        code == null ? null : _loadedProviders[code]?.providerName;
    if (loadedName?.isNotEmpty == true) return loadedName!;
    for (final provider
        in widget.availableProviders ?? const <VideoProvider>[]) {
      if (provider.codeName == code) return provider.displayName;
    }
    return 'Current provider';
  }

  int? _downloadResolutionHeight(String resolution) {
    final match = RegExp(r'(\d{3,4})').firstMatch(resolution);
    return int.tryParse(match?.group(1) ?? '');
  }

  BetterPlayerSubtitlesSource? _originalSubtitleTrack() {
    BetterPlayerSubtitlesSource? fallback;
    for (final source in _activeSubtitles) {
      final urls = source.urls;
      if (source.type != BetterPlayerSubtitlesSourceType.network ||
          urls == null ||
          urls.isEmpty ||
          urls.first?.isNotEmpty != true) {
        continue;
      }
      if (source.selectedByDefault == true) return source;
      fallback ??= source;
    }
    return fallback;
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: .72,
        minChildSize: .45,
        maxChildSize: .95,
        expand: false,
        snap: true,
        builder: (context, scrollController) => PlayerSheetScaffold(
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
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            itemCount: subtitles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
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

  String _sanitizeError(dynamic error) {
    if (error == null) return tr('switch_provider_error');
    String msg = error.toString();
    final isDeveloperError = RegExp(
      r'(PlatformException|IndexOutOfBoundsException|MethodChannel|SourceFile:|java\.|android\.|io\.flutter|\n\s*at\s)',
      caseSensitive: false,
    ).hasMatch(msg);
    if (isDeveloperError) return tr('switch_provider_error');

    msg = msg.replaceAll(RegExp(r'https?://[^\s]+'), '').trim();
    msg = msg
        .replaceAll(
          RegExp(
              r'^(Exception|SocketException|FormatException|ScraperApiException):\s*'),
          '',
        )
        .trim();
    // Player surfaces are intentionally compact. Multi-line or very long
    // errors are diagnostics, not useful recovery guidance for the viewer.
    if (msg.isEmpty || msg.contains('\n') || msg.length > 160) {
      return tr('switch_provider_error');
    }
    return msg;
  }

  Widget _buildCustomPlayerErrorWidget(
      BuildContext context, String? errorText) {
    final cleanError = _sanitizeError(errorText);
    final hasProviders = widget.availableProviders != null &&
        widget.availableProviders!.isNotEmpty;
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.warningCircle(),
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              cleanError,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'FigtreeSB',
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (hasProviders)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.colors.first,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (widget.useTvControls) {
                        _showTvProviderMenu();
                      } else {
                        _showProviderSwitcher();
                      }
                    },
                    icon: Icon(PhosphorIcons.arrowsLeftRight(), size: 18),
                    label: Text(tr('switch_provider')),
                  ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                  onPressed: () {
                    final currentSource = _currentProviderCode;
                    if (currentSource != null) {
                      _switchToProvider(
                        currentSource,
                        closeMenu: () {},
                        refreshMenu: () {},
                      );
                    }
                  },
                  icon: Icon(PhosphorIcons.arrowClockwise(), size: 18),
                  label: Text(tr('retry')),
                ),
                IconButton(
                  onPressed: _exitPlayer,
                  icon: Icon(PhosphorIcons.x(), color: Colors.white70),
                  tooltip: tr('close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TvPlayerMenuData {
  const _TvPlayerMenuData(this.title, this.items);

  final String title;
  final List<BetterPlayerTvMenuItem> items;
}

class _TvNextEpisodeOverlay extends StatelessWidget {
  const _TvNextEpisodeOverlay({
    required this.episode,
    required this.accentColor,
    required this.onCancel,
    required this.onPlay,
    this.countdown,
  });

  final EpisodeMetadata episode;
  final int? countdown;
  final Color accentColor;
  final VoidCallback onCancel;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.escape ||
                event.logicalKey == LogicalKeyboardKey.goBack ||
                event.logicalKey == LogicalKeyboardKey.browserBack)) {
          onCancel();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: ColoredBox(
        color: Colors.black38,
        child: SafeArea(
          minimum: const EdgeInsets.all(36),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 570,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xf5161716),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 28,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.skipForward(PhosphorIconsStyle.fill),
                        color: accentColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tr('next_episode'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (countdown case final seconds?)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 46,
                              height: 46,
                              child: CircularProgressIndicator(
                                value: seconds / 10,
                                strokeWidth: 4,
                                color: accentColor,
                                backgroundColor: Colors.white12,
                              ),
                            ),
                            Text(
                              '$seconds',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 190,
                          height: 108,
                          child: episode.stillPath == null
                              ? const ColoredBox(
                                  color: Color(0xff292a28),
                                  child: Icon(
                                    PhosphorIconsRegular.filmStrip,
                                    color: Colors.white54,
                                    size: 34,
                                  ),
                                )
                              : Image.network(
                                  'https://image.tmdb.org/t/p/w780${episode.stillPath}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const ColoredBox(
                                    color: Color(0xff292a28),
                                    child: Icon(
                                      PhosphorIconsRegular.filmStrip,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${episode.episodeNumber}. ${episode.episodeName}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (episode.overview?.trim().isNotEmpty ==
                                true) ...[
                              const SizedBox(height: 8),
                              Text(
                                episode.overview!.trim(),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _TvPromptButton(
                        label: tr('cancel'),
                        icon: PhosphorIcons.x(),
                        accentColor: accentColor,
                        onPressed: onCancel,
                      ),
                      const SizedBox(width: 12),
                      _TvPromptButton(
                        label: tr('play_now'),
                        icon: PhosphorIcons.play(PhosphorIconsStyle.fill),
                        accentColor: accentColor,
                        primary: true,
                        autofocus: true,
                        onPressed: onPlay,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TvPromptButton extends StatefulWidget {
  const _TvPromptButton({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onPressed,
    this.primary = false,
    this.autofocus = false,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onPressed;
  final bool primary;
  final bool autofocus;

  @override
  State<_TvPromptButton> createState() => _TvPromptButtonState();
}

class _TvPromptButtonState extends State<_TvPromptButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: widget.autofocus,
      onFocusChange: (focused) => setState(() => _focused = focused),
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 13),
          decoration: BoxDecoration(
            color: widget.primary
                ? widget.accentColor
                : _focused
                    ? const Color(0xff30312f)
                    : const Color(0xff242523),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: _focused ? Colors.white : Colors.transparent,
              width: 3,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 22),
              const SizedBox(width: 9),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
