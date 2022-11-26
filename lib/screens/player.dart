// import 'dart:io';

// import 'package:chewie/chewie.dart';
// import 'package:cinemax/screens/movie_video_loader.dart';
// import 'package:flutter/material.dart';
// import 'package:subtitle/subtitle.dart' as sub;
// import 'package:video_player/video_player.dart';

// import '../models/video_quality.dart';

// class ChewieDemo extends StatefulWidget {
//   const ChewieDemo({
//     required this.videoUrl,
//     Key? key,
//     this.title = 'Chewie Demo',
//   }) : super(key: key);

//   final String title;
//   final List<VideoQuality> videoUrl;

//   @override
//   State<StatefulWidget> createState() {
//     return _ChewieDemoState();
//   }
// }

// class _ChewieDemoState extends State<ChewieDemo> {
//   TargetPlatform? _platform;
//   late VideoPlayerController? _videoPlayerController1;
//   //late VideoPlayerController _videoPlayerController2;
//   ChewieController? _chewieController;
//   int? bufferDelay;

//   @override
//   void initState() {
//     super.initState();
//     initializePlayer();
//     initSub();
//   }

//   @override
//   void dispose() {
//     _videoPlayerController1!.dispose();
//     //  _videoPlayerController2.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }

//   sub.SubtitleController? con;

//   void initSub() async {
//     var url = Uri.parse(
//         'https://www.opensubtitles.com/download/7399F060B983F352DD4754836B99851542F0CF523E231531BEAAD789281BD1D3B8F03F87CC51BB834B9AB9D9C7BEACF7C88EFABF95FFD5E72A201B638670CD4E9DF635230133720C89B5CB93376AED7A739993A7E88AE7B508A9CA7F429482DC69A49204B179C39F98E916257D9A59D96CF1E6459BA7C696E5ACC0DB0C9BF7EC5BC1BB01B61BD38C9084EBC68CB8332530BF0ECB618EB6228D30EEABD5D768C778BE34F3C85636FF5ACD7C668FD9F18DEF4EA513C7471A62163E8430B5026631125AF3214B9D2ED1B529098D4B1660C0666EE17922DD2D8FFE7A3E2BED14A0416A5E4BB0E62764407602F6320A344339365B8CD2B05A55905938FCD39FC6EA121777DA48EC25151C2ED2DD01B060541413E63029F3CF60F9/subfile/Fall.2022.1080p.WEB-DL.DD5.1.H.srt');
//     con =
//         sub.SubtitleController(provider: sub.SubtitleProvider.fromNetwork(url));
//     await con!.initial();
//     // print(con!.subtitles);
//     getDropdownItems();
//   }

//   List<Subtitle> dropdownItems = [];
//   void getDropdownItems() {
//     for (int i = 0; i < con!.subtitles.length; i++) {
//       var newItem = Subtitle(
//           index: 0,
//           start: con!.subtitles[i].start,
//           end: con!.subtitles[i].end,
//           text: con!.subtitles[i].data);
//       dropdownItems.add(newItem);
//     }
//     print(dropdownItems);
//   }

//   // List<String> srcs = [
//   //   "https://hls2x.vidfiles.net/videos/hls/ImPLQ1JzOmbCRW_izooELQ/1664191663/367261/1ebfff9d06ccb5c25e8ac8d74d9add7c/ep.0.v3.1662080095.360.m3u8",
//   //   "https://hls2x.vidfiles.net/videos/hls/ImPLQ1JzOmbCRW_izooELQ/1664191663/367261/1ebfff9d06ccb5c25e8ac8d74d9add7c/ep.0.v3.1662080095.720.m3u8",
//   //   "https://hls2x.vidfiles.net/videos/hls/ImPLQ1JzOmbCRW_izooELQ/1664191663/367261/1ebfff9d06ccb5c25e8ac8d74d9add7c/ep.0.v3.1662080095.1080.m3u8"
//   // ];

//   Future<void> initializePlayer() async {
//     _videoPlayerController1 =
//         VideoPlayerController.network(widget.videoUrl[currPlayIndex].videoUrl);
//     // _videoPlayerController2 =
//     //     VideoPlayerController.network(srcs[currPlayIndex]);
//     await Future.wait([
//       _videoPlayerController1!.initialize(),
//       // _videoPlayerController2.initialize()
//     ]);
//     _createChewieController();
//     setState(() {});
//   }

//   void _createChewieController() {
//     // final subtitles = [
//     //     Subtitle(
//     //       index: 0,
//     //       start: Duration.zero,
//     //       end: const Duration(seconds: 10),
//     //       text: 'Hello from subtitles',
//     //     ),
//     //     Subtitle(
//     //       index: 0,
//     //       start: const Duration(seconds: 10),
//     //       end: const Duration(seconds: 20),
//     //       text: 'Whats up? :)',
//     //     ),
//     //   ];
//     // final subtitles = con!.subtitles;

