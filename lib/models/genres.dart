class GenreList {
  List<Genres>? genre;

  GenreList({
    this.genre,
  });

  GenreList.fromJson(Map<String, dynamic> json) {
    if (json['genres'] != null) {
      genre = [];
      json['genres'].forEach((v) {
        genre?.add(Genres.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (genre != null) {
      data['genres'] = genre?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Genres {
  String? genreName;
  int? genreID;
  Genres({this.genreName, this.genreID});
  Genres.fromJson(Map<String, dynamic> json) {
    genreName = json['name'];
    genreID = json['id'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = genreName;
    data['id'] = genreID;
    return data;
  }
}

class MovieGenreNaming {
  String? genreName;
  int? genreValue;

  MovieGenreNaming({this.genreValue, this.genreName});
}

class TVGenreNaming {
  String? genreName;
  int? genreValue;

  TVGenreNaming({this.genreValue, this.genreName});
}

class GenreData {
  List<MovieGenreNaming> movieGenres = [
    MovieGenreNaming(genreName: 'Action', genreValue: 28),
    MovieGenreNaming(genreName: 'Adventure', genreValue: 12),
    MovieGenreNaming(genreName: 'Animation', genreValue: 16),
    MovieGenreNaming(genreName: 'Comedy', genreValue: 35),
    MovieGenreNaming(genreName: 'Crime', genreValue: 80),
    MovieGenreNaming(genreName: 'Documentary', genreValue: 99),
    MovieGenreNaming(genreName: 'Drama', genreValue: 18),
    MovieGenreNaming(genreName: 'Family', genreValue: 10751),
    MovieGenreNaming(genreName: 'Fantasy', genreValue: 14),
    MovieGenreNaming(genreName: 'History', genreValue: 36),
    MovieGenreNaming(genreName: 'Horror', genreValue: 27),
    MovieGenreNaming(genreName: 'Music', genreValue: 10402),
    MovieGenreNaming(genreName: 'Mystery', genreValue: 9648),
    MovieGenreNaming(genreName: 'Romance', genreValue: 10749),
    MovieGenreNaming(genreName: 'Science Fiction', genreValue: 878),
    MovieGenreNaming(genreName: 'TV Movie', genreValue: 10770),
    MovieGenreNaming(genreName: 'Thriller', genreValue: 53),
    MovieGenreNaming(genreName: 'War', genreValue: 10752),
    MovieGenreNaming(genreName: 'Western', genreValue: 37),
  ];

  List<TVGenreNaming> tvGenre = [
    TVGenreNaming(genreName: 'Action & Adventure', genreValue: 10759),
    TVGenreNaming(genreName: 'Animation', genreValue: 16),
    TVGenreNaming(genreName: 'Comedy', genreValue: 35),
    TVGenreNaming(genreName: 'Crime', genreValue: 80),
    TVGenreNaming(genreName: 'Documentary', genreValue: 99),
    TVGenreNaming(genreName: 'Drama', genreValue: 18),
    TVGenreNaming(genreName: 'Family', genreValue: 10751),
    TVGenreNaming(genreName: 'Kids', genreValue: 10762),
    TVGenreNaming(genreName: 'Mystery', genreValue: 9648),
    TVGenreNaming(genreName: 'News', genreValue: 10763),
    TVGenreNaming(genreName: 'Reality', genreValue: 10764),
    TVGenreNaming(genreName: 'Sci-Fi & Fantasy', genreValue: 10765),
    TVGenreNaming(genreName: 'Soap', genreValue: 10766),
    TVGenreNaming(genreName: 'Talk', genreValue: 10767),
    TVGenreNaming(genreName: 'War & Politics', genreValue: 10768),
    TVGenreNaming(genreName: 'Western', genreValue: 37),
  ];
}
