// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

import 'package:cinemax/models/function.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:web_scraper/web_scraper.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    //  fetchLink();
    super.initState();
    fetchProducts();
  }

  final webScraper = WebScraper('https://2embed.biz');
  List<Map<String, dynamic>>? productNames;
  late List<Map<String, dynamic>> productDescriptions;

  void fetchProducts() async {
    // Loads web page and downloads into local state of library
    if (await webScraper.loadWebPage('/play/movie.php?imdb=tt1632708')) {
      setState(() {
        // getElement takes the address of html tag/element and attributes you want to scrap from website
        // it will return the attributes in the same order passed
        productNames =
            webScraper.getElement('#player > source', ['src', 'type']);
        productDescriptions = webScraper.getElement(
            'div.thumbnail > div.caption > p.description', ['class']);
        // print('${'https://2embed.biz productNames![0]['attributes']['src']}');
        print('https://2embed.biz/play/'
            '${productNames![0]['attributes']['src']}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchProducts();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Video player example'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.navigation),
              onPressed: () {
                Navigator.push<_PlayerVideoAndPopPage>(
                  context,
                  MaterialPageRoute<_PlayerVideoAndPopPage>(
                    builder: (BuildContext context) => _PlayerVideoAndPopPage(),
                  ),
                );
              },
            )
          ],
          // bottom: const TabBar(
          //   isScrollable: true,
          //   tabs: <Widget>[
          //     Tab(
          //       icon: Icon(Icons.cloud),
          //       text: 'Remote',
          //     ),
          //     Tab(icon: Icon(Icons.insert_drive_file), text: 'Asset'),
          //     Tab(icon: Icon(Icons.list), text: 'List example'),
          //   ],
          // ),
        ),
        body: _BumbleBeeRemoteVideo(),
      ),
    );
  }
}

class _BumbleBeeRemoteVideo extends StatefulWidget {
  @override
  _BumbleBeeRemoteVideoState createState() => _BumbleBeeRemoteVideoState();
}

class _BumbleBeeRemoteVideoState extends State<_BumbleBeeRemoteVideo> {
  late VideoPlayerController _controller;

