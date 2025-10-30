// import 'package:better_player/better_player.dart';
// import 'package:cinemax/constants/app_constants.dart';
// import 'package:cinemax/controllers/recently_watched_database_controller.dart';
// import 'package:cinemax/models/recently_watched.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../provider/recently_watched_provider.dart';
// import '../../provider/settings_provider.dart';

// class PlayerTest extends StatefulWidget {
//   const PlayerTest({required this.sources, required this.subs, Key? key})
//       : super(key: key);
//   final Map<String, String> sources;
//   final List<BetterPlayerSubtitlesSource> subs;

//   @override
//   State<PlayerTest> createState() => _PlayerTestState();
// }

// class _PlayerTestState extends State<PlayerTest> with WidgetsBindingObserver {
//   late BetterPlayerController _betterPlayerController;
//   late BetterPlayerControlsConfiguration betterPlayerControlsConfiguration;
//   late BetterPlayerBufferingConfiguration betterPlayerBufferingConfiguration;
//   RecentlyWatchedMoviesController recentlyWatchedMoviesController =
//       RecentlyWatchedMoviesController();
//   RecentlyWatchedEpisodeController recentlyWatchedEpisodeController =
//       RecentlyWatchedEpisodeController();
//   late int duration;

//   final GlobalKey _betterPlayerKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addObserver(this);
//     betterPlayerBufferingConfiguration =
//         const BetterPlayerBufferingConfiguration(
//       maxBufferMs: 18000,
//       minBufferMs: 15000,
//     );
//     betterPlayerControlsConfiguration = BetterPlayerControlsConfiguration(
//       enableFullscreen: true,
//       name: "No Hard Feelings (2023)",
//       controlBarColor: Colors.black.withValues(alpha: 0.3),
//       enablePip: true,
//       progressBarBackgroundColor: Colors.white,
//       muteIcon: Icons.volume_mute_rounded,
//       unMuteIcon: Icons.volume_off_rounded,
//       pauseIcon: Icons.pause_rounded,
//       pipMenuIcon: Icons.picture_in_picture_rounded,
//       playIcon: Icons.play_arrow_rounded,
//       showControlsOnInitialize: false,
//       progressBarBufferedColor: Colors.black45,
//       skipForwardIcon: Icons.forward_10_rounded,
//       skipBackIcon: Icons.replay_10_rounded,
//       fullscreenEnableIcon: Icons.fullscreen_rounded,
//       fullscreenDisableIcon: Icons.fullscreen_exit_rounded,
//       overflowMenuIcon: Icons.menu_rounded,
//       subtitlesIcon: Icons.closed_caption_rounded,
//       qualitiesIcon: Icons.hd_rounded,
//       enableAudioTracks: false,
//     );

//     BetterPlayerConfiguration betterPlayerConfiguration =
//         BetterPlayerConfiguration(
//             autoDetectFullscreenDeviceOrientation: true,
//             autoPlay: true,
//             fit: BoxFit.contain,
//             autoDispose: true,
//             controlsConfiguration: betterPlayerControlsConfiguration,
//             showPlaceholderUntilPlay: true,
//             allowedScreenSleep: false,
//             subtitlesConfiguration: const BetterPlayerSubtitlesConfiguration());

//     String? link;

//     link = widget.sources.values.first;

//     BetterPlayerDataSource dataSource =
//         BetterPlayerDataSource(BetterPlayerDataSourceType.network, link,
//             resolutions: widget.sources,
//             subtitles: widget.subs,
//             cacheConfiguration: const BetterPlayerCacheConfiguration(
//               useCache: true,
//               preCacheSize: 471859200 * 471859200,
//               maxCacheSize: 1073741824 * 1073741824,
//               maxCacheFileSize: 471859200 * 471859200,

//               ///Android only option to use cached video between app sessions
//               key: "testCacheKey",
//             ),
//             bufferingConfiguration: betterPlayerBufferingConfiguration);
//     _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
//     _betterPlayerController.setupDataSource(dataSource);
//     _betterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // print(widget.movieMetadata!.elementAt(0));
//     return WillPopScope(
//       onWillPop: () async {
//         return true;
//       },
//       child: Scaffold(
//         body: Center(
//           child: SizedBox(
//             height: MediaQuery.of(context).size.height,
//             width: double.infinity,
//             child: Stack(
//               children: [
//                 BetterPlayer(
//                   controller: _betterPlayerController,
//                   key: _betterPlayerKey,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
