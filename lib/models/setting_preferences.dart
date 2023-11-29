// ignore_for_file: constant_identifier_names
import 'package:flixquest/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdultModePreferences {
  static const ADULT_MODE_STATUS = "adultStatus";

  setAdultMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(ADULT_MODE_STATUS, value);
  }

  Future<bool> getAdultMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(ADULT_MODE_STATUS) ?? false;
  }
}

class CountryPreferences {
  static const COUNTRY_STATUS = 'US';

  setCountryName(String countryName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(COUNTRY_STATUS, countryName);
  }

  Future<String> getCountryName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(COUNTRY_STATUS) ?? 'US';
  }
}

class DefaultHomePreferences {
  static const DEFAULT_SCREEN_STATUS = 'defaultStatus';
  setDefaultHome(int deafultHomeValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(DEFAULT_SCREEN_STATUS, deafultHomeValue);
  }

  Future<int> getDefaultHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(DEFAULT_SCREEN_STATUS) ?? 0;
  }
}

class ImagePreferences {
  static const IMAGE_QUALITY_STATUS = "w500/";
  setImageQuality(String imageQuality) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(IMAGE_QUALITY_STATUS, imageQuality);
  }

  Future<String> getImageQuality() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(IMAGE_QUALITY_STATUS) ?? "w500/";
  }
}

class Material3Preferences {
  static const MATERIAL3_MODE_STATUS = "materialStatus";

  setMaterial3Mode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(MATERIAL3_MODE_STATUS, value);
  }

  Future<bool> getMaterial3Mode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(MATERIAL3_MODE_STATUS) ?? false;
  }
}

class ThemeModePreferences {
  static const THEME_MODE_STATUS = "themeStatusV2";

  setThemeMode(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(THEME_MODE_STATUS, value);
  }

  Future<String> getThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(THEME_MODE_STATUS) ?? "dark";
  }
}

class ViewPreferences {
  static const VIEW_PREFERENCE_STATUS = "list";
  setViewType(String viewType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(VIEW_PREFERENCE_STATUS, viewType);
  }

  Future<String> getViewType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(VIEW_PREFERENCE_STATUS) ?? "grid";
  }
}

class VideoPlayerPreferences {
  static const SEEK_PREFERENCE = 'seek';
  setSeekDuration(int seekDuration) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(SEEK_PREFERENCE, seekDuration);
  }

  Future<int> getSeekDuraion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(SEEK_PREFERENCE) ?? 10;
  }

  // static const MIN_BUFFER_PREFERENCE = 'min_buffer';
  // setMinBufferDuration(int bufferDuration) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setInt(MIN_BUFFER_PREFERENCE, bufferDuration);
  // }

  // Future<int> getMinBuffer() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getInt(MIN_BUFFER_PREFERENCE) ?? 120000;
  // }

  static const MAX_BUFFER_PREFERENCE = 'max_buffer';
  setMaxBufferDuration(int bufferDuration) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(MAX_BUFFER_PREFERENCE, bufferDuration);
  }

  Future<int> getMaxBuffer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(MAX_BUFFER_PREFERENCE) ?? 360000;
  }

  static const DEFAULT_VIDEO_QUALITY = 'video_quality';
  setDefaultVideoQuality(int videoQuality) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(DEFAULT_VIDEO_QUALITY, videoQuality);
  }

  Future<int> getDefaultVideoQuality() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(DEFAULT_VIDEO_QUALITY) ?? 0;
  }

  static const DEFAULT_SUBTITLE = 'default_subtitle_v2';
  setDefaultSubtitle(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(DEFAULT_SUBTITLE, language);
  }

  Future<String> getSubLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(DEFAULT_SUBTITLE) ?? 'en';
  }

  static const DEFAULT_FULL_SCREEN = 'default_full_screen';
  setDefaultFullScreen(bool mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(DEFAULT_FULL_SCREEN, mode);
  }

  Future<bool> autoFullScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(DEFAULT_FULL_SCREEN) ?? true;
  }

  static const SUBTITLE_FOREGROUND_COLOR = 'subtitle_foreground_color';
  setSubtitleForeground(String color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SUBTITLE_FOREGROUND_COLOR, color);
  }

  Future<String> subtitleForeground() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SUBTITLE_FOREGROUND_COLOR) ?? 'Color(0xffffffff)';
  }

  static const SUBTITLE_BACKGROUND_COLOR = 'subtitle_background_color';
  setSubtitleBackground(String color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SUBTITLE_BACKGROUND_COLOR, color);
  }

  Future<String> subtitleBackground() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SUBTITLE_BACKGROUND_COLOR) ?? 'Color(0x73000000)';
  }

  static const SUBTITLE_FONT_SIZE = 'subtitle_font_size';
  setSubtitleFont(int size) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(SUBTITLE_FONT_SIZE, size);
  }

  Future<int> subtitleFont() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(SUBTITLE_FONT_SIZE) ?? 17;
  }

  static const SUBTITLE_MODE = 'subtitle_mode';
  setSubtitleMode(bool mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(SUBTITLE_MODE, mode);
  }

  Future<bool> getSubtitleMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SUBTITLE_MODE) ?? false;
  }
}

class AppLanguagePreferences {
  static const APP_LANGUAGE_CODE = 'en';

  setAppLanguage(String lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(APP_LANGUAGE_CODE, lang);
  }

  Future<String> getAppLang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(APP_LANGUAGE_CODE) ?? 'en';
  }
}

class AppColorPreferences {
  static const APP_COLOR_INDEX = "appColorIndex";

  setAppColorIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(APP_COLOR_INDEX, index);
  }

  Future<int> getAppColorIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(APP_COLOR_INDEX) ?? -1;
  }
}

class ProviderPrecedencePreference {
  static const PROVIDER_PRECEDENCE = "providerPrecedence";

  setProviderPrecedence(String pre) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PROVIDER_PRECEDENCE, pre);
  }

  Future<String> getProviderPrecedence() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PROVIDER_PRECEDENCE) ?? providerPreference;
  }
}
