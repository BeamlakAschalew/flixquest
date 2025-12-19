import 'package:flixquest/video_providers/common.dart';

/// AnimeKai Search classes
class AnimeKaiSearch {
  int? currentPage;
  bool? hasNextPage;
  List<AnimeKaiSearchEntry>? results;

  AnimeKaiSearch.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(AnimeKaiSearchEntry.fromJson(v));
      });
    }
  }
}

class AnimeKaiSearchEntry {
  String? id;
  String? title;
  String? image;
  String? type;
  String? url;

  AnimeKaiSearchEntry.fromJson(Map<String, dynamic> json) {
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
  }
}

/// AnimeKai Info class
class AnimeKaiInfo {
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
  bool? hasSub;
  bool? hasDub;
  List<AnimeKaiEpisode>? episodes;

  AnimeKaiInfo.fromJson(Map<String, dynamic> json) {
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
    hasSub = json['hasSub'];
    hasDub = json['hasDub'];
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes!.add(AnimeKaiEpisode.fromJson(v));
      });
    }
  }
}

class AnimeKaiEpisode {
  String? id;
  int? number;
  String? title;
  String? url;
  String? image;
  bool? isFiller;

  AnimeKaiEpisode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    title = json['title'];
    url = json['url'];
    image = json['image'];
    isFiller = json['isFiller'];
  }
}

/// AnimeKai Stream Sources
class AnimeKaiStreamSources {
  List<AnimeKaiVideoLinks>? videoLinks;
  List<AnimeKaiSubLinks>? videoSubtitles;
  bool? messageExists;
  String? download;

  AnimeKaiStreamSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(AnimeKaiVideoLinks.fromJson(v));
      });
    }
    if (json.containsKey('subtitles') && json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(AnimeKaiSubLinks.fromJson(v));
      });
    }
    if (json.containsKey('message')) {
      messageExists = true;
    }
    download = json['download'];
  }
}

class AnimeKaiVideoLinks extends RegularVideoLinks {
  AnimeKaiVideoLinks.fromJson(super.json) : super.fromJson();
}

class AnimeKaiSubLinks extends RegularSubtitleLinks {
  AnimeKaiSubLinks.fromJson(Map<String, dynamic> json)
      : super(url: json['url'], language: json['lang']);
}
