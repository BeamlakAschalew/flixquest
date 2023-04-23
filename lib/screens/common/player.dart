import 'dart:ui';

import 'package:cinemax/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_viewer/video_viewer.dart';

class Player extends StatefulWidget {
  const Player(
      {required this.sources,
      required this.thumbnail,
      required this.subs,
      Key? key})
      : super(key: key);
  final Map<String, VideoSource> sources;
  final Map<String, VideoViewerSubtitle> subs;
  final String? thumbnail;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  VideoViewerController controller = VideoViewerController();

  // void sth() {
  //   print('durrr: ${controller.maxBuffering}');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: VideoViewer(
              controller: controller,
              enableVerticalSwapingGesture: false,
              enableFullscreenScale: true,
              autoPlay: true,
              defaultAspectRatio: 16 / 9,
              //   volumeManager: VideoViewerVolumeManager.device,
              enableHorizontalSwapingGesture: false,
              source: widget.sources,
              onFullscreenFixLandscape: true,
              style: VideoViewerStyle(
                playAndPauseStyle: PlayAndPauseWidgetStyle(
                    play: const MediaButtons(
                      assetName: 'assets/images/play.png',
                    ),
                    pause: const MediaButtons(
                      assetName: 'assets/images/pause.png',
                    ),
                    replay: const MediaButtons(
                      assetName: 'assets/images/refresh.png',
                    ),
                    background: Theme.of(context).colorScheme.primary,
                    circleRadius: 110),
                loading: const LoadingWidget(),
                buffering: const LoadingWidget(),
                settingsStyle: SettingsMenuStyle(items: []),
                subtitleStyle: SubtitleStyle(),
                // header: AppBar(
                //   title: Text('vid'),
                //   actions: [
                //     IconButton(
                //         onPressed: () => Navigator.pop(context),
                //         icon: Icon(Icons.arrow_back))
                //   ],
                // ),
                progressBarStyle: ProgressBarStyle(
                    bar: BarStyle.progress(
                        buffered: Colors.white,
                        height: 8,
                        color: Theme.of(context).primaryColor,
                        dotSize: 12)),
                thumbnail: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      '${TMDB_BASE_IMAGE_URL}w600_and_h900_bestv2/${widget.thumbnail!}',
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                        child: Container(
                          color: Colors.white.withOpacity(0.0),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

class MediaButtons extends StatelessWidget {
  const MediaButtons({
    Key? key,
    required this.assetName,
  }) : super(key: key);

  final String assetName;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 20,
        width: 20,
        margin: const EdgeInsets.all(20),
        child: Image.asset(assetName));
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        height: 120,
        width: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_shadow.png',
              height: 65,
              width: 65,
            ),
            const SizedBox(
              height: 15,
            ),
            const SizedBox(width: 160, child: LinearProgressIndicator())
          ],
        ),
      ),
    );
  }
}
