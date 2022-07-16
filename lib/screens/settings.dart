import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool adultModeFromShared = false;
  void adultCheck() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getBool('adultMode') == null ||
          prefs.getBool('adultMode') == false) {
        adultModeFromShared = false;
      } else if (prefs.getBool('adultMode') == true) {
        adultModeFromShared = true;
      }
      // print(adultModeFromShared);
    });
  }

  void updateAdultData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('adultMode', adultModeFromShared);
    });
  }

  @override
  void initState() {
    super.initState();
    adultCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Column(
          children: [
            SwitchListTile(
              activeColor: const Color(0xFFF57C00),
              value: adultModeFromShared,
              secondary: const Icon(Icons.explicit),
              title: const Text('Adult'),
              onChanged: (bool value) {
                setState(() {
                  adultModeFromShared = value;
                  updateAdultData();
                });
              },
            ),
          ],
        ));
  }
}
