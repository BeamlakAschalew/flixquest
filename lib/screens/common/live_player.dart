import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LivePlayer extends StatefulWidget {
  const LivePlayer(
      {required this.sources,
      required this.colors,
      required this.autoFullScreen,
      required this.channelName,
      Key? key})
      : super(key: key);
  final Map<String, String> sources;
  final List<Color> colors;
  final bool autoFullScreen;
  final String channelName;

  @override
  State<LivePlayer> createState() => _LivePlayerState();
}

class _LivePlayerState extends State<LivePlayer> {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerControlsConfiguration betterPlayerControlsConfiguration;
  late BetterPlayerBufferingConfiguration betterPlayerBufferingConfiguration;

  final GlobalKey _betterPlayerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    betterPlayerBufferingConfiguration =
        const BetterPlayerBufferingConfiguration(
      maxBufferMs: 120000,
      minBufferMs: 15000,
    );
    betterPlayerControlsConfiguration = BetterPlayerControlsConfiguration(
      name: widget.channelName,
      enableFullscreen: true,
      enablePip: true,
      backgroundColor: widget.colors.elementAt(1).withOpacity(0.6),
      controlBarColor: Colors.black.withOpacity(0.3),
      progressBarBackgroundColor: Colors.white,
      muteIcon: Icons.volume_off_rounded,
      unMuteIcon: Icons.volume_up_rounded,
      pauseIcon: Icons.pause_rounded,
      pipMenuIcon: Icons.picture_in_picture_rounded,
      playIcon: Icons.play_arrow_rounded,
      showControlsOnInitialize: false,
      loadingColor: widget.colors.first,
      iconsColor: widget.colors.first,
      progressBarPlayedColor: widget.colors.first,
      progressBarBufferedColor: Colors.black45,
      skipForwardIcon: Icons.forward_10_rounded,
      skipBackIcon: Icons.replay_10_rounded,
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
            //  fullScreenByDefault: true,
            looping: true,
            autoPlay: true,
            allowedScreenSleep: false,
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

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, widget.sources.entries.first.value,
        resolutions: widget.sources,
        liveStream: true,
        bufferingConfiguration: betterPlayerBufferingConfiguration);
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource).then((value) {
      if (_betterPlayerController.videoPlayerController!.value.aspectRatio >
          1.0) {
        if (widget.autoFullScreen) {
          _betterPlayerController.enterFullScreen();
        }
      }
    });
    _betterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: BetterPlayer(
            key: _betterPlayerKey,
            controller: _betterPlayerController,
          ),
        ),
      ),
    );
  }
}
