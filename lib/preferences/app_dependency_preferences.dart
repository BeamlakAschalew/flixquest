// ignore_for_file: constant_identifier_names

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

class AppDependencies {
  static const FLIXQUEST_LOGO_URL = 'flixquestLogoUrl';
  static const FLIXQUEST_API_URL = 'flixquestAPIURL';
  static const TMDB_PROXY = 'tmdb_proxy';
  static const OCCASIONAL_THEME = 'occasionalTheme';
  static const OCCASIONAL_THEME_SELECTION = 'occasionalThemeSelection';
  static const OCCASIONAL_THEME_ENABLED = 'occasionalThemeEnabled';
  static const OCCASIONAL_EFFECTS_ENABLED = 'occasionalEffectsEnabled';
  static const AMBIENT_MODE_ENABLED = 'ambientModeEnabled';

  Future<void> setFlixQuestUrl(String value) async {
    await sharedPrefsSingleton.setString(FLIXQUEST_LOGO_URL, value);
  }

  Future<String> getFQURL() async {
    return sharedPrefsSingleton.getString(FLIXQUEST_API_URL) ?? flixquestApiUrl;
  }

  Future<void> setFlixquestAPIUrl(String value) async {
    await sharedPrefsSingleton.setString(FLIXQUEST_API_URL, value);
  }

  Future<String> getFlixQuestLogo() async {
    return sharedPrefsSingleton.getString(FLIXQUEST_LOGO_URL) ?? 'default';
  }

  Future<void> setTmdbProxy(String value) async {
    await sharedPrefsSingleton.setString(TMDB_PROXY, value);
  }

  Future<String> getTmdbProxy() async {
    return sharedPrefsSingleton.getString(TMDB_PROXY) ?? '';
  }

  Future<void> setOccasionalTheme(String value) async {
    await sharedPrefsSingleton.setString(OCCASIONAL_THEME, value);
  }

  Future<String> getOccasionalTheme() async {
    return sharedPrefsSingleton.getString(OCCASIONAL_THEME) ?? '';
  }

  Future<void> setOccasionalThemeSelection(String value) async {
    await sharedPrefsSingleton.setString(OCCASIONAL_THEME_SELECTION, value);
  }

  Future<String> getOccasionalThemeSelection() async {
    return sharedPrefsSingleton.getString(OCCASIONAL_THEME_SELECTION) ??
        'automatic';
  }

  Future<void> setOccasionalThemeEnabled(bool value) async {
    await sharedPrefsSingleton.setBool(OCCASIONAL_THEME_ENABLED, value);
  }

  Future<bool> getOccasionalThemeEnabled() async {
    return sharedPrefsSingleton.getBool(OCCASIONAL_THEME_ENABLED) ?? true;
  }

  Future<void> setOccasionalEffectsEnabled(bool value) async {
    await sharedPrefsSingleton.setBool(OCCASIONAL_EFFECTS_ENABLED, value);
  }

  Future<bool> getOccasionalEffectsEnabled() async {
    return sharedPrefsSingleton.getBool(OCCASIONAL_EFFECTS_ENABLED) ?? true;
  }

  Future<void> setAmbientModeEnabled(bool value) async {
    await sharedPrefsSingleton.setBool(AMBIENT_MODE_ENABLED, value);
  }

  Future<bool> getAmbientModeEnabled() async {
    return sharedPrefsSingleton.getBool(AMBIENT_MODE_ENABLED) ?? false;
  }
}
