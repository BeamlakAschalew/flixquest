import 'package:cinemax/screens/movie_video_loader.dart';
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'package:flutter/foundation.dart';

class PlayVideoFromNetworkQualityUrls extends StatefulWidget {
  const PlayVideoFromNetworkQualityUrls({required this.videoUrl, Key? key})
      : super(key: key);
  final List<VideoQalityUrls> videoUrl;
  // final List<QualitiesList> qualitiesList;

  @override
  State<PlayVideoFromNetworkQualityUrls> createState() =>
      _PlayVideoFromAssetState();
}

class _PlayVideoFromAssetState extends State<PlayVideoFromNetworkQualityUrls> {
  late final PodPlayerController controller;

  @override
  void initState() {
    controller = PodPlayerController(
      podPlayerConfig:
          PodPlayerConfig(videoQualityPriority: [0, 360, 480, 720, 1080]),
      playVideoFrom: PlayVideoFrom.networkQualityUrls(
        videoPlayerOptions: VideoPlayerOptions(),
        videoUrls: widget.videoUrl,
        formatHint: VideoFormat.hls,
      ),
    )..initialise();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Play video from Quality urls')),
      body: SafeArea(
        child: Center(
          child: widget.videoUrl.isEmpty
              ? CircularProgressIndicator()
              : PodVideoPlayer(
                  controller: controller,
                  // overlayBuilder: (options) {
                  //   return Center(
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //       children: [Text('data'), Text('data'), Text('data')],
                  //     ),
                  //   );
                  // },
                  podProgressBarConfig: const PodProgressBarConfig(
                    padding: kIsWeb
                        ? EdgeInsets.zero
                        : EdgeInsets.only(
                            bottom: 20,
                            left: 20,
                            right: 20,
                          ),
                    playingBarColor: Colors.blue,
                    circleHandlerColor: Colors.blue,
                    backgroundColor: Colors.blueGrey,
                  ),
                ),
        ),
      ),
    );
  }
}
