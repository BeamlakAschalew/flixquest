class TVGenreList {
  List<TVGenres>? genre;

  TVGenreList({
    this.genre,
  });

  TVGenreList.fromJson(Map<String, dynamic> json) {
    if (json['genres'] != null) {
      genre = [];
      json['genres'].forEach((v) {
        genre?.add(TVGenres.fromJson(v));
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

class TVGenres {
  String? genreName;
  int? genreID;
  TVGenres({this.genreName, this.genreID});
  TVGenres.fromJson(Map<String, dynamic> json) {
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
