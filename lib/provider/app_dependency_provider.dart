import 'package:flutter/material.dart';

import '../constants/api_constants.dart';
import '../preferences/app_dependency_preferences.dart';

class AppDependencyProvider extends ChangeNotifier {
  final AppDependencies _preferences = AppDependencies();

  String _flixquestAPIUrl = flixquestApiUrl;
  String get flixquestAPIURL => _flixquestAPIUrl;

  String _flixQuestLogo = 'default';
  String get flixQuestLogo => _flixQuestLogo;

  bool _displayWatchNowButton = true;
  bool get displayWatchNowButton => _displayWatchNowButton;

  bool _displayOTTDrawer = true;
  bool get displayOTTDrawer => _displayOTTDrawer;

  bool _isForcedUpdate = false;
  bool get isForcedUpdate => _isForcedUpdate;

  String _tmdbProxy = '';
  String get tmdbProxy => _tmdbProxy;

  Future<void> getFQUrl() async {
    flixquestAPIURL = await _preferences.getFQURL();
  }

  set flixquestAPIURL(String value) {
    _flixquestAPIUrl = value;
    _preferences.setFlixquestAPIUrl(value);
    notifyListeners();
  }

  Future<void> getFlixQuestLogo() async {
    flixQuestLogo = await _preferences.getFlixQuestLogo();
  }

  set flixQuestLogo(String value) {
    _flixQuestLogo = value;
    _preferences.setFlixQuestUrl(value);
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

  set isForcedUpdate(bool value) {
    _isForcedUpdate = value;
    notifyListeners();
  }

  Future<void> getTmdbProxy() async {
    tmdbProxy = await _preferences.getTmdbProxy();
  }

  set tmdbProxy(String value) {
    _tmdbProxy = value;
    _preferences.setTmdbProxy(value);
    notifyListeners();
  }
}
