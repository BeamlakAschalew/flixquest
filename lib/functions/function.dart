import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_constants.dart';

String episodeSeasonFormatter(int episodeNumber, int seasonNumber) {
  String formattedSeason =
      seasonNumber <= 9 ? 'S0$seasonNumber' : 'S$seasonNumber';
  String formattedEpisode =
      episodeNumber <= 9 ? 'E0$episodeNumber' : 'E$episodeNumber';
  return "$formattedSeason | $formattedEpisode";
}

Future<void> requestNotificationPermissions() async {
  final PermissionStatus status = await Permission.notification.request();
  if (!status.isGranted && !status.isPermanentlyDenied) {
    Permission.notification.request();
  }
}

Future<bool> checkConnection() async {
  bool? isInternetWorking;
  try {
    final response = await InternetAddress.lookup('google.com');

    isInternetWorking = response.isNotEmpty;
  } on SocketException catch (e) {
    debugPrint(e.toString());
    isInternetWorking = false;
  }

  return isInternetWorking;
}

String removeCharacters(String input) {
  String charactersToRemove = ",.?\"'";
  String pattern = '[$charactersToRemove]';
  String result = input.replaceAll(RegExp(pattern), '');
  return result;
}

Future<bool> clearTempCache() async {
  try {
    Directory tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
      return true;
    } else {
      return false;
    }
  } catch (e) {
    throw Exception("Failed to clear temp files");
  }
}

Future<bool> clearCache() async {
  try {
    Directory cacheDir = await getApplicationCacheDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
      return true;
    } else {
      return false;
    }
  } catch (e) {
    throw Exception("Failed to clear cache");
  }
}

void fileDelete() async {
  for (int i = 0; i < appNames.length; i++) {
    File file =
        File("${(await getApplicationCacheDirectory()).path}${appNames[i]}");
    if (file.existsSync()) {
      file.delete();
    }
  }
}
