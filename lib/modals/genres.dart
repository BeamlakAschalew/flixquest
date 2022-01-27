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
  Genres({this.genreName});
  Genres.fromJson(Map<String, dynamic> json) {
    genreName = json['name'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = genreName;
    return data;
  }
}
