import 'common.dart';

class ZoroSearch {
  int? currentPage;
  bool? hasNextPage;
  List<ZoroSearchEntry>? results;

  ZoroSearch.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(ZoroSearchEntry.fromJson(v));
      });
    }
  }
}

class ZoroSearchEntry {
  ZoroSearchEntry({
    required this.id,
    required this.title,
  });

  String? id;
  String? title;
  String? type;

  ZoroSearchEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
  }
}

class ZoroInfo {
  String? id;
  String? title;
  String? message;
  List<ZoroInfoEntries>? episodes;

  ZoroInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    if (json.containsKey('message')) {
      message = json['message'];
    }
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes!.add(ZoroInfoEntries.fromJson(v));
      });
    }
  }
}

class ZoroInfoEntries {
  String? id;
  String? title;
  String? url;
  String? episode;

  ZoroInfoEntries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    episode = json['number'].toString();
  }
}

class ZoroStreamSources {
  ZoroStreamSources(
      {required this.videoLinks,
      required this.videoSubtitles,
      required this.messageExists});

  List<ZoroVideoLinks>? videoLinks;
  List<ZoroSubLinks>? videoSubtitles;

  bool? messageExists;

  ZoroStreamSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(ZoroVideoLinks.fromJson(v));
      });
    }
    if (json.containsKey('subtitles') && json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(ZoroSubLinks.fromJson(v));
      });
    }
    if (json.containsKey('message')) {
      messageExists = true;
    }
  }
}

class ZoroVideoLinks extends RegularVideoLinks {
  ZoroVideoLinks.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

class ZoroSubLinks extends RegularSubtitleLinks {
  ZoroSubLinks.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}
