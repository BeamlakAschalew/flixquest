// ignore_for_file: constant_identifier_names
import 'package:shared_preferences/shared_preferences.dart';

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