//     final subtitles = [
//       Subtitle(
//         index: 0,
//         start: Duration.zero,
//         end: const Duration(seconds: 10),
//         text: const TextSpan(
//           children: [
//             TextSpan(
//               text: 'Hello',
//               style: TextStyle(color: Colors.red, fontSize: 22),
//             ),
//             TextSpan(
//               text: ' from ',
//               style: TextStyle(color: Colors.green, fontSize: 20),
//             ),
//             TextSpan(
//               text: 'subtitles',
//               style: TextStyle(color: Colors.blue, fontSize: 18),
//             )
//           ],
//         ),
//       ),
//       Subtitle(
//         index: 0,
//         start: const Duration(seconds: 10),
//         end: const Duration(seconds: 20),
//         text: 'Whats up? :)',
//         // text: const TextSpan(
//         //   text: 'Whats up? :)',
//         //   style: TextStyle(color: Colors.amber, fontSize: 22, fontStyle: FontStyle.italic),
//         // ),
//       ),
//     ];

//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController1!,
//       autoPlay: true,
//       looping: true,
//       progressIndicatorDelay:
//           bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,

//       additionalOptions: (context) {
//         return <OptionItem>[
//           OptionItem(
//             onTap: toggleVideo,
//             iconData: Icons.live_tv_sharp,
//             title: 'Toggle Video Src',
//           ),
//         ];
//       },
//       subtitle: Subtitles(dropdownItems),
//       subtitleBuilder: (context, dynamic subtitle) => Container(
//         padding: const EdgeInsets.all(10.0),
//         child: subtitle is InlineSpan
//             ? RichText(
//                 text: subtitle,
//               )
//             : Text(
//                 subtitle.toString(),
//                 style: const TextStyle(color: Colors.black),
//               ),
//       ),

//       hideControlsTimer: const Duration(seconds: 1),

//       // Try playing around with some of these other options:

//       // showControls: false,
//       // materialProgressColors: ChewieProgressColors(
//       //   playedColor: Colors.red,
//       //   handleColor: Colors.blue,
//       //   backgroundColor: Colors.grey,
//       //   bufferedColor: Colors.lightGreen,
//       // ),
//       // placeholder: Container(
//       //   color: Colors.grey,
//       // ),
//       // autoInitialize: true,
//     );
//   }

//   int currPlayIndex = 0;

//   Future<void> toggleVideo() async {
//     // await _videoPlayerController1.pause();
//     // currPlayIndex += 1;
//     // if (currPlayIndex >= widget.videoUrl.length) {
//     //   currPlayIndex = 0;
//     // }
//     // await initializePlayer();
//     if (_videoPlayerController1 == null) {
//       // If there was no controller, just create a new one
//       initializePlayer();
//     } else {
//       // If there was a controller, we need to dispose of the old one first
//       final oldController = _videoPlayerController1;

//       // Registering a callback for the end of next frame
//       // to dispose of an old controller
//       // (which won't be used anymore after calling setState)
//       WidgetsBinding.instance.addPostFrameCallback((_) async {
//         await oldController!.dispose();

//         // Initing new controller
//         initializePlayer();
//       });

