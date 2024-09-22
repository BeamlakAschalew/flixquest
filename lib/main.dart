import 'dart:io';
import 'package:flixquest/flixquest_main.dart';
import '../models/translation.dart';
import '../provider/app_dependency_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'constants/app_constants.dart';
import 'provider/recently_watched_provider.dart';
import 'package:flutter/material.dart';
import 'provider/settings_provider.dart';
import 'singleton/sharedpreferences_singleton.dart';

Future<void> _messageHandler(RemoteMessage message) async {}

bool isTablet(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double threshold = 1000.0;
  return screenWidth > threshold;
}

SettingsProvider settingsProvider = SettingsProvider();
RecentProvider recentProvider = RecentProvider();
AppDependencyProvider appDependencyProvider = AppDependencyProvider();
final Future<FirebaseApp> _initialization = Firebase.initializeApp();

Future<void> appInitialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ByteData data =
  //     await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  // SecurityContext.defaultContext
  //     .setTrustedCertificatesBytes(data.buffer.asUint8List());
  await dotenv.load(fileName: '.env');
  await EasyLocalization.ensureInitialized();
  sharedPrefsSingleton = await SharedPreferencesSingleton.getInstance();
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
  await settingsProvider.getSubtitleMode();
  await settingsProvider.getViewMode();
  await settingsProvider.getSubtitleSize();
  await settingsProvider.getForegroundSubtitleColor();
  await settingsProvider.getBackgroundSubtitleColor();
  await settingsProvider.getAppLanguage();
  await settingsProvider.getAppColorIndex();
  await settingsProvider.getProviderPrecedence();
  await settingsProvider.getPlayerTimeStyle();
  await settingsProvider.getUseProxyMode();
  await settingsProvider.getSubtitleStyle();
  await recentProvider.fetchMovies();
  await recentProvider.fetchEpisodes();
  await appDependencyProvider.getConsumetUrl();
  await appDependencyProvider.getFlixQuestLogo();
  await appDependencyProvider.getOpenSubKey();
  await appDependencyProvider.getStreamingServerFlixHQ();
  await appDependencyProvider.getStreamingServerDCVA();
  await appDependencyProvider.getStreamingServerZoro();
  await appDependencyProvider.getStreamRoute();
  await appDependencyProvider.getFQUrl();
  await appDependencyProvider.getTmdbProxy();

  await _initialization;
}

void main() async {
  await appInitialize();
  HttpOverrides.global = MyHttpOverrides();
  runApp(EasyLocalization(
    supportedLocales: Translation.all,
    path: 'assets/translations',
    fallbackLocale: Translation.all[0],
    startLocale: Locale(settingsProvider.appLanguage),
    child: FlixQuest(
      settingsProvider: settingsProvider,
      recentProvider: recentProvider,
      appDependencyProvider: appDependencyProvider,
      init: _initialization,
    ),
  ));
}
