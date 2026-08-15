import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../functions/function.dart';
import '../../models/live_tv.dart';
import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../../services/analytics_service.dart';
import '../../services/daddylive_service.dart';
import '../../services/stream_intro_service.dart';

class LivePlayer extends StatefulWidget {
  const LivePlayer({
    required this.videoUrl,
    required this.colors,
    required this.autoFullScreen,
    required this.channelName,
    required this.analytics,
    required this.analyticsSurface,
    required this.scraperApiUrl,
    this.headers = const <String, String>{},
    this.streamIcon,
    this.channels = const <Channel>[],
    this.initialChannelId,
    this.service,
    this.onChannelSwitch,
    this.enableCast = true,
    this.useTvControls = false,
    super.key,
  });

  final String videoUrl;
  final List<Color> colors;
  final bool autoFullScreen;
  final String channelName;
  final AnalyticsService analytics;
  final String analyticsSurface;
  final String scraperApiUrl;
  final Map<String, String> headers;
  final String? streamIcon;

  /// Channels available for in-player switching. When empty, the channel
  /// switcher is hidden.
  final List<Channel> channels;
  final String? initialChannelId;
  final DaddyLiveService? service;
  final void Function(Channel channel)? onChannelSwitch;
  final bool enableCast;
  final bool useTvControls;

  @override
  State<LivePlayer> createState() => _LivePlayerState();
}

class _LivePlayerState extends State<LivePlayer> {
  static const Duration _recoveryWindow = Duration(seconds: 60);
  static const List<Duration> _automaticRecoveryDelays = <Duration>[
    Duration(seconds: 8),
    Duration(seconds: 12),
    Duration(seconds: 15),
  ];

  late BetterPlayerController _betterPlayerController;
  final BetterPlayerTvControlsController _tvControlsController =
      BetterPlayerTvControlsController();
  final StreamIntroService _introService = StreamIntroService();
  late BetterPlayerControlsConfiguration betterPlayerControlsConfiguration;
  late BetterPlayerBufferingConfiguration betterPlayerBufferingConfiguration;

  final GlobalKey _betterPlayerKey = GlobalKey();

  String? _currentChannelId;
  late String _currentChannelName;
  bool _isSwitching = false;
  String? _bannerText;
  Timer? _bannerTimer;
  Timer? _recoveryDeadlineTimer;
  Timer? _recoveryAttemptTimer;
  late final DateTime _sessionStartedAt;
  late final String _sessionId;
  DateTime? _playingStartedAt;
  DateTime? _bufferingStartedAt;
  int _watchedMs = 0;
  int _bufferingMs = 0;
  int _bufferCount = 0;
  int _channelSwitchCount = 0;
  bool _hasInitialized = false;
  bool _wasPlayingBeforeBuffering = false;
  bool _automaticRecoveryRunning = false;
  int _automaticRecoveryAttempt = 0;
  DateTime? _recoveryStartedAt;
  Object? _lastPlaybackError;
  late String _currentVideoUrl;
  late Map<String, String> _currentVideoHeaders;
  final ValueNotifier<_LivePlaybackFailure?> _playbackFailure =
      ValueNotifier<_LivePlaybackFailure?>(null);
  late final AppDependencyProvider _appDependencies;
  int? _occasionalEffectsSuppressionId;

