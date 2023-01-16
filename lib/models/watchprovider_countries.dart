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
        countryName: 'United Arab Emirates',
        flagPath: 'assets/images/country_flags/united-arab-emirates.png',
        isoCode: 'AE'),
    WatchProviderCountries(
        countryName: 'Argentina',
        flagPath: 'assets/images/country_flags/argentina.png',
        isoCode: 'AR'),
    WatchProviderCountries(
        countryName: 'Austria',
        flagPath: 'assets/images/country_flags/austria.png',
        isoCode: 'AT'),
    WatchProviderCountries(
        countryName: 'Australia',
        flagPath: 'assets/images/country_flags/australia.png',
        isoCode: 'AU'),
    WatchProviderCountries(
        countryName: 'Belgium',
        flagPath: 'assets/images/country_flags/belgium.png',
        isoCode: 'BE'),
    WatchProviderCountries(
        countryName: 'Bulgaria',
        flagPath: 'assets/images/country_flags/bulgaria.png',
        isoCode: 'BG'),
    WatchProviderCountries(
        countryName: 'Brazil',
        flagPath: 'assets/images/country_flags/brazil.png',
        isoCode: 'BR'),
    WatchProviderCountries(
        countryName: 'Canada',
        flagPath: 'assets/images/country_flags/canada.png',
        isoCode: 'CA'),
    WatchProviderCountries(
        countryName: 'Switzerland',
        flagPath: 'assets/images/country_flags/switzerland.png',
        isoCode: 'CH'),
    WatchProviderCountries(
        countryName: 'Cote D\'Ivoire',
        flagPath: 'assets/images/country_flags/ivory-coast.png',
        isoCode: 'CI'),
    WatchProviderCountries(
        countryName: 'Czech Republic',
        flagPath: 'assets/images/country_flags/czech-republic.png',
        isoCode: 'CZ'),
    WatchProviderCountries(
        countryName: 'Germany',
        flagPath: 'assets/images/country_flags/germany.png',
        isoCode: 'DE'),
    WatchProviderCountries(
        countryName: 'Denmark',
        flagPath: 'assets/images/country_flags/denmark.png',
        isoCode: 'DK'),
    WatchProviderCountries(
        countryName: 'Estonia',
        flagPath: 'assets/images/country_flags/estonia.png',
        isoCode: 'EE'),
    WatchProviderCountries(
        countryName: 'Spain',
        flagPath: 'assets/images/country_flags/spain.png',
        isoCode: 'ES'),
    WatchProviderCountries(
        countryName: 'Finland',
        flagPath: 'assets/images/country_flags/finland.png',
        isoCode: 'FI'),
    WatchProviderCountries(
        countryName: 'France',
        flagPath: 'assets/images/country_flags/france.png',
        isoCode: 'FR'),
    WatchProviderCountries(
        countryName: 'United Kingdom',
        flagPath: 'assets/images/country_flags/united-kingdom.png',
        isoCode: 'GB'),
    WatchProviderCountries(
        countryName: 'Hong Kong',
        flagPath: 'assets/images/country_flags/hong-kong.png',
        isoCode: 'HK'),
    WatchProviderCountries(
        countryName: 'Croatia',
        flagPath: 'assets/images/country_flags/croatia.png',
        isoCode: 'HR'),
    WatchProviderCountries(
        countryName: 'Hungary',
        flagPath: 'assets/images/country_flags/hungary.png',
        isoCode: 'HU'),
    WatchProviderCountries(
        countryName: 'Indonesia',
        flagPath: 'assets/images/country_flags/indonesia.png',
        isoCode: 'ID'),
    WatchProviderCountries(
        countryName: 'Ireland',
        flagPath: 'assets/images/country_flags/ireland.png',
        isoCode: 'IE'),
    WatchProviderCountries(
        countryName: 'India',
        flagPath: 'assets/images/country_flags/india.png',
        isoCode: 'IN'),
    WatchProviderCountries(
        countryName: 'Italy',
        flagPath: 'assets/images/country_flags/italy.png',
        isoCode: 'IT'),
    WatchProviderCountries(
        countryName: 'Japan',
        flagPath: 'assets/images/country_flags/japan.png',
        isoCode: 'JP'),
    WatchProviderCountries(
        countryName: 'Kenya',
        flagPath: 'assets/images/country_flags/kenya.png',
        isoCode: 'KE'),
    WatchProviderCountries(
        countryName: 'South Korea',
        flagPath: 'assets/images/country_flags/south-korea.png',
        isoCode: 'KR'),
    WatchProviderCountries(
        countryName: 'Lithuania',
        flagPath: 'assets/images/country_flags/lithuania.png',
        isoCode: 'LT'),
    WatchProviderCountries(
        countryName: 'Mexico',
        flagPath: 'assets/images/country_flags/mexico.png',
        isoCode: 'MX'),
    WatchProviderCountries(
        countryName: 'Netherlands',
        flagPath: 'assets/images/country_flags/netherlands.png',
        isoCode: 'NL'),
    WatchProviderCountries(
        countryName: 'Norway',
        flagPath: 'assets/images/country_flags/norway.png',
        isoCode: 'NO'),
    WatchProviderCountries(
        countryName: 'New Zealand',
        flagPath: 'assets/images/country_flags/new-zealand.png',
        isoCode: 'NZ'),
    WatchProviderCountries(
        countryName: 'Philippines',
        flagPath: 'assets/images/country_flags/philippines.png',
        isoCode: 'PH'),
    WatchProviderCountries(
        countryName: 'Poland',
        flagPath: 'assets/images/country_flags/poland.png',
        isoCode: 'PL'),
    WatchProviderCountries(
        countryName: 'Portugal',
        flagPath: 'assets/images/country_flags/portugal.png',
        isoCode: 'PT'),
    WatchProviderCountries(
        countryName: 'Serbia',
        flagPath: 'assets/images/country_flags/serbia.png',
        isoCode: 'RS'),
    WatchProviderCountries(
        countryName: 'Russia',
        flagPath: 'assets/images/country_flags/russia.png',
        isoCode: 'RU'),
    WatchProviderCountries(
        countryName: 'Sweden',
        flagPath: 'assets/images/country_flags/sweden.png',
        isoCode: 'SE'),
    WatchProviderCountries(
        countryName: 'Slovakia',
        flagPath: 'assets/images/country_flags/slovakia.png',
        isoCode: 'SK'),
    WatchProviderCountries(
        countryName: 'Turkey',
        flagPath: 'assets/images/country_flags/turkey.png',
        isoCode: 'TR'),
    WatchProviderCountries(
        countryName: 'United States of America',
        flagPath: 'assets/images/country_flags/united-states.png',
        isoCode: 'US'),
    WatchProviderCountries(
        countryName: 'South Africa',
        flagPath: 'assets/images/country_flags/south-africa.png',
        isoCode: 'ZA'),
  ];
}
