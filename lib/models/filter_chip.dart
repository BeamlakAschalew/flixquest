class MovieGenreFilterChipWidget {
  MovieGenreFilterChipWidget(
      {required this.genreName, required this.genreValue});
  String genreName;
  String genreValue;
}

class TVGenreFilterChipWidget {
  TVGenreFilterChipWidget({required this.genreName, required this.genreValue});
  String genreName;
  String genreValue;
}

class MovieGenreFilterChipData {
  List<MovieGenreFilterChipWidget> movieGenreFilterdata =
      <MovieGenreFilterChipWidget>[
    MovieGenreFilterChipWidget(genreName: 'Action', genreValue: '28'),
    MovieGenreFilterChipWidget(genreName: 'Adventure', genreValue: '12'),
    MovieGenreFilterChipWidget(genreName: 'Animation', genreValue: '16'),
    MovieGenreFilterChipWidget(genreName: 'Comedy', genreValue: '35'),
    MovieGenreFilterChipWidget(genreName: 'Crime', genreValue: '80'),
    MovieGenreFilterChipWidget(genreName: 'Documentary', genreValue: '99'),
    MovieGenreFilterChipWidget(genreName: 'Drama', genreValue: '18'),
    MovieGenreFilterChipWidget(genreName: 'Family', genreValue: '10751'),
    MovieGenreFilterChipWidget(genreName: 'Fantasy', genreValue: '14'),
    MovieGenreFilterChipWidget(genreName: 'History', genreValue: '36'),
    MovieGenreFilterChipWidget(genreName: 'Horror', genreValue: '27'),
    MovieGenreFilterChipWidget(genreName: 'Music', genreValue: '10402'),
    MovieGenreFilterChipWidget(genreName: 'Mystery', genreValue: '9648'),
    MovieGenreFilterChipWidget(genreName: 'Romance', genreValue: '10749'),
    MovieGenreFilterChipWidget(genreName: 'Science Fiction', genreValue: '878'),
    MovieGenreFilterChipWidget(genreName: 'TV Movie', genreValue: '10770'),
    MovieGenreFilterChipWidget(genreName: 'Thriller', genreValue: '53'),
    MovieGenreFilterChipWidget(genreName: 'War', genreValue: '10752'),
    MovieGenreFilterChipWidget(genreName: 'Western', genreValue: '37'),
  ];
}

class TVGenreFilterChipData {
  List<TVGenreFilterChipWidget> tvGenreList = <TVGenreFilterChipWidget>[
    TVGenreFilterChipWidget(
        genreName: 'Action & Adventure', genreValue: '10759'),
    TVGenreFilterChipWidget(genreName: 'Animation', genreValue: '16'),
    TVGenreFilterChipWidget(genreName: 'Comedy', genreValue: '35'),
    TVGenreFilterChipWidget(genreName: 'Crime', genreValue: '80'),
    TVGenreFilterChipWidget(genreName: 'Documentary', genreValue: '99'),
    TVGenreFilterChipWidget(genreName: 'Drama', genreValue: '18'),
    TVGenreFilterChipWidget(genreName: 'Family', genreValue: '10751'),
    TVGenreFilterChipWidget(genreName: 'Kids', genreValue: '10762'),
    TVGenreFilterChipWidget(genreName: 'Mystery', genreValue: '9648'),
    TVGenreFilterChipWidget(genreName: 'News', genreValue: '10763'),
    TVGenreFilterChipWidget(genreName: 'Reality', genreValue: '10764'),
    TVGenreFilterChipWidget(genreName: 'Sci-Fi & Fantasy', genreValue: '10765'),
    TVGenreFilterChipWidget(genreName: 'Soap', genreValue: '10766'),
    TVGenreFilterChipWidget(genreName: 'Talk', genreValue: '10767'),
    TVGenreFilterChipWidget(genreName: 'War & Politics', genreValue: '10768'),
    TVGenreFilterChipWidget(genreName: 'Western', genreValue: '37'),
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
