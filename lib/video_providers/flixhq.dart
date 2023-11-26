import 'package:flixquest/video_providers/common.dart';

/// FlixHQ Movie classes
class FlixHQMovieSearch {
  int? currentPage;
  bool? hasNextPage;
  List<FlixHQMovieSearchEntry>? results;

  FlixHQMovieSearch.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(FlixHQMovieSearchEntry.fromJson(v));
      });
    }
  }
}

class FlixHQMovieSearchEntry {
  FlixHQMovieSearchEntry({
    required this.id,
    required this.releaseDate,
    required this.title,
    required this.type,
  });

  String? id;
  String? title;
  String? releaseDate;
  String? type;

  FlixHQMovieSearchEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    releaseDate = json['releaseDate'];
    type = json['type'];
  }
}

class FlixHQMovieInfo {
  String? id;
  String? title;
  String? url;
  String? type;
  String? releaseDate;
  String? message;
  List<FlixHQMovieInfoEntries>? episodes;

  FlixHQMovieInfo.fromJson(Map<String, dynamic> json) {
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
        episodes!.add(FlixHQMovieInfoEntries.fromJson(v));
      });
    }
  }
}

class FlixHQMovieInfoEntries {
  String? id;
  String? title;
  String? url;

  FlixHQMovieInfoEntries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
  }
}

/// FlixHQ TV classes
class FlixHQTVSearch {
  FlixHQTVSearch(
      {required this.currentPage,
      required this.hasNextPage,
      required this.results});

  int? currentPage;
  bool? hasNextPage;
  List<FlixHQTVSearchEntry>? results;

  FlixHQTVSearch.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(FlixHQTVSearchEntry.fromJson(v));
      });
    }
  }
}

class FlixHQTVSearchEntry {
  FlixHQTVSearchEntry(
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

  FlixHQTVSearchEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    image = json['image'];
    seasons = json['seasons'];
    type = json['type'];
  }
}

class FlixHQTVInfo {
  FlixHQTVInfo(
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
  List<FlixHQTVInfoEntries>? episodes;

  FlixHQTVInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    type = json['type'];
    releaseDate = json['releaseDate'];
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes!.add(FlixHQTVInfoEntries.fromJson(v));
      });
    }
  }
}

class FlixHQTVInfoEntries {
  FlixHQTVInfoEntries(
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

  FlixHQTVInfoEntries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    season = json['season'];
    episode = json['number'];
  }
}

/// FlixHQ Movie TMDB route
class FlixHQMovieInfoTMDBRoute {
  FlixHQMovieInfoTMDBRoute(
      {required this.id, required this.episodeId, required this.type});

  String? id;
  String? episodeId;
  String? type;

  FlixHQMovieInfoTMDBRoute.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json.containsKey('episodeId')) {
      episodeId = json['episodeId'];
    }
    type = json['type'];
  }
}

// FlixHQ TV TMDB Route
class FlixHQTVInfoTMDBRoute {
  FlixHQTVInfoTMDBRoute({required this.id, required this.seasons});

  String? id;
  List<FlixHQTVTMDBSeasons>? seasons;

  FlixHQTVInfoTMDBRoute.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['seasons'] != null) {
      seasons = [];
      json['seasons'].forEach((v) {
        seasons!.add(FlixHQTVTMDBSeasons.fromJson(v));
      });
    }
  }
}

class FlixHQTVTMDBSeasons {
  FlixHQTVTMDBSeasons({required this.episodes, required this.seasonNumber});

  int? seasonNumber;
  List<FlixHQTVTMDBEpisodes>? episodes;

  FlixHQTVTMDBSeasons.fromJson(Map<String, dynamic> json) {
    seasonNumber = json['season'];
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes!.add(FlixHQTVTMDBEpisodes.fromJson(v));
      });
    }
  }
}

class FlixHQTVTMDBEpisodes {
  FlixHQTVTMDBEpisodes({required this.id});

  String? id;

  FlixHQTVTMDBEpisodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }
}

// COMMONS
class FlixHQStreamSources {
  FlixHQStreamSources(
      {required this.videoLinks,
      required this.videoSubtitles,
      required this.messageExists});

  List<FlixHQVideoLinks>? videoLinks;
  List<FlixHQSubLinks>? videoSubtitles;

  bool? messageExists;

  FlixHQStreamSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(FlixHQVideoLinks.fromJson(v));
      });
    }
    if (json.containsKey('subtitles') && json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(FlixHQSubLinks.fromJson(v));
      });
    }
    if (json.containsKey('message')) {
      messageExists = true;
    }
  }
}

class FlixHQVideoLinks extends RegularVideoLinks {
  FlixHQVideoLinks.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

class FlixHQSubLinks extends RegularSubtitleLinks {
  FlixHQSubLinks.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}
