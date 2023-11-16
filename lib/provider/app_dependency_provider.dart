import '../constants/api_constants.dart';
import 'package:flutter/material.dart';
import '../models/app_dependency_preferences.dart';

class AppDependencyProvider extends ChangeNotifier {
  AppDependencies appDependencies = AppDependencies();

  String _consumetUrl = 'https://consumet.beamlak.dev';
  String get consumetUrl => _consumetUrl;

  String _flixQuestLogo = 'default';
  String get flixQuestLogo => _flixQuestLogo;

  String _opensubtitlesKey = openSubtitlesKey;
  String get opensubtitlesKey => _opensubtitlesKey;

  String _streamingServer = STREAMING_SERVER;
  String get streamingServer => _streamingServer;

  bool _enableADS = true;
  bool get enableADS => _enableADS;

  String _fetchRoute = "flixHQ";
  String get fetchRoute => _fetchRoute;

  bool _useExternalSubtitles = false;
  bool get useExternalSubtitles => _useExternalSubtitles;

  bool _enableOTTADS = true;
  bool get enableOTTADS => _enableOTTADS;

  bool _displayWatchNowButton = true;
  bool get displayWatchNowButton => _displayWatchNowButton;

  bool _displayOTTDrawer = true;
  bool get displayOTTDrawer => _displayOTTDrawer;

  Future<void> getConsumetUrl() async {
    consumetUrl = await appDependencies.getConsumetUrl();
  }

  set consumetUrl(String value) {
    _consumetUrl = value;
    appDependencies.setConsumetUrl(value);
    notifyListeners();
  }

  Future<void> getFlixQuestLogo() async {
    flixQuestLogo = await appDependencies.getFlixQuestLogo();
  }

  set flixQuestLogo(String value) {
    _flixQuestLogo = value;
    appDependencies.setFlixQuestUrl(value);
    notifyListeners();
  }

  Future<void> getOpenSubKey() async {
    opensubtitlesKey = await appDependencies.getOpenSubtitlesKey();
  }

  set opensubtitlesKey(String value) {
    _opensubtitlesKey = value;
    appDependencies.setOpenSubKey(value);
    notifyListeners();
  }

  Future<void> getStreamingServer() async {
    streamingServer = await appDependencies.getStreamServer();
  }

  set streamingServer(String value) {
    _streamingServer = value;
    appDependencies.setStreamServer(value);
    notifyListeners();
  }

  set enableADS(bool value) {
    _enableADS = value;
    notifyListeners();
  }

  Future<void> getStreamRoute() async {
    fetchRoute = await appDependencies.getStreamRoute();
  }

  set fetchRoute(String value) {
    _fetchRoute = value;
    appDependencies.setStreamRoute(value);
    notifyListeners();
  }

  set useExternalSubtitles(bool value) {
    _useExternalSubtitles = value;
    notifyListeners();
  }

  set enableOTTADS(bool value) {
    _enableOTTADS = value;
    notifyListeners();
  }

  set displayWatchNowButton(bool value) {
    _displayWatchNowButton = value;
    notifyListeners();
  }

  set displayOTTDrawer(bool value) {
    _displayOTTDrawer = value;
    notifyListeners();
  }
}
