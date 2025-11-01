import 'package:flixquest/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../constants/api_constants.dart';
import '../preferences/setting_preferences.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsPreferences _settingsPreferences = SettingsPreferences();

  bool _isAdult = false;
  bool get isAdult => _isAdult;

  bool _isMaterial3Enabled = false;
  bool get isMaterial3Enabled => _isMaterial3Enabled;

  String _appTheme = 'dark';
  String get appTheme => _appTheme;

  int _defaultValue = 0;
  int get defaultValue => _defaultValue;

  String _imageQuality = 'w500/';
  String get imageQuality => _imageQuality;

  String _defaultCountry = 'US';
  String get defaultCountry => _defaultCountry;

  String _defaultView = 'list';
  String get defaultView => _defaultView;

  int _defaultSeekDuration = 10;
  int get defaultSeekDuration => _defaultSeekDuration;

  int _playerTimeDisplay = 1;
  int get playerTimeDisplay => _playerTimeDisplay;

  // int _defaultMinBufferDuration = 120000;
  // int get defaultMinBufferDuration => _defaultMinBufferDuration;

  int _defaultMaxBufferDuration = 360000;
  int get defaultMaxBufferDuration => _defaultMaxBufferDuration;

  int _defaultVideoResolution = 0;
  int get defaultVideoResolution => _defaultVideoResolution;

  String _defaultSubtitleLanguage = 'en';
  String get defaultSubtitleLanguage => _defaultSubtitleLanguage;

  bool _defaultViewMode = true;
  bool get defaultViewMode => _defaultViewMode;

  late Mixpanel mixpanel;

  String _subtitleForegroundColor = Colors.white.toString();
  String get subtitleForegroundColor => _subtitleForegroundColor;

  String _subtitleBackgroundColor = Colors.black45.toString();
  String get subtitleBackgroundColor => _subtitleBackgroundColor;

  int _subtitleFontSize = 17;
  int get subtitleFontSize => _subtitleFontSize;

  String _appLanguage = 'en';
  String get appLanguage => _appLanguage;

  bool _fetchSpecificLangSubs = false;
  bool get fetchSpecificLangSubs => _fetchSpecificLangSubs;

  int _appColorIndex = -1;
  int get appColorIndex => _appColorIndex;

  String _proPrecedence = providerPreference;
  String get proPreference => _proPrecedence;

  bool _enableProxy = false;
  bool get enableProxy => _enableProxy;

  String _subtitleTextStyle = 'regular';
  String get subtitleTextStyle => _subtitleTextStyle;

  bool _enableNextEpisodeButton = true;
  bool get enableNextEpisodeButton => _enableNextEpisodeButton;

  // theme change
  Future<void> getCurrentThemeMode() async {
    appTheme = await _settingsPreferences.getThemeMode();
  }

  set appTheme(String value) {
    _appTheme = value;
    _settingsPreferences.setThemeMode(value);
    notifyListeners();
  }

  // material theme change
  Future<void> getCurrentMaterial3Mode() async {
    isMaterial3Enabled = await _settingsPreferences.getMaterial3Mode();
  }

  set isMaterial3Enabled(bool value) {
    _isMaterial3Enabled = value;
    _settingsPreferences.setMaterial3Mode(value);
    notifyListeners();
  }

  // adult preference change
  Future<void> getCurrentAdultMode() async {
    isAdult = await _settingsPreferences.getAdultMode();
  }

  set isAdult(bool value) {
    _isAdult = value;
    _settingsPreferences.setAdultMode(value);
    notifyListeners();
  }

  // screen preference
  Future<void> getCurrentDefaultScreen() async {
    defaultValue = await _settingsPreferences.getDefaultHome();
  }

  set defaultValue(int value) {
    _defaultValue = value;
    _settingsPreferences.setDefaultHome(value);
    notifyListeners();
  }

  // image preference
  Future<void> getCurrentImageQuality() async {
    imageQuality = await _settingsPreferences.getImageQuality();
  }

  set imageQuality(String value) {
    _imageQuality = value;
    _settingsPreferences.setImageQuality(value);
    notifyListeners();
  }

  // watch country
  Future<void> getCurrentWatchCountry() async {
    defaultCountry = await _settingsPreferences.getCountryName();
  }

  set defaultCountry(String value) {
    _defaultCountry = value;
    _settingsPreferences.setCountryName(value);
    notifyListeners();
  }

  // mixpanel
  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(mixpanelKey,
        optOutTrackingDefault: false, trackAutomaticEvents: true);
    notifyListeners();
  }

  // view preference
  Future<void> getCurrentViewType() async {
    defaultView = await _settingsPreferences.getViewType();
  }

  set defaultView(String value) {
    _defaultView = value;
    _settingsPreferences.setViewType(value);
    notifyListeners();
  }

  Future<void> getSeekDuration() async {
    defaultSeekDuration = await _settingsPreferences.getSeekDuraion();
  }

  set defaultSeekDuration(int value) {
    _defaultSeekDuration = value;
    _settingsPreferences.setSeekDuration(value);
    notifyListeners();
  }

  Future<void> getViewMode() async {
    defaultViewMode = await _settingsPreferences.autoFullScreen();
  }

  set defaultViewMode(bool value) {
    _defaultViewMode = value;
    _settingsPreferences.setDefaultFullScreen(value);
    notifyListeners();
  }

  // Future<void> getMinBufferDuration() async {
  //   defaultMinBufferDuration = await videoPlayerPreferences.getMinBuffer();
  // }

  // set defaultMinBufferDuration(int value) {
  //   _defaultMinBufferDuration = value;
  //   videoPlayerPreferences.setMinBufferDuration(value);
  //   notifyListeners();
  // }

  Future<void> getMaxBufferDuration() async {
    defaultMaxBufferDuration = await _settingsPreferences.getMaxBuffer();
  }

  set defaultMaxBufferDuration(int value) {
    _defaultMaxBufferDuration = value;
    _settingsPreferences.setMaxBufferDuration(value);
    notifyListeners();
  }

  Future<void> getVideoResolution() async {
    defaultVideoResolution =
        await _settingsPreferences.getDefaultVideoQuality();
  }

  set defaultVideoResolution(int value) {
    _defaultVideoResolution = value;
    _settingsPreferences.setDefaultVideoQuality(value);
    notifyListeners();
  }

  Future<void> getSubtitleLanguage() async {
    defaultSubtitleLanguage = await _settingsPreferences.getSubLanguage();
  }

  set defaultSubtitleLanguage(String value) {
    _defaultSubtitleLanguage = value;
    _settingsPreferences.setDefaultSubtitle(value);
    notifyListeners();
  }

  Future<void> getForegroundSubtitleColor() async {
    subtitleForegroundColor = await _settingsPreferences.subtitleForeground();
  }

  set subtitleForegroundColor(String value) {
    _subtitleForegroundColor = value;
    _settingsPreferences.setSubtitleForeground(value);
    notifyListeners();
  }

  Future<void> getBackgroundSubtitleColor() async {
    subtitleBackgroundColor = await _settingsPreferences.subtitleBackground();
  }

  set subtitleBackgroundColor(String value) {
    _subtitleBackgroundColor = value;
    _settingsPreferences.setSubtitleBackground(value);
    notifyListeners();
  }

  Future<void> getSubtitleSize() async {
    subtitleFontSize = await _settingsPreferences.subtitleFont();
  }

  set subtitleFontSize(int value) {
    _subtitleFontSize = value;
    _settingsPreferences.setSubtitleFont(value);
    notifyListeners();
  }

  Future<void> getAppLanguage() async {
    appLanguage = await _settingsPreferences.getAppLang();
  }

  set appLanguage(String value) {
    _appLanguage = value;
    _settingsPreferences.setAppLanguage(value);
    notifyListeners();
  }

  Future<void> getSubtitleMode() async {
    fetchSpecificLangSubs = await _settingsPreferences.getSubtitleMode();
  }

  set fetchSpecificLangSubs(bool value) {
    _fetchSpecificLangSubs = value;
    _settingsPreferences.setSubtitleMode(value);
    notifyListeners();
  }

  Future<void> getAppColorIndex() async {
    appColorIndex = await _settingsPreferences.getAppColorIndex();
  }

  set appColorIndex(int value) {
    _appColorIndex = value;
    _settingsPreferences.setAppColorIndex(value);
    notifyListeners();
  }

  Future<void> getPlayerTimeStyle() async {
    playerTimeDisplay = await _settingsPreferences.getPlayerStyleIndex();
  }

  set playerTimeDisplay(int value) {
    _playerTimeDisplay = value;
    _settingsPreferences.setPlayerStyleIndex(value);
    notifyListeners();
  }

  Future<void> getProviderPrecedence() async {
    proPreference = await _settingsPreferences.getProviderPrecedence();
  }

  set proPreference(String value) {
    _proPrecedence = value;
    _settingsPreferences.setProviderPrecedence(value);
    notifyListeners();
  }

  Future<void> getUseProxyMode() async {
    enableProxy = await _settingsPreferences.getUseProxy();
  }

  set enableProxy(bool value) {
    _enableProxy = value;
    _settingsPreferences.setUseProxy(value);
    notifyListeners();
  }

  Future<void> getSubtitleStyle() async {
    subtitleTextStyle = await _settingsPreferences.getSubtitleStyle();
  }

  set subtitleTextStyle(String value) {
    _subtitleTextStyle = value;
    _settingsPreferences.setSubtitleStyle(value);
    notifyListeners();
  }

  Future<void> getEnableNextEpisodeButton() async {
    enableNextEpisodeButton =
        await _settingsPreferences.getEnableNextEpisodeButton();
  }

  set enableNextEpisodeButton(bool value) {
    _enableNextEpisodeButton = value;
    _settingsPreferences.setEnableNextEpisodeButton(value);
    notifyListeners();
  }
}
