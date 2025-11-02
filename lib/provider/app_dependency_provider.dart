import '../constants/api_constants.dart';
import 'package:flutter/material.dart';
import '../preferences/app_dependency_preferences.dart';

class AppDependencyProvider extends ChangeNotifier {
  final AppDependencies __appDependencies = AppDependencies();

  String _consumetUrl = CONSUMET_API;
  String get consumetUrl => _consumetUrl;

  String _newFlixHQUrl = flixhqNewUrl;
  String get newFlixHQUrl => _newFlixHQUrl;

  String _flixApiUrl = flixAPIUrl;
  String get flixApiUrl => _flixApiUrl;

  String _flixquestAPIUrl = flixquestApiUrl;
  String get flixquestAPIURL => _flixquestAPIUrl;

  String _flixQuestLogo = 'default';
  String get flixQuestLogo => _flixQuestLogo;

  String _opensubtitlesKey = openSubtitlesKey;
  String get opensubtitlesKey => _opensubtitlesKey;

  String _streamingServerFlixHQ = STREAMING_SERVER_FLIXHQ;
  String get streamingServerFlixHQ => _streamingServerFlixHQ;

  String _streamingServerDCVA = STREAMING_SERVER_DCVA;
  String get streamingServerDCVA => _streamingServerDCVA;

  String _streamingServerZoro = STREAMING_SERVER_ZORO;
  String get streamingServerZoro => _streamingServerZoro;

  bool _enableADS = true;
  bool get enableADS => _enableADS;

  String _fetchRoute = 'flixHQ';
  String get fetchRoute => _fetchRoute;

  bool _useExternalSubtitles = false;
  bool get useExternalSubtitles => _useExternalSubtitles;

  bool _enableOTTADS = true;
  bool get enableOTTADS => _enableOTTADS;

  bool _displayWatchNowButton = true;
  bool get displayWatchNowButton => _displayWatchNowButton;

  bool _displayOTTDrawer = true;
  bool get displayOTTDrawer => _displayOTTDrawer;

  bool _isForcedUpdate = false;
  bool get isForcedUpdate => _isForcedUpdate;

  String _flixhqZoeServer = 'vidcloud';
  String get flixhqZoeServer => _flixhqZoeServer;

  String _newFlixhqServer = 'megacloud';
  String get newFlixhqServer => _newFlixhqServer;

  String _goMoviesServer = 'upcloud';
  String get goMoviesServer => _goMoviesServer;

  String _vidSrcToServer = 'vidplay';
  String get vidSrcToServer => _vidSrcToServer;

  String _vidSrcServer = 'vidsrcembed';
  String get vidSrcServer => _vidSrcServer;

  String _tmdbProxy = '';
  String get tmdbProxy => _tmdbProxy;

  bool _fetchSubtitles = true;
  bool get fetchSubtitles => _fetchSubtitles;

  Future<void> getConsumetUrl() async {
    consumetUrl = await __appDependencies.getConsumetUrl();
  }

  set consumetUrl(String value) {
    _consumetUrl = value;
    __appDependencies.setConsumetUrl(value);
    notifyListeners();
  }

  Future<void> getNewFlixHQUrl() async {
    newFlixHQUrl = await __appDependencies.getNewFlixHQUrl();
  }

  set newFlixHQUrl(String value) {
    _newFlixHQUrl = value;
    __appDependencies.setNewFlixHQUrl(value);
    notifyListeners();
  }

  Future<void> getFlixApiUrl() async {
    flixApiUrl = await __appDependencies.getFlixApiUrl();
  }

  set flixApiUrl(String value) {
    _flixApiUrl = value;
    __appDependencies.setFlixApiUrl(value);
    notifyListeners();
  }

  Future<void> getFQUrl() async {
    flixquestAPIURL = await __appDependencies.getFQURL();
  }

  set flixquestAPIURL(String value) {
    _flixquestAPIUrl = value;
    __appDependencies.setFlixquestAPIUrl(value);
    notifyListeners();
  }

  Future<void> getFlixQuestLogo() async {
    flixQuestLogo = await __appDependencies.getFlixQuestLogo();
  }

  set flixQuestLogo(String value) {
    _flixQuestLogo = value;
    __appDependencies.setFlixQuestUrl(value);
    notifyListeners();
  }

  Future<void> getOpenSubKey() async {
    opensubtitlesKey = await __appDependencies.getOpenSubtitlesKey();
  }

  set opensubtitlesKey(String value) {
    _opensubtitlesKey = value;
    __appDependencies.setOpenSubKey(value);
    notifyListeners();
  }

  Future<void> getStreamingServerFlixHQ() async {
    streamingServerFlixHQ = await __appDependencies.getStreamServerFlixHQ();
  }

  set streamingServerFlixHQ(String value) {
    _streamingServerFlixHQ = value;
    __appDependencies.setStreamServerFlixHQ(value);
    notifyListeners();
  }

  Future<void> getStreamingServerDCVA() async {
    streamingServerDCVA = await __appDependencies.getStreamServerDCVA();
  }

  set streamingServerDCVA(String value) {
    _streamingServerDCVA = value;
    __appDependencies.setStreamServerDCVA(value);
    notifyListeners();
  }

  Future<void> getStreamingServerZoro() async {
    streamingServerZoro = await __appDependencies.getStreamServerZoro();
  }

  set streamingServerZoro(String value) {
    _streamingServerZoro = value;
    __appDependencies.setStreamServerZoro(value);
    notifyListeners();
  }

  set enableADS(bool value) {
    _enableADS = value;
    notifyListeners();
  }

  Future<void> getStreamRoute() async {
    fetchRoute = await __appDependencies.getStreamRoute();
  }

  set fetchRoute(String value) {
    _fetchRoute = value;
    __appDependencies.setStreamRoute(value);
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

  set isForcedUpdate(bool value) {
    _isForcedUpdate = value;
    notifyListeners();
  }

  set goMoviesServer(String value) {
    _goMoviesServer = value;
    notifyListeners();
  }

  set flixhqZoeServer(String value) {
    _flixhqZoeServer = value;
    notifyListeners();
  }

  set newFlixhqServer(String value) {
    _newFlixhqServer = value;
    notifyListeners();
  }

  set vidSrcServer(String value) {
    _vidSrcServer = value;
    notifyListeners();
  }

  set vidSrcToServer(String value) {
    _vidSrcToServer = value;
    notifyListeners();
  }

  set fetchSubtitles(bool value) {
    _fetchSubtitles = value;
    notifyListeners();
  }

  Future<void> getTmdbProxy() async {
    tmdbProxy = await __appDependencies.getTmdbProxy();
  }

  set tmdbProxy(String value) {
    _tmdbProxy = value;
    __appDependencies.setTmdbProxy(value);
    notifyListeners();
  }
}
