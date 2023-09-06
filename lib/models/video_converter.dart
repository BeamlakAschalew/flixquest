// // ignore_for_file: unused_local_variable, unnecessary_brace_in_string_interps, avoid_print

// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
// import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
// import 'package:ffmpeg_kit_flutter/media_information_session.dart';
// import 'package:ffmpeg_kit_flutter/statistics.dart';

// class VideoConverter {
//   Statistics? _statistics;
//   late Function(double) _onProgress;
//   String? duration;

//   Future<String?> convertM3U8toMP4(String inputPath, String outputPath,
//       int index, Function(double) onProgress) async {
//     _onProgress = onProgress;

//     FFprobeKit.getMediaInformation(inputPath)
//         .then((MediaInformationSession session) async {
//       var information = session.getMediaInformation();

//       if (information != null) {
//         duration = information.getDuration();
//       }
//       print('DURATIONNNN: ${duration}');
//     });

//     FFmpegKit.executeAsync(
//       '-i $inputPath -y -c:v mpeg4 $outputPath',
//       ((session) async {
//         final state =
//             FFmpegKitConfig.sessionStateToString(await session.getState());
//         final returnCode = await session.getReturnCode();
//         final failStackTrace = await session.getFailStackTrace();
//         final duration = await session.getDuration();
//       }),
//       ((log) => print(log.getMessage())),
//       (statistics) {
//         _statistics = statistics;
//         _updateProgressDialog();
//       },
//     );

//     return '';
//   }

//   void _updateProgressDialog() {
//     if (_statistics != null) {
//       final progress = ((_statistics!.getTime() /
//               Duration(seconds: num.parse(duration!).toInt()).inMilliseconds) *
//           100);
//       // final progress = _statistics!.getTime();
//       print('PRRR: ${progress}');
//       print('Tota; dur: ${duration}');

//       _onProgress(progress.toDouble() / 100);
//     }
//   }
// }
