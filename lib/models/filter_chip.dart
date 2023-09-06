import 'package:easy_localization/easy_localization.dart';

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
    MovieGenreFilterChipWidget(genreName: tr('action'), genreValue: '28'),
    MovieGenreFilterChipWidget(genreName: tr('adventure'), genreValue: '12'),
    MovieGenreFilterChipWidget(genreName: tr('animation'), genreValue: '16'),
    MovieGenreFilterChipWidget(genreName: tr('comedy'), genreValue: '35'),
    MovieGenreFilterChipWidget(genreName: tr('crime'), genreValue: '80'),
    MovieGenreFilterChipWidget(genreName: tr('documentary'), genreValue: '99'),
    MovieGenreFilterChipWidget(genreName: tr('drama'), genreValue: '18'),
    MovieGenreFilterChipWidget(genreName: tr('family'), genreValue: '10751'),
    MovieGenreFilterChipWidget(genreName: tr('fantasy'), genreValue: '14'),
    MovieGenreFilterChipWidget(genreName: tr('history'), genreValue: '36'),
    MovieGenreFilterChipWidget(genreName: tr('horror'), genreValue: '27'),
    MovieGenreFilterChipWidget(genreName: tr('music'), genreValue: '10402'),
    MovieGenreFilterChipWidget(genreName: tr('mystery'), genreValue: '9648'),
    MovieGenreFilterChipWidget(genreName: tr('romance'), genreValue: '10749'),
    MovieGenreFilterChipWidget(
        genreName: tr('science_fiction'), genreValue: '878'),
    MovieGenreFilterChipWidget(genreName: tr('tv_movie'), genreValue: '10770'),
    MovieGenreFilterChipWidget(genreName: tr('thriller'), genreValue: '53'),
    MovieGenreFilterChipWidget(genreName: tr('war'), genreValue: '10752'),
    MovieGenreFilterChipWidget(genreName: tr('western'), genreValue: '37'),
  ];
}

class TVGenreFilterChipData {
  List<TVGenreFilterChipWidget> tvGenreList = <TVGenreFilterChipWidget>[
    TVGenreFilterChipWidget(
        genreName: tr('action_and_adventure'), genreValue: '10759'),
    TVGenreFilterChipWidget(genreName: tr('animation'), genreValue: '16'),
    TVGenreFilterChipWidget(genreName: tr('comedy'), genreValue: '35'),
    TVGenreFilterChipWidget(genreName: tr('crime'), genreValue: '80'),
    TVGenreFilterChipWidget(genreName: tr('documentary'), genreValue: '99'),
    TVGenreFilterChipWidget(genreName: tr('drama'), genreValue: '18'),
    TVGenreFilterChipWidget(genreName: tr('family'), genreValue: '10751'),
    TVGenreFilterChipWidget(genreName: tr('kids'), genreValue: '10762'),
    TVGenreFilterChipWidget(genreName: tr('mystery'), genreValue: '9648'),
    TVGenreFilterChipWidget(genreName: tr('news'), genreValue: '10763'),
    TVGenreFilterChipWidget(genreName: tr('reality'), genreValue: '10764'),
    TVGenreFilterChipWidget(
        genreName: tr('scifi_and_fantasy'), genreValue: '10765'),
    TVGenreFilterChipWidget(genreName: tr('soap'), genreValue: '10766'),
    TVGenreFilterChipWidget(genreName: tr('talk'), genreValue: '10767'),
    TVGenreFilterChipWidget(
        genreName: tr('war_and_politics'), genreValue: '10768'),
    TVGenreFilterChipWidget(genreName: tr('western'), genreValue: '37'),
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