  @override
  void initState() {
    super.initState();
    _appDependencies =
        Provider.of<AppDependencyProvider>(context, listen: false);
    _occasionalEffectsSuppressionId =
        _appDependencies.suppressOccasionalEffects();
    _sessionStartedAt = DateTime.now();
    _sessionId =
        '${_sessionStartedAt.microsecondsSinceEpoch}-${identityHashCode(this)}';
    _currentChannelId =
        widget.initialChannelId ?? widget.channels.firstOrNull?.id;
    _currentChannelName = widget.channelName;
    _currentVideoUrl = widget.videoUrl;
    _currentVideoHeaders = Map<String, String>.of(widget.headers);

    betterPlayerBufferingConfiguration =
        const BetterPlayerBufferingConfiguration(
      // Favor a deeper forward buffer so slow and fluctuating links can
      // absorb sustained throughput drops. Bound history for Android TV RAM.
      maxBufferMs: 180000,
      minBufferMs: 30000,
      bufferForPlaybackMs: 6000,
      bufferForPlaybackAfterRebufferMs: 12000,
      backBufferDurationMs: 30000,
      retainBackBufferFromKeyframe: false,
    );

    betterPlayerControlsConfiguration =
        _buildControlsConfiguration(_currentChannelName);

    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      autoDetectFullscreenDeviceOrientation: !widget.useTvControls,
      autoDetectFullscreenAspectRatio: !widget.useTvControls,
      looping: false,
      autoPlay: true,
      allowedScreenSleep: false,
      fit: BoxFit.contain,
      autoDispose: true,
      controlsConfiguration: betterPlayerControlsConfiguration,
      errorBuilder: (_, __) => const SizedBox.expand(),
      overlayOnTop: true,
      overlay: ValueListenableBuilder<_LivePlaybackFailure?>(
        valueListenable: _playbackFailure,
        builder: (context, failure, _) {
          if (failure == null) return const SizedBox.expand();
          return _LivePlayerErrorOverlay(
            message: failure.message,
            retrying: failure.retrying,
            onRetry: _retryStream,
            onChannels: canSwitchChannels
                ? () => unawaited(_showChannelSwitcher())
                : null,
          );
        },
      ),
      showPlaceholderUntilPlay: true,
      subtitlesConfiguration: const BetterPlayerSubtitlesConfiguration(
        backgroundColor: Colors.black45,
        fontFamily: 'Figtree',
        fontColor: Colors.white,
        outlineEnabled: false,
        fontSize: 17,
      ),
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.addEventsListener(_onPlayerEvent);
    unawaited(_setupInitialStream());
    _betterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);
  }

  Future<void> _setupInitialStream() async {
    try {
      await _setupStreamWithIntro(
        _buildDataSource(widget.videoUrl, widget.headers),
      );
      if (widget.autoFullScreen && !_betterPlayerController.isFullScreen) {
        _betterPlayerController.enterFullScreen();
      }
    } catch (error) {
      _trackPlayerEvent('setup_error', error: error.toString());
      _beginPlaybackRecovery(error);
    }
  }

  Future<void> _setupStreamWithIntro(
    BetterPlayerDataSource dataSource,
  ) async {
    StreamIntroConfig intro = const StreamIntroConfig.disabled();
    try {
      intro = await _introService.fetch(widget.scraperApiUrl);
    } catch (error) {
      debugPrint('[LivePlayer] Branded intro unavailable: $error');
    }
    if (intro.enabled && intro.url != null) {
      await _betterPlayerController.setupDataSourceWithPreRoll(
        preRollDataSource: _buildIntroDataSource(intro.url!),
        betterPlayerDataSource: dataSource,
      );
    } else {
      await _betterPlayerController.setupDataSource(dataSource);
    }
  }

  BetterPlayerDataSource _buildIntroDataSource(Uri url) =>
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url.toString(),
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          maxCacheSize: 50 * 1024 * 1024,
          maxCacheFileSize: 20 * 1024 * 1024,
        ),
      );

  BetterPlayerControlsConfiguration _buildControlsConfiguration(
    String channelName,
  ) {
    final seekDuration = Provider.of<SettingsProvider>(context, listen: false)
        .defaultSeekDuration;

    return BetterPlayerControlsConfiguration(
      gestureConfiguration: BetterPlayerGestureConfiguration(
        enableVolumeSwipe: !widget.useTvControls,
        enableBrightnessSwipe: !widget.useTvControls,
        enableSeekSwipe: !widget.useTvControls,
      ),
      name: channelName,
      enableFullscreen: true,
      enableSubtitles: true,
      showSubtitlesButton: !widget.useTvControls,
      showQualitiesButton: !widget.useTvControls,
      enableCrop: true,
      cropIcon: PhosphorIcons.crop(),
      enablePip: !widget.useTvControls,
      enableCast: !widget.useTvControls && widget.enableCast,
      backgroundColor: Colors.black,
      controlBarColor: Colors.black.withValues(alpha: 0.3),
      progressBarBackgroundColor: Colors.white,
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
      iconsColor: widget.colors.first,
      backwardSkipTimeInMilliseconds:
          Duration(seconds: seekDuration).inMilliseconds,
      forwardSkipTimeInMilliseconds:
          Duration(seconds: seekDuration).inMilliseconds,
      progressBarPlayedColor: widget.colors.first,
      progressBarBufferedColor: Colors.black45,
      skipForwardIcon: PhosphorIcons.fastForward(),
      skipBackIcon: PhosphorIcons.rewind(),
      fullscreenEnableIcon: PhosphorIcons.cornersOut(),
      fullscreenDisableIcon: PhosphorIcons.cornersIn(),
      overflowMenuIcon: PhosphorIcons.list(),
      subtitlesIcon: PhosphorIcons.closedCaptioning(),
      qualitiesIcon: PhosphorIcons.highDefinition(),
      overflowMenuIconsColor: widget.colors.first,
      overflowModalTextColor: widget.colors.first,
      overflowModalColor: widget.colors.last,
      enableAudioTracks: true,
      overflowMenuCustomItems: canSwitchChannels
          ? <BetterPlayerOverflowMenuItem>[
              BetterPlayerOverflowMenuItem(
                PhosphorIcons.televisionSimple(),
                'Channels',
                _showChannelSwitcher,
              ),
            ]
          : const <BetterPlayerOverflowMenuItem>[],
    );
  }

  bool get canSwitchChannels =>
      widget.service != null &&
      widget.channels.isNotEmpty &&
      widget.channels.length > 1;

  BetterPlayerDataSource _buildDataSource(
    String url,
    Map<String, String> headers,
  ) {
    final resolvedHeaders = <String, String>{
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      'Connection': 'keep-alive',
      ...headers,
    };
    return BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      liveStream: true,
      bufferingConfiguration: betterPlayerBufferingConfiguration,
      headers: resolvedHeaders,
      videoFormat: BetterPlayerVideoFormat.hls,
      castConfiguration: widget.enableCast
          ? BetterPlayerCastConfiguration(
              title: _currentChannelName,
              subtitle: 'Live TV',
              imageUrl: widget.streamIcon,
              contentType: 'application/x-mpegURL',
              isLive: true,
              requestHeaders: resolvedHeaders,
              customData: <String, Object?>{
                'mediaType': 'live',
                'channelId': _currentChannelId,
              },
            )
          : null,
    );
  }

  Future<void> _retryStream() async {
    final failure = _playbackFailure.value;
    if (failure?.retrying == true || !mounted) return;
    _cancelPlaybackRecovery();
    _playbackFailure.value = _LivePlaybackFailure(
      message: failure?.message ?? 'This channel is temporarily unavailable.',
      retrying: true,
    );
    _betterPlayerController.setControlsEnabled(false);
    _trackPlayerEvent('retry');
    try {
      final service = widget.service;
      final channelId = _currentChannelId;
      final stream = service != null && channelId != null
          ? await service.getStream(channelId)
          : null;
      final url = stream?.url ?? _currentVideoUrl;
      final headers = stream?.headers ?? _currentVideoHeaders;
      if (url.trim().isEmpty) {
        throw StateError('The channel returned no playable stream.');
      }

      // Do not replay the branded intro during recovery.
      await _betterPlayerController.setupDataSource(
        _buildDataSource(url, headers),
      );
      if (!mounted) return;
      _currentVideoUrl = url;
      _currentVideoHeaders = Map<String, String>.of(headers);
      _finishPlaybackRecovery();
      if (_betterPlayerController.isPlaying() != true) {
        await _betterPlayerController.play();
      }
      _trackPlayerEvent('retry_success');
    } catch (error) {
      _trackPlayerEvent('retry_error', error: error.toString());
      _beginPlaybackRecovery(error);
    }
  }

  void _beginPlaybackRecovery(Object error) {
    if (!mounted) return;
    _stopWatchClock();
    _wasPlayingBeforeBuffering = false;
    _lastPlaybackError = error;
    if (_recoveryStartedAt == null) {
      _recoveryStartedAt = DateTime.now();
      _automaticRecoveryAttempt = 0;
      _recoveryDeadlineTimer = Timer(
        _recoveryWindow,
        _showTerminalPlaybackError,
      );
      _trackPlayerEvent('reconnecting', error: error.toString());
    }
    _playbackFailure.value = _LivePlaybackFailure(
      message: friendlyLiveTvError(error),
      retrying: true,
    );
    // Keep playback alive. Better Player retries the current HLS source on
    // its own; the slower app-level attempts below also resolve fresh tokens.
    _betterPlayerController.setControlsEnabled(false);
    _scheduleAutomaticRecovery();
  }

  void _scheduleAutomaticRecovery() {
    if (_recoveryStartedAt == null ||
        _automaticRecoveryRunning ||
        _recoveryAttemptTimer?.isActive == true ||
        _automaticRecoveryAttempt >= _automaticRecoveryDelays.length) {
      return;
    }
    final delay = _automaticRecoveryDelays[_automaticRecoveryAttempt];
    _recoveryAttemptTimer = Timer(
      delay,
      () => unawaited(_attemptAutomaticRecovery()),
    );
  }

  Future<void> _attemptAutomaticRecovery() async {
    _recoveryAttemptTimer = null;
    if (!mounted || _recoveryStartedAt == null || _automaticRecoveryRunning) {
      return;
    }
    _automaticRecoveryRunning = true;
    final attempt = ++_automaticRecoveryAttempt;
    _trackPlayerEvent('auto_retry_$attempt');
    try {
      final service = widget.service;
      final channelId = _currentChannelId;
      if (service != null && channelId != null) {
        final stream = await service.getStream(channelId);
        if (!mounted || _recoveryStartedAt == null) return;
        _currentVideoUrl = stream.url;
        _currentVideoHeaders = Map<String, String>.of(stream.headers);
        await _betterPlayerController.setupDataSource(
          _buildDataSource(stream.url, stream.headers),
        );
      } else {
        await _betterPlayerController.retryDataSource();
      }
      if (!mounted || _recoveryStartedAt == null) return;
      if (_betterPlayerController.isPlaying() != true) {
        await _betterPlayerController.play();
      }
    } catch (error) {
      _lastPlaybackError = error;
      _trackPlayerEvent('auto_retry_error', error: error.toString());
    } finally {
      _automaticRecoveryRunning = false;
      if (mounted && _recoveryStartedAt != null) {
        _scheduleAutomaticRecovery();
      }
    }
  }

  void _finishPlaybackRecovery() {
    if (_recoveryStartedAt != null) {
      _trackPlayerEvent('reconnected');
    }
    _cancelPlaybackRecovery();
    _playbackFailure.value = null;
    _betterPlayerController.setControlsEnabled(true);
  }

  void _showTerminalPlaybackError() {
    if (!mounted || _recoveryStartedAt == null) return;
    final error = _lastPlaybackError ??
        'This channel did not recover after several attempts.';
    _cancelPlaybackRecovery();
    _playbackFailure.value = _LivePlaybackFailure(
      message: friendlyLiveTvError(error),
    );
    _trackPlayerEvent('reconnect_exhausted', error: error.toString());
  }

  void _cancelPlaybackRecovery() {
    _recoveryDeadlineTimer?.cancel();
    _recoveryDeadlineTimer = null;
    _recoveryAttemptTimer?.cancel();
    _recoveryAttemptTimer = null;
    _recoveryStartedAt = null;
    _automaticRecoveryAttempt = 0;
    _lastPlaybackError = null;
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        if (_playbackFailure.value != null) _finishPlaybackRecovery();
        if (!_hasInitialized) {
          _hasInitialized = true;
          _trackPlayerEvent(
            'initialized',
            startupMs: _sessionElapsedMs,
          );
        }
        break;
      case BetterPlayerEventType.play:
        if (_playbackFailure.value != null) _finishPlaybackRecovery();
        _startWatchClock();
        _trackPlayerEvent('play');
        break;
      case BetterPlayerEventType.pause:
        _wasPlayingBeforeBuffering = false;
        _stopWatchClock();
        _trackPlayerEvent('pause');
        break;
      case BetterPlayerEventType.bufferingStart:
        _wasPlayingBeforeBuffering = _playingStartedAt != null;
        _stopWatchClock();
        _bufferingStartedAt ??= DateTime.now();
        _bufferCount++;
        _trackPlayerEvent('buffering_started');
        break;
      case BetterPlayerEventType.bufferingEnd:
        final startedAt = _bufferingStartedAt;
        final durationMs = startedAt == null
            ? 0
            : DateTime.now().difference(startedAt).inMilliseconds;
        _bufferingMs += durationMs;
        _bufferingStartedAt = null;
        if (_wasPlayingBeforeBuffering) _startWatchClock();
        _wasPlayingBeforeBuffering = false;
        if (_recoveryStartedAt != null) _finishPlaybackRecovery();
        _trackPlayerEvent('buffering_ended', bufferingMs: durationMs);
        break;
      case BetterPlayerEventType.exception:
        final error = event.parameters?['exception']?.toString() ??
            event.parameters?.toString() ??
            'Unknown player error';
        _trackPlayerEvent('error', error: error);
        _beginPlaybackRecovery(error);
        break;
      case BetterPlayerEventType.openFullscreen:
        _trackPlayerEvent('fullscreen_opened');
        break;
      case BetterPlayerEventType.hideFullscreen:
        _trackPlayerEvent('fullscreen_closed');
        break;
      case BetterPlayerEventType.pipStart:
        _trackPlayerEvent('pip_started');
        break;
      case BetterPlayerEventType.pipStop:
        _trackPlayerEvent('pip_stopped');
        break;
      default:
        break;
    }
  }

  int get _sessionElapsedMs =>
      DateTime.now().difference(_sessionStartedAt).inMilliseconds;

  void _startWatchClock() => _playingStartedAt ??= DateTime.now();

  void _stopWatchClock() {
    final startedAt = _playingStartedAt;
    if (startedAt == null) return;
    _watchedMs += DateTime.now().difference(startedAt).inMilliseconds;
    _playingStartedAt = null;
  }

  void _trackPlayerEvent(
    String event, {
    int? startupMs,
    int? bufferingMs,
    String? error,
  }) {
    widget.analytics.trackLiveTVPlayerEvent(
      surface: widget.analyticsSurface,
      sessionId: _sessionId,
      channelId: _currentChannelId ?? 'unknown',
      channelName: _currentChannelName,
      event: event,
      sessionElapsedMs: _sessionElapsedMs,
      startupMs: startupMs,
      bufferingMs: bufferingMs,
      bufferCount: _bufferCount,
      error: error,
    );
  }

  Future<void> _showChannelSwitcher() async {
    widget.analytics.trackLiveTVInteraction(
      surface: widget.analyticsSurface,
      action: 'channel_switcher_opened',
      resultCount: widget.channels.length,
    );
    final selected = await showModalBottomSheet<Channel>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _ChannelSwitcherSheet(
        channels: widget.channels,
        currentChannelId: _currentChannelId,
      ),
    );
    if (selected == null) {
      widget.analytics.trackLiveTVInteraction(
        surface: widget.analyticsSurface,
        action: 'channel_switcher_dismissed',
      );
      return;
    }
    await _switchChannel(selected);
  }

  Future<void> _switchChannel(Channel channel) async {
    final service = widget.service;
    if (_isSwitching || service == null || channel.id == _currentChannelId) {
      return;
    }
    _cancelPlaybackRecovery();
    final failure = _playbackFailure.value;
    if (failure != null) {
      _playbackFailure.value = _LivePlaybackFailure(
        message: failure.message,
        retrying: true,
      );
    }
    setState(() {
      _isSwitching = true;
      _currentChannelId = channel.id;
      _currentChannelName = channel.name;
      betterPlayerControlsConfiguration =
          _buildControlsConfiguration(channel.name);
      _betterPlayerController.setBetterPlayerControlsConfiguration(
        betterPlayerControlsConfiguration,
      );
    });
    _showBanner('Switching to ${channel.name}…');
    final stopwatch = Stopwatch()..start();
    widget.analytics.trackLiveTVInteraction(
      surface: widget.analyticsSurface,
      action: 'channel_switch_requested',
      value: 'player',
    );
    try {
      final stream = await service.getStream(channel.id);
      if (!mounted) return;
      await _betterPlayerController.setupDataSource(
        _buildDataSource(stream.url, stream.headers),
      );
      if (!mounted) return;
      _currentVideoUrl = stream.url;
      _currentVideoHeaders = Map<String, String>.of(stream.headers);
      setState(() {
        _isSwitching = false;
      });
      _finishPlaybackRecovery();
      _channelSwitchCount++;
      widget.analytics.trackLiveTVChannelView(
        channelName: channel.name,
        streamId: channel.id,
      );
      widget.analytics.trackLiveTVStreamResolution(
        surface: widget.analyticsSurface,
        channelId: channel.id,
        channelName: channel.name,
        outcome: 'success',
        durationMs: stopwatch.elapsedMilliseconds,
        source: 'player_switcher',
      );
      widget.onChannelSwitch?.call(channel);
      _showBanner(channel.name);
    } catch (error) {
      widget.analytics.trackLiveTVStreamResolution(
        surface: widget.analyticsSurface,
        channelId: channel.id,
        channelName: channel.name,
        outcome: 'error',
        durationMs: stopwatch.elapsedMilliseconds,
        source: 'player_switcher',
        error: error.toString(),
      );
      if (!mounted) return;
      setState(() => _isSwitching = false);
      _beginPlaybackRecovery(
        'Unable to switch channel: ${error.toString()}',
      );
    }
  }

  void _showBanner(String text) {
    _bannerTimer?.cancel();
    setState(() => _bannerText = text);
    _bannerTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _bannerText = null);
    });
  }

  @override
  void dispose() {
    final suppressionId = _occasionalEffectsSuppressionId;
    if (suppressionId != null) {
      _occasionalEffectsSuppressionId = null;
      // Do not reveal the app-level particle canvas over the outgoing player
      // transition. Nested scopes keep replacement players suppressed.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _appDependencies.releaseOccasionalEffectsSuppression(suppressionId);
      });
    }
    _bannerTimer?.cancel();
    _cancelPlaybackRecovery();
    _betterPlayerController.removeEventsListener(_onPlayerEvent);
    _playbackFailure.dispose();
    _stopWatchClock();
    final bufferingStartedAt = _bufferingStartedAt;
    if (bufferingStartedAt != null) {
      _bufferingMs +=
          DateTime.now().difference(bufferingStartedAt).inMilliseconds;
    }
    widget.analytics.trackLiveTVSessionEnded(
      surface: widget.analyticsSurface,
      sessionId: _sessionId,
      channelId: _currentChannelId ?? 'unknown',
      channelName: _currentChannelName,
      durationMs: _sessionElapsedMs,
      watchedMs: _watchedMs,
      bufferingMs: _bufferingMs,
      bufferCount: _bufferCount,
      channelSwitchCount: _channelSwitchCount,
    );
    _betterPlayerController.dispose();
    _introService.close();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (widget.useTvControls && _tvControlsController.handleBack()) return;
        _exitPlayer();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: BetterPlayer(
                    key: _betterPlayerKey,
                    controller: _betterPlayerController,
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: AnimatedSlide(
                        offset: _bannerText == null
                            ? const Offset(0, -2)
                            : Offset.zero,
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        child: AnimatedOpacity(
                          opacity: _bannerText == null ? 0 : 1,
                          duration: const Duration(milliseconds: 240),
                          child: Material(
                            color: Colors.black.withValues(alpha: .78),
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  if (_isSwitching)
                                    const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  else
                                    Icon(
                                      PhosphorIcons.broadcast(
                                        PhosphorIconsStyle.fill,
                                      ),
                                      size: 18,
                                      color: widget.colors.first,
                                    ),
                                  const SizedBox(width: 9),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              .62,
                                    ),
                                    child: Text(
                                      _bannerText ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'FigtreeSB',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _exitPlayer() {
    Navigator.of(context).pop();
  }
}

class _ChannelSwitcherSheet extends StatefulWidget {
  const _ChannelSwitcherSheet({
    required this.channels,
    required this.currentChannelId,
  });

  final List<Channel> channels;
  final String? currentChannelId;

  @override
  State<_ChannelSwitcherSheet> createState() => _ChannelSwitcherSheetState();
}

class _ChannelSwitcherSheetState extends State<_ChannelSwitcherSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tokens = searchTokens(_query);
    final filtered = tokens.isEmpty
        ? widget.channels
        : widget.channels
            .where(
              (channel) => normalizeSearchText(
                '${channel.name} ${channel.id}',
              ).contains(tokens.join(' ')),
            )
            .toList(growable: false);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    PhosphorIcons.televisionSimple(),
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Channels',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.channels.length} channels • tap to switch',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search channels',
                prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: Icon(PhosphorIcons.x()),
                      ),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final channel = filtered[index];
                final isCurrent = channel.id == widget.currentChannelId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: isCurrent
                        ? colors.primary.withValues(alpha: .14)
                        : colors.surfaceContainerHighest.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.pop(context, channel),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    channel.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  if (channel.nowPlaying != null ||
                                      channel
                                          .categories.isNotEmpty) ...<Widget>[
                                    const SizedBox(height: 3),
                                    Text(
                                      channel.nowPlaying ??
                                          channel.categories.join(' • '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: channel.nowPlaying != null
                                                ? colors.primary
                                                : colors.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              isCurrent
                                  ? PhosphorIcons.playCircle(
                                      PhosphorIconsStyle.fill,
                                    )
                                  : PhosphorIcons.circle(),
                              size: 22,
                              color: isCurrent
                                  ? colors.primary
                                  : colors.outlineVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LivePlaybackFailure {
  const _LivePlaybackFailure({required this.message, this.retrying = false});

  final String message;
  final bool retrying;
}

class _LivePlayerErrorOverlay extends StatelessWidget {
  const _LivePlayerErrorOverlay({
    required this.message,
    required this.retrying,
    required this.onRetry,
    this.onChannels,
  });

  final String message;
  final bool retrying;
  final VoidCallback onRetry;
  final VoidCallback? onChannels;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: Colors.black.withValues(alpha: .86),
      child: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: .16),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: retrying
                      ? SizedBox.square(
                          dimension: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: colors.primary,
                          ),
                        )
                      : Icon(
                          PhosphorIcons.warningCircle(),
                          color: colors.error,
                          size: 30,
                        ),
                ),
                const SizedBox(height: 18),
                Text(
                  retrying ? 'Reconnecting…' : 'Channel unavailable',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'FigtreeSB',
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  retrying
                      ? 'Resolving a fresh stream for this channel.'
                      : message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: retrying ? null : onRetry,
                      icon: Icon(PhosphorIcons.arrowClockwise()),
                      label: const Text('Retry'),
                    ),
                    if (onChannels != null)
                      OutlinedButton.icon(
                        onPressed: retrying ? null : onChannels,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                        ),
                        icon: Icon(PhosphorIcons.televisionSimple()),
                        label: const Text('Choose channel'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
