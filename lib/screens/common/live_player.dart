import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LivePlayer extends StatefulWidget {
  const LivePlayer({required this.sources, required this.colors, Key? key})
      : super(key: key);
  final Map<String, String> sources;
  final List<Color> colors;

  @override
  State<LivePlayer> createState() => _LivePlayerState();
}

class _LivePlayerState extends State<LivePlayer> {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerControlsConfiguration betterPlayerControlsConfiguration;
  late BetterPlayerBufferingConfiguration betterPlayerBufferingConfiguration;

  @override
  void initState() {
    super.initState();

    betterPlayerBufferingConfiguration =
        const BetterPlayerBufferingConfiguration(
      maxBufferMs: 120000,
      minBufferMs: 15000,
    );
    betterPlayerControlsConfiguration = BetterPlayerControlsConfiguration(
      enableFullscreen: true,
      backgroundColor: widget.colors.elementAt(1).withOpacity(0.6),
      progressBarBackgroundColor: Colors.white,
      pauseIcon: Icons.pause_outlined,
      pipMenuIcon: Icons.picture_in_picture_sharp,
      playIcon: Icons.play_arrow_sharp,
      showControlsOnInitialize: true,
      loadingColor: widget.colors.first,
      iconsColor: widget.colors.first,
      progressBarPlayedColor: widget.colors.first,
      progressBarBufferedColor: Colors.black45,
    );

    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
            autoDetectFullscreenDeviceOrientation: true,
            //  fullScreenByDefault: true,
            looping: true,
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

    // String keyToFind = widget.videoProperties.elementAt(2) == 0
    //     ? 'auto'
    //     : widget.videoProperties.elementAt(2).toString();
    // String link = widget.sources.entries
    //     .where((entry) => entry.key == keyToFind)
    //     .map((entry) => entry.value)
    //     .first;

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, widget.sources.entries.first.value,
        resolutions: widget.sources,
        liveStream: true,
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
      if (_betterPlayerController.videoPlayerController!.value.aspectRatio >
          1.0) {
        _betterPlayerController.enterFullScreen();
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: _betterPlayerController
                .videoPlayerController!.value.aspectRatio,
            child: BetterPlayer(
              controller: _betterPlayerController,
            ),
          ),
        ),
      ),
    );
  }
}
