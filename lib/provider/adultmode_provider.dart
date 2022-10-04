import 'package:cinemax/models/adultmode_preferences.dart';
import 'package:flutter/cupertino.dart';

class AdultmodeProvider with ChangeNotifier {
  AdultModePreferences adultModePreferences = AdultModePreferences();
  bool _isAdult = false;
  bool get isAdult => _isAdult;

  set isAdult(bool value) {
    _isAdult = value;
    adultModePreferences.setAdultMode(value);
    notifyListeners();
  }
}
