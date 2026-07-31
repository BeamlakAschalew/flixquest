import 'dart:io';
import 'package:flixquest/flixquest_main.dart';
import '../models/translation.dart';
import '../provider/app_dependency_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:media_kit/media_kit.dart';
import 'constants/app_constants.dart';
import 'functions/function.dart';
import 'provider/bookmark_provider.dart';
import 'provider/recently_watched_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'provider/settings_provider.dart';
import 'services/bookmark_sync_service.dart';
import 'singleton/sharedpreferences_singleton.dart';
import 'tv/platform/device_presentation.dart';
import 'tv/platform/device_presentation_detector.dart';

@pragma('vm:entry-point')
Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

bool isTablet(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double threshold = 1000.0;
  return screenWidth > threshold;
}

SettingsProvider settingsProvider = SettingsProvider();
RecentProvider recentProvider = RecentProvider();
BookmarkProvider bookmarkProvider = BookmarkProvider();
AppDependencyProvider appDependencyProvider = AppDependencyProvider();
final Future<FirebaseApp> _initialization = Firebase.initializeApp();

Future<DevicePresentation> appInitialize({
  DevicePresentationDetector? devicePresentationDetector,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase-dependent services and providers must not be accessed until the
  // default app has finished initializing.
  await _initialization;

  final devicePresentation = await resolveDevicePresentation(
    detector: devicePresentationDetector,
  );

  // Initialize MediaKit for video playback with multiple codec support
  // MediaKit.ensureInitialized();

  // Reset orientation to all orientations on app start
  // This is CRITICAL for handling ungraceful app termination (force-close, system kill)
  // When the app is killed while streaming in landscape mode, this ensures
  // orientation is reset on next app launch since dispose() never gets called
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ByteData data =
  //     await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  // SecurityContext.defaultContext
  //     .setTrustedCertificatesBytes(data.buffer.asUint8List());
  await dotenv.load(fileName: '.env');
  await EasyLocalization.ensureInitialized();
  sharedPrefsSingleton = await SharedPreferencesSingleton.getInstance();
  await clearVideoPlaybackCache();
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
  await settingsProvider.getPlayerTimeStyle();
  await settingsProvider.getUseProxyMode();
  await settingsProvider.getSubtitleStyle();
  await settingsProvider.getEnableNextEpisodeButton();
  await recentProvider.fetchMovies();
  await recentProvider.fetchEpisodes();
  await bookmarkProvider.fetchBookmarks();
  await appDependencyProvider.getFlixQuestLogo();
  await appDependencyProvider.getFQUrl();
  await appDependencyProvider.getTmdbProxy();

  await BookmarkSyncService.instance.init();

  return devicePresentation;
}

void main() async {
  final devicePresentation = await appInitialize();
  HttpOverrides.global = MyHttpOverrides();
  runApp(EasyLocalization(
    supportedLocales: Translation.all,
    path: 'assets/translations',
    fallbackLocale: Translation.all[0],
    startLocale: Locale(settingsProvider.appLanguage),
    child: FlixQuest(
      settingsProvider: settingsProvider,
      recentProvider: recentProvider,
      bookmarkProvider: bookmarkProvider,
      appDependencyProvider: appDependencyProvider,
      devicePresentation: devicePresentation,
      init: _initialization,
    ),
  ));
}
