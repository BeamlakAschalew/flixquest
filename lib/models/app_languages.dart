import 'package:easy_localization/easy_localization.dart';

class AppLanguages {
  AppLanguages(
      {required this.languageFlag,
      required this.languageName,
      required this.languageCode});
  String languageName;
  String languageFlag;
  String languageCode;
}

class LanguageData {
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
  ];
}
