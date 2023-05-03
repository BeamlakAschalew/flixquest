// ignore_for_file: constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';

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
