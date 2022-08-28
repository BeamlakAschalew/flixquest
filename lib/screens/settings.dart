import 'package:cinemax/models/image_preferences.dart';
import 'package:cinemax/provider/adultmode_provider.dart';
import 'package:cinemax/provider/darktheme_provider.dart';
import 'package:cinemax/provider/imagequality_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String initialDropdownValue = 'w500';
  @override
  Widget build(BuildContext context) {
    final adultChange = Provider.of<AdultmodeProvider>(context);
    final themeChange = Provider.of<DarkthemeProvider>(context);
    final imagequalityChange = Provider.of<ImagequalityProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            activeColor: const Color(0xFFF57C00),
            value: adultChange.isAdult,
            secondary: const Icon(
              Icons.explicit,
              color: Color(0xFFF57C00),
            ),
            title: const Text('Include Adult'),
            onChanged: (bool value) {
              setState(() {
                adultChange.isAdult = value;
              });
            },
          ),
          SwitchListTile(
            activeColor: const Color(0xFFF57C00),
            value: themeChange.darktheme,
            secondary: const Icon(
              Icons.dark_mode,
              color: Color(0xFFF57C00),
            ),
            title: const Text('Dark mode'),
            onChanged: (bool value) {
              setState(() {
                themeChange.darktheme = value;
              });
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.image,
              color: const Color(0xFFF57C00),
            ),
            title: const Text('Image quality'),
            trailing: DropdownButton(
                value: imagequalityChange.imageQuality,
                items: const [
                  DropdownMenuItem(child: Text('High'), value: 'original/'),
                  DropdownMenuItem(
                    child: Text('Medium'),
                    value: 'w600_and_h900_bestv2/',
                  ),
                  DropdownMenuItem(
                    child: Text('Low'),
                    value: 'w500/',
                  )
                ],
                onChanged: (String? value) {
                  setState(() {
                    imagequalityChange.imageQuality = value!;
                    print(imagequalityChange.imageQuality);
                  });
                }),
          ),
        ],
      ),
    );
  }
}
