import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import '/models/watchprovider_countries.dart';
import '/screens/common/country_choose.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'player_settings.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String initialDropdownValue = 'w500';
  int initialHomeScreenValue = 0;
  CountryData countryData = CountryData();
  String? countryFlag;
  String? countryName;
  String? release;
  bool isBelow33 = true;

  void androidVersionCheck() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      if (sdkInt >= 33) {
        setState(() {
          isBelow33 = false;
        });
      }
    }
  }

  @override
  void initState() {
    androidVersionCheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final adultChange = Provider.of<SettingsProvider>(context);
    final themeChange = Provider.of<SettingsProvider>(context);
    final imagequalityChange = Provider.of<SettingsProvider>(context);
    final defaultHomeValue = Provider.of<SettingsProvider>(context);
    final country = Provider.of<SettingsProvider>(context).defaultCountry;
    final viewType = Provider.of<SettingsProvider>(context);
    final m3 = Provider.of<SettingsProvider>(context);

    for (int i = 0; i < countryData.countries.length; i++) {
      if (countryData.countries[i].isoCode.contains(country)) {
        setState(() {
          countryFlag = countryData.countries[i].flagPath;
          countryName = countryData.countries[i].countryName;
        });
        break;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr("settings"),
        ),
      ),
      body: Column(
        children: [
          SwitchListTile(
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF9B9B9B),
            value: adultChange.isAdult,
            secondary: Icon(
              Icons.explicit,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              tr("include_adult"),
            ),
            onChanged: (bool value) {
              setState(() {
                adultChange.isAdult = value;
              });
            },
          ),
          SwitchListTile(
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF9B9B9B),
            value: themeChange.darktheme,
            secondary: Icon(
              Icons.dark_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              tr("dark_mode"),
            ),
            onChanged: (bool value) {
              setState(() {
                themeChange.darktheme = value;
              });
            },
          ),
          ListTile(
            leading: Icon(
              Icons.play_arrow,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              tr("player_settings"),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: ((context) {
                return const PlayerSettings();
              })));
            },
          ),
          Visibility(
            visible: !isBelow33,
            child: SwitchListTile(
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFF9B9B9B),
              subtitle: Text(
                tr("android_12"),
              ),
              value: m3.isMaterial3Enabled,
              secondary: Icon(
                Icons.color_lens,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                tr("material_theming"),
              ),
              onChanged: (bool value) {
                setState(() {
                  m3.isMaterial3Enabled = value;
                });
              },
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.image,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              tr("image_quality"),
            ),
            trailing: DropdownButton(
                value: imagequalityChange.imageQuality,
                items: [
                  DropdownMenuItem(
                      value: 'original/',
                      child: Text(
                        tr("high"),
                      )),
                  DropdownMenuItem(
                      value: 'w600_and_h900_bestv2/',
                      child: Text(
                        tr("medium"),
                      )),
                  DropdownMenuItem(
                      value: 'w500/',
                      child: Text(
                        tr("low"),
                      ))
                ],
                onChanged: (String? value) {
                  setState(() {
                    imagequalityChange.imageQuality = value!;
                  });
                }),
          ),
          ListTile(
            leading: Icon(
              Icons.list,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              tr("list_view_type"),
            ),
            trailing: DropdownButton(
                value: viewType.defaultView,
                items: [
                  DropdownMenuItem(
                      value: 'list',
                      child: Wrap(spacing: 3, children: [
                        Icon(
                          Icons.list,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Text(
                          tr("list"),
                        )
                      ])),
                  DropdownMenuItem(
                    value: 'grid',
                    child: Wrap(spacing: 3, children: [
                      Icon(
                        Icons.grid_view,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Text(
                        tr("grid"),
                      )
                    ]),
                  ),
                ],
                onChanged: (String? value) {
                  setState(() {
                    viewType.defaultView = value!;
                  });
                }),
          ),
          ListTile(
            leading: Icon(
              Icons.phone_android_sharp,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              tr("default_home_screen"),
            ),
            trailing: DropdownButton(
                value: defaultHomeValue.defaultValue,
                items: [
                  DropdownMenuItem(
                      value: 0,
                      child: Text(
                        tr("movies"),
                      )),
                  DropdownMenuItem(
                      value: 1,
                      child: Text(
                        tr("tv_shows"),
                      )),
                  DropdownMenuItem(
                      value: 2,
                      child: Text(
                        tr("discover"),
                      )),
                  DropdownMenuItem(
                      value: 3,
                      child: Text(
                        tr("profile"),
                      ))
                ],
                onChanged: (int? value) {
                  setState(() {
                    defaultHomeValue.defaultValue = value!;
                  });
                }),
          ),
          ListTile(
            onTap: (() {
              Navigator.push(context, MaterialPageRoute(builder: ((context) {
                return const CountryChoose();
              })));
            }),
            leading: Icon(
              FontAwesomeIcons.earthAmericas,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              tr("watch_country"),
            ),
            trailing: Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Image.asset(
                    countryFlag!,
                    height: 25,
                    width: 25,
                  ),
                  Text(countryName!)
                ]),
          ),
        ],
      ),
    );
  }
}
