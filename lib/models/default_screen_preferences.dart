// ignore_for_file: constant_identifier_names
import 'package:shared_preferences/shared_preferences.dart';

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
