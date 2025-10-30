import 'common.dart';

/// ViewAsian Movie classes
class ViewasianMovieSearch {
  int? currentPage;
  bool? hasNextPage;
  List<ViewasianMovieSearchEntry>? results;

  ViewasianMovieSearch.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(ViewasianMovieSearchEntry.fromJson(v));
      });
    }
  }
}

class ViewasianMovieSearchEntry {
  ViewasianMovieSearchEntry({
    required this.id,
    required this.title,
  });

  String? id;
  String? title;

  ViewasianMovieSearchEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }
}

class ViewasianMovieInfo {
  String? id;
  String? title;
  String? releaseDate;
  String? message;
  List<ViewasianMovieInfoEntries>? episodes;

  ViewasianMovieInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    releaseDate = json['releaseDate'];
    if (json.containsKey('message')) {
      message = json['message'];
    }
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes!.add(ViewasianMovieInfoEntries.fromJson(v));
      });
    }
  }
}

class ViewasianMovieInfoEntries {
  String? id;
  String? title;
  String? url;
  String? subType;
  int? episode;

  ViewasianMovieInfoEntries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    episode = json['episode'];
    subType = json['subType'];
  }
}

class ViewasianStreamSources {
  ViewasianStreamSources(
      {required this.videoLinks,
      required this.videoSubtitles,
      required this.messageExists});

  List<ViewasianVideoLinks>? videoLinks;
  List<ViewasianSubLinks>? videoSubtitles;

  bool? messageExists;

  ViewasianStreamSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(ViewasianVideoLinks.fromJson(v));
      });
    }
    if (json.containsKey('subtitles') && json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(ViewasianSubLinks.fromJson(v));
      });
    }
    if (json.containsKey('message')) {
      messageExists = true;
    }
  }
}

class ViewasianVideoLinks extends RegularVideoLinks {
  ViewasianVideoLinks.fromJson(super.json) : super.fromJson();
}

class ViewasianSubLinks extends RegularSubtitleLinks {
  ViewasianSubLinks.fromJson(super.json) : super.fromJson();
}
