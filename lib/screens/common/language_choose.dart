// ignore_for_file: deprecated_member_use

import '../../models/app_languages.dart';
import 'package:easy_localization/easy_localization.dart';
import '/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui_components/app_ui_components.dart';

class AppLanguageChoose extends StatefulWidget {
  const AppLanguageChoose({super.key});

  @override
  State<AppLanguageChoose> createState() => _AppLanguageChooseState();
}

class _AppLanguageChooseState extends State<AppLanguageChoose> {
  @override
  Widget build(BuildContext context) {
    final languageChange = Provider.of<SettingsProvider>(context);

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

    return Scaffold(
      appBar: AppBar(title: Text(tr('choose_language'))),
      body: AppResponsiveContent(
        maxWidth: 640,
        padding: EdgeInsets.fromLTRB(
          AppUI.pagePadding(context),
          16,
          AppUI.pagePadding(context),
          24,
        ),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: langs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final language = langs[index];
            return AppSelectionTile(
              title: language.languageName,
              selected: languageChange.appLanguage == language.languageCode,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(
                  language.languageFlag,
                  width: 32,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
              onTap: () {
                languageChange.appLanguage = language.languageCode;
                EasyLocalization.of(context)!
                    .setLocale(Locale(language.languageCode));
              },
            );
          },
        ),
      ),
    );
  }
}
