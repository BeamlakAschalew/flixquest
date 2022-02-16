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

class TVDetails {
  List<dynamic>? runtime;
  String? tagline;
  String? originalTitle;
  String? status;
  bool? inProduction;
  int? numberOfSeasons;
  int? numberOfEpisodes;
  int? id;
  String? backdropPath;
  List<ProductionCompanies>? productionCompanies;
  List<ProductionCountries>? productionCountries;
  List<SpokenLanguages>? spokenLanguages;
  List<Seasons>? seasons;
  List<EpisodeList>? episodes;
  List<CreatedBy>? createdBy;

  TVDetails(
      {this.runtime,
      this.tagline,
      this.status,
      this.originalTitle,
      this.inProduction,
      this.numberOfEpisodes,
      this.numberOfSeasons,
      this.productionCompanies,
      this.productionCountries,
      this.spokenLanguages,
      this.id,
      this.backdropPath,
      this.createdBy});
  TVDetails.fromJson(Map<String, dynamic> json) {
    runtime = json['episode_run_time'];
    tagline = json['tagline'];
    status = json['status'];
    id = json['id'];
    backdropPath = json['backdrop_path'];
    originalTitle = json['original_name'];
    numberOfEpisodes = json['number_of_episodes'];
    numberOfSeasons = json['number_of_seasons'];
    inProduction = json['in_production'];
    if (json['production_companies'] != null) {
      productionCompanies = [];
      json['production_companies'].forEach((v) {
        productionCompanies?.add(ProductionCompanies.fromJson(v));
      });
    }
    if (json['production_countries'] != null) {
      productionCountries = [];
      json['production_countries'].forEach((v) {
        productionCountries?.add(ProductionCountries.fromJson(v));
      });
    }
    if (json['spoken_languages'] != null) {
      spokenLanguages = [];
      json['spoken_languages'].forEach((v) {
        spokenLanguages?.add(SpokenLanguages.fromJson(v));
      });
    }
    if (json['seasons'] != null) {
      seasons = [];
      json['seasons'].forEach((v) {
        seasons?.add(Seasons.fromJson(v));
      });
    }
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes?.add(EpisodeList.fromJson(v));
      });
    }
    if (json['created_by'] != null) {
      createdBy = [];
      json['created_by'].forEach((v) {
        createdBy?.add(CreatedBy.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (productionCompanies != null) {
      data['production_companies'] =
          productionCompanies?.map((v) => v.toJson()).toList();
    }
    if (productionCountries != null) {
      data['production_countries'] =
          productionCountries?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Seasons {
  String? name;
  int? seasonNumber;
  String? posterPath;
  int? seasonId;
  String? overview;
  String? airDate;
  int? episodeCount;
  Seasons(
      {this.airDate,
      this.episodeCount,
      this.name,
      this.overview,
      this.posterPath,
      this.seasonId,
      this.seasonNumber});
  Seasons.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    seasonNumber = json['season_number'];
    posterPath = json['poster_path'];
    seasonId = json['id'];
    overview = json['overview'];
    airDate = json['air_date'];
    episodeCount = json['episode_count'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['season_number'] = seasonNumber;
    data['poster_path'] = posterPath;
    data['id'] = seasonId;
    data['overview'] = overview;
    data['air_date'] = airDate;
    data['episode_count'] = episodeCount;
    return data;
  }
}

class EpisodeList {
  int? episodeNumber;
  String? name;
  String? airDate;
  EpisodeList({this.airDate, this.episodeNumber, this.name});
  EpisodeList.fromJson(Map<String, dynamic> json) {
    episodeNumber = json['episode_number'];
    name = json['name'];
    airDate = json['air_date'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['episode_number'] = episodeNumber;
    data['name'] = name;
    data['air_date'] = airDate;
    return data;
  }
}

class ProductionCompanies {
  String? name;
  ProductionCompanies({this.name});
  ProductionCompanies.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;

    return data;
  }
}

class ProductionCountries {
  String? name;
  ProductionCountries({this.name});
  ProductionCountries.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;

    return data;
  }
}

class SpokenLanguages {
  String? englishName;
  SpokenLanguages({this.englishName});
  SpokenLanguages.fromJson(Map<String, dynamic> json) {
    englishName = json['english_name'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['english_name'] = englishName;
    return data;
  }
}

class CreatedBy {
  int? id;
  String? name;
  String? profilePath;
  int? gender;
  CreatedBy({this.gender, this.id, this.name, this.profilePath});
  CreatedBy.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profilePath = json['profile_path'];
    gender = json['gender'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['profile_path'] = profilePath;
    data['gender'] = gender;
    return data;
  }
}

class PersonTVList {
  List<TV>? movies;
  PersonTVList({this.movies});
  PersonTVList.fromJson(Map<String, dynamic> json) {
    if (json['cast'] != null) {
      movies = [];
      json['cast'].forEach((v) {
        movies!.add(TV.fromJson(v));
      });
    }
    // if (json['crew'] != null) {
    //   movies = [];
    //   json['crew'].forEach((v) {
    //     movies!.add(TV.fromJson(v));
    //   });
    // }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (movies != null) {
      data['cast'] = movies!.map((v) => v.toJson()).toList();
    }
    // if (movies != null) {
    //   data['crew'] = movies!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}
