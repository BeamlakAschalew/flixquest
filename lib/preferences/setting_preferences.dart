// ignore_for_file: constant_identifier_names
import 'package:flixquest/constants/app_constants.dart';

class SettingsPreferences {
  static const ADULT_MODE_STATUS = 'adultStatus-v2';

  setAdultMode(bool value) async {
    sharedPrefsSingleton.setBool(ADULT_MODE_STATUS, value);
  }

  Future<bool> getAdultMode() async {
    return sharedPrefsSingleton.getBool(ADULT_MODE_STATUS) ?? false;
  }

  static const COUNTRY_STATUS = 'US';

  setCountryName(String countryName) async {
    sharedPrefsSingleton.setString(COUNTRY_STATUS, countryName);
  }

  Future<String> getCountryName() async {
    return sharedPrefsSingleton.getString(COUNTRY_STATUS) ?? 'US';
  }

  static const DEFAULT_SCREEN_STATUS = 'defaultStatus';
  setDefaultHome(int deafultHomeValue) async {
    sharedPrefsSingleton.setInt(DEFAULT_SCREEN_STATUS, deafultHomeValue);
  }

  Future<int> getDefaultHome() async {
    return sharedPrefsSingleton.getInt(DEFAULT_SCREEN_STATUS) ?? 0;
  }

  static const IMAGE_QUALITY_STATUS = 'w500/';
  setImageQuality(String imageQuality) async {
    sharedPrefsSingleton.setString(IMAGE_QUALITY_STATUS, imageQuality);
  }

  Future<String> getImageQuality() async {
    return sharedPrefsSingleton.getString(IMAGE_QUALITY_STATUS) ?? 'w500/';
  }

  static const MATERIAL3_MODE_STATUS = 'materialStatus';

  setMaterial3Mode(bool value) async {
    sharedPrefsSingleton.setBool(MATERIAL3_MODE_STATUS, value);
  }

  Future<bool> getMaterial3Mode() async {
    return sharedPrefsSingleton.getBool(MATERIAL3_MODE_STATUS) ?? false;
  }

  static const THEME_MODE_STATUS = 'themeStatusV2';

  setThemeMode(String value) async {
    sharedPrefsSingleton.setString(THEME_MODE_STATUS, value);
  }

  Future<String> getThemeMode() async {
    return sharedPrefsSingleton.getString(THEME_MODE_STATUS) ?? 'dark';
  }

  static const VIEW_PREFERENCE_STATUS = 'list';
  setViewType(String viewType) async {
    sharedPrefsSingleton.setString(VIEW_PREFERENCE_STATUS, viewType);
  }

  Future<String> getViewType() async {
    return sharedPrefsSingleton.getString(VIEW_PREFERENCE_STATUS) ?? 'grid';
  }

  static const SEEK_PREFERENCE = 'seek';
  setSeekDuration(int seekDuration) async {
    sharedPrefsSingleton.setInt(SEEK_PREFERENCE, seekDuration);
  }

  Future<int> getSeekDuraion() async {
    return sharedPrefsSingleton.getInt(SEEK_PREFERENCE) ?? 10;
  }

  // static const MIN_BUFFER_PREFERENCE = 'min_buffer';
  // setMinBufferDuration(int bufferDuration) async {
  //
  //   sharedPrefsSingleton.setInt(MIN_BUFFER_PREFERENCE, bufferDuration);
  // }

  // Future<int> getMinBuffer() async {
  //
  //   return sharedPrefsSingleton.getInt(MIN_BUFFER_PREFERENCE) ?? 120000;
  // }

  static const MAX_BUFFER_PREFERENCE = 'max_buffer';
  setMaxBufferDuration(int bufferDuration) async {
    sharedPrefsSingleton.setInt(MAX_BUFFER_PREFERENCE, bufferDuration);
  }

  Future<int> getMaxBuffer() async {
    return sharedPrefsSingleton.getInt(MAX_BUFFER_PREFERENCE) ?? 360000;
  }

  static const DEFAULT_VIDEO_QUALITY = 'video_quality';
  setDefaultVideoQuality(int videoQuality) async {
    sharedPrefsSingleton.setInt(DEFAULT_VIDEO_QUALITY, videoQuality);
  }

  Future<int> getDefaultVideoQuality() async {
    return sharedPrefsSingleton.getInt(DEFAULT_VIDEO_QUALITY) ?? 0;
  }

  static const DEFAULT_SUBTITLE = 'default_subtitle_v2';
  setDefaultSubtitle(String language) async {
    sharedPrefsSingleton.setString(DEFAULT_SUBTITLE, language);
  }

