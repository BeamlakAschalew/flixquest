// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';

// class MediaKitLivePlayer extends StatefulWidget {
//   const MediaKitLivePlayer({
//     required this.videoUrl,
//     required this.colors,
//     required this.autoFullScreen,
//     required this.channelName,
//     this.streamIcon,
//     super.key,
//   });

//   final String videoUrl;
//   final List<Color> colors;
//   final bool autoFullScreen;
//   final String channelName;
//   final String? streamIcon;

//   @override
//   State<MediaKitLivePlayer> createState() => _MediaKitLivePlayerState();
// }

// class _MediaKitLivePlayerState extends State<MediaKitLivePlayer> {
//   late final Player _player;
//   late final VideoController _videoController;
//   bool _isInitialized = false;
//   bool _hasError = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//   }

//   Future<void> _initializePlayer() async {
//     try {
//       // Initialize the player with live stream optimizations
//       _player = Player(
//         configuration: PlayerConfiguration(
//           title: 'Live TV',
//           // Larger buffer for live streams to prevent pausing
//           bufferSize: 128 * 1024 * 1024, // 64 MB (increased from 32 MB)
//           // Custom options for live streaming
//           muted: false,
//           // Reduce logging noise
//           logLevel: MPVLogLevel.warn,
//         ),
//       );

//       // Create video controller
//       _videoController = VideoController(
//         _player,
//         configuration: const VideoControllerConfiguration(
//           enableHardwareAcceleration: true,
//         ),
//       );

//       // Listen to player errors
//       _player.stream.error.listen((error) {
//         if (mounted && error.isNotEmpty) {
//           setState(() {
//             _hasError = true;
//             _errorMessage = error;
//           });
//           print('Player error: $error');
//         }
//       });

//       // Listen to buffering state to detect issues
//       _player.stream.buffering.listen((isBuffering) {
//         if (mounted) {
//           print('Buffering: $isBuffering');
//         }
//       });

//       // Open the stream with custom headers
//       await _player.open(
//         Media(
//           widget.videoUrl,
//           httpHeaders: {
//             'User-Agent':
//                 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
//             'Connection': 'keep-alive',
//             'Accept': '*/*',
//           },
//         ),
//         play: true,
//       );

//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//         });

//         // Auto fullscreen if enabled and video is landscape
//         if (widget.autoFullScreen) {
//           // Wait a bit for the video to load and determine aspect ratio
//           Future.delayed(const Duration(milliseconds: 500), () {
//             if (mounted) {
//               SystemChrome.setPreferredOrientations([
//                 DeviceOrientation.landscapeLeft,
//                 DeviceOrientation.landscapeRight,
//               ]);
//               SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//             }
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//           _errorMessage = e.toString();
//         });
//       }
//     }
//   }

