class RecentMovie {
  RecentMovie(
      {required this.dateTime,
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

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['release_year'] = releaseYear;
    map['elapsed'] = elapsed;
    map['remaining'] = remaining;
    map['date_watched'] = dateTime;
    map['poster_path'] = posterPath;
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
  }
}

class RecentEpisode {}
