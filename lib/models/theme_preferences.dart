// ignore_for_file: constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';

class ThemeModePreferences {
  static const THEME_MODE_STATUS = "themeStatus";

  setThemeMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_MODE_STATUS, value);
  }

  Future<bool> getThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_MODE_STATUS) ?? false;
  }
}
