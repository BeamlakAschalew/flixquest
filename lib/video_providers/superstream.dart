import 'common.dart';

class SuperstreamStreamSources {
  SuperstreamStreamSources(
      {required this.videoLinks,
      required this.videoSubtitles,
      required this.messageExists});

  List<SuperstreamVideoLinks>? videoLinks;
  List<SuperstreamSubLinks>? videoSubtitles;

  bool? messageExists;

  SuperstreamStreamSources.fromJson(Map<String, dynamic> json) {
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
