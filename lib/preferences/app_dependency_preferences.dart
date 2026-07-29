// ignore_for_file: constant_identifier_names

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

class AppDependencies {
  static const FLIXQUEST_LOGO_URL = 'flixquestLogoUrl';
  static const FLIXQUEST_API_URL = 'flixquestAPIURL';
  static const TMDB_PROXY = 'tmdb_proxy';

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
}
