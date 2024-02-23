import 'dart:io';
import 'dart:math';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';
import '../video_providers/names.dart';

String episodeSeasonFormatter(int episodeNumber, int seasonNumber) {
  String formattedSeason =
      seasonNumber <= 9 ? 'S0$seasonNumber' : 'S$seasonNumber';
  String formattedEpisode =
      episodeNumber <= 9 ? 'E0$episodeNumber' : 'E$episodeNumber';
  return "$formattedSeason : $formattedEpisode";
}

Future<void> requestNotificationPermissions() async {
  final PermissionStatus status = await Permission.notification.status;
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

String normalizeTitle(String title) {
  return title
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[":\']'), '')
      .replaceAll(RegExp('[^a-zA-Z0-9]+'), '_');
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

int totalStreamingDuration = 0; // Keep track of the total streaming duration

// Function to update and log the aggregate streaming duration
void updateAndLogTotalStreamingDuration(int durationInSeconds) {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  totalStreamingDuration += durationInSeconds;

  // Log the new total duration as a custom event for tracking purposes
  analytics.logEvent(
    name: 'total_streaming_duration',
    parameters: <String, dynamic>{
      'duration_seconds': totalStreamingDuration,
    },
  );
}

String generateCacheKey() {
  Random random = Random();

  List<String> characters = [];
  String generatedChars = "";

  for (var i = 0; i < 26; i++) {
    characters.add(String.fromCharCode(97 + i)); // Lowercase letters a-z
  }

  for (var i = 0; i < 26; i++) {
    characters.add(String.fromCharCode(65 + i)); // Uppercase letters A-Z
  }

  for (var i = 0; i < 10; i++) {
    characters.add(i.toString()); // Numbers 0-9
  }

  characters.add('-');

  int min = 0;
  int max = characters.length - 1;
  int randomInt;

  for (int i = 0; i < 50; i++) {
    randomInt = min + random.nextInt(max - min + 1);
    generatedChars += characters[randomInt];
  }

  return generatedChars;
}

String processVttFileTimestamps(String vttFile) {
  final lines = vttFile.split('\n');
  final processedLines = <String>[];

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.contains('-->') && line.trim().length == 23) {
      String endTimeModifiedString =
          '${line.trim().substring(0, line.trim().length - 9)}00:${line.trim().substring(line.trim().length - 9)}';
      String finalStr = '00:$endTimeModifiedString';
      processedLines.add(finalStr);
    } else {
      processedLines.add(line);
    }
  }

  return processedLines.join('\n');
}

List<VideoProvider?> parseProviderPrecedenceString(String raw) {
  List<VideoProvider?> videoProviders = raw.split(' ').map((providerString) {
    List<String> parts = providerString.split('-');
    if (parts.length == 2) {
      return VideoProvider(fullName: parts[1], codeName: parts[0]);
    } else {}
  }).toList();

  return videoProviders;
}

bool isReleased(String target) {
  DateTime currentDate = DateTime.now();
  DateTime mediaDate = DateFormat('yyyy-MM-dd').parse(target);
  return mediaDate.isBefore(currentDate) ||
      mediaDate.isAtSameMomentAs(currentDate);
}

int createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}

String buildImageUrl(String baseImage, String proxyUrl, bool isProxyEnabled, BuildContext context) {
  String concatenated = baseImage;
  if (isProxyEnabled && proxyUrl.isNotEmpty) {
    concatenated = "$proxyUrl?destination=$baseImage";
  }

  return concatenated;
}
