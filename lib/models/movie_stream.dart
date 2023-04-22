class MovieStream {
  MovieStream(
      {required this.currentIndex,
      required this.hasNextPage,
      required this.results});

  int? currentIndex;
  bool? hasNextPage;
  List<MovieResults>? results;
}

class MovieResults {
  MovieResults(
      {required this.id,
      required this.image,
      required this.releaseDate,
      required this.title,
      required this.type,
      required this.url});

  String? id;
  String? title;
  String? url;
  String? image;
  String? releaseDate;
  String? type;
}

class MovieInfo {
  MovieInfo();

  String? id;
  String? title;
  String? url;
  String? type;
  String? releaseDate;
}

class MovieEpisodes {
  MovieEpisodes();

  String? id;
  String? title;
  String? url;
}
