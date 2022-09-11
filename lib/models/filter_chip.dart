class GenreFilterChipWidget {
  GenreFilterChipWidget({required this.genreName, required this.genreValue});
  String genreName;
  String genreValue;
}

class GenreFilterChipData {
  List<GenreFilterChipWidget> genreFilterdata = <GenreFilterChipWidget>[
    GenreFilterChipWidget(genreName: 'Action', genreValue: '28'),
    GenreFilterChipWidget(genreName: 'Adventure', genreValue: '12'),
    GenreFilterChipWidget(genreName: 'Animation', genreValue: '16'),
    GenreFilterChipWidget(genreName: 'Comedy', genreValue: '35'),
    GenreFilterChipWidget(genreName: 'Crime', genreValue: '80'),
    GenreFilterChipWidget(genreName: 'Documentary', genreValue: '99'),
    GenreFilterChipWidget(genreName: 'Drama', genreValue: '18'),
    GenreFilterChipWidget(genreName: 'Family', genreValue: '10751'),
    GenreFilterChipWidget(genreName: 'Fantasy', genreValue: '14'),
    GenreFilterChipWidget(genreName: 'History', genreValue: '36'),
    GenreFilterChipWidget(genreName: 'Horror', genreValue: '27'),
    GenreFilterChipWidget(genreName: 'Music', genreValue: '10402'),
    GenreFilterChipWidget(genreName: 'Mystery', genreValue: '9648'),
    GenreFilterChipWidget(genreName: 'Romance', genreValue: '10749'),
    GenreFilterChipWidget(genreName: 'Science Fiction', genreValue: '878'),
    GenreFilterChipWidget(genreName: 'TV Movie', genreValue: '10770'),
    GenreFilterChipWidget(genreName: 'Thriller', genreValue: '53'),
    GenreFilterChipWidget(genreName: 'War', genreValue: '10752'),
    GenreFilterChipWidget(genreName: 'Western', genreValue: '37'),
  ];
}

class WatchProvidersFilterChipWidget {
  WatchProvidersFilterChipWidget(
      {required this.networkName, required this.networkId});
  String networkName;
  String networkId;
}

class WatchProvidersFilterChipData {
  List<WatchProvidersFilterChipWidget> providerFilterData =
      <WatchProvidersFilterChipWidget>[
    WatchProvidersFilterChipWidget(networkName: 'Netflix', networkId: '8'),
    WatchProvidersFilterChipWidget(networkName: 'Amazon Prime', networkId: '9'),
    WatchProvidersFilterChipWidget(
        networkName: 'Disney Plus', networkId: '337'),
    WatchProvidersFilterChipWidget(networkName: 'hulu', networkId: '15'),
    WatchProvidersFilterChipWidget(networkName: 'HBO Max', networkId: '384'),
    WatchProvidersFilterChipWidget(
        networkName: 'Apple TV plus', networkId: '350'),
    WatchProvidersFilterChipWidget(networkName: 'Peacock', networkId: '387'),
    WatchProvidersFilterChipWidget(networkName: 'iTunes', networkId: '2'),
    WatchProvidersFilterChipWidget(
        networkName: 'YouTube Premium', networkId: '188'),
    WatchProvidersFilterChipWidget(
        networkName: 'Paramount Plus', networkId: '531'),
    WatchProvidersFilterChipWidget(
        networkName: 'Netflix Kids', networkId: '175'),
  ];
}
