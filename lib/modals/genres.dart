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
