import 'package:cinemax/provider/settings_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubLangChoose extends StatefulWidget {
  const SubLangChoose({Key? key}) : super(key: key);

  @override
  State<SubLangChoose> createState() => _SubLangChooseState();
}

class _SubLangChooseState extends State<SubLangChoose> {
  List<String> supportedLanguages = [
    '',
    tr("arabic"),
    tr("bulgarian"),
    tr("chinese"),
    tr("croaitian"),
    tr("czech"),
    tr("danish"),
    tr("dutch"),
    tr("english"),
    tr("estonian"),
    tr("finnish"),
    tr("french"),
    tr("german"),
    tr("greek"),
    tr("hebrew"),
    tr("hindi"),
    tr("hungarian"),
    tr("indonesian"),
    tr("italian"),
    tr("japanese"),
    tr("korean"),
    tr("latvian"),
    tr("lithuanian"),
    tr("malay"),
    tr("norwegian"),
    tr("polish"),
    tr("portuguese"),
    tr("romanian"),
    tr("russian"),
    tr("slovak"),
    tr("slovene"),
    tr("spanish"),
    tr("swedish"),
    tr("thai"),
    tr("turkish"),
    tr("ukrainian")
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
                        (String languages) => ListTile(
                          title: Text(languages == '' ? tr("any") : languages),
                          leading: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Radio(
                                value: languages,
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
