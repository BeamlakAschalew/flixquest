import 'common.dart';

/// Goku provider - Consumet based

/// Goku search
class GokuSearch {
  int? currentPage;
  bool? hasNextPage;
  List<GokuSearchEntry>? results;

  GokuSearch.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(GokuSearchEntry.fromJson(v));
      });
    }
  }
}

class GokuSearchEntry {
  GokuSearchEntry({
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

  GokuSearchEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    releaseDate = json['releaseDate'];
    type = json['type'];
    seasons = json['seasons'];
  }
}

class GokuInfo {
  String? id;
  String? title;
  String? url;
  String? type;
  String? releaseDate;
  String? message;
  List<GokuInfoEntries>? episodes;

  GokuInfo.fromJson(Map<String, dynamic> json) {
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
        episodes!.add(GokuInfoEntries.fromJson(v));
      });
    }
  }
}

class GokuInfoEntries {
  String? id;
  String? title;
  String? url;
  int? season;
  int? episode;

  GokuInfoEntries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    season = json['season'];
    episode = json['number'];
  }
}

class GokuStreamSources {
  GokuStreamSources(
      {required this.videoLinks,
      required this.videoSubtitles,
      required this.messageExists});

  List<GokuVideoLinks>? videoLinks;
  List<GokuSubLinks>? videoSubtitles;

  bool? messageExists;

  GokuStreamSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(GokuVideoLinks.fromJson(v));
      });
    }
    if (json.containsKey('subtitles') && json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(GokuSubLinks.fromJson(v));
      });
    }
    if (json.containsKey('message')) {
      messageExists = true;
    }
  }
}

class GokuVideoLinks extends RegularVideoLinks {
  GokuVideoLinks.fromJson(super.json) : super.fromJson();
}

class GokuSubLinks extends RegularSubtitleLinks {
  GokuSubLinks.fromJson(super.json) : super.fromJson();
}
