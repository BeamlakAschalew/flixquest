class RegularVideoLinks {
  String? url;
  String? quality;
  bool? isM3U8;

  RegularVideoLinks.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    if (json.containsKey('quality')) {
      quality = json['quality'];
    } else {
      quality = 'unknown quality';
    }
    isM3U8 = json['isM3U8'];
  }
}

class RegularSubtitleLinks {
  String? url;
  String? language;

  RegularSubtitleLinks.fromJson(Map<String, dynamic> json) {
    url = json['url'] ?? json['file'];
    language = json['lang'] ?? json['label'];
  }
}

/// Dramacool/Viewasian provider

/// Dramacool/Viewasian search
class DCVASearch {
  int? currentPage;
  bool? hasNextPage;
  List<DCVASearchEntry>? results;

  DCVASearch.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(DCVASearchEntry.fromJson(v));
      });
    }
  }
}

class DCVASearchEntry {
  DCVASearchEntry({
    required this.id,
    required this.title,
  });

  String? id;
  String? title;

  DCVASearchEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }
}

class DCVAInfo {
  String? id;
  String? title;
  String? releaseDate;
  String? message;
  List<DCVAInfoEntries>? episodes;

  DCVAInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    releaseDate = json['releaseDate'];
    if (json.containsKey('message')) {
      message = json['message'];
    }
    if (json['episodes'] != null) {
      episodes = [];
      json['episodes'].forEach((v) {
        episodes!.add(DCVAInfoEntries.fromJson(v));
      });
    }
  }
}

class DCVAInfoEntries {
  String? id;
  String? title;
  String? url;
  String? subType;
  String? episode;

  DCVAInfoEntries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    episode = json['episode'].toString();
    subType = json['subType'];
  }
}

class DCVAStreamSources {
  DCVAStreamSources(
      {required this.videoLinks,
      required this.videoSubtitles,
      required this.messageExists});

  List<DCVAVideoLinks>? videoLinks;
  List<DCVASubLinks>? videoSubtitles;

  bool? messageExists;

  DCVAStreamSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(DCVAVideoLinks.fromJson(v));
      });
    }
    if (json.containsKey('subtitles') && json['subtitles'] != null) {
      videoSubtitles = [];
      json['subtitles'].forEach((v) {
        videoSubtitles!.add(DCVASubLinks.fromJson(v));
      });
    }
    if (json.containsKey('message')) {
      messageExists = true;
    }
  }
}

class DCVAVideoLinks extends RegularVideoLinks {
  DCVAVideoLinks.fromJson(super.json) : super.fromJson();
}

class DCVASubLinks extends RegularSubtitleLinks {
  DCVASubLinks.fromJson(super.json) : super.fromJson();
}
