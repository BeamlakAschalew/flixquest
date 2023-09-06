import 'package:cinemax/models/languages.dart';
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
  SubtitleLanguage languages = SubtitleLanguage();

  @override
  Widget build(BuildContext context) {
    final languageChange = Provider.of<SettingsProvider>(context);
    return Scaffold(
        appBar: AppBar(title: Text(tr("choose_subtitle_language"))),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
                  children: languages.supportedLanguages
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
