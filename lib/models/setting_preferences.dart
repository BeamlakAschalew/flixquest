// ignore_for_file: constant_identifier_names
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
  static const MATERIAL3_MODE_STATUS = "adultStatus";

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
  static const THEME_MODE_STATUS = "themeStatus";

  setThemeMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_MODE_STATUS, value);
  }

  Future<bool> getThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_MODE_STATUS) ?? true;
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
    return prefs.getInt(MAX_BUFFER_PREFERENCE) ?? 240000;
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

  static const DEFAULT_SUBTITLE = 'default_subtitle';
  setDefaultSubtitle(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(DEFAULT_SUBTITLE, language);
  }
}
