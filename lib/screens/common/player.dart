// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flixquest/models/tv_stream_metadata.dart';

import '../../models/movie_stream_metadata.dart';
import '/constants/app_constants.dart';
import '/controllers/recently_watched_database_controller.dart';
import '/models/recently_watched.dart';
import '/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:better_player_plus/better_player.dart';
import '../../functions/function.dart';
import '../../provider/recently_watched_provider.dart';
import '../../provider/settings_provider.dart';
import '../../provider/app_dependency_provider.dart';
import '../../api/endpoints.dart';
import '../../functions/network.dart';

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

  @override
  State<PlayerOne> createState() => _PlayerOneState();
}

class _PlayerOneState extends State<PlayerOne> with WidgetsBindingObserver {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerControlsConfiguration betterPlayerControlsConfiguration;
  late BetterPlayerBufferingConfiguration betterPlayerBufferingConfiguration;
  RecentlyWatchedMoviesController recentlyWatchedMoviesController =
      RecentlyWatchedMoviesController();
  RecentlyWatchedEpisodeController recentlyWatchedEpisodeController =
      RecentlyWatchedEpisodeController();
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
  bool _nextEpisodeButtonDismissed = false;
  Timer? _progressCheckTimer;
  OverlayEntry? _nextEpisodeOverlay;

  late SettingsProvider settings;

