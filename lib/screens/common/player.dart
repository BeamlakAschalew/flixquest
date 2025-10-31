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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Season ${widget.tvMetadata!.seasonNumber} Episodes',
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
                        onTap: () {
                          if (!isCurrentEpisode &&
                              widget.onEpisodeChange != null) {
                            Navigator.pop(context);
                            widget.onEpisodeChange!(
                              episode.episodeId,
                              episode.episodeNumber,
                              episode.seasonNumber,
                            );
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
                // Trigger next episode
                if (widget.onEpisodeChange != null) {
                  widget.onEpisodeChange!(
                    nextEpisode.episodeId,
                    nextEpisode.episodeNumber,
                    nextEpisode.seasonNumber,
                  );
                }
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
                  onPressed: () {
                    dismissed = true;
                    countdownTimer?.cancel();
                    Navigator.of(dialogContext).pop();
                    // Trigger next episode immediately
                    if (widget.onEpisodeChange != null) {
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
        body: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: BetterPlayer(
              controller: _betterPlayerController,
              key: _betterPlayerKey,
            ),
          ),
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
