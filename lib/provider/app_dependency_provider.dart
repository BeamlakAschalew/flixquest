import 'package:flutter/material.dart';
import '../models/app_dependency_preferences.dart';

class AppDependencyProvider extends ChangeNotifier {
  AppDependencies appDependencies = AppDependencies();

  String _consumetUrl = 'https://consumet.beamlak.dev';
  String get consumetUrl => _consumetUrl;

  String _cinemaxLogo = 'default';
  String get cinemaxLogo => _cinemaxLogo;

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
}
