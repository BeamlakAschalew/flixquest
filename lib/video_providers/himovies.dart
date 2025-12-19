import 'common.dart';

/// Himovies provider - Consumet based

/// Himovies search
class HimoviesSearch {
  int? currentPage;
  bool? hasNextPage;
  List<HimoviesSearchEntry>? results;

  HimoviesSearch.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(HimoviesSearchEntry.fromJson(v));
      });
    }
  }
}

class HimoviesSearchEntry {
  HimoviesSearchEntry({
    required this.id,
    required this.releaseDate,
    required this.title,
    required this.type,
  });

  String? id;
  String? title;
  String? releaseDate;
  String? type;
  int? seasons;

  HimoviesSearchEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    releaseDate = json['releaseDate'];
    type = json['type'];
    seasons = json['seasons'];
  }
}

class HimoviesInfo {
  String? id;
  String? title;
  String? url;
  String? type;
  String? releaseDate;
  String? message;
  List<HimoviesInfoEntries>? episodes;

  HimoviesInfo.fromJson(Map<String, dynamic> json) {
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
        episodes!.add(HimoviesInfoEntries.fromJson(v));
      });
    }
  }
}

class HimoviesInfoEntries {
  String? id;
  String? title;
  String? url;
  int? season;
  int? episode;

  HimoviesInfoEntries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    season = json['season'];
    episode = json['number'];
  }
}

class HimoviesStreamSources {
  HimoviesStreamSources(
      {required this.videoLinks,
      required this.videoSubtitles,
      required this.messageExists});

  List<HimoviesVideoLinks>? videoLinks;
  List<HimoviesSubLinks>? videoSubtitles;

  bool? messageExists;

  HimoviesStreamSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(HimoviesVideoLinks.fromJson(v));
      });
    }
    if (json.containsKey('subtitles') && json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(HimoviesSubLinks.fromJson(v));
      });
    }
    if (json.containsKey('message')) {
      messageExists = true;
    }
  }
}

class HimoviesVideoLinks extends RegularVideoLinks {
  HimoviesVideoLinks.fromJson(super.json) : super.fromJson();
}

class HimoviesSubLinks extends RegularSubtitleLinks {
  HimoviesSubLinks.fromJson(super.json) : super.fromJson();
}
