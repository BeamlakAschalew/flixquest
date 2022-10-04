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
