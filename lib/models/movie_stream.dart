class MovieStream {
  MovieStream(
      {required this.currentPage,
      required this.hasNextPage,
      required this.results});

  int? currentPage;
  bool? hasNextPage;
  List<MovieResults>? results;

  MovieStream.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(MovieResults.fromJson(v));
      });
    }
  }
}

class MovieResults {
  MovieResults(
      {required this.id,
      required this.image,
      required this.releaseDate,
      required this.title,
      required this.type,
      required this.url});

  String? id;
  String? title;
  String? url;
  String? image;
  String? releaseDate;
  String? type;

  MovieResults.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    image = json['image'];
    releaseDate = json['releaseDate'];
    type = json['type'];
  }
}

class MovieInfo {
  MovieInfo();

  String? id;
  String? title;
  String? url;
  String? type;
  String? releaseDate;
  String? message;
  List<MovieEpisodes>? episodes;

  MovieInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    type = json['type'];
    releaseDate = json['releaseDate'];
    if (json.containsKey('message')) {
      message = json['message'];
    }
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes!.add(MovieEpisodes.fromJson(v));
      });
    }
  }
}

class MovieEpisodes {
  MovieEpisodes();

  String? id;
  String? title;
  String? url;

  MovieEpisodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
  }
}

class MovieVideoSources {
  MovieVideoSources(
      {required this.videoLinks,
      required this.videoSubtitles,
      required this.messageExists});

  List<MovieVideoLinks>? videoLinks;
  List<MovieVideoSubtitles>? videoSubtitles;

  bool? messageExists;

  MovieVideoSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(MovieVideoLinks.fromJson(v));
      });
    }
    if (json.containsKey('subtitles') && json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(MovieVideoSubtitles.fromJson(v));
      });
    }
    if (json.containsKey('message')) {
      messageExists = true;
    }
  }
}

class MovieVideoLinks {
  String? url;
  String? quality;
  bool? isM3U8;

  MovieVideoLinks.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    quality = json['quality'];
    isM3U8 = json['isM3U8'];
  }
}

class MovieVideoSubtitles {
  String? url;
  String? language;

  MovieVideoSubtitles.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    language = json['lang'];
  }
}

/// TMDB route

class MovieInfoTMDBRoute {
  MovieInfoTMDBRoute(
      {required this.id, required this.episodeId, required this.type});

  String? id;
  String? episodeId;
  String? type;

  MovieInfoTMDBRoute.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json.containsKey('episodeId')) {
      episodeId = json['episodeId'];
    }
    type = json['type'];
  }
}

class TMA {
  String? label;
  List<TMAVideoSources>? sources;
  List<TMASubtitleSources>? subSources;

  TMA({required this.label, required this.sources});

  TMA.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    if (json['sources'][0]['sources'] != null) {
      sources = [];
      json['sources'][0]['sources'].forEach((element) {
        sources!.add(TMAVideoSources.fromJson(element));
      });
    }
    if (json['subtitles'] != null) {
      subSources = [];
      json['sources'].forEach((element) {
        subSources!.add(TMASubtitleSources.fromJson(element));
      });
    }
  }
}

class TMAVideoSources {
  String? quality, url;
  TMAVideoSources({required this.quality, required this.url});

  TMAVideoSources.fromJson(Map<String, dynamic> json) {
    quality = json['quality'];
    url = json['url'];
  }
}

class TMASubtitleSources {
  String? language, url, type;
  TMASubtitleSources(
      {required this.language, required this.type, required this.url});

  TMASubtitleSources.fromJson(Map<String, dynamic> json) {
    language = json['language'];
    url = json['url'];
    type = json['type'];
  }
}