  @override
  void initState() {
    settings = Provider.of<SettingsProvider>(context, listen: false);
    super.initState();
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
          _showEpisodeSelectionBottomSheet();
        },
        enableMovieRecommendations: widget.mediaType == MediaType.movie &&
            widget.movieMetadata?.recommendations != null &&
            widget.movieMetadata!.recommendations!.isNotEmpty,
        onMovieRecommendationsTap: () {
          _showMovieRecommendationsBottomSheet();
        },
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
        playerTimeMode: settings.playerTimeDisplay);
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

          // Show button at 85% progress if there's a next episode, in fullscreen, and not manually dismissed
          if (progress >= 0.85 &&
              !_showNextEpisodeButton &&
              !_nextEpisodeButtonDismissed &&
              _hasNextEpisode() &&
              isFullScreen) {
            _showNextEpisodeButton = true;
            _showNextEpisodeOverlay();
          } else if ((progress < 0.85 || !isFullScreen) &&
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
      builder: (context) => _buildNextEpisodeFloatingButton(),
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
    int elapsed = await _betterPlayerController.videoPlayerController!.position
        .then((value) => value!.inSeconds);

    int remaining = duration - elapsed;
    String dt = DateTime.now().toString();

    var isBookmarked = await recentlyWatchedMoviesController
        .contain(widget.movieMetadata!.movieId!);
    dynamic prv;
    if (mounted) {
      prv = Provider.of<RecentProvider>(context, listen: false);
    }

    RecentMovie rMov = RecentMovie(
        dateTime: dt,
        elapsed: elapsed,
        id: widget.movieMetadata!.movieId!,
        posterPath: widget.movieMetadata!.posterPath!,
        releaseYear: widget.movieMetadata!.releaseYear!,
        remaining: remaining,
        title: widget.movieMetadata!.movieName,
        backdropPath: widget.movieMetadata!.backdropPath!);

    double percentage = (elapsed / duration) * 100;

    if (!isBookmarked) {
      prv.addMovie(rMov);
    } else {
      if (percentage <= 85) {
        prv.updateMovie(rMov, widget.movieMetadata!.movieId!);
      } else {
        prv.deleteMovie(widget.movieMetadata!.movieId!);
      }
    }
  }

  Future<void> insertRecentEpisodeData() async {
    int elapsed = await _betterPlayerController.videoPlayerController!.position
        .then((value) => value!.inSeconds);

    int remaining = duration - elapsed;
    String dt = DateTime.now().toString();

    var isBookmarked = await recentlyWatchedEpisodeController
        .contain(widget.tvMetadata!.episodeId!);

    dynamic prv;
    if (mounted) {
      prv = Provider.of<RecentProvider>(context, listen: false);
    }

    RecentEpisode rEpisode = RecentEpisode(
        dateTime: dt,
        elapsed: elapsed,
        id: widget.tvMetadata!.episodeId!,
        posterPath: widget.tvMetadata!.posterPath!,
        remaining: remaining,
        seriesName: widget.tvMetadata!.seriesName!,
        episodeName: widget.tvMetadata!.episodeName!,
        episodeNum: widget.tvMetadata!.episodeNumber!,
        seasonNum: widget.tvMetadata!.seasonNumber!,
        seriesId: widget.tvMetadata!.tvId!);

    double percentage = (elapsed / duration) * 100;
    if (!isBookmarked) {
      prv.addEpisode(rEpisode);
    } else {
      if (percentage <= 85) {
        prv.updateEpisode(
            rEpisode,
            widget.tvMetadata!.episodeId!,
            widget.tvMetadata!.episodeNumber!,
            widget.tvMetadata!.seasonNumber!);
      } else {
        prv.deleteEpisode(
            widget.tvMetadata!.episodeId!,
            widget.tvMetadata!.episodeNumber!,
            widget.tvMetadata!.seasonNumber!);
      }
    }
  }

  /// Handles saving progress and analytics before switching to a new episode/movie
  Future<void> _handleContentSwitch() async {
    // Save current playback progress
    if (widget.mediaType == MediaType.movie) {
      await insertRecentMovieData();
    } else {
      await insertRecentEpisodeData();
    }

    // Send analytics for current viewing session
    updateAndLogTotalStreamingDuration(playbackDurationInSeconds);

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

  void _showEpisodeSelectionBottomSheet() {
    if (widget.mediaType != MediaType.tvShow ||
        widget.tvMetadata?.seasonEpisodes == null ||
        widget.tvMetadata!.seasonEpisodes!.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Back button to season selector (if multiple seasons available)
                  if (widget.tvMetadata!.allSeasons != null &&
                      widget.tvMetadata!.allSeasons!.length > 1)
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                        _showSeasonSelectionBottomSheet();
                      },
                    )
                  else
                    SizedBox(width: 60),
                  Expanded(
                    child: Text(
                      'Season ${widget.tvMetadata!.seasonNumber} Episodes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            // Episode List
            Expanded(
              child: Consumer<RecentProvider>(
                builder: (context, recentProvider, child) {
                  return ListView.builder(
                    itemCount: widget.tvMetadata!.seasonEpisodes!.length,
                    itemBuilder: (context, index) {
                      final episode = widget.tvMetadata!.seasonEpisodes![index];
                      final isCurrentEpisode = episode.episodeNumber ==
                          widget.tvMetadata!.episodeNumber;

                      // Check if episode is in recently watched
                      final recentEpisode = recentProvider.episodes.firstWhere(
                        (e) => e.id == episode.episodeId,
                        orElse: () => RecentEpisode(
                          dateTime: '',
                          elapsed: 0,
                          id: 0,
                          posterPath: '',
                          remaining: 0,
                          seriesName: '',
                          episodeName: '',
                          episodeNum: 0,
                          seasonNum: 0,
                          seriesId: 0,
                        ),
                      );

                      final hasProgress = recentEpisode.id != 0;
                      final progressPercentage =
                          hasProgress && recentEpisode.elapsed! > 0
                              ? (recentEpisode.elapsed! /
                                      (recentEpisode.elapsed! +
                                          recentEpisode.remaining!)) *
                                  100
                              : 0.0;

                      return InkWell(
                        onTap: () async {
                          if (!isCurrentEpisode &&
                              widget.onEpisodeChange != null) {
                            // Save progress and send analytics before switching
                            await _handleContentSwitch();

                            if (mounted) {
                              // Close the bottom sheet first
                              Navigator.pop(context);
                              // Then trigger the callback to load new episode
                              widget.onEpisodeChange!(
                                episode.episodeId,
                                episode.episodeNumber,
                                episode.seasonNumber,
                              );
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrentEpisode
                                ? widget.colors.first.withOpacity(0.1)
                                : null,
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Episode thumbnail
                                Stack(
                                  children: [
                                    Container(
                                      width: 140,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[800],
                                      ),
                                      child: episode.stillPath != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                'https://image.tmdb.org/t/p/w300${episode.stillPath}',
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Center(
                                                    child: Icon(
                                                      Icons.movie,
                                                      color: Colors.grey[600],
                                                      size: 32,
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : Center(
                                              child: Icon(
                                                Icons.movie,
                                                color: Colors.grey[600],
                                                size: 32,
                                              ),
                                            ),
                                    ),
                                    // Progress bar
                                    if (hasProgress && progressPercentage > 0)
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 3,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                            ),
                                          ),
                                          child: LinearProgressIndicator(
                                            value: progressPercentage / 100,
                                            backgroundColor: Colors.grey[700],
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              widget.colors.first,
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Current episode indicator
                                    if (isCurrentEpisode)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: widget.colors.first,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Playing',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(width: 12),
                                // Episode info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${episode.episodeNumber}. ${episode.episodeName}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isCurrentEpisode
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (episode.runtime != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            '${episode.runtime}m',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                        ),
                                      if (episode.overview != null &&
                                          episode.overview!.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            episode.overview!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSeasonSelectionBottomSheet() {
    if (widget.tvMetadata?.allSeasons == null ||
        widget.tvMetadata!.allSeasons!.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Season',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            // Season List
            Expanded(
              child: ListView.builder(
                itemCount: widget.tvMetadata!.allSeasons!.length,
                itemBuilder: (context, index) {
                  final season = widget.tvMetadata!.allSeasons![index];
                  final isCurrentSeason =
                      season.seasonNumber == widget.tvMetadata!.seasonNumber;

                  return InkWell(
                    onTap: () async {
                      if (!isCurrentSeason) {
                        // Close season selector first
                        Navigator.pop(context);

                        // Show loading indicator and store the dialog context
                        final loadingContext = this.context;
                        showDialog(
                          context: loadingContext,
                          barrierDismissible: false,
                          builder: (dialogContext) => Center(
                            child: CircularProgressIndicator(
                              color: widget.colors.first,
                            ),
                          ),
                        );

                        // Fetch episodes for the selected season
                        await _fetchEpisodesForSeason(season.seasonNumber);

                        // Close loading dialog using the correct context
                        if (mounted && Navigator.canPop(loadingContext)) {
                          Navigator.of(loadingContext).pop();
                        }

                        // Show episode list for the new season
                        if (mounted) {
                          _showEpisodeSelectionBottomSheet();
                        }
                      } else {
                        // Already on this season, just go back to episode list
                        Navigator.pop(context);
                        _showEpisodeSelectionBottomSheet();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrentSeason
                            ? widget.colors.first.withOpacity(0.1)
                            : null,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Season poster
                            if (season.posterPath != null)
                              Container(
                                width: 60,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[800],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'https://image.tmdb.org/t/p/w185${season.posterPath}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.tv,
                                          color: Colors.grey[600],
                                          size: 32,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 60,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[800],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.tv,
                                    color: Colors.grey[600],
                                    size: 32,
                                  ),
                                ),
                              ),
                            SizedBox(width: 16),
                            // Season info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    season.seasonName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isCurrentSeason
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${season.episodeCount} Episodes',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  if (season.overview != null &&
                                      season.overview!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        season.overview!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isCurrentSeason)
                              Icon(
                                Icons.check_circle,
                                color: widget.colors.first,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchEpisodesForSeason(int seasonNumber) async {
    try {
      final isProxyEnabled =
          Provider.of<SettingsProvider>(context, listen: false).enableProxy;
      final proxyUrl =
          Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;

      await fetchTVDetails(
        Endpoints.getSeasonDetails(
          widget.tvMetadata!.tvId!,
          seasonNumber,
          'en',
        ),
        isProxyEnabled,
        proxyUrl,
      ).then((value) {
        if (value.episodes != null && value.episodes!.isNotEmpty) {
          setState(() {
            widget.tvMetadata!.seasonNumber = seasonNumber;
            widget.tvMetadata!.seasonEpisodes = value.episodes!
                .map((episode) => EpisodeMetadata.fromEpisodeList(episode))
                .toList();
          });
        }
      });
    } catch (e) {
      debugPrint('Failed to fetch episodes for season $seasonNumber: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load season episodes'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMovieRecommendationsBottomSheet() {
    if (widget.movieMetadata?.recommendations == null ||
        widget.movieMetadata!.recommendations!.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended Movies',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            // Movie List
            Expanded(
              child: ListView.builder(
                itemCount: widget.movieMetadata!.recommendations!.length,
                itemBuilder: (context, index) {
                  final movie = widget.movieMetadata!.recommendations![index];

                  return InkWell(
                    onTap: () {
                      // Close the bottom sheet
                      Navigator.pop(context);
                      // Show a message that movie loading will be implemented
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Loading ${movie.title}...'),
                          backgroundColor: widget.colors.first,
                        ),
                      );
                      // TODO: Implement movie switching similar to episode switching
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Movie poster
                            Container(
                              width: 100,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[800],
                              ),
                              child: movie.posterPath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        'https://image.tmdb.org/t/p/w300${movie.posterPath}',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              Icons.movie,
                                              color: Colors.grey[600],
                                              size: 40,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.movie,
                                        color: Colors.grey[600],
                                        size: 40,
                                      ),
                                    ),
                            ),
                            SizedBox(width: 12),
                            // Movie info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'FigtreeSB',
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  if (movie.releaseDate != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        movie.releaseDate!.split('-')[0],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Figtree',
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                  if (movie.voteAverage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${movie.voteAverage!.toStringAsFixed(1)}/10',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontFamily: 'Figtree',
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (movie.overview != null &&
                                      movie.overview!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        movie.overview!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Figtree',
                                          color: Colors.grey[500],
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
        _showNextEpisodeCountdown(nextEpisode);
      }
    } else if (widget.mediaType == MediaType.movie) {
      debugPrint(
          'Movie finished. Recommendations: ${widget.movieMetadata?.recommendations?.length ?? 0}');
      if (widget.movieMetadata?.recommendations != null &&
          widget.movieMetadata!.recommendations!.isNotEmpty) {
        // Show recommended movie countdown
        _showRecommendedMovieCountdown();
      } else {
        debugPrint('No recommendations available for this movie');
      }
    }
  }

  void _showNextEpisodeCountdown(EpisodeMetadata nextEpisode) {
    int countdown = 10; // 10 second countdown
    Timer? countdownTimer;
    bool dismissed = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
              if (countdown > 0 && !dismissed) {
                setDialogState(() {
                  countdown--;
                });
              } else if (countdown == 0 && !dismissed) {
                timer.cancel();
                if (Navigator.canPop(dialogContext)) {
                  Navigator.of(dialogContext).pop();
                }
                // Save progress and send analytics before switching
                _handleContentSwitch().then((_) {
                  // Trigger next episode
                  if (widget.onEpisodeChange != null && mounted) {
                    widget.onEpisodeChange!(
                      nextEpisode.episodeId,
                      nextEpisode.episodeNumber,
                      nextEpisode.seasonNumber,
                    );
                  }
                });
              }
            });

            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Next Episode',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${nextEpisode.episodeNumber}. ${nextEpisode.episodeName}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (nextEpisode.overview != null &&
                      nextEpisode.overview!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        nextEpisode.overview!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Playing in $countdown seconds...',
                      style: TextStyle(
                        color: widget.colors.first,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    dismissed = true;
                    countdownTimer?.cancel();
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    dismissed = true;
                    countdownTimer?.cancel();
                    Navigator.of(dialogContext).pop();
                    // Save progress and send analytics before switching
                    await _handleContentSwitch();
                    // Trigger next episode immediately
                    if (widget.onEpisodeChange != null && mounted) {
                      widget.onEpisodeChange!(
                        nextEpisode.episodeId,
                        nextEpisode.episodeNumber,
                        nextEpisode.seasonNumber,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.colors.first,
                  ),
                  child: Text(
                    'Play Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Dialog dismissed, cancel timer
      dismissed = true;
      countdownTimer?.cancel();
    });
  }

  void _showRecommendedMovieCountdown() {
    if (widget.movieMetadata?.recommendations == null ||
        widget.movieMetadata!.recommendations!.isEmpty) {
      return;
    }

    int countdown = 10; // 10 second countdown
    Timer? countdownTimer;
    bool dismissed = false;
    int selectedIndex = 0; // Track which movie is selected

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
              if (countdown > 0 && !dismissed) {
                setDialogState(() {
                  countdown--;
                });
              } else if (countdown == 0 && !dismissed) {
                timer.cancel();
                if (Navigator.canPop(dialogContext)) {
                  Navigator.of(dialogContext).pop();
                }
                // Trigger next movie (would need to be implemented)
                // For now, just show a message
                if (mounted) {
                  final selectedMovie =
                      widget.movieMetadata!.recommendations![selectedIndex];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Loading ${selectedMovie.title}...'),
                      backgroundColor: widget.colors.first,
                    ),
                  );
                }
              }
            });

            final currentMovie =
                widget.movieMetadata!.recommendations![selectedIndex];

            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Recommended Movies',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'FigtreeBold',
                ),
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie poster
                      if (currentMovie.posterPath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w300${currentMovie.posterPath}',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                color: Colors.grey[800],
                                child: Center(
                                  child: Icon(
                                    Icons.movie,
                                    color: Colors.grey[600],
                                    size: 50,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 12),
                      Text(
                        currentMovie.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'FigtreeSB',
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (currentMovie.voteAverage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${currentMovie.voteAverage!.toStringAsFixed(1)}/10',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Figtree',
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (currentMovie.overview != null &&
                          currentMovie.overview!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            currentMovie.overview!,
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Figtree',
                              color: Colors.grey[400],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Playing in $countdown seconds...',
                          style: TextStyle(
                            color: widget.colors.first,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'FigtreeBold',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Show other recommendations
                      if (widget.movieMetadata!.recommendations!.length >
                          1) ...[
                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 8),
                        Text(
                          'More Recommendations',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'FigtreeSB',
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                widget.movieMetadata!.recommendations!.length,
                            itemBuilder: (context, index) {
                              final movie =
                                  widget.movieMetadata!.recommendations![index];
                              final isSelected = index == selectedIndex;

                              return GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    selectedIndex = index;
                                    countdown = 10; // Reset countdown
                                  });
                                },
                                child: Container(
                                  width: 90,
                                  margin: EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected
                                        ? Border.all(
                                            color: widget.colors.first,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: movie.posterPath != null
                                            ? Image.network(
                                                'https://image.tmdb.org/t/p/w185${movie.posterPath}',
                                                height: 110,
                                                width: 90,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    height: 110,
                                                    width: 90,
                                                    color: Colors.grey[800],
                                                    child: Icon(
                                                      Icons.movie,
                                                      color: Colors.grey[600],
                                                      size: 30,
                                                    ),
                                                  );
                                                },
                                              )
                                            : Container(
                                                height: 110,
                                                width: 90,
                                                color: Colors.grey[800],
                                                child: Icon(
                                                  Icons.movie,
                                                  color: Colors.grey[600],
                                                  size: 30,
                                                ),
                                              ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        movie.title,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'Figtree',
                                          color: isSelected
                                              ? widget.colors.first
                                              : Colors.grey[300],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    dismissed = true;
                    countdownTimer?.cancel();
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'Figtree',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    dismissed = true;
                    countdownTimer?.cancel();
                    Navigator.of(dialogContext).pop();
                    // Trigger selected movie immediately
                    if (mounted) {
                      final selectedMovie =
                          widget.movieMetadata!.recommendations![selectedIndex];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Loading ${selectedMovie.title}...'),
                          backgroundColor: widget.colors.first,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.colors.first,
                  ),
                  child: Text(
                    'Play Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'FigtreeSB',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Dialog dismissed, cancel timer
      dismissed = true;
      countdownTimer?.cancel();
    });
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

  Widget _buildNextEpisodeFloatingButton() {
    if (widget.tvMetadata?.seasonEpisodes == null) {
      return SizedBox.shrink();
    }

    final currentIndex = widget.tvMetadata!.seasonEpisodes!.indexWhere(
      (e) => e.episodeNumber == widget.tvMetadata!.episodeNumber,
    );

    if (currentIndex == -1 ||
        currentIndex >= widget.tvMetadata!.seasonEpisodes!.length - 1) {
      return SizedBox.shrink();
    }

    final nextEpisode = widget.tvMetadata!.seasonEpisodes![currentIndex + 1];

    return Positioned(
      bottom: 100, // Increased padding to not cover progress bar
      right: 16,
      child: AnimatedOpacity(
        opacity: _showNextEpisodeButton ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: () async {
            if (widget.onEpisodeChange != null) {
              // Save progress and send analytics before switching
              await _handleContentSwitch();

              if (mounted) {
                // Trigger next episode
                widget.onEpisodeChange!(
                  nextEpisode.episodeId,
                  nextEpisode.episodeNumber,
                  nextEpisode.seasonNumber,
                );
              }
            }
          },
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.colors.first,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Episode thumbnail
                    if (nextEpisode.stillPath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              'https://image.tmdb.org/t/p/w300${nextEpisode.stillPath}',
                              height: 110,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 110,
                                  color: Colors.grey[800],
                                  child: Center(
                                    child: Icon(
                                      Icons.movie,
                                      color: Colors.grey[600],
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Play icon overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.play_circle_filled,
                                    color: widget.colors.first,
                                    size: 50,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Episode info
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Episode',
                            style: TextStyle(
                              color: widget.colors.first,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'FigtreeBold',
                              letterSpacing: 0.5,
                              decoration:
                                  TextDecoration.none, // Remove any decoration
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${nextEpisode.episodeNumber}. ${nextEpisode.episodeName}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'FigtreeSB',
                              decoration:
                                  TextDecoration.none, // Remove any decoration
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Close button at top right
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      // Hide the next episode button and mark as dismissed
                      _showNextEpisodeButton = false;
                      _nextEpisodeButtonDismissed = true;
                      _hideNextEpisodeOverlay();
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
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
}
