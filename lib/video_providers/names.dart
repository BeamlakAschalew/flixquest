class ProviderNames {
  static List<VideoProvider> providers = [
    VideoProvider(fullName: 'FlixHQ', codeName: 'flixhq'),
    VideoProvider(fullName: 'Superstream', codeName: 'superstream'),
    VideoProvider(fullName: 'Dramacool', codeName: 'dramacool'),
    VideoProvider(fullName: 'ViewAsian', codeName: 'viewasian'),
    VideoProvider(fullName: 'FlixHQNew', codeName: 'flixhqNew')
  ];
}

class VideoProvider {
  String fullName;
  String codeName;

  VideoProvider({required this.fullName, required this.codeName});
}