//   void _retryStream() {
//     setState(() {
//       _hasError = false;
//       _errorMessage = null;
//     });
//     _player.open(
//       Media(
//         widget.videoUrl,
//         httpHeaders: {
//           'User-Agent':
//               'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
//           'Connection': 'keep-alive',
//           'Accept': '*/*',
//           'Cache-Control': 'no-cache',
//         },
//       ),
//       play: true,
//     );
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     SystemChrome.setEnabledSystemUIMode(
//       SystemUiMode.manual,
//       overlays: SystemUiOverlay.values,
//     );
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: _isInitialized
//           ? Stack(
//               children: [
//                 Center(
//                   child: MaterialVideoControlsTheme(
//                     normal: MaterialVideoControlsThemeData(
//                       // Allow seeking for live streams
//                       seekOnDoubleTap: false,
//                       displaySeekBar: false, // Show seek bar

//                       // Custom theme colors
//                       seekBarThumbColor: widget.colors.first,
//                       seekBarPositionColor: widget.colors.first,
//                       seekBarBufferColor:
//                           widget.colors.first.withValues(alpha: 0.4),
//                       seekBarColor: Colors.white.withValues(alpha: 0.2),

//                       // Button styling
//                       buttonBarButtonSize: 32,
//                       buttonBarButtonColor: Colors.white,

//                       // Padding and margins
//                       topButtonBarMargin: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                       bottomButtonBarMargin: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),

//                       // Top bar with channel name
//                       topButtonBar: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 8,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withValues(alpha: 0.5),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.live_tv_rounded,
//                                 color: widget.colors.first,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Flexible(
//                                 child: Text(
//                                   widget.channelName,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     shadows: [
//                                       Shadow(
//                                         offset: Offset(0, 1),
//                                         blurRadius: 3,
//                                         color: Colors.black45,
//                                       ),
//                                     ],
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Spacer(),
//                       ],

//                       // Bottom controls bar
//                       bottomButtonBar: [
//                         const MaterialPlayOrPauseButton(iconSize: 32),
//                         const SizedBox(width: 8),
//                         const MaterialPositionIndicator(
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const Spacer(),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.red.withValues(alpha: 0.9),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: const Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.circle,
//                                 color: Colors.white,
//                                 size: 10,
//                               ),
//                               SizedBox(width: 6),
//                               Text(
//                                 'LIVE',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         const MaterialFullscreenButton(iconSize: 28),
//                       ],
//                     ),
//                     fullscreen: MaterialVideoControlsThemeData(
//                       // Fullscreen theme - same as normal for consistency
//                       seekOnDoubleTap: false,
//                       displaySeekBar: false,

//                       // Custom theme colors
//                       seekBarThumbColor: widget.colors.first,
//                       seekBarPositionColor: widget.colors.first,
//                       seekBarBufferColor:
//                           widget.colors.first.withValues(alpha: 0.4),
//                       seekBarColor: Colors.white.withValues(alpha: 0.2),

//                       // Button styling
//                       buttonBarButtonSize: 32,
//                       buttonBarButtonColor: Colors.white,

//                       // Padding and margins
//                       topButtonBarMargin: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                       bottomButtonBarMargin: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),

//                       // Top bar with channel name
//                       topButtonBar: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 8,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withValues(alpha: 0.5),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.live_tv_rounded,
//                                 color: widget.colors.first,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Flexible(
//                                 child: Text(
//                                   widget.channelName,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     shadows: [
//                                       Shadow(
//                                         offset: Offset(0, 1),
//                                         blurRadius: 3,
//                                         color: Colors.black45,
//                                       ),
//                                     ],
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Spacer(),
//                       ],

//                       // Bottom controls bar
//                       bottomButtonBar: [
//                         const MaterialPlayOrPauseButton(iconSize: 32),
//                         const SizedBox(width: 8),
//                         const MaterialPositionIndicator(
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const Spacer(),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.red.withValues(alpha: 0.9),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: const Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.circle,
//                                 color: Colors.white,
//                                 size: 10,
//                               ),
//                               SizedBox(width: 6),
//                               Text(
//                                 'LIVE',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         const MaterialFullscreenButton(iconSize: 28),
//                       ],
//                     ),
//                     child: Video(
//                       controller: _videoController,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//                 if (_hasError)
//                   Center(
//                     child: Container(
//                       padding: const EdgeInsets.all(24),
//                       margin: const EdgeInsets.all(40),
//                       decoration: BoxDecoration(
//                         color: Colors.black87,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: widget.colors.first.withValues(alpha: 0.3),
//                           width: 2,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.5),
//                             blurRadius: 20,
//                             spreadRadius: 5,
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: widget.colors.first.withValues(alpha: 0.2),
//                             ),
//                             child: Icon(
//                               Icons.error_outline_rounded,
//                               color: widget.colors.first,
//                               size: 48,
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           const Text(
//                             'Stream Error',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           if (_errorMessage != null) ...[
//                             const SizedBox(height: 12),
//                             Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withValues(alpha: 0.1),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 _errorMessage!,
//                                 style: const TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 13,
//                                 ),
//                                 textAlign: TextAlign.center,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                           const SizedBox(height: 20),
//                           ElevatedButton.icon(
//                             onPressed: _retryStream,
//                             icon: const Icon(Icons.refresh_rounded),
//                             label: const Text(
//                               'Retry Stream',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: widget.colors.first,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 24,
//                                 vertical: 14,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               elevation: 4,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//               ],
//             )
//           : Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: widget.colors.first.withValues(alpha: 0.2),
//                     ),
//                     child: CircularProgressIndicator(
//                       color: widget.colors.first,
//                       strokeWidth: 3,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 12,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withValues(alpha: 0.5),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           'Loading ${widget.channelName}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.live_tv_rounded,
//                               color: widget.colors.first,
//                               size: 16,
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               'Connecting to live stream...',
//                               style: TextStyle(
//                                 color: Colors.white.withValues(alpha: 0.7),
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
