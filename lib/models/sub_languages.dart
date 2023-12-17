import 'package:easy_localization/easy_localization.dart';

class SubLanguages {
  SubLanguages(
      {required this.languageName,
      required this.languageCode,
      required this.englishName});
  String languageName;
  String languageCode;
  String englishName;
}

List<SubLanguages> supportedLanguages = [
  SubLanguages(languageName: '', languageCode: '', englishName: ''),
  SubLanguages(
      languageName: tr("arabic"), languageCode: 'ar', englishName: 'Arabic'),
  SubLanguages(
      languageName: tr("bulgarian"),
      languageCode: 'bg',
      englishName: 'Bulgarian'),
  SubLanguages(
      languageName: tr("chinese"), languageCode: 'zh', englishName: 'Chinese'),
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
      languageName: tr("english"), languageCode: 'en', englishName: 'English'),
  SubLanguages(
      languageName: tr("estonian"),
      languageCode: 'et',
      englishName: 'Estonian'),
  SubLanguages(
      languageName: tr("finnish"), languageCode: 'fi', englishName: 'Finnish'),
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
      languageName: tr("italian"), languageCode: 'it', englishName: 'Italian'),
  SubLanguages(
      languageName: tr("japanese"),
      languageCode: 'ja',
      englishName: 'Japanese'),
  SubLanguages(
      languageName: tr("korean"), languageCode: 'ko', englishName: 'Korean'),
  SubLanguages(
      languageName: tr("latvian"), languageCode: 'lv', englishName: 'Latvian'),
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
      languageName: tr("russian"), languageCode: 'ru', englishName: 'Russian'),
  SubLanguages(
      languageName: tr("serbian"), languageCode: 'sr', englishName: 'Serbian'),
  SubLanguages(
      languageName: tr("slovak"), languageCode: 'sk', englishName: 'Slovak'),
  SubLanguages(
      languageName: tr("slovene"), languageCode: 'sl', englishName: 'Slovene'),
  SubLanguages(
      languageName: tr("spanish"), languageCode: 'es', englishName: 'Spanish'),
  SubLanguages(
      languageName: tr("swedish"), languageCode: 'sv', englishName: 'Swedish'),
  SubLanguages(
      languageName: tr("thai"), languageCode: 'th', englishName: 'Thai'),
  SubLanguages(
      languageName: tr("turkish"), languageCode: 'tr', englishName: 'Turkish'),
  SubLanguages(
      languageName: tr("ukrainian"),
      languageCode: 'uk',
      englishName: 'Ukrainian'),
];
