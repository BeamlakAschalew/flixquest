import 'package:flixquest/video_providers/common.dart';

/// HiAnime Search classes
class HiAnimeSearch {
  int? currentPage;
  bool? hasNextPage;
  List<HiAnimeSearchEntry>? results;

  HiAnimeSearch.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(HiAnimeSearchEntry.fromJson(v));
      });
    }
  }
}

class HiAnimeSearchEntry {
  String? id;
  String? title;
  String? image;
  String? type;
  String? url;

  HiAnimeSearchEntry.fromJson(Map<String, dynamic> json) {
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

/// HiAnime Info class
class HiAnimeInfo {
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
  List<HiAnimeEpisode>? episodes;

  HiAnimeInfo.fromJson(Map<String, dynamic> json) {
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
        episodes!.add(HiAnimeEpisode.fromJson(v));
      });
    }
  }
}

class HiAnimeEpisode {
  String? id;
  int? number;
  String? title;
  String? url;
  String? image;
  bool? isFiller;

  HiAnimeEpisode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    title = json['title'];
    url = json['url'];
    image = json['image'];
    isFiller = json['isFiller'];
  }
}

/// HiAnime Stream Sources
class HiAnimeStreamSources {
  List<HiAnimeVideoLinks>? videoLinks;
  List<HiAnimeSubLinks>? videoSubtitles;
  bool? messageExists;
  String? download;

  HiAnimeStreamSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(HiAnimeVideoLinks.fromJson(v));
      });
    }
    if (json.containsKey('subtitles') && json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(HiAnimeSubLinks.fromJson(v));
      });
    }
    if (json.containsKey('message')) {
      messageExists = true;
    }
    download = json['download'];
  }
}

class HiAnimeVideoLinks extends RegularVideoLinks {
  HiAnimeVideoLinks.fromJson(super.json) : super.fromJson();
}

class HiAnimeSubLinks extends RegularSubtitleLinks {
  HiAnimeSubLinks.fromJson(Map<String, dynamic> json)
      : super(url: json['url'], language: json['lang']);
}
