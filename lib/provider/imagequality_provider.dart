import 'package:flutter/material.dart';

class ImagequalityProvider with ChangeNotifier {
  String _imageQuality = "w500/";
  String get imageQuality => _imageQuality;

  set imageQuality(String value) {
    _imageQuality = value;
    // adultModePreferences.setAdultMode(value);
    notifyListeners();
  }
}
