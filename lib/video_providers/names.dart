class ProviderNames {
  static List<Provider> providers = [
    Provider(fullName: 'FlixHQ', codeName: 'flixhq'),
    Provider(fullName: 'Superstream', codeName: 'superstream'),
    Provider(fullName: 'Dramacool', codeName: 'dramacool'),
    Provider(fullName: 'ViewAsian', codeName: 'viewasian')
  ];
}

class Provider {
  String fullName;
  String codeName;

  Provider({required this.fullName, required this.codeName});
}
