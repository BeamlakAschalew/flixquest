import '/models/adultmode_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../constants/api_constants.dart';
import '../models/default_screen_preferences.dart';
import '../models/image_preferences.dart';
import '../models/theme_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeModePreferences themeModePreferences = ThemeModePreferences();
  AdultModePreferences adultModePreferences = AdultModePreferences();
  DefaultHomePreferences defaultHomePreferences = DefaultHomePreferences();
  ImagePreferences imagePreferences = ImagePreferences();

  bool _isAdult = false;
  bool get isAdult => _isAdult;

  bool _darktheme = false;
  bool get darktheme => _darktheme;

  int _defaultValue = 0;
  int get defaultValue => _defaultValue;

  String _imageQuality = "w500/";
  String get imageQuality => _imageQuality;

  late Mixpanel mixpanel;

  // theme change
  Future<void> getCurrentThemeMode() async {
    darktheme = await themeModePreferences.getThemeMode();
  }

  set darktheme(bool value) {
    _darktheme = value;
    themeModePreferences.setThemeMode(value);
    notifyListeners();
  }

  // adult preference change
  Future<void> getCurrentAdultMode() async {
    isAdult = await adultModePreferences.getAdultMode();
  }

  set isAdult(bool value) {
    _isAdult = value;
    adultModePreferences.setAdultMode(value);
    notifyListeners();
  }

  // screen preference
  Future<void> getCurrentDefaultScreen() async {
    defaultValue = await defaultHomePreferences.getDefaultHome();
  }

  set defaultValue(int value) {
    _defaultValue = value;
    defaultHomePreferences.setDefaultHome(value);
    notifyListeners();
  }

  // image preference
  Future<void> getCurrentImageQuality() async {
    imageQuality = await imagePreferences.getImageQuality();
  }

  set imageQuality(String value) {
    _imageQuality = value;
    imagePreferences.setImageQuality(value);
    notifyListeners();
  }

  // mixpanel
  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(mixpanelKey,
        optOutTrackingDefault: false, trackAutomaticEvents: true);
    notifyListeners();
  }
}
