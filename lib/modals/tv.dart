class TVList {
  int? page;
  int? totalMovies;
  int? totalPages;
  List<TV>? tvSeries;

  TVList({this.page, this.totalMovies, this.totalPages, this.tvSeries});

  TVList.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    totalMovies = json['total_results'];
    totalPages = json['total_pages'];
    if (json['results'] != null) {
      tvSeries = [];
      json['results'].forEach((v) {
        tvSeries!.add(TV.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['total_results'] = totalMovies;
    data['total_pages'] = totalPages;
    if (tvSeries != null) {
      data['results'] = tvSeries!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TV {
  int? voteCount;
  int? id;
  num? voteAverage;
  String? name;
  num? popularity;
  String? posterPath;
  String? originalLanguage;
  String? originalName;
  List<int>? genreIds;
  String? backdropPath;
  String? overview;
  String? firstAirDate;
  // String? originCountry;

  TV({
    this.voteCount,
    this.id,
    this.voteAverage,
    this.name,
    this.popularity,
    this.posterPath,
    this.originalLanguage,
    this.originalName,
    this.genreIds,
    this.backdropPath,
    this.overview,
    this.firstAirDate,
    // this.originCountry,
  });

  TV.fromJson(Map<String, dynamic> json) {
    voteCount = json['vote_count'];
    id = json['id'];
    voteAverage = json['vote_average'];
    name = json['name'];
    popularity = json['popularity'];
    posterPath = json['poster_path'];
    originalLanguage = json['original_language'];
    originalName = json['original_name'];
    genreIds = json['genre_ids'].cast<int>();
    backdropPath = json['backdrop_path'];
    overview = json['overview'];
    firstAirDate = json['first_air_date'];
    // originCountry = json['origin_country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vote_count'] = voteCount;
    data['id'] = id;
    data['vote_average'] = voteAverage;
    data['name'] = name;
    data['popularity'] = popularity;
    data['poster_path'] = posterPath;
    data['original_language'] = originalLanguage;
    data['original_title'] = originalName;
    data['genre_ids'] = genreIds;
    data['backdrop_path'] = backdropPath;
    data['overview'] = overview;
    data['first_air_date'] = firstAirDate;
    // data['origin_country'] = originCountry;
    return data;
  }
}
