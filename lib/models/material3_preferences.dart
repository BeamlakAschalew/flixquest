// ignore_for_file: constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';

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
