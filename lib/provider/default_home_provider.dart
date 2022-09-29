import '/models/default_screen_preferences.dart';
import 'package:flutter/material.dart';

class DeafultHomeProvider with ChangeNotifier {
  DefaultHomePreferences defaultHomePreferences = DefaultHomePreferences();
  int _defaultValue = 0;
  int get defaultValue => _defaultValue;

  set defaultValue(int value) {
    _defaultValue = value;
    defaultHomePreferences.setDefaultHome(value);
    notifyListeners();
  }
}
