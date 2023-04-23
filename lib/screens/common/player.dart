import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoViewer(
          source: widget.sources,
          onFullscreenFixLandscape: true,
          style: VideoViewerStyle(
            settingsStyle: SettingsMenuStyle(items: []),
            subtitleStyle: SubtitleStyle(),
            thumbnail: Image.network(
              "https://play-lh.googleusercontent.com/aA2iky4PH0REWCcPs9Qym2X7e9koaa1RtY-nKkXQsDVU6Ph25_9GkvVuyhS72bwKhN1P",
            ),
          )),
    );
  }
}
