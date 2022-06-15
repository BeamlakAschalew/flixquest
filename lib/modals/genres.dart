class GeneralGenreList {
  List<CommonGenres>? genre;

  GeneralGenreList({
    this.genre,
  });

  GeneralGenreList.fromJson(Map<String, dynamic> json) {
    if (json['genres'] != null) {
      genre = [];
      json['genres'].forEach((v) {
        genre?.add(CommonGenres.fromJson(v));
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

class CommonGenres {
  String? genreName;
  int? genreID;
  CommonGenres({this.genreName, this.genreID});
  CommonGenres.fromJson(Map<String, dynamic> json) {
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
