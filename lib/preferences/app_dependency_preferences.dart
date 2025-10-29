// ignore_for_file: constant_identifier_names

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

class AppDependencies {
  static const CONSUMET_URL_KEY = 'consumetUrlKey';
  static const NEW_FLIXHQ_URL = 'newFlixHQUrl';
  static const FLIXQUEST_LOGO_URL = 'flixquestLogoUrl';
  static const OPENSUBTITLES_KEY = 'opensubtitlesKey';
  static const STREAM_SERVER_FLIXHQ = 'vidcloud';
  static const STREAM_SERVER_DCVA = 'asianload';
  static const STREAM_SERVER_ZORO = 'vidcloud';
  static const SHOWBOX_URL = 'showbox_url';
  static const STREAM_ROUTE = 'streamRoute';
  static const FLIXQUEST_API_URL = 'flixquestAPIURL';
  static const TMDB_PROXY = 'tmdb_proxy';
  static const NEW_FLIXHQ_SERVER = 'megacloud';

  setConsumetUrl(String value) async {
    sharedPrefsSingleton.setString(CONSUMET_URL_KEY, value);
  }

  Future<String> getConsumetUrl() async {
    return sharedPrefsSingleton.getString(CONSUMET_URL_KEY) ??
        'https://consumet.beamlak.dev/';
  }

  setNewFlixHQUrl(String value) async {
    sharedPrefsSingleton.setString(NEW_FLIXHQ_URL, value);
  }

  Future<String> getNewFlixHQUrl() async {
    return sharedPrefsSingleton.getString(NEW_FLIXHQ_URL) ??
        'https://flixhq.beamlak.dev/';
  }

  setFlixQuestUrl(String value) async {
    sharedPrefsSingleton.setString(FLIXQUEST_LOGO_URL, value);
  }

  Future<String> getFQURL() async {
    return sharedPrefsSingleton.getString(FLIXQUEST_API_URL) ??
        'https://flixquest-api.beamlak.dev/';
  }

  setFlixquestAPIUrl(String value) async {
    sharedPrefsSingleton.setString(FLIXQUEST_API_URL, value);
  }

  Future<String> getFlixQuestLogo() async {
    return sharedPrefsSingleton.getString(FLIXQUEST_LOGO_URL) ?? 'default';
  }

  setOpenSubKey(String value) async {
    sharedPrefsSingleton.setString(OPENSUBTITLES_KEY, value);
  }

  Future<String> getOpenSubtitlesKey() async {
    return sharedPrefsSingleton.getString(OPENSUBTITLES_KEY) ??
        openSubtitlesKey;
  }

  setStreamServerFlixHQ(String value) async {
    sharedPrefsSingleton.setString(STREAM_SERVER_FLIXHQ, value);
  }

  Future<String> getStreamServerFlixHQ() async {
    return sharedPrefsSingleton.getString(STREAM_SERVER_FLIXHQ) ??
        STREAMING_SERVER_FLIXHQ;
  }

  setStreamServerNewFlixHQ(String value) async {
    sharedPrefsSingleton.setString(NEW_FLIXHQ_SERVER, value);
  }

  Future<String> getStreamServerNewFlixHQ() async {
    return sharedPrefsSingleton.getString(NEW_FLIXHQ_SERVER) ??
        STREAMING_SERVER_NEW_FLIXHQ;
  }

  setStreamServerDCVA(String value) async {
    sharedPrefsSingleton.setString(STREAM_SERVER_DCVA, value);
  }

  Future<String> getStreamServerDCVA() async {
    return sharedPrefsSingleton.getString(STREAM_SERVER_DCVA) ??
        STREAMING_SERVER_DCVA;
  }

  Future<bool> enableAD(bool enable) async {
    return enable;
  }

  Future<String> getShowboxUrl() async {
    return sharedPrefsSingleton.getString(SHOWBOX_URL) ?? '';
  }

  setShowboxUrl(String value) async {
    sharedPrefsSingleton.setString(SHOWBOX_URL, value);
  }

  Future<String> getStreamRoute() async {
    return sharedPrefsSingleton.getString(STREAM_ROUTE) ?? 'flixHQ';
  }

  setStreamRoute(String value) async {
    sharedPrefsSingleton.setString(STREAM_ROUTE, value);
  }

  setStreamServerZoro(String value) async {
    sharedPrefsSingleton.setString(STREAM_SERVER_ZORO, value);
  }

  Future<String> getStreamServerZoro() async {
    return sharedPrefsSingleton.getString(STREAM_SERVER_ZORO) ??
        STREAMING_SERVER_ZORO;
  }

  setTmdbProxy(String value) async {
    sharedPrefsSingleton.setString(TMDB_PROXY, value);
  }

  Future<String> getTmdbProxy() async {
    return sharedPrefsSingleton.getString(TMDB_PROXY) ?? '';
  }
}
