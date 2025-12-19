import 'package:flixquest/video_providers/common.dart';

/// AnimePahe Search classes
class AnimePaheSearch {
  int? currentPage;
  bool? hasNextPage;
  List<AnimePaheSearchEntry>? results;

  AnimePaheSearch.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(AnimePaheSearchEntry.fromJson(v));
      });
    }
  }
}

class AnimePaheSearchEntry {
  String? id;
  String? title;
  String? image;
  String? type;
  String? url;
  int? episodes;
  String? status;

  AnimePaheSearchEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // Handle title as string or object
    if (json['title'] is String) {
      title = json['title'];
    } else if (json['title'] is Map) {
      title = json['title']['userPreferred'] ??
          json['title']['english'] ??
          json['title']['romaji'] ??
          json['title']['native'];
    }
    image = json['image'];
    type = json['type'];
    url = json['url'];
    episodes = json['episodes'];
    status = json['status'];
  }
}

/// AnimePahe Info class
class AnimePaheInfo {
  String? id;
  String? title;
  String? url;
  String? image;
  String? description;
  String? type;
  String? releaseDate;
  String? status;
  int? totalEpisodes;
  List<String>? genres;
  String? subOrDub;
  List<AnimePaheEpisode>? episodes;

  AnimePaheInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // Handle title as string or object
    if (json['title'] is String) {
      title = json['title'];
    } else if (json['title'] is Map) {
      title = json['title']['userPreferred'] ??
          json['title']['english'] ??
          json['title']['romaji'] ??
          json['title']['native'];
    }
    url = json['url'];
    image = json['image'];
    description = json['description'];
    type = json['type'];
    releaseDate = json['releaseDate']?.toString();
    status = json['status'];
    totalEpisodes = json['totalEpisodes'];
    if (json['genres'] != null) {
      genres = List<String>.from(json['genres']);
    }
    subOrDub = json['subOrDub'];
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes!.add(AnimePaheEpisode.fromJson(v));
      });
    }
  }
}

class AnimePaheEpisode {
  String? id;
  int? number;
  String? title;
  String? url;
  String? image;
  int? duration;

  AnimePaheEpisode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    title = json['title'];
    url = json['url'];
    image = json['image'];
    duration = json['duration'];
  }
}

/// AnimePahe Stream Sources
class AnimePaheStreamSources {
  List<AnimePaheVideoLinks>? videoLinks;
  List<AnimePaheSubLinks>? videoSubtitles;
  bool? messageExists;
  String? download;

  AnimePaheStreamSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(AnimePaheVideoLinks.fromJson(v));
      });
    }
    if (json.containsKey('subtitles') && json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(AnimePaheSubLinks.fromJson(v));
      });
    }
    if (json.containsKey('message')) {
      messageExists = true;
    }
    download = json['download'];
  }
}

class AnimePaheVideoLinks extends RegularVideoLinks {
  AnimePaheVideoLinks.fromJson(super.json) : super.fromJson();
}

class AnimePaheSubLinks extends RegularSubtitleLinks {
  AnimePaheSubLinks.fromJson(Map<String, dynamic> json)
      : super(url: json['url'], language: json['lang']);
}
