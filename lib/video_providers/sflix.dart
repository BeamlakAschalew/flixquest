import 'common.dart';

/// Sflix provider - Consumet based

/// Sflix search
class SflixSearch {
  int? currentPage;
  bool? hasNextPage;
  List<SflixSearchEntry>? results;

  SflixSearch.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(SflixSearchEntry.fromJson(v));
      });
    }
  }
}

class SflixSearchEntry {
  SflixSearchEntry({
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

  SflixSearchEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    releaseDate = json['releaseDate'];
    type = json['type'];
    seasons = json['seasons'];
  }
}

class SflixInfo {
  String? id;
  String? title;
  String? url;
  String? type;
  String? releaseDate;
  String? message;
  List<SflixInfoEntries>? episodes;

  SflixInfo.fromJson(Map<String, dynamic> json) {
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
        episodes!.add(SflixInfoEntries.fromJson(v));
      });
    }
  }
}

class SflixInfoEntries {
  String? id;
  String? title;
  String? url;
  int? season;
  int? episode;

  SflixInfoEntries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    season = json['season'];
    episode = json['number'];
  }
}

class SflixStreamSources {
  SflixStreamSources(
      {required this.videoLinks,
      required this.videoSubtitles,
      required this.messageExists});

  List<SflixVideoLinks>? videoLinks;
  List<SflixSubLinks>? videoSubtitles;

  bool? messageExists;

  SflixStreamSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(SflixVideoLinks.fromJson(v));
      });
    }
    if (json.containsKey('subtitles') && json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(SflixSubLinks.fromJson(v));
      });
    }
    if (json.containsKey('message')) {
      messageExists = true;
    }
  }
}

class SflixVideoLinks extends RegularVideoLinks {
  SflixVideoLinks.fromJson(super.json) : super.fromJson();
}

class SflixSubLinks extends RegularSubtitleLinks {
  SflixSubLinks.fromJson(super.json) : super.fromJson();
}
