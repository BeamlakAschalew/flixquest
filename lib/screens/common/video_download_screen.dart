import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/video_converter.dart';

class VideoDownloadScreen extends StatefulWidget {
  const VideoDownloadScreen({Key? key}) : super(key: key);

  @override
  State<VideoDownloadScreen> createState() => _VideoDownloadScreenState();
}

class _VideoDownloadScreenState extends State<VideoDownloadScreen> {
  double _progress = 0.0;

  Future<void> _convertM3U8toMP4() async {
    Directory? appDir = Directory("storage/emulated/0/Cinemax/Backdrops");

    String outputPath = "${appDir!.path}/output1.mp4";
    String _outputPath;

    setState(() {
      _progress = 0.0;
    });

    String? convertedFilePath = await VideoConverter().convertM3U8toMP4(
      "https://owt.webarchivecdn.com/_v10/fa04a352eb61a03283fece4192642c3772dd4c91f3bf55220f1154c0e8fb68245fafd786a97b09f74ba5029bdfe3a76ee261a3a678ee15121196ab1594ec7de95914b91025932a20df96e37c85d0c55eaac424cc93db56afeede0544d5fea229bf2d2db1ce01ed8a52448647f8c2aea26c66c89c242c5d0e019cf514b8ff9a1d2d6eb89eb04acf4754db62945b11f0e7/360/index.m3u8",
      outputPath,
      (double progress) {
        setState(() {
          _progress = progress / 100;
        });
      },
    );

    if (convertedFilePath != null) {
      setState(() {
        _outputPath = convertedFilePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _convertM3U8toMP4,
            child: Text("Convert to MP4"),
          ),
          if (_progress > 0.0) LinearProgressIndicator(value: _progress),
          // if (_outputFilePath.isNotEmpty)
          //   Text("Output MP4 File Path: $_outputFilePath"),
        ],
      ),
    );
  }
}
