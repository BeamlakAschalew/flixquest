import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import '../main.dart';

String episodeSeasonFormatter(int episodeNumber, int seasonNumber) {
  String formattedSeason =
      seasonNumber <= 9 ? 'S0$seasonNumber' : 'S$seasonNumber';
  String formattedEpisode =
      episodeNumber <= 9 ? 'E0$episodeNumber' : 'E$episodeNumber';
  return "$formattedSeason | $formattedEpisode";
}

Future<void> _messageHandler(RemoteMessage message) async {}

Future<void> appInitialize(Future<FirebaseApp> init) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await EasyLocalization.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  await settingsProvider.getCurrentThemeMode();
  await settingsProvider.getCurrentMaterial3Mode();
  await settingsProvider.initMixpanel();
  await settingsProvider.getCurrentAdultMode();
  await settingsProvider.getCurrentDefaultScreen();
  await settingsProvider.getCurrentImageQuality();
  await settingsProvider.getCurrentWatchCountry();
  await settingsProvider.getCurrentViewType();
  await settingsProvider.getSeekDuration();
  await settingsProvider.getMaxBufferDuration();
  await settingsProvider.getVideoResolution();
  await settingsProvider.getSubtitleLanguage();
  await settingsProvider.getViewMode();
  await recentProvider.fetchMovies();
  await recentProvider.fetchEpisodes();
  await appDependencyProvider.getConsumetUrl();
  await appDependencyProvider.getCinemaxLogo();
  await appDependencyProvider.getOpenSubKey();
  await appDependencyProvider.getStreamingServer();
  await settingsProvider.getSubtitleSize();
  await settingsProvider.getForegroundSubtitleColor();
  await settingsProvider.getBackgroundSubtitleColor();
  await settingsProvider.getAppLanguage();
  await init;
}
