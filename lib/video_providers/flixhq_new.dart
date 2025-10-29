import 'package:flixquest/video_providers/common.dart';
import 'package:flixquest/video_providers/flixhq.dart';

class FlixHQNewStreamSources {
  FlixHQNewStreamSources(
      {required this.videoLinks,
      required this.videoSubtitles,
      required this.messageExists});

  List<FlixHQVideoLinks>? videoLinks;
  List<FlixHQSubLinks>? videoSubtitles;

  bool? messageExists;

  FlixHQNewStreamSources.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('sources') && json['sources'] != null) {
      videoLinks = [];
      json['sources'].forEach((v) {
        videoLinks!.add(FlixHQVideoLinks.fromJson(v));
      });
    }
    if (json['sources'][0].containsKey('subtitles') &&
        json['sources'][0]['subtitles'] != null) {
      videoSubtitles = [];
      json['sources'][0]['subtitles'].forEach((v) {
        videoSubtitles!.add(FlixHQSubLinks.fromJson(v));
      });
    }
    if (json.containsKey('error')) {
      messageExists = true;
    }
  }
}

class FlixHQNewVideoLinks extends RegularVideoLinks {
  FlixHQNewVideoLinks.fromJson(super.json) : super.fromJson();
}

class FlixHQNewSubLinks extends RegularSubtitleLinks {
  FlixHQNewSubLinks.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}
