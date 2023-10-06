import '/models/sub_languages.dart';
import '/provider/settings_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubLangChoose extends StatefulWidget {
  const SubLangChoose({Key? key}) : super(key: key);

  @override
  State<SubLangChoose> createState() => _SubLangChooseState();
}

class _SubLangChooseState extends State<SubLangChoose> {
  List<SubLanguages> supportedLanguages = [
    SubLanguages(languageName: '', languageCode: '', englishName: 'any'),
    SubLanguages(
        languageName: tr("arabic"), languageCode: 'ar', englishName: 'Arabic'),
    SubLanguages(
        languageName: tr("bulgarian"),
        languageCode: 'bg',
        englishName: 'Bulgarian'),
    SubLanguages(
        languageName: tr("chinese"),
        languageCode: 'zh',
        englishName: 'Chinese'),
    SubLanguages(
        languageName: tr("croaitian"),
        languageCode: 'hr',
        englishName: 'Croaitian'),
    SubLanguages(
        languageName: tr("czech"), languageCode: 'cs', englishName: 'Czech'),
    SubLanguages(
        languageName: tr("danish"), languageCode: 'da', englishName: 'Danish'),
    SubLanguages(
        languageName: tr("dutch"), languageCode: 'nl', englishName: 'Dutch'),
    SubLanguages(
        languageName: tr("english"),
        languageCode: 'en',
        englishName: 'English'),
    SubLanguages(
        languageName: tr("estonian"),
        languageCode: 'et',
        englishName: 'Estonian'),
    SubLanguages(
        languageName: tr("finnish"),
        languageCode: 'fi',
        englishName: 'Finnish'),
    SubLanguages(
        languageName: tr("french"), languageCode: 'fr', englishName: 'French'),
    SubLanguages(
        languageName: tr("german"), languageCode: 'de', englishName: 'German'),
    SubLanguages(
        languageName: tr("greek"), languageCode: 'el', englishName: 'Greek'),
    SubLanguages(
        languageName: tr("hebrew"), languageCode: 'he', englishName: 'Hebrew'),
    SubLanguages(
        languageName: tr("hindi"), languageCode: 'hi', englishName: 'Hindi'),
    SubLanguages(
        languageName: tr("hungarian"),
        languageCode: 'hu',
        englishName: 'Hungarian'),
    SubLanguages(
        languageName: tr("indonesian"),
        languageCode: 'id',
        englishName: 'Indonesian'),
    SubLanguages(
        languageName: tr("italian"),
        languageCode: 'it',
        englishName: 'Italian'),
    SubLanguages(
        languageName: tr("japanese"),
        languageCode: 'ja',
        englishName: 'Japanese'),
    SubLanguages(
        languageName: tr("korean"), languageCode: 'ko', englishName: 'Korean'),
    SubLanguages(
        languageName: tr("latvian"),
        languageCode: 'lv',
        englishName: 'Latvian'),
    SubLanguages(
        languageName: tr("lithuanian"),
        languageCode: 'lt',
        englishName: 'Lithuanian'),
    SubLanguages(
        languageName: tr("malay"), languageCode: 'ms', englishName: 'Malay'),
    SubLanguages(
        languageName: tr("norwegian"),
        languageCode: 'no',
        englishName: 'Norwegian'),
    SubLanguages(
        languageName: tr("polish"), languageCode: 'pl', englishName: 'Polish'),
    SubLanguages(
        languageName: tr("portuguese"),
        languageCode: 'pt',
        englishName: 'Portuguese'),
    SubLanguages(
        languageName: tr("romanian"),
        languageCode: 'ro',
        englishName: 'Romanian'),
    SubLanguages(
        languageName: tr("russian"),
        languageCode: 'ru',
        englishName: 'Russian'),
    SubLanguages(
        languageName: tr("slovak"), languageCode: 'sk', englishName: 'Slovak'),
    SubLanguages(
        languageName: tr("slovene"),
        languageCode: 'sl',
        englishName: 'Slovene'),
    SubLanguages(
        languageName: tr("spanish"),
        languageCode: 'es',
        englishName: 'Spanish'),
    SubLanguages(
        languageName: tr("swedish"),
        languageCode: 'sv',
        englishName: 'Swedish'),
    SubLanguages(
        languageName: tr("thai"), languageCode: 'th', englishName: 'Thai'),
    SubLanguages(
        languageName: tr("turkish"),
        languageCode: 'tr',
        englishName: 'Turkish'),
    SubLanguages(
        languageName: tr("ukrainian"),
        languageCode: 'uk',
        englishName: 'Ukrainian'),
  ];

  @override
  Widget build(BuildContext context) {
    final languageChange = Provider.of<SettingsProvider>(context);
    return Scaffold(
        appBar: AppBar(title: Text(tr("choose_subtitle_language"))),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
                  children: supportedLanguages
                      .map(
                        (SubLanguages languages) => ListTile(
                          title: Text(languages.languageName == ''
                              ? tr("any")
                              : languages.languageName),
                          leading: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Radio(
                                value: languages.languageCode,
                                groupValue:
                                    languageChange.defaultSubtitleLanguage,
                                onChanged: (String? value) {
                                  setState(() {
                                    languageChange.defaultSubtitleLanguage =
                                        value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList())),
        ));
  }
}
