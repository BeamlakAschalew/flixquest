class RecentMovie {
  RecentMovie(
      {required this.backdropPath,
      required this.dateTime,
      required this.elapsed,
      required this.id,
      required this.posterPath,
      required this.releaseYear,
      required this.remaining,
      required this.title});

  int? id;
  String? title;
  int? releaseYear;
  int? elapsed;
  int? remaining;
  String? dateTime;
  String? posterPath;
  String? backdropPath;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['release_year'] = releaseYear;
    map['elapsed'] = elapsed;
    map['remaining'] = remaining;
    map['date_watched'] = dateTime;
    map['poster_path'] = posterPath;
    map['backdrop_path'] = backdropPath;
    return map;
  }

  RecentMovie.fromMapObject(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    releaseYear = map['release_year'];
    elapsed = map['elapsed'];
    remaining = map['remaining'];
    dateTime = map['date_watched'];
    posterPath = map['poster_path'];
    backdropPath = map['backdrop_path'];
  }
}

class RecentEpisode {
  int? id;
  String? seriesName;
  String? episodeName;
  int? episodeNum;
  int? seasonNum;
  String? posterPath;
  String? dateTime;
  int? elapsed;
  int? remaining;
  int? seriesId;

  RecentEpisode(
      {required this.dateTime,
      required this.elapsed,
      required this.episodeName,
      required this.episodeNum,
      required this.id,
      required this.posterPath,
      required this.remaining,
      required this.seasonNum,
      required this.seriesName,
      required this.seriesId});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['series_name'] = seriesName;
    map['episode_name'] = episodeName;
    map['episode_num'] = episodeNum;
    map['season_num'] = seasonNum;
    map['poster_path'] = posterPath;
    map['elapsed'] = elapsed;
    map['remaining'] = remaining;
    map['date_added'] = dateTime;
    map['series_id'] = seriesId;
    return map;
  }

  RecentEpisode.fromMapObject(Map<String, dynamic> map) {
    id = map['id'];
    seriesName = map['series_name'];
    episodeName = map['episode_name'];
    episodeNum = map['episode_num'];
    seasonNum = map['season_num'];
    posterPath = map['poster_path'];
    elapsed = map['elapsed'];
    remaining = map['remaining'];
    dateTime = map['date_added'];
    seriesId = map['series_id'];
  }
}