  // Future<ClosedCaptionFile> _loadCaptions() async {
  //   // final String fileContents = await DefaultAssetBundle.of(context)
  //   //     .loadString('assets/bumble_bee_captions.vtt');
  //   // return WebVTTCaptionFile(
  //   //     fileContents); // For vtt files, use WebVTTCaptionFile
  // }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'https://2embed.biz/play/play.php?imdb=tt10986410&token=dytRTloxbWhSc3lHVWdrQ1FoL01Pdz09&type=series&sea=2&epi=1',
      formatHint: VideoFormat.hls,
      // closedCaptionFile: _loadCaptions(),
      videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true, allowBackgroundPlayback: true),
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(padding: const EdgeInsets.only(top: 20.0)),
          const Text('With remote mp4'),
          Container(
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  ClosedCaption(text: _controller.value.caption.text),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration.zero,
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (Duration delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<Duration>>[
                for (final Duration offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem<Duration>(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerVideoAndPopPage extends StatefulWidget {
  @override
  _PlayerVideoAndPopPageState createState() => _PlayerVideoAndPopPageState();
}

class _PlayerVideoAndPopPageState extends State<_PlayerVideoAndPopPage> {
  late VideoPlayerController _videoPlayerController;
  bool startedPlaying = false;

  @override
  void initState() {
    super.initState();

    _videoPlayerController =
        VideoPlayerController.asset('assets/Butterfly-209.mp4');
    _videoPlayerController.addListener(() {
      if (startedPlaying && !_videoPlayerController.value.isPlaying) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<bool> started() async {
    await _videoPlayerController.initialize();
    await _videoPlayerController.play();
    startedPlaying = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: FutureBuilder<bool>(
          future: started(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data ?? false) {
              return AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              );
            } else {
              return const Text('waiting for video to load');
            }
          },
        ),
      ),
    );
  }
}
//// cut here

// class _ButterFlyAssetVideoInList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: <Widget>[
//         const _ExampleCard(title: 'Item a'),
//         const _ExampleCard(title: 'Item b'),
//         const _ExampleCard(title: 'Item c'),
//         const _ExampleCard(title: 'Item d'),
//         const _ExampleCard(title: 'Item e'),
//         const _ExampleCard(title: 'Item f'),
//         const _ExampleCard(title: 'Item g'),
//         Card(
//             child: Column(children: <Widget>[
//           Column(
//             children: <Widget>[
//               const ListTile(
//                 leading: Icon(Icons.cake),
//                 title: Text('Video video'),
//               ),
//               Stack(
//                   alignment: FractionalOffset.bottomRight +
//                       const FractionalOffset(-0.1, -0.1),
//                   children: <Widget>[
//                     _ButterFlyAssetVideo(),
//                     Image.asset('assets/flutter-mark-square-64.png'),
//                   ]),
//             ],
//           ),
//         ])),
//         const _ExampleCard(title: 'Item h'),
//         const _ExampleCard(title: 'Item i'),
//         const _ExampleCard(title: 'Item j'),
//         const _ExampleCard(title: 'Item k'),
//         const _ExampleCard(title: 'Item l'),
//       ],
//     );
//   }
// }

/// A filler card to show the video in a list of scrolling contents.
// class _ExampleCard extends StatelessWidget {
//   const _ExampleCard({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           ListTile(
//             leading: const Icon(Icons.airline_seat_flat_angled),
//             title: Text(title),
//           ),
//           ButtonBar(
//             children: <Widget>[
//               TextButton(
//                 child: const Text('BUY TICKETS'),
//                 onPressed: () {
//                   /* ... */
//                 },
//               ),
//               TextButton(
//                 child: const Text('SELL TICKETS'),
//                 onPressed: () {
//                   /* ... */
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ButterFlyAssetVideo extends StatefulWidget {
//   @override
//   _ButterFlyAssetVideoState createState() => _ButterFlyAssetVideoState();
// }

// class _ButterFlyAssetVideoState extends State<_ButterFlyAssetVideo> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.asset('assets/Butterfly-209.mp4');

//     _controller.addListener(() {
//       setState(() {});
//     });
//     _controller.setLooping(true);
//     _controller.initialize().then((_) => setState(() {}));
//     _controller.play();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: <Widget>[
//           Container(
//             padding: const EdgeInsets.only(top: 20.0),
//           ),
//           const Text('With assets mp4'),
//           Container(
//             padding: const EdgeInsets.all(20),
//             child: AspectRatio(
//               aspectRatio: _controller.value.aspectRatio,
//               child: Stack(
//                 alignment: Alignment.bottomCenter,
//                 children: <Widget>[
//                   VideoPlayer(_controller),
//                   _ControlsOverlay(controller: _controller),
//                   VideoProgressIndicator(_controller, allowScrubbing: true),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'dart:io';

// import 'package:chewie/chewie.dart';
// import 'package:cinemax/models/function.dart';
// import 'package:flutter/material.dart';
// // ignore: depend_on_referenced_packages
// import 'package:video_player/video_player.dart';

// class ChewieDemo extends StatefulWidget {
//   const ChewieDemo({
//     Key? key,
//     this.title = 'Chewie Demo',
//   }) : super(key: key);

//   final String title;

//   @override
//   State<StatefulWidget> createState() {
//     return _ChewieDemoState();
//   }
// }

// class _ChewieDemoState extends State<ChewieDemo> {
//   TargetPlatform? _platform;
//   late VideoPlayerController _videoPlayerController1;
//   late VideoPlayerController _videoPlayerController2;
//   ChewieController? _chewieController;
//   int? bufferDelay;

//   @override
//   void initState() {
//     super.initState();
//     fetchLink();
//     initializePlayer();
//   }

//   @override
//   void dispose() {
//     _videoPlayerController1.dispose();
//     _videoPlayerController2.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }

//   List<String> srcs = [
//     // "https://2embed.biz/play/play.php?imdb=tt1632708&token=d1IwTitINEdZZEVDZkE4M2FkUlJTQT09",
//     // "https://assets.mixkit.co/videos/preview/mixkit-daytime-city-traffic-aerial-view-56-large.mp4",
//     // "https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4"
//   ];

//   Future<void> initializePlayer() async {
//     _videoPlayerController1 =
//         VideoPlayerController.asset('assets/m3u8/tv.m3u8');
//     _videoPlayerController2 =
//         VideoPlayerController.asset('assets/m3u8/tv.m3u8');
//     await Future.wait([
//       _videoPlayerController1.initialize(),
//       _videoPlayerController2.initialize()
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
//       videoPlayerController: _videoPlayerController1,
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
//       subtitle: Subtitles(subtitles),
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
//     await _videoPlayerController1.pause();
//     currPlayIndex += 1;
//     if (currPlayIndex >= srcs.length) {
//       currPlayIndex = 0;
//     }
//     await initializePlayer();
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
//                         _videoPlayerController1.pause();
//                         _videoPlayerController1.seekTo(Duration.zero);
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
//                         _videoPlayerController2.pause();
//                         _videoPlayerController2.seekTo(Duration.zero);
//                         _chewieController = _chewieController!.copyWith(
//                           videoPlayerController: _videoPlayerController2,
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
