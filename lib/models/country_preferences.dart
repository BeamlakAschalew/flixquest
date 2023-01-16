// ignore_for_file: constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';

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
