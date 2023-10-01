// ignore_for_file: avoid_unnecessary_containers
import 'package:cinemax/models/translation.dart';
import 'package:cinemax/provider/app_dependency_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'cinemax_main.dart';
import 'functions/function.dart';
import 'provider/recently_watched_provider.dart';
import 'package:flutter/material.dart';
import 'provider/settings_provider.dart';

SettingsProvider settingsProvider = SettingsProvider();
RecentProvider recentProvider = RecentProvider();
AppDependencyProvider appDependencyProvider = AppDependencyProvider();

final Future<FirebaseApp> _initialization = Firebase.initializeApp();

void main() async {
  await appInitialize(_initialization);
  runApp(EasyLocalization(
    supportedLocales: Translation.all,
    path: 'assets/translations',
    fallbackLocale: Translation.all[0],
    startLocale: Locale(settingsProvider.appLanguage),
    child: Cinemax(
      settingsProvider: settingsProvider,
      recentProvider: recentProvider,
      appDependencyProvider: appDependencyProvider,
      init: _initialization,
    ),
  ));
}
