class Images {
  List<Backdrops>? backdrop;
  List<Posters>? poster;

  Images({
    this.backdrop,
    this.poster,
  });

  Images.fromJson(Map<String, dynamic> json) {
    if (json['backdrops'] != null) {
      backdrop = [];
      json['backdrops'].forEach((v) {
        backdrop?.add(Backdrops.fromJson(v));
      });
    }
    if (json['posters'] != null) {
      poster = [];
      json['posters'].forEach((v) {
        poster?.add(Posters.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (backdrop != null) {
      data['backdrops'] = backdrop?.map((v) => v.toJson()).toList();
    }
    if (poster != null) {
      data['posters'] = poster?.map((v) => v.toJson()).toList();
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

class Posters {
  String? posterPath;
  Posters({this.posterPath});
  Posters.fromJson(Map<String, dynamic> json) {
    posterPath = json['file_path'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file_path'] = posterPath;
    return data;
  }
}

class PersonImages {
  List<Profiles>? profile;
  PersonImages(this.profile);

  PersonImages.fromJson(Map<String, dynamic> json) {
    if (json['profiles'] != null) {
      profile = [];
      json['profiles'].forEach((v) {
        profile?.add(Profiles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (profile != null) {
      data['profiles'] = profile?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Profiles {
  String? filePath;
  Profiles(this.filePath);
  Profiles.fromJson(Map<String, dynamic> json) {
    filePath = json['file_path'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file_path'] = filePath;

    return data;
  }
}
