class MovieImages {
  List<Backdrops>? backdrop;

  MovieImages({
    this.backdrop,
  });

  MovieImages.fromJson(Map<String, dynamic> json) {
    if (json['backdrops'] != null) {
      backdrop = [];
      json['backdrops'].forEach((v) {
        backdrop?.add(Backdrops.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (backdrop != null) {
      data['backdrops'] = backdrop?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Backdrops {
  String? filePath;
  Backdrops({this.filePath});
  Backdrops.fromJson(Map<String, dynamic> json) {
    filePath = json['file_path'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file_path'] = filePath;

    return data;
  }
}
