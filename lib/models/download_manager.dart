import 'dart:io';

import 'package:cinemax/models/video_converter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Download {
  final String input, output;
  double progress;
  Download({required this.input, required this.output, required this.progress});
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

  void updateDownload(double progress, int index) {
    _downloads[index].progress = progress;
    notifyListeners();
  }

  void startDownload(Download download) async {
    notifyListeners();
  }

  void cancelDownload(Download download) {
    notifyListeners();

    // Cancel the download task here
  }
}
