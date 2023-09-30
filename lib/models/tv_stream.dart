class TVStream {
  TVStream(
      {required this.currentPage,
      required this.hasNextPage,
      required this.results});

  int? currentPage;
  bool? hasNextPage;
  List<TVResults>? results;

  TVStream.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(TVResults.fromJson(v));
      });
    }
  }
}

class TVResults {
  TVResults(
      {required this.id,
      required this.image,
      required this.seasons,
      required this.title,
      required this.type,
      required this.url});

  String? id;
  String? title;
  String? url;
  String? image;
  int? seasons;
  String? type;

  TVResults.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    image = json['image'];
    seasons = json['seasons'];
    type = json['type'];
  }
}

class TVInfo {
  TVInfo(
      {required this.episodes,
      required this.id,
      required this.releaseDate,
      required this.title,
      required this.type,
      required this.url});

  String? id;
  String? title;
  String? url;
  String? type;
  String? releaseDate;
  List<TVEpisodes>? episodes;

  TVInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    type = json['type'];
    releaseDate = json['releaseDate'];
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes!.add(TVEpisodes.fromJson(v));
      });
    }
  }
}

class TVEpisodes {
  TVEpisodes(
      {required this.episode,
      required this.id,
      required this.season,
      required this.title,
      required this.url});

  String? id;
  String? title;
  String? url;
  int? season;
  int? episode;

  TVEpisodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    season = json['season'];
    episode = json['number'];
  }
}

class TVVideoSources {
  TVVideoSources({required this.videoLinks, required this.videoSubtitles});

  List<TVVideoLinks>? videoLinks;
  List<TVVideoSubtitles>? videoSubtitles;

  TVVideoSources.fromJson(Map<String, dynamic> json) {
    if (json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(TVVideoLinks.fromJson(v));
      });
    }
    if (json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(TVVideoSubtitles.fromJson(v));
      });
    }
  }
}

class TVVideoLinks {
  TVVideoLinks(
      {required this.isM3U8, required this.quality, required this.url});

  String? url;
  String? quality;
  bool? isM3U8;

  TVVideoLinks.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    quality = json['quality'];
    isM3U8 = json['isM3U8'];
  }
}

class TVVideoSubtitles {
  String? url;
  String? language;

  TVVideoSubtitles.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    language = json['lang'];
  }
}

/// TV TMDB route

class TVTMDBRoute {
  TVTMDBRoute({required this.id, required this.seasons});

  late String id;
  late List<TVTMDBSeasons> seasons;

  TVTMDBRoute.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['seasons'] != null) {
      seasons = [];
      json['seasons'].forEach((v) {
        seasons.add(TVTMDBSeasons.fromJson(v));
      });
    }
  }
}

class TVTMDBSeasons {
  TVTMDBSeasons({required this.episodes, required this.seasonNumber});

  late int seasonNumber;
  late List<TVTMDBEpisodes> episodes;

  TVTMDBSeasons.fromJson(Map<String, dynamic> json) {
    seasonNumber = json['season'];
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes.add(TVTMDBEpisodes.fromJson(v));
      });
    }
  }
}

class TVTMDBEpisodes {
  TVTMDBEpisodes({required this.id});

  late String id;

  TVTMDBEpisodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }
}
