import 'common.dart';

/// Dramacool provider

/// Dramacool search
class DramacoolSearch {
  int? currentPage;
  bool? hasNextPage;
  List<DramacoolMovieSearchEntry>? results;

  DramacoolSearch.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(DramacoolMovieSearchEntry.fromJson(v));
      });
    }
  }
}

class DramacoolMovieSearchEntry {
  DramacoolMovieSearchEntry({
    required this.id,
    required this.title,
  });

  String? id;
  String? title;

  DramacoolMovieSearchEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }
}

class DramacoolMovieInfo {
  String? id;
  String? title;
  String? releaseDate;
  String? message;
  List<DramacoolMovieInfoEntries>? episodes;

  DramacoolMovieInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    releaseDate = json['releaseDate'];
    if (json.containsKey('message')) {
      message = json['message'];
    }
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes!.add(DramacoolMovieInfoEntries.fromJson(v));
      });
    }
  }
}

class DramacoolMovieInfoEntries {
  String? id;
  String? title;
  String? url;
  String? subType;
  int? episode;

  DramacoolMovieInfoEntries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    episode = json['episode'];
    subType = json['subType'];
  }
}

class DramacoolStreamSources {
  DramacoolStreamSources(
      {required this.videoLinks,
      required this.videoSubtitles,
      required this.messageExists});

  List<SuperstreamVideoLinks>? videoLinks;
  List<SuperstreamSubLinks>? videoSubtitles;

  bool? messageExists;

  DramacoolStreamSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(SuperstreamVideoLinks.fromJson(v));
      });
    }
    if (json.containsKey('subtitles') && json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(SuperstreamSubLinks.fromJson(v));
      });
    }
    if (json.containsKey('message')) {
      messageExists = true;
    }
  }
}

class SuperstreamVideoLinks extends RegularVideoLinks {
  SuperstreamVideoLinks.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}

class SuperstreamSubLinks extends RegularSubtitleLinks {
  SuperstreamSubLinks.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}
