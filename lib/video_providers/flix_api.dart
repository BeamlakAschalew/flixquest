class FlixAPIResponse {
  late bool success;
  FlixAPIMedia? media;
  FlixAPIStream? stream;

  FlixAPIResponse({this.success = false, this.media, this.stream});

  FlixAPIResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    media = json['media'] != null ? FlixAPIMedia.fromJson(json['media']) : null;
    stream =
        json['stream'] != null ? FlixAPIStream.fromJson(json['stream']) : null;
  }
}

class FlixAPIMedia {
  String? type;
  String? title;
  int? releaseYear;
  String? tmdbId;

  FlixAPIMedia({this.type, this.title, this.releaseYear, this.tmdbId});

  FlixAPIMedia.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    title = json['title'];
    releaseYear = json['releaseYear'];
    tmdbId = json['tmdbId'];
  }
}

class FlixAPIStream {
  String? sourceId;
  String? type;
  String? id;
  String? playlist;
  List<String>? flags;
  List<FlixAPICaption>? captions;
  Map<String, String>? headers;

  FlixAPIStream({
    this.sourceId,
    this.type,
    this.id,
    this.playlist,
    this.flags,
    this.captions,
    this.headers,
  });

  FlixAPIStream.fromJson(Map<String, dynamic> json) {
    sourceId = json['sourceId'];
    type = json['type'];
    id = json['id'];
    playlist = json['playlist'];

    if (json['flags'] != null) {
      flags = List<String>.from(json['flags']);
    }

    if (json['captions'] != null) {
      captions = [];
      json['captions'].forEach((v) {
        captions!.add(FlixAPICaption.fromJson(v));
      });
    }

    if (json['headers'] != null) {
      headers = Map<String, String>.from(json['headers']);
    }
  }
}

class FlixAPICaption {
  String? url;
  String? language;

  FlixAPICaption({this.url, this.language});

  FlixAPICaption.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    language = json['language'] ?? json['lang'];
  }
}