//       // Making sure that controller is not used by setting it to null
//       setState(() {
//         _videoPlayerController1 = null;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: widget.title,
//       theme: AppTheme.light.copyWith(
//         platform: _platform ?? Theme.of(context).platform,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text(widget.title),
//         ),
//         body: Column(
//           children: <Widget>[
//             Expanded(
//               child: Center(
//                 child: _chewieController != null &&
//                         _chewieController!
//                             .videoPlayerController.value.isInitialized
//                     ? Chewie(
//                         controller: _chewieController!,
//                       )
//                     : Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           CircularProgressIndicator(),
//                           SizedBox(height: 20),
//                           Text('Loading'),
//                         ],
//                       ),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 _chewieController?.enterFullScreen();
//               },
//               child: const Text('Fullscreen'),
//             ),
//             Row(
//               children: <Widget>[
//                 Expanded(
//                   child: TextButton(
//                     onPressed: () {
//                       setState(() {
//                         _videoPlayerController1!.pause();
//                         _videoPlayerController1!.seekTo(Duration.zero);
//                         _createChewieController();
//                       });
//                     },
//                     child: const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 16.0),
//                       child: Text("Landscape Video"),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: TextButton(
//                     onPressed: () {
//                       setState(() {
//                         // _videoPlayerController2.pause();
//                         // _videoPlayerController2.seekTo(Duration.zero);
//                         _chewieController = _chewieController!.copyWith(
//                           //videoPlayerController: _videoPlayerController2,
//                           autoPlay: true,
//                           looping: true,
//                           /* subtitle: Subtitles([
//                             Subtitle(
//                               index: 0,
//                               start: Duration.zero,
//                               end: const Duration(seconds: 10),
//                               text: 'Hello from subtitles',
//                             ),
//                             Subtitle(
//                               index: 0,
//                               start: const Duration(seconds: 10),
//                               end: const Duration(seconds: 20),
//                               text: 'Whats up? :)',
//                             ),
//                           ]),
//                           subtitleBuilder: (context, subtitle) => Container(
//                             padding: const EdgeInsets.all(10.0),
//                             child: Text(
//                               subtitle,
//                               style: const TextStyle(color: Colors.white),
//                             ),
//                           ), */
//                         );
//                       });
//                     },
//                     child: const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 16.0),
//                       child: Text("Portrait Video"),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             Row(
//               children: <Widget>[
//                 Expanded(
//                   child: TextButton(
//                     onPressed: () {
//                       setState(() {
//                         _platform = TargetPlatform.android;
//                       });
//                     },
//                     child: const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 16.0),
//                       child: Text("Android controls"),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: TextButton(
//                     onPressed: () {
//                       setState(() {
//                         _platform = TargetPlatform.iOS;
//                       });
//                     },
//                     child: const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 16.0),
//                       child: Text("iOS controls"),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             Row(
//               children: <Widget>[
//                 Expanded(
//                   child: TextButton(
//                     onPressed: () {
//                       setState(() {
//                         _platform = TargetPlatform.windows;
//                       });
//                     },
//                     child: const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 16.0),
//                       child: Text("Desktop controls"),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (Platform.isAndroid)
//               ListTile(
//                 title: const Text("Delay"),
//                 subtitle: DelaySlider(
//                   delay:
//                       _chewieController?.progressIndicatorDelay?.inMilliseconds,
//                   onSave: (delay) async {
//                     if (delay != null) {
//                       bufferDelay = delay == 0 ? null : delay;
//                       await initializePlayer();
//                     }
//                   },
//                 ),
//               )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class DelaySlider extends StatefulWidget {
//   const DelaySlider({Key? key, required this.delay, required this.onSave})
//       : super(key: key);

//   final int? delay;
//   final void Function(int?) onSave;
//   @override
//   State<DelaySlider> createState() => _DelaySliderState();
// }

// class _DelaySliderState extends State<DelaySlider> {
//   int? delay;
//   bool saved = false;

//   @override
//   void initState() {
//     super.initState();
//     delay = widget.delay;
//   }

//   @override
//   Widget build(BuildContext context) {
//     const int max = 1000;
//     return ListTile(
//       title: Text(
//         "Progress indicator delay ${delay != null ? "${delay.toString()} MS" : ""}",
//       ),
//       subtitle: Slider(
//         value: delay != null ? (delay! / max) : 0,
//         onChanged: (value) async {
//           delay = (value * max).toInt();
//           setState(() {
//             saved = false;
//           });
//         },
//       ),
//       trailing: IconButton(
//         icon: const Icon(Icons.save),
//         onPressed: saved
//             ? null
//             : () {
//                 widget.onSave(delay);
//                 setState(() {
//                   saved = true;
//                 });
//               },
//       ),
//     );
//   }
// }

// class AppTheme {
//   static final light = ThemeData(
//     brightness: Brightness.light,
//     useMaterial3: true,
//     colorScheme: const ColorScheme.light(secondary: Colors.red),
//     disabledColor: Colors.grey.shade400,
//     visualDensity: VisualDensity.adaptivePlatformDensity,
//   );

//   static final dark = ThemeData(
//     brightness: Brightness.dark,
//     colorScheme: const ColorScheme.dark(secondary: Colors.red),
//     disabledColor: Colors.grey.shade400,
//     useMaterial3: true,
//     visualDensity: VisualDensity.adaptivePlatformDensity,
//   );
// }

import 'package:cinemax/provider/darktheme_provider.dart';
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class Player extends StatefulWidget {
  const Player({required this.videoUrl, required this.videoTitle, Key? key})
      : super(key: key);
  final List<VideoQalityUrls> videoUrl;
  final String videoTitle;
  // final List<QualitiesList> qualitiesList;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late final PodPlayerController controller;

  @override
  void initState() {
    controller = PodPlayerController(
      podPlayerConfig:
          const PodPlayerConfig(videoQualityPriority: [0, 360, 480, 720, 1080]),
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
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
            width: double.infinity,
            height: double.infinity,
            child: PodVideoPlayer(
              controller: controller,
              matchFrameAspectRatioToVideo: true,
              matchVideoAspectRatioToFrame: true,
              alwaysShowProgressBar: false,
              videoTitle: Text(widget.videoTitle),
              podProgressBarConfig: const PodProgressBarConfig(
                padding: kIsWeb
                    ? EdgeInsets.zero
                    : EdgeInsets.only(
                        bottom: 20,
                        left: 20,
                        right: 20,
                      ),
                playingBarColor: Colors.orange,
                circleHandlerColor: Colors.orange,
                backgroundColor: Colors.blueGrey,
                bufferedBarColor: Colors.orangeAccent,
                alwaysVisibleCircleHandler: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
