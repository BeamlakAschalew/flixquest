// ignore_for_file: constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';

class AppDependencies {
  static const CONSUMET_URL_KEY = "consumetUrlKey";
  static const CINEMAX_LOGO_URL = "cinemaxLogoUrl";

  setConsumetUrl(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(CONSUMET_URL_KEY, value);
  }

  Future<String> getConsumetUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(CONSUMET_URL_KEY) ?? 'https://consumet.beamlak.dev';
  }

  setCinemaxUrl(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(CINEMAX_LOGO_URL, value);
  }

  Future<String> getCinemaxLogo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(CINEMAX_LOGO_URL) ?? 'default';
  }
}
