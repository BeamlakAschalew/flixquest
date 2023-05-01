import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:video_viewer/video_viewer.dart';

class PlayerOne extends StatefulWidget {
  const PlayerOne(
      {required this.sources,
      required this.thumbnail,
      required this.subs,
      required this.colors,
      Key? key})
      : super(key: key);
  final Map<String, String> sources;
  final List<BetterPlayerSubtitlesSource> subs;
  final String? thumbnail;
  final List<Color> colors;

  @override
  State<PlayerOne> createState() => _PlayerOneState();
}

class _PlayerOneState extends State<PlayerOne> {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerControlsConfiguration betterPlayerControlsConfiguration;
  late BetterPlayerBufferingConfiguration betterPlayerBufferingConfiguration =
      const BetterPlayerBufferingConfiguration(
    maxBufferMs: 240000,
    minBufferMs: 120000,
  );

  @override
  void initState() {
    super.initState();

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
      progressBarBufferedColor: widget.colors.first.withOpacity(0.3),
    );

    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
            autoDetectFullscreenDeviceOrientation: true,
            fullScreenByDefault: true,
            autoPlay: true,
            fit: BoxFit.contain,
            autoDispose: true,
            controlsConfiguration: betterPlayerControlsConfiguration,
            showPlaceholderUntilPlay: true,
            subtitlesConfiguration: const BetterPlayerSubtitlesConfiguration(
                backgroundColor: Colors.black45,
                fontFamily: 'Poppins',
                fontColor: Colors.white,
                fontSize: 17));

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, widget.sources.values.first,
        resolutions: widget.sources,
        subtitles: widget.subs,
        bufferingConfiguration: betterPlayerBufferingConfiguration);
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
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
          child: BetterPlayer(
            controller: _betterPlayerController,
          ),
        ),
      ),
    );
  }
}