  Future<String> getSubLanguage() async {
    return sharedPrefsSingleton.getString(DEFAULT_SUBTITLE) ?? 'en';
  }

  static const DEFAULT_FULL_SCREEN = 'default_full_screen';
  setDefaultFullScreen(bool mode) async {
    sharedPrefsSingleton.setBool(DEFAULT_FULL_SCREEN, mode);
  }

  Future<bool> autoFullScreen() async {
    return sharedPrefsSingleton.getBool(DEFAULT_FULL_SCREEN) ?? true;
  }

  static const SUBTITLE_FOREGROUND_COLOR = 'subtitle_foreground_color';
  setSubtitleForeground(String color) async {
    sharedPrefsSingleton.setString(SUBTITLE_FOREGROUND_COLOR, color);
  }

  Future<String> subtitleForeground() async {
    return sharedPrefsSingleton.getString(SUBTITLE_FOREGROUND_COLOR) ??
        'Color(0xffffffff)';
  }

  static const SUBTITLE_BACKGROUND_COLOR = 'subtitle_background_color';
  setSubtitleBackground(String color) async {
    sharedPrefsSingleton.setString(SUBTITLE_BACKGROUND_COLOR, color);
  }

  Future<String> subtitleBackground() async {
    return sharedPrefsSingleton.getString(SUBTITLE_BACKGROUND_COLOR) ??
        'Color(0x73000000)';
  }

  static const SUBTITLE_FONT_SIZE = 'subtitle_font_size';
  setSubtitleFont(int size) async {
    sharedPrefsSingleton.setInt(SUBTITLE_FONT_SIZE, size);
  }

  Future<int> subtitleFont() async {
    return sharedPrefsSingleton.getInt(SUBTITLE_FONT_SIZE) ?? 17;
  }

  static const SUBTITLE_MODE = 'subtitle_mode';
  setSubtitleMode(bool mode) async {
    sharedPrefsSingleton.setBool(SUBTITLE_MODE, mode);
  }

  Future<bool> getSubtitleMode() async {
    return sharedPrefsSingleton.getBool(SUBTITLE_MODE) ?? false;
  }

  static const APP_LANGUAGE_CODE = 'en';

  setAppLanguage(String lang) async {
    sharedPrefsSingleton.setString(APP_LANGUAGE_CODE, lang);
  }

  Future<String> getAppLang() async {
    return sharedPrefsSingleton.getString(APP_LANGUAGE_CODE) ?? 'en';
  }

  static const APP_COLOR_INDEX = 'appColorIndex';

  setAppColorIndex(int index) async {
    sharedPrefsSingleton.setInt(APP_COLOR_INDEX, index);
  }

  Future<int> getAppColorIndex() async {
    return sharedPrefsSingleton.getInt(APP_COLOR_INDEX) ?? -1;
  }

  static const PROVIDER_PRECEDENCE = 'providerPrecedence-v8';

  setProviderPrecedence(String pre) async {
    sharedPrefsSingleton.setString(PROVIDER_PRECEDENCE, pre);
  }

  Future<String> getProviderPrecedence() async {
    return sharedPrefsSingleton.getString(PROVIDER_PRECEDENCE) ??
        providerPreference;
  }

  static const PLAYER_STYLE_INDEX = 'playerStyleIndex';

  setPlayerStyleIndex(int index) async {
    sharedPrefsSingleton.setInt(PLAYER_STYLE_INDEX, index);
  }

  Future<int> getPlayerStyleIndex() async {
    return sharedPrefsSingleton.getInt(PLAYER_STYLE_INDEX) ?? 1;
  }

  static const USE_PROXY = 'use_proxy';

  setUseProxy(bool useProxy) {
    sharedPrefsSingleton.setBool(USE_PROXY, useProxy);
  }

  Future<bool> getUseProxy() async {
    return sharedPrefsSingleton.getBool(USE_PROXY) ?? false;
  }

  static const SUBTITLE_TEXT_STYLE = 'subtitle_text_style';

  setSubtitleStyle(String value) {
    sharedPrefsSingleton.setString(SUBTITLE_TEXT_STYLE, value);
  }

  Future<String> getSubtitleStyle() async {
    return sharedPrefsSingleton.getString(SUBTITLE_TEXT_STYLE) ?? 'regular';
  }

  static const ENABLE_NEXT_EPISODE_BUTTON = 'enable_next_episode_button';

  setEnableNextEpisodeButton(bool value) {
    sharedPrefsSingleton.setBool(ENABLE_NEXT_EPISODE_BUTTON, value);
  }

  Future<bool> getEnableNextEpisodeButton() async {
    return sharedPrefsSingleton.getBool(ENABLE_NEXT_EPISODE_BUTTON) ?? false;
  }
}
