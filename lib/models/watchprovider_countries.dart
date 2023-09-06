import 'package:easy_localization/easy_localization.dart';

class WatchProviderCountries {
  WatchProviderCountries(
      {required this.countryName,
      required this.flagPath,
      required this.isoCode});
  String isoCode;
  String countryName;
  String flagPath;
}

class CountryData {
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
}
