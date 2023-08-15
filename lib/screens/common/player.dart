import 'package:better_player/better_player.dart';
import 'package:cinemax/controllers/recently_watched_database_controller.dart';
import 'package:cinemax/models/recently_watched.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayerOne extends StatefulWidget {
  const PlayerOne(
      {required this.sources,
      required this.thumbnail,
      required this.subs,
      required this.colors,
      required this.videoProperties,
      required this.metadata,
      Key? key})
      : super(key: key);
  final Map<String, String> sources;
  final List<BetterPlayerSubtitlesSource> subs;
  final String? thumbnail;
  final List<Color> colors;
  final List videoProperties;
  final List metadata;

  @override
  State<PlayerOne> createState() => _PlayerOneState();
}

class _PlayerOneState extends State<PlayerOne> {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerControlsConfiguration betterPlayerControlsConfiguration;
  late BetterPlayerBufferingConfiguration betterPlayerBufferingConfiguration;
  RecentlyWatchedMoviesController recentlyWatchedMoviesController =
      RecentlyWatchedMoviesController();
  late int duration;

  @override
  void initState() {
    super.initState();

    betterPlayerBufferingConfiguration = BetterPlayerBufferingConfiguration(
      maxBufferMs: widget.videoProperties.first,
      minBufferMs: 15000,
    );
    betterPlayerControlsConfiguration = BetterPlayerControlsConfiguration(
      enableFullscreen: true,
      backgroundColor: widget.colors.elementAt(1).withOpacity(0.6),
      progressBarBackgroundColor: Colors.white,
      pauseIcon: Icons.pause_outlined,
      pipMenuIcon: Icons.picture_in_picture_sharp,
      playIcon: Icons.play_arrow_sharp,
      showControlsOnInitialize: false,
      loadingColor: widget.colors.first,
      iconsColor: widget.colors.first,
      backwardSkipTimeInMilliseconds:
          Duration(seconds: widget.videoProperties.elementAt(1)).inMilliseconds,
      forwardSkipTimeInMilliseconds:
          Duration(seconds: widget.videoProperties.elementAt(1)).inMilliseconds,
      progressBarPlayedColor: widget.colors.first,
      progressBarBufferedColor: Colors.black45,
    );

    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
            autoDetectFullscreenDeviceOrientation: true,
            fullScreenByDefault: widget.videoProperties.elementAt(3),
            autoPlay: true,
            fit: BoxFit.contain,
            autoDispose: true,
            controlsConfiguration: betterPlayerControlsConfiguration,
            showPlaceholderUntilPlay: true,
            subtitlesConfiguration: const BetterPlayerSubtitlesConfiguration(
                backgroundColor: Colors.black45,
                fontFamily: 'Poppins',
                fontColor: Colors.white,
                outlineEnabled: false,
                fontSize: 17));

    String keyToFind = widget.videoProperties.elementAt(2) == 0
        ? 'auto'
        : widget.videoProperties.elementAt(2).toString();
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
    _betterPlayerController.setupDataSource(dataSource).then((value) =>
        duration = _betterPlayerController
            .videoPlayerController!.value.duration!.inSeconds);
  }

  Future<void> getMovieData() async {
    int elapsed = await _betterPlayerController.videoPlayerController!.position
        .then((value) => value!.inSeconds);

    int remaining = duration - elapsed;
    String dt = DateTime.now().toString();

    bool isBookmarked = false;

    var iB = await recentlyWatchedMoviesController
        .contain(widget.metadata.elementAt(0));

    if (!iB) {
      recentlyWatchedMoviesController
          .insertMovie(RecentMovie(
              dateTime: dt,
              elapsed: elapsed,
              id: widget.metadata.elementAt(0),
              posterPath: widget.metadata.elementAt(2),
              releaseYear: widget.metadata.elementAt(3),
              remaining: remaining,
              title: widget.metadata.elementAt(1)))
          .then((value) => print(value));
    } else {
      print('Existssss');
      recentlyWatchedMoviesController.updateMovie(
          RecentMovie(
              dateTime: dt,
              elapsed: elapsed,
              id: widget.metadata.elementAt(0),
              posterPath: widget.metadata.elementAt(2),
              releaseYear: widget.metadata.elementAt(3),
              remaining: remaining,
              title: widget.metadata.elementAt(1)),
          widget.metadata.elementAt(0));
    }
  }

  @override
  void dispose() {
    _betterPlayerController.isVideoInitialized()! ? getMovieData() : '';
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.metadata.elementAt(0));
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: BetterPlayer(
            controller: _betterPlayerController,
          ),
        ),
      ),
    );
  }
}
