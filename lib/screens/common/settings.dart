import 'dart:io';
import 'package:flixquest/models/app_colors.dart';
import 'package:flixquest/services/globle_method.dart';

import '../../functions/function.dart';
import '/models/app_languages.dart';
import '/screens/common/language_choose.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import '/models/watchprovider_countries.dart';
import '/screens/common/country_choose.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '/provider/settings_provider.dart';
import '/provider/app_dependency_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'player_settings.dart';
import 'provider_choose.dart';
import '../../ui_components/app_ui_components.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

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

  final AppColorsList appColors = AppColorsList();

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
    final settingsValues = Provider.of<SettingsProvider>(context);
    final appDependencies = context.watch<AppDependencyProvider>();
    final occasionalCatalog = appDependencies.occasionalThemeCatalog;
    final occasionalThemes = appDependencies.availableOccasionalThemes;

    List<AppLanguages> langs = [
      AppLanguages(
          languageFlag: 'assets/images/country_flags/united-kingdom.png',
          languageName: tr('english'),
          languageCode: 'en'),
      AppLanguages(
          languageFlag: 'assets/images/country_flags/united-arab-emirates.png',
          languageName: tr('arabic'),
          languageCode: 'ar'),
      AppLanguages(
          languageFlag: 'assets/images/country_flags/spain.png',
          languageName: tr('spanish'),
          languageCode: 'es'),
      AppLanguages(
          languageFlag: 'assets/images/country_flags/india.png',
          languageName: tr('hindi'),
          languageCode: 'hi')
    ];

    List<WatchProviderCountries> countries = [
      WatchProviderCountries(
        countryName: tr('uae'),
        flagPath: 'assets/images/country_flags/united-arab-emirates.png',
        isoCode: 'AE',
      ),
      WatchProviderCountries(
        countryName: tr('argentina'),
        flagPath: 'assets/images/country_flags/argentina.png',
        isoCode: 'AR',
      ),
      WatchProviderCountries(
        countryName: tr('austria'),
        flagPath: 'assets/images/country_flags/austria.png',
        isoCode: 'AT',
      ),
      WatchProviderCountries(
        countryName: tr('australia'),
        flagPath: 'assets/images/country_flags/australia.png',
        isoCode: 'AU',
      ),
      WatchProviderCountries(
        countryName: tr('belgium'),
        flagPath: 'assets/images/country_flags/belgium.png',
        isoCode: 'BE',
      ),
      WatchProviderCountries(
        countryName: tr('bulgaria'),
        flagPath: 'assets/images/country_flags/bulgaria.png',
        isoCode: 'BG',
      ),
      WatchProviderCountries(
        countryName: tr('brazil'),
        flagPath: 'assets/images/country_flags/brazil.png',
        isoCode: 'BR',
      ),
      WatchProviderCountries(
        countryName: tr('canada'),
        flagPath: 'assets/images/country_flags/canada.png',
        isoCode: 'CA',
      ),
      WatchProviderCountries(
        countryName: tr('switzerland'),
        flagPath: 'assets/images/country_flags/switzerland.png',
        isoCode: 'CH',
      ),
      WatchProviderCountries(
        countryName: tr('cote_divoire'),
        flagPath: 'assets/images/country_flags/ivory-coast.png',
        isoCode: 'CI',
      ),
      WatchProviderCountries(
        countryName: tr('czech_republic'),
        flagPath: 'assets/images/country_flags/czech-republic.png',
        isoCode: 'CZ',
      ),
      WatchProviderCountries(
        countryName: tr('germany'),
        flagPath: 'assets/images/country_flags/germany.png',
        isoCode: 'DE',
      ),
      WatchProviderCountries(
        countryName: tr('denmark'),
        flagPath: 'assets/images/country_flags/denmark.png',
        isoCode: 'DK',
      ),
      WatchProviderCountries(
        countryName: tr('estonia'),
        flagPath: 'assets/images/country_flags/estonia.png',
        isoCode: 'EE',
      ),
      WatchProviderCountries(
        countryName: tr('spain'),
        flagPath: 'assets/images/country_flags/spain.png',
        isoCode: 'ES',
      ),
      WatchProviderCountries(
        countryName: tr('finland'),
        flagPath: 'assets/images/country_flags/finland.png',
        isoCode: 'FI',
      ),
      WatchProviderCountries(
        countryName: tr('france'),
        flagPath: 'assets/images/country_flags/france.png',
        isoCode: 'FR',
      ),
      WatchProviderCountries(
        countryName: tr('uk'),
        flagPath: 'assets/images/country_flags/united-kingdom.png',
        isoCode: 'GB',
      ),
      WatchProviderCountries(
        countryName: tr('hong_kong'),
        flagPath: 'assets/images/country_flags/hong-kong.png',
        isoCode: 'HK',
      ),
      WatchProviderCountries(
        countryName: tr('croatia'),
        flagPath: 'assets/images/country_flags/croatia.png',
        isoCode: 'HR',
      ),
      WatchProviderCountries(
        countryName: tr('hungary'),
        flagPath: 'assets/images/country_flags/hungary.png',
        isoCode: 'HU',
      ),
      WatchProviderCountries(
        countryName: tr('indonesia'),
        flagPath: 'assets/images/country_flags/indonesia.png',
        isoCode: 'ID',
      ),
      WatchProviderCountries(
        countryName: tr('ireland'),
        flagPath: 'assets/images/country_flags/ireland.png',
        isoCode: 'IE',
      ),
      WatchProviderCountries(
        countryName: tr('india'),
        flagPath: 'assets/images/country_flags/india.png',
        isoCode: 'IN',
      ),
      WatchProviderCountries(
        countryName: tr('italy'),
        flagPath: 'assets/images/country_flags/italy.png',
        isoCode: 'IT',
      ),
      WatchProviderCountries(
        countryName: tr('japan'),
        flagPath: 'assets/images/country_flags/japan.png',
        isoCode: 'JP',
      ),
      WatchProviderCountries(
        countryName: tr('kenya'),
        flagPath: 'assets/images/country_flags/kenya.png',
        isoCode: 'KE',
      ),
      WatchProviderCountries(
        countryName: tr('south_korea'),
        flagPath: 'assets/images/country_flags/south-korea.png',
        isoCode: 'KR',
      ),
      WatchProviderCountries(
        countryName: tr('lithuania'),
        flagPath: 'assets/images/country_flags/lithuania.png',
        isoCode: 'LT',
      ),
      WatchProviderCountries(
        countryName: tr('mexico'),
        flagPath: 'assets/images/country_flags/mexico.png',
        isoCode: 'MX',
      ),
      WatchProviderCountries(
        countryName: tr('netherlands'),
        flagPath: 'assets/images/country_flags/netherlands.png',
        isoCode: 'NL',
      ),
      WatchProviderCountries(
        countryName: tr('norway'),
        flagPath: 'assets/images/country_flags/norway.png',
        isoCode: 'NO',
      ),
      WatchProviderCountries(
        countryName: tr('new_zealand'),
        flagPath: 'assets/images/country_flags/new-zealand.png',
        isoCode: 'NZ',
      ),
      WatchProviderCountries(
        countryName: tr('philippines'),
        flagPath: 'assets/images/country_flags/philippines.png',
        isoCode: 'PH',
      ),
      WatchProviderCountries(
        countryName: tr('poland'),
        flagPath: 'assets/images/country_flags/poland.png',
        isoCode: 'PL',
      ),
      WatchProviderCountries(
        countryName: tr('portugal'),
        flagPath: 'assets/images/country_flags/portugal.png',
        isoCode: 'PT',
      ),
      WatchProviderCountries(
        countryName: tr('serbia'),
        flagPath: 'assets/images/country_flags/serbia.png',
        isoCode: 'RS',
      ),
      WatchProviderCountries(
        countryName: tr('russia'),
        flagPath: 'assets/images/country_flags/russia.png',
        isoCode: 'RU',
      ),
      WatchProviderCountries(
        countryName: tr('sweden'),
        flagPath: 'assets/images/country_flags/sweden.png',
        isoCode: 'SE',
      ),
      WatchProviderCountries(
        countryName: tr('slovakia'),
        flagPath: 'assets/images/country_flags/slovakia.png',
        isoCode: 'SK',
      ),
      WatchProviderCountries(
        countryName: tr('turkey'),
        flagPath: 'assets/images/country_flags/turkey.png',
        isoCode: 'TR',
      ),
      WatchProviderCountries(
        countryName: tr('usa'),
        flagPath: 'assets/images/country_flags/united-states.png',
        isoCode: 'US',
      ),
      WatchProviderCountries(
        countryName: tr('south_africa'),
        flagPath: 'assets/images/country_flags/south-africa.png',
        isoCode: 'ZA',
      ),
    ];

    for (int i = 0; i < countries.length; i++) {
      if (countries[i].isoCode.contains(settingsValues.defaultCountry)) {
        countryFlag = countries[i].flagPath;
        countryName = countries[i].countryName;
        break;
      }
    }

    for (int i = 0; i < langs.length; i++) {
      if (langs[i].languageCode.contains(settingsValues.appLanguage)) {
        languageFlag = langs[i].languageFlag;
        languageName = langs[i].languageName;
        break;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('settings'),
        ),
      ),
      body: AppResponsiveContent(
        padding: EdgeInsets.zero,
        maxWidth: 760,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            const SizedBox(height: 12),
            _SettingsGroup(
              title: tr('appearance'),
              children: [
                _SettingsChoiceTile<String>(
                  icon: PhosphorIcons.moon(),
                  title: tr('theme_mode'),
                  value: settingsValues.appTheme,
                  options: {
                    'dark': tr('dark'),
                    'light': tr('light'),
                    'amoled': tr('amoled'),
                  },
                  onChanged: (value) =>
                      setState(() => settingsValues.appTheme = value),
                ),
                if (occasionalCatalog.enabled)
                  SwitchListTile(
                    value: appDependencies.occasionalThemeEnabled,
                    secondary: Icon(
                      PhosphorIcons.sparkle(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr('seasonal_themes')),
                    subtitle: Text(tr('seasonal_themes_description')),
                    onChanged: (value) {
                      appDependencies.occasionalThemeEnabled = value;
                    },
                  ),
                if (occasionalCatalog.enabled &&
                    appDependencies.occasionalThemeEnabled &&
                    occasionalCatalog.allowUserSelection &&
                    occasionalThemes.isNotEmpty)
                  _OccasionalThemeChoiceTile(
                    provider: appDependencies,
                  ),
                if (occasionalCatalog.enabled &&
                    appDependencies.occasionalThemeEnabled &&
                    occasionalCatalog.effectsEnabled &&
                    occasionalCatalog.allowUserEffectsToggle)
                  SwitchListTile(
                    value: appDependencies.occasionalEffectsEnabled,
                    secondary: Icon(
                      PhosphorIcons.sparkle(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(tr('seasonal_effects')),
                    subtitle: Text(tr('seasonal_effects_description')),
                    onChanged: (value) {
                      appDependencies.occasionalEffectsEnabled = value;
                    },
                  ),
                ListTile(
                  leading: Icon(
                    PhosphorIcons.play(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    tr('player_settings'),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: ((context) {
                      return const PlayerSettings();
                    })));
                  },
                ),
                ListTile(
                  leading: Icon(
                    PhosphorIcons.arrowsDownUp(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(tr('provider_precedence')),
                  trailing: Icon(PhosphorIcons.caretRight()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProviderChooseScreen(),
                      ),
                    );
                  },
                ),
                Visibility(
                  visible: !isBelow33,
                  child: SwitchListTile(
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFF9B9B9B),
                    subtitle: Text(
                      tr('android_12'),
                    ),
                    value: settingsValues.isMaterial3Enabled,
                    secondary: Icon(
                      PhosphorIcons.palette(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      tr('material_theming'),
                    ),
                    onChanged: (bool value) {
                      setState(() {
                        settingsValues.isMaterial3Enabled = value;
                      });
                    },
                  ),
                ),
                SwitchListTile(
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFF9B9B9B),
                  subtitle: Text(
                    tr('enable_warning'),
                  ),
                  value: settingsValues.enableProxy,
                  secondary: Icon(
                    PhosphorIcons.globe(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    tr('use_proxy'),
                  ),
                  onChanged: (bool value) {
                    if (value) {
                      showDialog(
                          context: context,
                          builder: (BuildContext ctx) {
                            return AlertDialog(
                              title: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(tr('use_proxy_title')),
                              ),
                              content: Text(tr('use_proxy_detail')),
                              actions: [
                                ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                    child: Text(tr('cancel'))),
                                TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        settingsValues.enableProxy = value;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      tr('enable'),
                                    ))
                              ],
                            );
                          });
                    } else {
                      setState(() {
                        settingsValues.enableProxy = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsGroup(
              title: tr('content_preferences'),
              children: [
                _SettingsChoiceTile<String>(
                  icon: PhosphorIcons.image(),
                  title: tr('image_quality'),
                  value: settingsValues.imageQuality,
                  options: {
                    'original/': tr('high'),
                    'w600_and_h900_bestv2/': tr('medium'),
                    'w500/': tr('low'),
                  },
                  onChanged: (value) =>
                      setState(() => settingsValues.imageQuality = value),
                ),
                _SettingsChoiceTile<String>(
                  icon: PhosphorIcons.list(),
                  title: tr('list_view_type'),
                  value: settingsValues.defaultView,
                  options: {'list': tr('list'), 'grid': tr('grid')},
                  onChanged: (value) =>
                      setState(() => settingsValues.defaultView = value),
                ),
                _SettingsChoiceTile<int>(
                  icon: PhosphorIcons.deviceMobile(),
                  title: tr('default_home_screen'),
                  value: settingsValues.defaultValue,
                  options: {
                    0: tr('movies'),
                    1: tr('tv_shows'),
                    2: tr('discover'),
                    3: tr('profile'),
                  },
                  onChanged: (value) =>
                      setState(() => settingsValues.defaultValue = value),
                ),
                ListTile(
                  onTap: (() {
                    Navigator.push(context,
                        MaterialPageRoute(builder: ((context) {
                      return const AppLanguageChoose();
                    })));
                  }),
                  leading: Icon(
                    PhosphorIcons.translate(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    tr('app_language'),
                  ),
                  trailing: Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (languageFlag != null)
                          Image.asset(languageFlag!, height: 25, width: 25),
                        Text(languageName ?? settingsValues.appLanguage)
                      ]),
                ),
                ListTile(
                  onTap: (() {
                    Navigator.push(context,
                        MaterialPageRoute(builder: ((context) {
                      return const CountryChoose();
                    })));
                  }),
                  leading: Icon(
                    PhosphorIcons.globeHemisphereWest(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    tr('watch_country'),
                  ),
                  trailing: Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (countryFlag != null)
                          Image.asset(countryFlag!, height: 25, width: 25),
                        Text(countryName ?? settingsValues.defaultCountry)
                      ]),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsGroup(
              title: tr('storage'),
              children: [
                ListTile(
                  leading: Icon(
                    PhosphorIcons.eraser(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(tr('clear_cache')),
                  trailing: ElevatedButton(
                      onPressed: () async {
                        await clearCache().then((value) {
                          if (!context.mounted) {
                            return;
                          }
                          GlobalMethods.showCustomScaffoldMessage(
                              SnackBar(
                                  duration: const Duration(
                                      seconds: 1, milliseconds: 500),
                                  content: Text(value
                                      ? tr('cleared_cache')
                                      : tr('cache_doesnt_exist'))),
                              context);
                        });
                        await clearTempCache().then((value) {
                          if (!context.mounted) {
                            return;
                          }
                          GlobalMethods.showCustomScaffoldMessage(
                              SnackBar(
                                  duration: const Duration(
                                      seconds: 1, milliseconds: 500),
                                  content: Text(value
                                      ? tr('cleared_cache')
                                      : tr('cache_doesnt_exist'))),
                              context);
                        });
                      },
                      child: Text(tr('clear'))),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsGroup(
              title: tr('custom_color'),
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 68,
                  child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      scrollDirection: Axis.horizontal,
                      children: appColors
                          .appColors(settingsValues.appTheme == 'dark' ||
                                  settingsValues.appTheme == 'amoled'
                              ? true
                              : false)
                          .map((AppColor appColor) {
                        final selected =
                            settingsValues.appColorIndex == appColor.index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => setState(() {
                              settingsValues.appColorIndex =
                                  selected ? -1 : appColor.index;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 50,
                              height: 50,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? appColor.cs.primary
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                    color: appColor.cs.primary,
                                    shape: BoxShape.circle),
                                child: selected
                                    ? Icon(PhosphorIcons.check(),
                                        color: appColor.cs.onPrimary)
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }).toList()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const Divider(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsChoiceTile<T> extends StatelessWidget {
  const _SettingsChoiceTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _showChoices(context),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Text(
              options[value] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 5),
          Icon(PhosphorIcons.caretRight()),
        ],
      ),
    );
  }

  Future<void> _showChoices(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child:
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            for (final option in options.entries)
              ListTile(
                title: Text(option.value),
                trailing: option.key == value
                    ? Icon(PhosphorIcons.check(),
                        color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () => Navigator.pop(context, option.key),
              ),
          ],
        ),
      ),
    );
    if (selected != null) onChanged(selected);
  }
}

class _OccasionalThemeChoiceTile extends StatelessWidget {
  const _OccasionalThemeChoiceTile({required this.provider});

  final AppDependencyProvider provider;

  String get _selectedLabel {
    if (provider.selectedOccasionalThemeId == 'automatic') {
      return tr('automatic');
    }
    for (final theme in provider.availableOccasionalThemes) {
      if (theme.id == provider.selectedOccasionalThemeId) {
        return theme.displayName;
      }
    }
    return tr('automatic');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _showChoices(context),
      leading: Icon(
        PhosphorIcons.sparkle(),
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(tr('occasional_theme')),
      subtitle: Text(
        tr('seasonal_theme_selection_description'),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              _selectedLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Icon(PhosphorIcons.caretRight()),
        ],
      ),
    );
  }

  Future<void> _showChoices(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * .78,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 14),
              child: Text(
                tr('occasional_theme'),
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            _OccasionalThemeOption(
              title: tr('automatic'),
              description: tr('automatic_theme_description'),
              colors: const [],
              selected: provider.selectedOccasionalThemeId == 'automatic',
              onTap: () {
                provider.selectOccasionalTheme('automatic');
                Navigator.pop(sheetContext);
              },
            ),
            for (final theme in provider.availableOccasionalThemes)
              _OccasionalThemeOption(
                title: theme.displayName,
                description: theme.description.isEmpty
                    ? tr('active_seasonal_theme')
                    : theme.description,
                colors: [
                  theme.primaryColor,
                  theme.secondaryColor,
                  theme.tertiaryColor,
                ],
                selected: provider.selectedOccasionalThemeId == theme.id,
                onTap: () {
                  provider.selectOccasionalTheme(theme.id);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _OccasionalThemeOption extends StatelessWidget {
  const _OccasionalThemeOption({
    required this.title,
    required this.description,
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final List<Color> colors;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected
            ? scheme.primary.withValues(alpha: .1)
            : scheme.surfaceContainerHighest.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 34,
                  child: colors.isEmpty
                      ? Icon(PhosphorIcons.magicWand(), color: scheme.primary)
                      : Stack(
                          children: [
                            for (var index = 0; index < colors.length; index++)
                              Positioned(
                                left: index * 11,
                                top: index.isOdd ? 7 : 1,
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: colors[index],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: scheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(PhosphorIcons.check(), color: scheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
