import 'package:flutter/material.dart';

class DarkthemeProvider with ChangeNotifier {
  bool _darktheme = true;
  bool get darktheme => _darktheme;

  set darktheme(bool value) {
    _darktheme = value;
    notifyListeners();
  }
}
