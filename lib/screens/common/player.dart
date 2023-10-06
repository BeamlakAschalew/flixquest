import 'dart:async';

import 'package:cinemax/constants/app_constants.dart';
import 'package:cinemax/controllers/recently_watched_database_controller.dart';
import 'package:cinemax/models/recently_watched.dart';
import 'package:cinemax/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:better_player/better_player.dart';
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
      Key? key})
      : super(key: key);
  final Map<String, String> sources;
  final List<BetterPlayerSubtitlesSource> subs;
  final List<Color> colors;
  final SettingsProvider settings;
  final List? movieMetadata;
  final List? tvMetadata;
  final MediaType? mediaType;

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
  late Timer _timer;
  bool isVideoPaused = false;

  void updateTotalMinutesStreamed(int minutes, Mixpanel mixpanel) async {
    mixpanel.registerSuperProperties({"Total minutes streamed": minutes});
  }

  @override
  void initState() {
    final mixpanel =
        Provider.of<SettingsProvider>(context, listen: false).mixpanel;
    super.initState();
    String backgroundColorString = widget.settings.subtitleBackgroundColor;
    String foregroundColorString = widget.settings.subtitleForegroundColor;
    String hexColorBackground =
        backgroundColorString.replaceAll("Color(0x", "").replaceAll(")", "");
    String hexColorForeground =
        foregroundColorString.replaceAll("Color(0x", "").replaceAll(")", "");

    Color backgroundColor = Color(int.parse("0x$hexColorBackground"));
    Color foregroundColor = Color(int.parse("0x$hexColorForeground"));

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
      name: widget.mediaType == MediaType.movie
          ? "${widget.movieMetadata!.elementAt(1)} (${widget.movieMetadata!.elementAt(3)})"
          : "${widget.tvMetadata!.elementAt(1)} | ${widget.tvMetadata!.elementAt(2)} | ${episodeSeasonFormatter(widget.tvMetadata!.elementAt(3), widget.tvMetadata!.elementAt(4))}",
      backgroundColor: widget.colors.elementAt(1).withOpacity(0.6),
      progressBarBackgroundColor: Colors.white,
      controlBarColor: Colors.black.withOpacity(0.3),
      muteIcon: Icons.volume_off_rounded,
      unMuteIcon: Icons.volume_up_rounded,
      pauseIcon: Icons.pause_rounded,
      pipMenuIcon: Icons.picture_in_picture_rounded,
      playIcon: Icons.play_arrow_rounded,
      showControlsOnInitialize: false,
      loadingColor: widget.colors.first,
      iconsColor: widget.colors.first,
      backwardSkipTimeInMilliseconds:
          Duration(seconds: widget.settings.defaultSeekDuration).inMilliseconds,
      forwardSkipTimeInMilliseconds:
          Duration(seconds: widget.settings.defaultSeekDuration).inMilliseconds,
      progressBarPlayedColor: widget.colors.first,
      progressBarBufferedColor: Colors.black45,
      skipForwardIcon: FontAwesomeIcons.rotateRight,
      skipBackIcon: FontAwesomeIcons.rotateLeft,
      fullscreenEnableIcon: Icons.fullscreen_rounded,
      fullscreenDisableIcon: Icons.fullscreen_exit_rounded,
      overflowMenuIcon: Icons.menu_rounded,
      subtitlesIcon: Icons.closed_caption_rounded,
      qualitiesIcon: Icons.hd_rounded,
      enableAudioTracks: false,
    );

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
            subtitlesConfiguration: BetterPlayerSubtitlesConfiguration(
                backgroundColor: backgroundColor,
                fontFamily: 'Poppins',
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
            cacheConfiguration: const BetterPlayerCacheConfiguration(
              useCache: true,
              preCacheSize: 471859200 * 471859200,
              maxCacheSize: 1073741824 * 1073741824,
              maxCacheFileSize: 471859200 * 471859200,

              ///Android only option to use cached video between app sessions
              key: "testCacheKey",
            ),
            bufferingConfiguration: betterPlayerBufferingConfiguration);
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource).then((value) {
      _betterPlayerController.videoPlayerController!.seekTo(Duration(
          seconds: widget.mediaType == MediaType.movie
              ? widget.movieMetadata!.elementAt(5)
              : widget.tvMetadata!.elementAt(6)));
      duration = _betterPlayerController
          .videoPlayerController!.value.duration!.inSeconds;
    });
    _betterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!isVideoPaused) {
        setState(() {
          totalMinutesWatched++;
        });

        mixpanel.registerSuperProperties(
            {'Total Minutes Streamed': totalMinutesWatched});
      }
    });

    _betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        _timer.cancel();
      }
    });
  }

  Future<void> insertRecentMovieData() async {
    print("INSERT CALLEDDDDDDDDDDD");
    int elapsed = await _betterPlayerController.videoPlayerController!.position
        .then((value) => value!.inSeconds);

    int remaining = duration - elapsed;
    String dt = DateTime.now().toString();

    var isBookmarked = await recentlyWatchedMoviesController
        .contain(widget.movieMetadata!.elementAt(0));
    dynamic prv;
    if (mounted) {
      prv = Provider.of<RecentProvider>(context, listen: false);
    }

    RecentMovie rMov = RecentMovie(
        dateTime: dt,
        elapsed: elapsed,
        id: widget.movieMetadata!.elementAt(0),
        posterPath: widget.movieMetadata!.elementAt(2),
        releaseYear: widget.movieMetadata!.elementAt(3),
        remaining: remaining,
        title: widget.movieMetadata!.elementAt(1),
        backdropPath: widget.movieMetadata!.elementAt(4));

    double percentage = (elapsed / duration) * 100;

    if (!isBookmarked) {
      prv.addMovie(rMov);
    } else {
      if (percentage <= 85) {
        prv.updateMovie(rMov, widget.movieMetadata!.elementAt(0));
      } else {
        prv.deleteMovie(widget.movieMetadata!.elementAt(0));
      }
    }
  }

  Future<void> insertRecentEpisodeData() async {
    int elapsed = await _betterPlayerController.videoPlayerController!.position
        .then((value) => value!.inSeconds);

    int remaining = duration - elapsed;
    String dt = DateTime.now().toString();

    var isBookmarked = await recentlyWatchedEpisodeController
        .contain(widget.tvMetadata!.elementAt(0));

    dynamic prv;
    if (mounted) {
      prv = Provider.of<RecentProvider>(context, listen: false);
    }

    RecentEpisode rEpisode = RecentEpisode(
        dateTime: dt,
        elapsed: elapsed,
        id: widget.tvMetadata!.elementAt(0),
        posterPath: widget.tvMetadata!.elementAt(5),
        remaining: remaining,
        seriesName: widget.tvMetadata!.elementAt(1),
        episodeName: widget.tvMetadata!.elementAt(2),
        episodeNum: widget.tvMetadata!.elementAt(3),
        seasonNum: widget.tvMetadata!.elementAt(4),
        seriesId: widget.tvMetadata!.elementAt(7));

    double percentage = (elapsed / duration) * 100;
    if (!isBookmarked) {
      prv.addEpisode(rEpisode);
    } else {
      if (percentage <= 85) {
        prv.updateEpisode(rEpisode, widget.tvMetadata!.elementAt(0),
            widget.tvMetadata!.elementAt(3), widget.tvMetadata!.elementAt(4));
      } else {
        prv.deleteEpisode(widget.tvMetadata!.elementAt(0),
            widget.tvMetadata!.elementAt(3), widget.tvMetadata!.elementAt(4));
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_betterPlayerController.isVideoInitialized()!) {
          widget.mediaType == MediaType.movie
              ? insertRecentMovieData()
              : insertRecentEpisodeData();
        }
        return true;
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
                        sources: widget.sources,
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
