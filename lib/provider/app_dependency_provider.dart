import 'package:cinemax/constants/api_constants.dart';
import 'package:flutter/material.dart';
import '../models/app_dependency_preferences.dart';

class AppDependencyProvider extends ChangeNotifier {
  AppDependencies appDependencies = AppDependencies();

  String _consumetUrl = 'https://consumet.beamlak.dev';
  String get consumetUrl => _consumetUrl;

  String _cinemaxLogo = 'default';
  String get cinemaxLogo => _cinemaxLogo;

  String _opensubtitlesKey = openSubtitlesKey;
  String get opensubtitlesKey => _opensubtitlesKey;

  String _streamingServer = STREAMING_SERVER;
  String get streamingServer => _streamingServer;

  bool _enableADS = false;
  bool get enableADS => _enableADS;

  String _fetchRoute = "tmDB";
  String get fetchRoute => _fetchRoute;

  Future<void> getConsumetUrl() async {
    consumetUrl = await appDependencies.getConsumetUrl();
  }

  set consumetUrl(String value) {
    _consumetUrl = value;
    appDependencies.setConsumetUrl(value);
    notifyListeners();
  }

  Future<void> getCinemaxLogo() async {
    cinemaxLogo = await appDependencies.getCinemaxLogo();
  }

  set cinemaxLogo(String value) {
    _cinemaxLogo = value;
    appDependencies.setCinemaxUrl(value);
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

  set fetchRoute(String value) {
    _fetchRoute = value;
    notifyListeners();
  }
}
