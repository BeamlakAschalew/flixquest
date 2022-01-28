class MovieRecommendations {
  List<Results>? result;

  MovieRecommendations({
    this.result,
  });

  MovieRecommendations.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      result = [];
      json['results'].forEach((v) {
        result?.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (result != null) {
      data['results'] = result?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? originalName;
  int? id;
  String? posterPath;
  num? voteAverage;

  Results({this.originalName, this.id, this.posterPath, this.voteAverage});
  Results.fromJson(Map<String, dynamic> json) {
    originalName = json['original_title'];
    id = json['id'];
    posterPath = json['poster_path'];
    voteAverage = json['vote_average'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['original_title'] = originalName;
    data['id'] = id;
    data['poster_path'] = posterPath;
    data['vote_average'] = voteAverage;
    return data;
  }
}
