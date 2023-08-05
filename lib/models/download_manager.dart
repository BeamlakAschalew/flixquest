import 'dart:io';

import 'package:cinemax/models/video_converter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Download {
  final String input, output, status, timestamp;
  bool isDownloading;
  double progress;
  Download(
      {required this.input,
      required this.isDownloading,
      required this.output,
      required this.progress,
      required this.status,
      required this.timestamp});
}

class DownloadProvider extends ChangeNotifier {
  List<Download> _downloads = [];
  List<Download> get downloads => _downloads;

  void addDownload(Download download) {
    _downloads.add(download);
    notifyListeners();
  }

  void removeDownload(Download download) {
    _downloads.remove(download);
    notifyListeners();
  }

  void startDownload(Download download) async {
    download.isDownloading = true;
    notifyListeners();

    // Directory? appDir = await getExternalStorageDirectory();
    // String outputPath = "${appDir!.path}/Cinemax/Backdrops/output1.mp4";

    try {
      await VideoConverter().convertM3U8toMP4(
        download.input,
        download.output,
        (double progress) {
          download.progress = progress / 100;
          notifyListeners();
        },
      );

      download.isDownloading = false;
      download.progress = 1.0;
      notifyListeners();
    } catch (error) {
      // Handle error if needed
      download.isDownloading = false;
      notifyListeners();
    }
  }

  void cancelDownload(Download download) {
    download.isDownloading = false;
    notifyListeners();

    // Cancel the download task here
  }
}
