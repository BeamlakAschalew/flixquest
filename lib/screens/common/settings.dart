import 'dart:io';
import '/models/app_languages.dart';
import '/screens/common/language_choose.dart';
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

  String? countryFlag;
  String? countryName;
  String? languageFlag;
  String? languageName;
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
    final appLang = Provider.of<SettingsProvider>(context).appLanguage;
    final viewType = Provider.of<SettingsProvider>(context);
    final m3 = Provider.of<SettingsProvider>(context);

    List<AppLanguages> langs = [
      AppLanguages(
          languageFlag: 'assets/images/country_flags/united-kingdom.png',
          languageName: tr("english"),
          languageCode: 'en'),
      AppLanguages(
          languageFlag: 'assets/images/country_flags/united-arab-emirates.png',
          languageName: tr("arabic"),
          languageCode: 'ar'),
      AppLanguages(
          languageFlag: 'assets/images/country_flags/spain.png',
          languageName: tr("spanish"),
          languageCode: 'es'),
      AppLanguages(
          languageFlag: 'assets/images/country_flags/india.png',
          languageName: tr("hindi"),
          languageCode: 'hi')
    ];

    List<WatchProviderCountries> countries = [
      WatchProviderCountries(
        countryName: tr("uae"),
        flagPath: 'assets/images/country_flags/united-arab-emirates.png',
        isoCode: 'AE',
      ),
      WatchProviderCountries(
        countryName: tr("argentina"),
        flagPath: 'assets/images/country_flags/argentina.png',
        isoCode: 'AR',
      ),
      WatchProviderCountries(
        countryName: tr("austria"),
        flagPath: 'assets/images/country_flags/austria.png',
        isoCode: 'AT',
      ),
      WatchProviderCountries(
        countryName: tr("australia"),
        flagPath: 'assets/images/country_flags/australia.png',
        isoCode: 'AU',
      ),
      WatchProviderCountries(
        countryName: tr("belgium"),
        flagPath: 'assets/images/country_flags/belgium.png',
        isoCode: 'BE',
      ),
      WatchProviderCountries(
        countryName: tr("bulgaria"),
        flagPath: 'assets/images/country_flags/bulgaria.png',
        isoCode: 'BG',
      ),
      WatchProviderCountries(
        countryName: tr("brazil"),
        flagPath: 'assets/images/country_flags/brazil.png',
        isoCode: 'BR',
      ),
      WatchProviderCountries(
        countryName: tr("canada"),
        flagPath: 'assets/images/country_flags/canada.png',
        isoCode: 'CA',
      ),
      WatchProviderCountries(
        countryName: tr("switzerland"),
        flagPath: 'assets/images/country_flags/switzerland.png',
        isoCode: 'CH',
      ),
      WatchProviderCountries(
        countryName: tr("cote_divoire"),
        flagPath: 'assets/images/country_flags/ivory-coast.png',
        isoCode: 'CI',
      ),
      WatchProviderCountries(
        countryName: tr("czech_republic"),
        flagPath: 'assets/images/country_flags/czech-republic.png',
        isoCode: 'CZ',
      ),
      WatchProviderCountries(
        countryName: tr("germany"),
        flagPath: 'assets/images/country_flags/germany.png',
        isoCode: 'DE',
      ),
      WatchProviderCountries(
        countryName: tr("denmark"),
        flagPath: 'assets/images/country_flags/denmark.png',
        isoCode: 'DK',
      ),
      WatchProviderCountries(
        countryName: tr("estonia"),
        flagPath: 'assets/images/country_flags/estonia.png',
        isoCode: 'EE',
      ),
      WatchProviderCountries(
        countryName: tr("spain"),
        flagPath: 'assets/images/country_flags/spain.png',
        isoCode: 'ES',
      ),
      WatchProviderCountries(
        countryName: tr("finland"),
        flagPath: 'assets/images/country_flags/finland.png',
        isoCode: 'FI',
      ),
      WatchProviderCountries(
        countryName: tr("france"),
        flagPath: 'assets/images/country_flags/france.png',
        isoCode: 'FR',
      ),
      WatchProviderCountries(
        countryName: tr("uk"),
        flagPath: 'assets/images/country_flags/united-kingdom.png',
        isoCode: 'GB',
      ),
      WatchProviderCountries(
        countryName: tr("hong_kong"),
        flagPath: 'assets/images/country_flags/hong-kong.png',
        isoCode: 'HK',
      ),
      WatchProviderCountries(
        countryName: tr("croatia"),
        flagPath: 'assets/images/country_flags/croatia.png',
        isoCode: 'HR',
      ),
      WatchProviderCountries(
        countryName: tr("hungary"),
        flagPath: 'assets/images/country_flags/hungary.png',
        isoCode: 'HU',
      ),
      WatchProviderCountries(
        countryName: tr("indonesia"),
        flagPath: 'assets/images/country_flags/indonesia.png',
        isoCode: 'ID',
      ),
      WatchProviderCountries(
        countryName: tr("ireland"),
        flagPath: 'assets/images/country_flags/ireland.png',
        isoCode: 'IE',
      ),
      WatchProviderCountries(
        countryName: tr("india"),
        flagPath: 'assets/images/country_flags/india.png',
        isoCode: 'IN',
      ),
      WatchProviderCountries(
        countryName: tr("italy"),
        flagPath: 'assets/images/country_flags/italy.png',
        isoCode: 'IT',
      ),
      WatchProviderCountries(
        countryName: tr("japan"),
        flagPath: 'assets/images/country_flags/japan.png',
        isoCode: 'JP',
      ),
      WatchProviderCountries(
        countryName: tr("kenya"),
        flagPath: 'assets/images/country_flags/kenya.png',
        isoCode: 'KE',
      ),
      WatchProviderCountries(
        countryName: tr("south_korea"),
        flagPath: 'assets/images/country_flags/south-korea.png',
        isoCode: 'KR',
      ),
      WatchProviderCountries(
        countryName: tr("lithuania"),
        flagPath: 'assets/images/country_flags/lithuania.png',
        isoCode: 'LT',
      ),
      WatchProviderCountries(
        countryName: tr("mexico"),
        flagPath: 'assets/images/country_flags/mexico.png',
        isoCode: 'MX',
      ),
      WatchProviderCountries(
        countryName: tr("netherlands"),
        flagPath: 'assets/images/country_flags/netherlands.png',
        isoCode: 'NL',
      ),
      WatchProviderCountries(
        countryName: tr("norway"),
        flagPath: 'assets/images/country_flags/norway.png',
        isoCode: 'NO',
      ),
      WatchProviderCountries(
        countryName: tr("new_zealand"),
        flagPath: 'assets/images/country_flags/new-zealand.png',
        isoCode: 'NZ',
      ),
      WatchProviderCountries(
        countryName: tr("philippines"),
        flagPath: 'assets/images/country_flags/philippines.png',
        isoCode: 'PH',
      ),
      WatchProviderCountries(
        countryName: tr("poland"),
        flagPath: 'assets/images/country_flags/poland.png',
        isoCode: 'PL',
      ),
      WatchProviderCountries(
        countryName: tr("portugal"),
        flagPath: 'assets/images/country_flags/portugal.png',
        isoCode: 'PT',
      ),
      WatchProviderCountries(
        countryName: tr("serbia"),
        flagPath: 'assets/images/country_flags/serbia.png',
        isoCode: 'RS',
      ),
      WatchProviderCountries(
        countryName: tr("russia"),
        flagPath: 'assets/images/country_flags/russia.png',
        isoCode: 'RU',
      ),
      WatchProviderCountries(
        countryName: tr("sweden"),
        flagPath: 'assets/images/country_flags/sweden.png',
        isoCode: 'SE',
      ),
      WatchProviderCountries(
        countryName: tr("slovakia"),
        flagPath: 'assets/images/country_flags/slovakia.png',
        isoCode: 'SK',
      ),
      WatchProviderCountries(
        countryName: tr("turkey"),
        flagPath: 'assets/images/country_flags/turkey.png',
        isoCode: 'TR',
      ),
      WatchProviderCountries(
        countryName: tr("usa"),
        flagPath: 'assets/images/country_flags/united-states.png',
        isoCode: 'US',
      ),
      WatchProviderCountries(
        countryName: tr("south_africa"),
        flagPath: 'assets/images/country_flags/south-africa.png',
        isoCode: 'ZA',
      ),
    ];

    for (int i = 0; i < countries.length; i++) {
      if (countries[i].isoCode.contains(country)) {
        setState(() {
          countryFlag = countries[i].flagPath;
          countryName = countries[i].countryName;
        });
        break;
      }
    }

    for (int i = 0; i < langs.length; i++) {
      if (langs[i].languageCode.contains(appLang)) {
        setState(() {
          languageFlag = langs[i].languageFlag;
          languageName = langs[i].languageName;
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
              Icons.explicit_rounded,
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
              Icons.dark_mode_rounded,
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
              Icons.play_arrow_rounded,
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
                Icons.color_lens_rounded,
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
              Icons.image_rounded,
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
              Icons.view_list_rounded,
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
              Icons.phone_android_rounded,
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
                return const AppLanguageChoose();
              })));
            }),
            leading: Icon(
              FontAwesomeIcons.language,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              tr("app_language"),
            ),
            trailing: Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Image.asset(
                    languageFlag!,
                    height: 25,
                    width: 25,
                  ),
                  Text(languageName!)
                ]),
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
