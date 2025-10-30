import 'common.dart';

class GogoSearch {
  int? currentPage;
  bool? hasNextPage;
  List<GogoSearchEntry>? results;

  GogoSearch.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(GogoSearchEntry.fromJson(v));
      });
    }
  }
}

class GogoSearchEntry {
  GogoSearchEntry(
      {required this.id,
      required this.title,
      required this.releaseDate,
      required this.subOrDub});

  String? id;
  String? title;
  String? releaseDate;
  String? subOrDub;

  GogoSearchEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    releaseDate = json['releaseDate'];
    subOrDub = json['subOrDub'];
  }
}

class GogoInfo {
  String? id;
  String? title;
  String? message;
  List<GogoInfoEntries>? episodes;

  GogoInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    if (json.containsKey('message')) {
      message = json['message'];
    }
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes!.add(GogoInfoEntries.fromJson(v));
      });
    }
  }
}

class GogoInfoEntries {
  String? id;
  String? title;
  String? url;
  String? episode;

  GogoInfoEntries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    episode = json['number'].toString();
  }
}

class GogoStreamSources {
  GogoStreamSources(
      {required this.videoLinks,
      required this.videoSubtitles,
      required this.messageExists});

  List<GogoVideoLinks>? videoLinks;
  List<GogoSubLinks>? videoSubtitles;

  bool? messageExists;

  GogoStreamSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(GogoVideoLinks.fromJson(v));
      });
    }
    if (json.containsKey('subtitles') && json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(GogoSubLinks.fromJson(v));
      });
    }
    if (json.containsKey('message')) {
      messageExists = true;
    }
  }
}

class GogoVideoLinks extends RegularVideoLinks {
  GogoVideoLinks.fromJson(super.json) : super.fromJson();
}

class GogoSubLinks extends RegularSubtitleLinks {
  GogoSubLinks.fromJson(super.json) : super.fromJson();
}
