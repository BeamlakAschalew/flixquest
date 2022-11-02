import 'package:cinemax/models/adultmode_preferences.dart';
import 'package:flutter/cupertino.dart';

class AdultmodeProvider with ChangeNotifier {
  AdultModePreferences adultModePreferences = AdultModePreferences();

  Future<void> getCurrentAdultMode() async {
    isAdult = await adultModePreferences.getAdultMode();
  }

  bool _isAdult = false;
  bool get isAdult => _isAdult;

  set isAdult(bool value) {
    _isAdult = value;
    adultModePreferences.setAdultMode(value);
    notifyListeners();
  }
}
